#!/usr/bin/env python3
"""Lightweight local vector knowledge helpers for agri-context-bridge."""

from __future__ import annotations

import json
import logging
import os
import re
import shutil
import threading
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Iterable, Optional


def now_iso() -> str:
    return datetime.now().astimezone().isoformat(timespec="seconds")


def sha256_text(value: str) -> str:
    import hashlib

    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def json_dumps(payload: Any) -> str:
    return json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def normalize_text(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def chunk_text(text: str, chunk_size: int, chunk_overlap: int) -> list[str]:
    normalized = normalize_text(text)
    if not normalized:
        return []
    if len(normalized) <= chunk_size:
        return [normalized]
    size = max(chunk_size, 1)
    overlap = max(0, min(chunk_overlap, size - 1))
    step = max(size - overlap, 1)
    chunks: list[str] = []
    for start in range(0, len(normalized), step):
        item = normalized[start : start + size].strip()
        if not item:
            continue
        chunks.append(item)
        if start + size >= len(normalized):
            break
    return chunks


def safe_relative_path(path: Path, root: Path) -> str:
    try:
        return str(path.resolve().relative_to(root.resolve())).replace("\\", "/")
    except ValueError:
        return str(path)


def detect_crop_id(*parts: Any) -> str:
    joined = " ".join(str(item or "") for item in parts)
    has_huoshan = any(token in joined for token in ("霍山石斛", "米斛", "龙头凤尾草", "Dendrobium huoshanense"))
    has_tiepi = any(token in joined for token in ("铁皮石斛", "Dendrobium officinale"))
    if has_huoshan and has_tiepi:
        return "shared"
    if has_huoshan:
        return "huoshan-shihu"
    if has_tiepi:
        return "shihu"
    return "shared"


class MissingVectorDependency(RuntimeError):
    """Raised when optional vector dependencies are not installed."""


@dataclass
class VectorKnowledgeConfig:
    enabled: bool = True
    backend: str = "chroma"
    persist_dir: str = "/home/linaro/project/EdgeLink_RK3568/data/agri-vectordb"
    embedding_model: str = "moka-ai/m3e-small"
    collection_name: str = "agri_knowledge"
    top_k: int = 5
    chunk_size: int = 400
    chunk_overlap: int = 80
    min_text_length: int = 80


@dataclass
class VectorDocument:
    text: str
    metadata: Dict[str, Any]


class LocalEmbeddingModel:
    def __init__(self, model_name: str) -> None:
        self.model_name = model_name
        self._model: Any = None
        self._lock = threading.Lock()
        self._active_name = model_name

    def _load(self) -> Any:
        with self._lock:
            if self._model is not None:
                return self._model
            model_path = Path(self.model_name)
            if self.model_name and not model_path.exists():
                logging.warning(
                    "embedding model %s is not available as a local path, fallback to local hashing embeddings",
                    self.model_name,
                )
            else:
                try:
                    from sentence_transformers import SentenceTransformer
                    os.environ.setdefault("HF_HUB_OFFLINE", "1")
                    os.environ.setdefault("TRANSFORMERS_OFFLINE", "1")
                    self._model = SentenceTransformer(self.model_name)
                    self._active_name = self.model_name
                    return self._model
                except ImportError as exc:  # pragma: no cover - runtime-only dependency
                    raise MissingVectorDependency(
                        "sentence-transformers is required for local vector embeddings"
                    ) from exc
                except Exception as exc:
                    logging.warning(
                        "failed to load sentence-transformers model %s, fallback to local hashing embeddings: %s",
                        self.model_name,
                        exc,
                    )
            try:
                from sklearn.feature_extraction.text import HashingVectorizer
            except ImportError as exc:  # pragma: no cover - runtime-only dependency
                raise MissingVectorDependency(
                    "scikit-learn is required for hashing vector fallback"
                ) from exc
            self._model = HashingVectorizer(
                analyzer="char",
                ngram_range=(2, 4),
                n_features=1024,
                alternate_sign=False,
                norm="l2",
            )
            self._active_name = "hashing-char-ngrams"
            return self._model

    def encode(self, texts: Iterable[str]) -> list[list[float]]:
        model = self._load()
        values = list(texts)
        if hasattr(model, "encode"):
            embeddings = model.encode(
                values,
                normalize_embeddings=True,
                show_progress_bar=False,
            )
            if hasattr(embeddings, "tolist"):
                return embeddings.tolist()
            return [list(map(float, item)) for item in embeddings]
        matrix = model.transform(values)
        return matrix.toarray().tolist()

    def describe(self) -> str:
        self._load()
        return self._active_name


class VectorKnowledgeStore:
    def __init__(self, config: VectorKnowledgeConfig) -> None:
        self.config = config
        self.persist_dir = Path(config.persist_dir)
        self.manifest_path = self.persist_dir / "manifest.json"
        self.simple_index_path = self.persist_dir / "chunks.json"
        self._lock = threading.RLock()
        self._client: Any = None
        self._collection: Any = None
        self._simple_records: Optional[list[Dict[str, Any]]] = None
        self._embedder = LocalEmbeddingModel(config.embedding_model)

    def load_manifest(self) -> Dict[str, Any]:
        if not self.manifest_path.exists():
            return {}
        try:
            return json.loads(self.manifest_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            logging.warning("failed to load vector knowledge manifest: %s", self.manifest_path)
            return {}

    def status(self) -> Dict[str, Any]:
        manifest = self.load_manifest()
        actual_backend = manifest.get("backend") or self.config.backend
        return {
            "enabled": self.config.enabled,
            "backend": actual_backend,
            "persistDir": str(self.persist_dir),
            "manifestPath": str(self.manifest_path),
            "modelName": manifest.get("modelName") or self.config.embedding_model,
            "chunkCount": int(manifest.get("chunkCount") or 0),
            "sourceCount": int(manifest.get("sourceCount") or 0),
            "builtAt": manifest.get("builtAt"),
            "ready": bool(manifest.get("chunkCount")),
        }

    def _import_chroma(self) -> Any:
        try:
            import chromadb
        except ImportError as exc:  # pragma: no cover - runtime-only dependency
            raise MissingVectorDependency("chromadb is required for vector knowledge search") from exc
        return chromadb

    def _get_client(self) -> Any:
        with self._lock:
            if self._client is not None:
                return self._client
            chromadb = self._import_chroma()
            self.persist_dir.mkdir(parents=True, exist_ok=True)
            self._client = chromadb.PersistentClient(path=str(self.persist_dir))
            return self._client

    def _get_collection(self) -> Optional[Any]:
        with self._lock:
            if self._collection is not None:
                return self._collection
            client = self._get_client()
            try:
                self._collection = client.get_collection(self.config.collection_name)
            except Exception:
                return None
            return self._collection

    def _reset_collection(self) -> Any:
        client = self._get_client()
        try:
            client.delete_collection(self.config.collection_name)
        except Exception:
            pass
        with self._lock:
            self._collection = client.create_collection(
                name=self.config.collection_name,
                metadata={"embedding_model": self.config.embedding_model},
            )
            return self._collection

    def _load_simple_records(self) -> list[Dict[str, Any]]:
        with self._lock:
            if self._simple_records is not None:
                return self._simple_records
            if not self.simple_index_path.exists():
                self._simple_records = []
                return self._simple_records
            payload = json.loads(self.simple_index_path.read_text(encoding="utf-8"))
            if not isinstance(payload, list):
                self._simple_records = []
                return self._simple_records
            self._simple_records = [item for item in payload if isinstance(item, dict)]
            return self._simple_records

    def _rebuild_simple(self, chunk_records: list[Dict[str, Any]]) -> None:
        if chunk_records:
            embeddings = self._embedder.encode([item["text"] for item in chunk_records])
        else:
            embeddings = []
        records: list[Dict[str, Any]] = []
        for item, embedding in zip(chunk_records, embeddings):
            records.append(
                {
                    "text": item["text"],
                    "metadata": item["metadata"],
                    "embedding": embedding,
                }
            )
        self.simple_index_path.write_text(json.dumps(records, ensure_ascii=False), encoding="utf-8")
        with self._lock:
            self._simple_records = records

    def _normalize_chroma_matches(
        self,
        raw: Dict[str, Any],
        query: str,
        crop_id: str,
        top_k: Optional[int],
    ) -> list[Dict[str, Any]]:
        matches: list[Dict[str, Any]] = []
        ids = (raw.get("ids") or [[]])[0]
        docs = (raw.get("documents") or [[]])[0]
        metas = (raw.get("metadatas") or [[]])[0]
        dists = (raw.get("distances") or [[]])[0]
        for chunk_id, document, metadata, distance in zip(ids, docs, metas, dists):
            if not isinstance(metadata, dict) or not document:
                continue
            score = rerank_score(
                query=query,
                crop_id=crop_id,
                metadata=metadata,
                document=document,
                distance=distance,
            )
            matches.append(
                {
                    "chunkId": str(metadata.get("chunkId") or chunk_id),
                    "cropId": str(metadata.get("cropId") or "shared"),
                    "sourceId": str(metadata.get("sourceId") or "unknown"),
                    "sourceTitle": str(metadata.get("sourceTitle") or "未知来源"),
                    "docType": str(metadata.get("docType") or "unknown"),
                    "filePath": str(metadata.get("filePath") or ""),
                    "extractionQuality": str(metadata.get("extractionQuality") or ""),
                    "score": round(score, 4),
                    "text": str(document),
                }
            )
        matches.sort(key=lambda item: item["score"], reverse=True)
        deduped: list[Dict[str, Any]] = []
        seen: set[str] = set()
        for item in matches:
            if item["chunkId"] in seen:
                continue
            deduped.append(item)
            seen.add(item["chunkId"])
            if len(deduped) >= (top_k or self.config.top_k):
                break
        return deduped

    def _search_simple(self, query: str, crop_id: str, top_k: Optional[int]) -> list[Dict[str, Any]]:
        records = self._load_simple_records()
        if not records:
            return []
        query_embedding = self._embedder.encode([build_query_text(query, crop_id)])[0]
        matches: list[Dict[str, Any]] = []
        for item in records:
            metadata = item.get("metadata")
            document = item.get("text")
            embedding = item.get("embedding")
            if not isinstance(metadata, dict) or not isinstance(document, str) or not isinstance(embedding, list):
                continue
            similarity = cosine_similarity(query_embedding, embedding)
            score = rerank_score(
                query=query,
                crop_id=crop_id,
                metadata=metadata,
                document=document,
                distance=1.0 - similarity,
            )
            matches.append(
                {
                    "chunkId": str(metadata.get("chunkId") or ""),
                    "cropId": str(metadata.get("cropId") or "shared"),
                    "sourceId": str(metadata.get("sourceId") or "unknown"),
                    "sourceTitle": str(metadata.get("sourceTitle") or "未知来源"),
                    "docType": str(metadata.get("docType") or "unknown"),
                    "filePath": str(metadata.get("filePath") or ""),
                    "extractionQuality": str(metadata.get("extractionQuality") or ""),
                    "score": round(score, 4),
                    "text": document,
                }
            )
        matches.sort(key=lambda item: item["score"], reverse=True)
        return matches[: max(top_k or self.config.top_k, 1)]

    def rebuild(self, knowledge_path: str) -> Dict[str, Any]:
        knowledge_file = Path(knowledge_path)
        repo_root = knowledge_file.parents[3]
        payload = json.loads(knowledge_file.read_text(encoding="utf-8"))
        source_index = {
            str(item.get("id")): item
            for item in payload.get("sources", [])
            if isinstance(item, dict) and item.get("id")
        }
        docs = collect_vector_documents(
            knowledge_file=knowledge_file,
            knowledge_payload=payload,
            source_index=source_index,
            repo_root=repo_root,
            min_text_length=self.config.min_text_length,
        )
        chunk_records = build_chunk_records(
            docs=docs,
            chunk_size=self.config.chunk_size,
            chunk_overlap=self.config.chunk_overlap,
        )
        if self.persist_dir.exists():
            shutil.rmtree(self.persist_dir)
        with self._lock:
            self._client = None
            self._collection = None
            self._simple_records = None
        self.persist_dir.mkdir(parents=True, exist_ok=True)
        actual_backend = self.config.backend
        if self.config.backend == "chroma":
            try:
                collection = self._reset_collection()
                if chunk_records:
                    embeddings = self._embedder.encode([item["text"] for item in chunk_records])
                    batch_size = 32
                    for start in range(0, len(chunk_records), batch_size):
                        batch = chunk_records[start : start + batch_size]
                        batch_embeddings = embeddings[start : start + batch_size]
                        collection.add(
                            ids=[item["metadata"]["chunkId"] for item in batch],
                            documents=[item["text"] for item in batch],
                            metadatas=[item["metadata"] for item in batch],
                            embeddings=batch_embeddings,
                        )
                self.simple_index_path.write_text("[]", encoding="utf-8")
            except Exception as exc:
                logging.warning("chroma backend unavailable, fallback to simple store: %s", exc)
                actual_backend = "simple"
                self._rebuild_simple(chunk_records)
        else:
            actual_backend = "simple"
            self._rebuild_simple(chunk_records)
        manifest = {
            "backend": actual_backend,
            "requestedBackend": self.config.backend,
            "modelName": self._embedder.describe(),
            "requestedModelName": self.config.embedding_model,
            "collectionName": self.config.collection_name,
            "builtAt": now_iso(),
            "chunkCount": len(chunk_records),
            "sourceCount": len({item["metadata"]["sourceId"] for item in chunk_records}),
            "knowledgePath": str(knowledge_file),
            "persistDir": str(self.persist_dir),
            "chunkSize": self.config.chunk_size,
            "chunkOverlap": self.config.chunk_overlap,
            "minTextLength": self.config.min_text_length,
        }
        self.manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
        return manifest

    def search(self, query: str, crop_id: str, top_k: Optional[int] = None) -> list[Dict[str, Any]]:
        if not self.config.enabled:
            return []
        text = normalize_text(query)
        if not text:
            return []
        manifest = self.load_manifest()
        backend = str(manifest.get("backend") or self.config.backend)
        if backend == "chroma":
            try:
                collection = self._get_collection()
                if collection is None:
                    return []
                query_embedding = self._embedder.encode([build_query_text(text, crop_id)])[0]
                desired = max(top_k or self.config.top_k, 1)
                fetch_count = max(desired * 4, desired)
                raw = collection.query(
                    query_embeddings=[query_embedding],
                    n_results=fetch_count,
                    include=["documents", "metadatas", "distances"],
                )
                return self._normalize_chroma_matches(raw, text, crop_id, top_k)
            except MissingVectorDependency:
                raise
            except Exception as exc:  # pragma: no cover - runtime safety
                logging.warning("vector knowledge search failed, fallback to simple store: %s", exc)
        return self._search_simple(text, crop_id, top_k)


def build_query_text(query: str, crop_id: str) -> str:
    crop_name = {
        "huoshan-shihu": "霍山石斛",
        "shihu": "铁皮石斛",
        "shared": "石斛",
    }.get(crop_id, crop_id)
    return f"作物：{crop_name}。问题：{query}"


def cosine_similarity(left: list[float], right: list[float]) -> float:
    if not left or not right:
        return 0.0
    size = min(len(left), len(right))
    if size <= 0:
        return 0.0
    return float(sum(float(left[i]) * float(right[i]) for i in range(size)))


def rerank_score(query: str, crop_id: str, metadata: Dict[str, Any], document: str, distance: Any) -> float:
    try:
        base = 1.0 - float(distance)
    except (TypeError, ValueError):
        base = 0.0
    target_crop = str(metadata.get("cropId") or "shared")
    score = base
    if target_crop == crop_id:
        score += 0.15
    elif target_crop == "shared":
        score += 0.08
    if crop_id == "huoshan-shihu" and "霍山石斛" in document:
        score += 0.08
    if crop_id == "shihu" and "铁皮石斛" in document:
        score += 0.08
    if any(token in document for token in re.findall(r"[\u4e00-\u9fffA-Za-z0-9]{2,}", query)[:6]):
        score += 0.03
    return score


def collect_vector_documents(
    knowledge_file: Path,
    knowledge_payload: Dict[str, Any],
    source_index: Dict[str, Dict[str, Any]],
    repo_root: Path,
    min_text_length: int,
) -> list[VectorDocument]:
    docs: list[VectorDocument] = []
    knowledge_root = knowledge_file.parent.parent
    curated_dir = knowledge_file.parent

    for crop_id, crop in knowledge_payload.get("crops", {}).items():
        if not isinstance(crop, dict):
            continue
        crop_name = str(crop.get("name") or crop_id)
        aliases = [str(item) for item in crop.get("aliases", []) if item]
        operational = crop.get("operationalTargets") if isinstance(crop.get("operationalTargets"), dict) else {}
        profile_parts = [f"{crop_name}。"]
        if aliases:
            profile_parts.append(f"别名：{'、'.join(aliases)}。")
        temperature = operational.get("temperatureC") if isinstance(operational.get("temperatureC"), dict) else {}
        humidity = operational.get("humidityPercent") if isinstance(operational.get("humidityPercent"), dict) else {}
        light = operational.get("light") if isinstance(operational.get("light"), dict) else {}
        if temperature.get("min") is not None and temperature.get("max") is not None:
            profile_parts.append(
                f"项目运行基线温度建议为 {temperature.get('min')}~{temperature.get('max')}℃。"
            )
        if humidity.get("min") is not None and humidity.get("max") is not None:
            profile_parts.append(
                f"项目运行基线湿度建议为 {humidity.get('min')}%~{humidity.get('max')}%。"
            )
        if light.get("description"):
            profile_parts.append(f"光照建议：{light.get('description')}")
        query_guidance = crop.get("queryGuidance") if isinstance(crop.get("queryGuidance"), dict) else {}
        notes = query_guidance.get("notes") if isinstance(query_guidance.get("notes"), list) else []
        if notes:
            profile_parts.append(" ".join(str(item) for item in notes if item))
        profile_text = normalize_text(" ".join(profile_parts))
        if len(profile_text) >= min_text_length:
            docs.append(
                VectorDocument(
                    text=profile_text,
                    metadata={
                        "cropId": crop_id,
                        "sourceId": f"structured_profile::{crop_id}",
                        "sourceTitle": f"{crop_name}结构化配置",
                        "docType": "structured_profile",
                        "filePath": safe_relative_path(knowledge_file, repo_root),
                        "extractionQuality": "structured",
                    },
                )
            )
        knowledge_highlights = crop.get("knowledgeHighlights")
        if isinstance(knowledge_highlights, list):
            for index, item in enumerate(knowledge_highlights, start=1):
                if not isinstance(item, dict):
                    continue
                source_id = str(item.get("source") or f"structured_highlight::{crop_id}::{index}")
                source = source_index.get(source_id, {})
                detail = normalize_text(
                    " ".join(
                        part
                        for part in (
                            crop_name,
                            item.get("category"),
                            item.get("title"),
                            item.get("detail"),
                        )
                        if part
                    )
                )
                if len(detail) < min_text_length:
                    continue
                docs.append(
                    VectorDocument(
                        text=detail,
                        metadata={
                            "cropId": crop_id,
                            "sourceId": source_id,
                            "sourceTitle": str(source.get("title") or item.get("title") or crop_name),
                            "docType": "structured_highlight",
                            "filePath": safe_relative_path(knowledge_file, repo_root),
                            "extractionQuality": str(source.get("extractionQuality") or "structured"),
                        },
                    )
                )

    for source_id, source in source_index.items():
        extracted_rel = source.get("extractedText")
        extraction_quality = str(source.get("extractionQuality") or "")
        if extraction_quality == "unusable" or not extracted_rel:
            continue
        file_path = knowledge_root / str(extracted_rel)
        if not file_path.exists():
            continue
        text = normalize_text(file_path.read_text(encoding="utf-8", errors="ignore"))
        if len(text) < min_text_length:
            continue
        source_title = str(source.get("title") or source_id)
        docs.append(
            VectorDocument(
                text=text,
                metadata={
                    "cropId": detect_crop_id(source_title, text),
                    "sourceId": source_id,
                    "sourceTitle": source_title,
                    "docType": "extracted_text",
                    "filePath": safe_relative_path(file_path, repo_root),
                    "extractionQuality": extraction_quality or "good",
                },
            )
        )

    for markdown_path in sorted(curated_dir.glob("*.md")):
        text = normalize_text(markdown_path.read_text(encoding="utf-8", errors="ignore"))
        if len(text) < min_text_length:
            continue
        docs.append(
            VectorDocument(
                text=text,
                metadata={
                    "cropId": detect_crop_id(markdown_path.stem, text),
                    "sourceId": f"curated_markdown::{markdown_path.stem}",
                    "sourceTitle": markdown_path.stem,
                    "docType": "curated_markdown",
                    "filePath": safe_relative_path(markdown_path, repo_root),
                    "extractionQuality": "curated",
                },
            )
        )
    return docs


def build_chunk_records(
    docs: Iterable[VectorDocument],
    chunk_size: int,
    chunk_overlap: int,
) -> list[Dict[str, Any]]:
    records: list[Dict[str, Any]] = []
    seen: set[str] = set()
    for doc in docs:
        pieces = chunk_text(doc.text, chunk_size=chunk_size, chunk_overlap=chunk_overlap)
        for index, chunk in enumerate(pieces, start=1):
            dedupe = sha256_text(f"{doc.metadata['sourceId']}::{chunk}")
            if dedupe in seen:
                continue
            seen.add(dedupe)
            metadata = dict(doc.metadata)
            metadata["chunkId"] = f"{metadata['sourceId']}::{index:04d}::{dedupe[:12]}"
            records.append({"text": chunk, "metadata": metadata})
    return records

#!/usr/bin/env python3
"""Build the local vector knowledge index for agri-context-bridge."""

from __future__ import annotations

import argparse
import configparser
import json
import sys
from pathlib import Path


ROOT_DIR = Path(__file__).resolve().parents[1]
SRC_DIR = ROOT_DIR / "src"
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))

from agri_vector_knowledge import VectorKnowledgeConfig, VectorKnowledgeStore  # noqa: E402


def load_vector_config(config_path: Path) -> tuple[str, VectorKnowledgeConfig]:
    parser = configparser.ConfigParser()
    if not parser.read(config_path, encoding="utf-8"):
        raise FileNotFoundError(str(config_path))
    knowledge_path = parser.get(
        "storage",
        "knowledge_path",
        fallback="/home/linaro/project/EdgeLink_RK3568/config/agri-knowledge/curated/铁皮石斛知识库.json",
    )
    vector = VectorKnowledgeConfig(
        enabled=parser.getboolean("vector_knowledge", "enabled", fallback=True),
        backend=parser.get("vector_knowledge", "backend", fallback="chroma"),
        persist_dir=parser.get(
            "vector_knowledge",
            "persist_dir",
            fallback="/home/linaro/project/EdgeLink_RK3568/data/agri-vectordb",
        ),
        embedding_model=parser.get(
            "vector_knowledge",
            "embedding_model",
            fallback="moka-ai/m3e-small",
        ),
        collection_name=parser.get(
            "vector_knowledge",
            "collection_name",
            fallback="agri_knowledge",
        ),
        top_k=parser.getint("vector_knowledge", "top_k", fallback=5),
        chunk_size=parser.getint("vector_knowledge", "chunk_size", fallback=400),
        chunk_overlap=parser.getint("vector_knowledge", "chunk_overlap", fallback=80),
        min_text_length=parser.getint("vector_knowledge", "min_text_length", fallback=80),
    )
    return knowledge_path, vector


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Build agri vector knowledge index")
    parser.add_argument(
        "--config",
        default=str(ROOT_DIR / "config" / "agri-context-bridge.ini"),
        help="INI config path",
    )
    parser.add_argument("--knowledge-path", default="", help="Override structured knowledge JSON path")
    parser.add_argument("--persist-dir", default="", help="Override vector DB persist dir")
    parser.add_argument("--embedding-model", default="", help="Override local embedding model")
    parser.add_argument("--chunk-size", type=int, default=0, help="Override chunk size")
    parser.add_argument("--chunk-overlap", type=int, default=-1, help="Override chunk overlap")
    parser.add_argument("--min-text-length", type=int, default=0, help="Override minimum text length")
    return parser


def main() -> int:
    args = build_arg_parser().parse_args()
    config_path = Path(args.config).resolve()
    knowledge_path, vector_config = load_vector_config(config_path)
    if args.knowledge_path:
        knowledge_path = args.knowledge_path
    if args.persist_dir:
        vector_config.persist_dir = args.persist_dir
    if args.embedding_model:
        vector_config.embedding_model = args.embedding_model
    if args.chunk_size > 0:
        vector_config.chunk_size = args.chunk_size
    if args.chunk_overlap >= 0:
        vector_config.chunk_overlap = args.chunk_overlap
    if args.min_text_length > 0:
        vector_config.min_text_length = args.min_text_length

    store = VectorKnowledgeStore(vector_config)
    manifest = store.rebuild(knowledge_path)
    print(json.dumps(manifest, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

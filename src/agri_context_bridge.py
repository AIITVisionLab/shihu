#!/usr/bin/env python3
"""Agriculture context bridge for OpenClaw on RK3568.

This service is intentionally independent from edgelink_gateway.py. It:
- accepts normalized vision + sensor events,
- stores evidence in SQLite,
- builds structured context for OpenClaw,
- returns analysis/chat reports for Java backend and APP teams,
- keeps physical execution disabled in v1.
"""

from __future__ import annotations

import argparse
import configparser
import hashlib
import json
import logging
import os
import queue
import signal
import sqlite3
import subprocess
import sys
import threading
import time
import uuid
from dataclasses import dataclass
from datetime import datetime, timedelta
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any, Dict, Iterable, Optional, Tuple
from urllib.parse import parse_qs, urlparse


MAX_BODY_BYTES = 256 * 1024
EVENT_LIMIT = 50
REPORT_LIMIT = 20
KEEPALIVE_SECONDS = 15


def now_iso() -> str:
    return datetime.now().astimezone().isoformat(timespec="seconds")


def normalize_event_ts(value: Any) -> str:
    now = datetime.now().astimezone()
    tzinfo = now.tzinfo
    if value is None:
        return now.isoformat(timespec="seconds")

    text = str(value).strip()
    if not text:
        return now.isoformat(timespec="seconds")

    parsed: Optional[datetime] = None
    if text.lstrip("-").isdigit():
        raw = int(text)
        magnitude = abs(raw)
        try:
            if magnitude >= 10**12:
                parsed = datetime.fromtimestamp(raw / 1000, tz=tzinfo)
            elif magnitude >= 10**9:
                parsed = datetime.fromtimestamp(raw, tz=tzinfo)
            else:
                return now.isoformat(timespec="seconds")
        except (OverflowError, OSError, ValueError):
            return now.isoformat(timespec="seconds")
    else:
        try:
            parsed = datetime.fromisoformat(text.replace("Z", "+00:00"))
        except ValueError:
            return now.isoformat(timespec="seconds")
        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=tzinfo)
        else:
            parsed = parsed.astimezone(tzinfo)

    if parsed.year < 2024:
        return now.isoformat(timespec="seconds")
    if parsed > now + timedelta(days=1):
        return now.isoformat(timespec="seconds")
    return parsed.isoformat(timespec="seconds")


def lower_text(value: Any) -> str:
    return str(value or "").strip().lower()


def normalize_severity(value: Any, default: str = "info") -> str:
    text = lower_text(value)
    if text in {"info", "warn", "warning", "critical"}:
        return "warn" if text == "warning" else text
    return default


def json_dumps(payload: Any) -> str:
    return json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def coerce_float(value: Any) -> Optional[float]:
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def coerce_int(value: Any) -> Optional[int]:
    try:
        return int(value)
    except (TypeError, ValueError):
        return None


def parse_json_loose(raw: str) -> Optional[Any]:
    text = raw.strip()
    if not text:
        return None
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    start = text.find("{")
    end = text.rfind("}")
    if start != -1 and end > start:
        try:
            return json.loads(text[start : end + 1])
        except json.JSONDecodeError:
            return None
    return None


def walk_for_text(payload: Any) -> Optional[str]:
    if isinstance(payload, str):
        return payload.strip() or None
    if isinstance(payload, dict):
        for key in (
            "text",
            "reply",
            "message",
            "content",
            "output",
            "assistant",
            "result",
            "response",
        ):
            if key in payload:
                text = walk_for_text(payload[key])
                if text:
                    return text
        for value in payload.values():
            text = walk_for_text(value)
            if text:
                return text
    if isinstance(payload, list):
        for item in payload:
            text = walk_for_text(item)
            if text:
                return text
    return None


def sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def make_event_id() -> str:
    return str(uuid.uuid4())


@dataclass
class HttpConfig:
    bind_host: str = "127.0.0.1"
    bind_port: int = 18081


@dataclass
class StorageConfig:
    db_path: str = "/home/linaro/project/EdgeLink_RK3568/data/agri-context-bridge.sqlite"
    profiles_path: str = "/home/linaro/project/EdgeLink_RK3568/config/agri-profiles.json"
    knowledge_path: str = "/home/linaro/project/EdgeLink_RK3568/config/agri-knowledge/curated/铁皮石斛知识库.json"
    retention_hours: int = 168
    prune_interval_seconds: int = 300


@dataclass
class OpenClawConfig:
    enabled: bool = True
    bin_path: str = "/home/linaro/openclaw/bin/openclaw"
    node_bin_dir: str = "/home/linaro/node-v22/bin"
    config_path: str = "/home/linaro/openclaw/config/openclaw.json"
    state_dir: str = "/home/linaro/openclaw/var"
    agent_id: str = "agri-orchestrator"
    timeout_seconds: int = 120


@dataclass
class AnalysisConfig:
    auto_analyze_vision: bool = True
    auto_analyze_sensor: bool = True
    recent_vision_window_minutes: int = 10
    report_cooldown_seconds: int = 60


@dataclass
class DomainConfig:
    default_crop_id: str = "huoshan-shihu"
    default_zone_id: str = "default-greenhouse"


@dataclass
class BridgeConfig:
    http: HttpConfig
    storage: StorageConfig
    openclaw: OpenClawConfig
    analysis: AnalysisConfig
    domain: DomainConfig


@dataclass
class NormalizedEvent:
    event_id: str
    source: str
    event_type: str
    device_id: str
    ts: str
    severity: str
    payload: Dict[str, Any]
    dedupe_key: str


class AgriRepository:
    def __init__(self, db_path: str) -> None:
        self.db_path = Path(db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self.lock = threading.Lock()
        self.conn = sqlite3.connect(self.db_path, check_same_thread=False)
        self.conn.row_factory = sqlite3.Row
        self._init_schema()

    def close(self) -> None:
        self.conn.close()

    def _init_schema(self) -> None:
        with self.conn:
            self.conn.execute(
                """
                CREATE TABLE IF NOT EXISTS events (
                    event_id TEXT PRIMARY KEY,
                    source TEXT NOT NULL,
                    event_type TEXT NOT NULL,
                    device_id TEXT NOT NULL,
                    ts TEXT NOT NULL,
                    severity TEXT NOT NULL,
                    dedupe_key TEXT NOT NULL UNIQUE,
                    payload_json TEXT NOT NULL
                )
                """
            )
            self.conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_events_type_ts ON events (event_type, ts DESC)"
            )
            self.conn.execute(
                """
                CREATE TABLE IF NOT EXISTS state_latest (
                    state_key TEXT PRIMARY KEY,
                    updated_at TEXT NOT NULL,
                    payload_json TEXT NOT NULL
                )
                """
            )
            self.conn.execute(
                """
                CREATE TABLE IF NOT EXISTS decision_reports (
                    report_id TEXT PRIMARY KEY,
                    ts TEXT NOT NULL,
                    mode TEXT NOT NULL,
                    session_id TEXT NOT NULL,
                    severity TEXT NOT NULL,
                    summary TEXT NOT NULL,
                    payload_json TEXT NOT NULL
                )
                """
            )
            self.conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_reports_ts ON decision_reports (ts DESC)"
            )
            self.conn.execute(
                """
                CREATE TABLE IF NOT EXISTS chat_sessions (
                    session_id TEXT PRIMARY KEY,
                    updated_at TEXT NOT NULL,
                    last_report_id TEXT,
                    payload_json TEXT NOT NULL
                )
                """
            )

    def insert_event(self, event: NormalizedEvent) -> Tuple[bool, str]:
        with self.lock, self.conn:
            existing = self.conn.execute(
                "SELECT event_id FROM events WHERE dedupe_key = ?",
                (event.dedupe_key,),
            ).fetchone()
            if existing:
                return False, str(existing["event_id"])
            self.conn.execute(
                """
                INSERT INTO events (
                    event_id, source, event_type, device_id, ts, severity, dedupe_key, payload_json
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    event.event_id,
                    event.source,
                    event.event_type,
                    event.device_id,
                    event.ts,
                    event.severity,
                    event.dedupe_key,
                    json_dumps(event.payload),
                ),
            )
            return True, event.event_id

    def upsert_state(self, state_key: str, payload: Dict[str, Any], updated_at: Optional[str] = None) -> None:
        ts = updated_at or now_iso()
        with self.lock, self.conn:
            self.conn.execute(
                """
                INSERT INTO state_latest (state_key, updated_at, payload_json)
                VALUES (?, ?, ?)
                ON CONFLICT(state_key) DO UPDATE SET
                    updated_at = excluded.updated_at,
                    payload_json = excluded.payload_json
                """,
                (state_key, ts, json_dumps(payload)),
            )

    def get_latest_state(self, state_key: str) -> Dict[str, Any]:
        with self.lock:
            row = self.conn.execute(
                "SELECT updated_at, payload_json FROM state_latest WHERE state_key = ?",
                (state_key,),
            ).fetchone()
        if not row:
            return {}
        payload = json.loads(str(row["payload_json"]))
        payload["updatedAt"] = str(row["updated_at"])
        return payload

    def insert_report(self, report: Dict[str, Any]) -> None:
        with self.lock, self.conn:
            self.conn.execute(
                """
                INSERT INTO decision_reports (report_id, ts, mode, session_id, severity, summary, payload_json)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    report["reportId"],
                    report["ts"],
                    report["mode"],
                    report["sessionId"],
                    report["severity"],
                    report["summary"],
                    json_dumps(report),
                ),
            )
            self.conn.execute(
                """
                INSERT INTO chat_sessions (session_id, updated_at, last_report_id, payload_json)
                VALUES (?, ?, ?, ?)
                ON CONFLICT(session_id) DO UPDATE SET
                    updated_at = excluded.updated_at,
                    last_report_id = excluded.last_report_id,
                    payload_json = excluded.payload_json
                """,
                (
                    report["sessionId"],
                    report["ts"],
                    report["reportId"],
                    json_dumps(
                        {
                            "mode": report["mode"],
                            "lastSummary": report["summary"],
                            "lastQuestion": report.get("question"),
                        }
                    ),
                ),
            )

    def get_report(self, report_id: str) -> Optional[Dict[str, Any]]:
        with self.lock:
            row = self.conn.execute(
                "SELECT payload_json FROM decision_reports WHERE report_id = ?",
                (report_id,),
            ).fetchone()
        return json.loads(str(row["payload_json"])) if row else None

    def get_latest_report(self, mode: Optional[str] = None) -> Optional[Dict[str, Any]]:
        query = "SELECT payload_json FROM decision_reports"
        params: list[Any] = []
        if mode:
            query += " WHERE mode = ?"
            params.append(mode)
        query += " ORDER BY ts DESC LIMIT 1"
        with self.lock:
            row = self.conn.execute(query, params).fetchone()
        return json.loads(str(row["payload_json"])) if row else None

    def get_recent_events(self, event_prefix: str, window_minutes: int, limit: int = EVENT_LIMIT) -> list[Dict[str, Any]]:
        since = (datetime.now().astimezone() - timedelta(minutes=window_minutes)).isoformat(timespec="seconds")
        with self.lock:
            rows = self.conn.execute(
                """
                SELECT event_id, source, event_type, device_id, ts, severity, payload_json
                FROM events
                WHERE event_type LIKE ? AND ts >= ?
                ORDER BY ts DESC
                LIMIT ?
                """,
                (f"{event_prefix}%", since, limit),
            ).fetchall()
        result: list[Dict[str, Any]] = []
        for row in rows:
            payload = json.loads(str(row["payload_json"]))
            result.append(
                {
                    "eventId": str(row["event_id"]),
                    "source": str(row["source"]),
                    "eventType": str(row["event_type"]),
                    "deviceId": str(row["device_id"]),
                    "ts": str(row["ts"]),
                    "severity": str(row["severity"]),
                    "payload": payload,
                }
            )
        return result

    def get_recent_reports(self, window_hours: int, limit: int = REPORT_LIMIT) -> list[Dict[str, Any]]:
        since = (datetime.now().astimezone() - timedelta(hours=window_hours)).isoformat(timespec="seconds")
        with self.lock:
            rows = self.conn.execute(
                """
                SELECT payload_json
                FROM decision_reports
                WHERE ts >= ?
                ORDER BY ts DESC
                LIMIT ?
                """,
                (since, limit),
            ).fetchall()
        return [json.loads(str(row["payload_json"])) for row in rows]

    def get_sensor_history(self, metric: str, window_minutes: int, limit: int = EVENT_LIMIT) -> list[Dict[str, Any]]:
        events = self.get_recent_events("sensor.snapshot", window_minutes, limit)
        points: list[Dict[str, Any]] = []
        for event in reversed(events):
            environment = event["payload"].get("environment") or {}
            value = environment.get(metric)
            if value is None:
                continue
            points.append({"ts": event["ts"], "value": value})
        return points

    def prune_older_than(self, cutoff_iso: str) -> Dict[str, int]:
        with self.lock, self.conn:
            events_deleted = self.conn.execute(
                "DELETE FROM events WHERE ts < ?",
                (cutoff_iso,),
            ).rowcount
            reports_deleted = self.conn.execute(
                "DELETE FROM decision_reports WHERE ts < ?",
                (cutoff_iso,),
            ).rowcount
            sessions_deleted = self.conn.execute(
                "DELETE FROM chat_sessions WHERE updated_at < ?",
                (cutoff_iso,),
            ).rowcount
        return {
            "events": int(events_deleted or 0),
            "reports": int(reports_deleted or 0),
            "sessions": int(sessions_deleted or 0),
        }


class ProfileStore:
    def __init__(self, path: str) -> None:
        self.path = Path(path)
        self.lock = threading.Lock()

    def load(self) -> Dict[str, Any]:
        with self.lock:
            if not self.path.exists():
                return {"crops": {}, "greenhouses": {}}
            return json.loads(self.path.read_text(encoding="utf-8"))

    def get_crop_profile(self, crop_id: str) -> Dict[str, Any]:
        payload = self.load()
        return payload.get("crops", {}).get(crop_id, {})

    def get_greenhouse_profile(self, zone_id: str) -> Dict[str, Any]:
        payload = self.load()
        return payload.get("greenhouses", {}).get(zone_id, {})


class KnowledgeStore:
    def __init__(self, path: str) -> None:
        self.path = Path(path)
        self.lock = threading.Lock()

    def load(self) -> Dict[str, Any]:
        with self.lock:
            if not self.path.exists():
                return {"version": "", "sources": [], "crops": {}}
            return json.loads(self.path.read_text(encoding="utf-8"))

    def get_crop_knowledge(self, crop_id: str) -> Dict[str, Any]:
        payload = self.load()
        return payload.get("crops", {}).get(crop_id, {})

    def get_sources(self) -> list[Dict[str, Any]]:
        payload = self.load()
        sources = payload.get("sources", [])
        return [item for item in sources if isinstance(item, dict)]


class OpenClawClient:
    def __init__(self, config: OpenClawConfig) -> None:
        self.config = config

    def invoke(self, session_id: str, message: str) -> Dict[str, Any]:
        env = os.environ.copy()
        path_parts = [self.config.node_bin_dir]
        if env.get("PATH"):
            path_parts.append(env["PATH"])
        env["PATH"] = ":".join(path_parts)
        env["OPENCLAW_CONFIG_PATH"] = self.config.config_path
        env["OPENCLAW_STATE_DIR"] = self.config.state_dir
        completed = subprocess.run(
            [
                self.config.bin_path,
                "agent",
                "--agent",
                self.config.agent_id,
                "--session-id",
                session_id,
                "--message",
                message,
                "--json",
                "--timeout",
                str(self.config.timeout_seconds),
            ],
            capture_output=True,
            text=True,
            env=env,
            timeout=self.config.timeout_seconds + 10,
            check=False,
        )
        merged = "\n".join(filter(None, [completed.stdout.strip(), completed.stderr.strip()]))
        if completed.returncode != 0:
            raise RuntimeError(merged or f"openclaw exit={completed.returncode}")
        parsed = parse_json_loose(merged)
        if isinstance(parsed, dict):
            return parsed
        text = walk_for_text(parsed) if parsed is not None else merged.strip()
        return {"text": text or merged.strip()}


class BridgeState:
    def __init__(self) -> None:
        self.lock = threading.Lock()
        self.subscribers: dict[str, list[queue.Queue[str]]] = {}
        self.last_report_ts_by_session: dict[str, float] = {}
        self.analysis_queue: queue.Queue[Dict[str, Any]] = queue.Queue()


class AgriContextBridgeApp:
    def __init__(self, config: BridgeConfig) -> None:
        self.config = config
        self.repo = AgriRepository(config.storage.db_path)
        self.profiles = ProfileStore(config.storage.profiles_path)
        self.knowledge = KnowledgeStore(config.storage.knowledge_path)
        self.openclaw = OpenClawClient(config.openclaw)
        self.state = BridgeState()
        self.stop_event = threading.Event()
        self.http_server: Optional[ThreadingHTTPServer] = None
        self.http_thread: Optional[threading.Thread] = None
        self.analysis_thread: Optional[threading.Thread] = None
        self._last_prune_monotonic = 0.0

    def close(self) -> None:
        self.stop_event.set()
        if self.http_server:
            self.http_server.shutdown()
            self.http_server.server_close()
        if self.http_thread and self.http_thread.is_alive():
            self.http_thread.join(timeout=2)
        if self.analysis_thread and self.analysis_thread.is_alive():
            self.analysis_thread.join(timeout=2)
        self.repo.close()

    def start(self) -> None:
        self.maybe_prune_old_data(force=True)
        self._start_analysis_worker()
        self._start_http_server()

    def check_config(self) -> None:
        Path(self.config.storage.db_path).parent.mkdir(parents=True, exist_ok=True)
        self.profiles.load()
        self.knowledge.load()

    def add_subscriber(self, session_id: str, sink: queue.Queue[str]) -> None:
        with self.state.lock:
            self.state.subscribers.setdefault(session_id, []).append(sink)

    def remove_subscriber(self, session_id: str, sink: queue.Queue[str]) -> None:
        with self.state.lock:
            sinks = self.state.subscribers.get(session_id, [])
            self.state.subscribers[session_id] = [item for item in sinks if item is not sink]
            if not self.state.subscribers[session_id]:
                self.state.subscribers.pop(session_id, None)

    def publish_report(self, report: Dict[str, Any]) -> None:
        payload = json_dumps(report)
        session_id = report["sessionId"]
        with self.state.lock:
            sinks = list(self.state.subscribers.get(session_id, []))
        for sink in sinks:
            sink.put(payload)

    def queue_analysis(self, reason: str, mode: str, session_id: str, question: str, crop_id: str, zone_id: str) -> bool:
        with self.state.lock:
            last = self.state.last_report_ts_by_session.get(session_id, 0.0)
            if time.time() - last < self.config.analysis.report_cooldown_seconds:
                return False
        self.state.analysis_queue.put(
            {
                "reason": reason,
                "mode": mode,
                "sessionId": session_id,
                "question": question,
                "cropId": crop_id,
                "zoneId": zone_id,
            }
        )
        return True

    def maybe_prune_old_data(self, force: bool = False) -> None:
        retention_hours = max(self.config.storage.retention_hours, 1)
        prune_interval = max(self.config.storage.prune_interval_seconds, 30)
        now_mono = time.monotonic()
        if not force and now_mono - self._last_prune_monotonic < prune_interval:
            return
        cutoff = datetime.now().astimezone() - timedelta(hours=retention_hours)
        deleted = self.repo.prune_older_than(cutoff.isoformat(timespec="seconds"))
        self._last_prune_monotonic = now_mono
        if any(deleted.values()):
            logging.info(
                "pruned old agri data: retention_hours=%s events=%s reports=%s sessions=%s",
                retention_hours,
                deleted["events"],
                deleted["reports"],
                deleted["sessions"],
            )

    def _start_analysis_worker(self) -> None:
        self.analysis_thread = threading.Thread(
            target=self._analysis_worker_loop,
            name="agri-analysis-worker",
            daemon=True,
        )
        self.analysis_thread.start()

    def _analysis_worker_loop(self) -> None:
        while not self.stop_event.is_set():
            try:
                task = self.state.analysis_queue.get(timeout=0.5)
            except queue.Empty:
                continue
            try:
                report = self.generate_report(
                    mode=str(task["mode"]),
                    session_id=str(task["sessionId"]),
                    question=str(task["question"]),
                    crop_id=str(task["cropId"]),
                    zone_id=str(task["zoneId"]),
                )
                logging.info(
                    "analysis completed: sessionId=%s reportId=%s reason=%s",
                    task["sessionId"],
                    report["reportId"],
                    task["reason"],
                )
            except Exception as exc:  # pragma: no cover
                logging.exception("analysis worker failed: %s", exc)

    def _start_http_server(self) -> None:
        app = self

        class BridgeHTTPServer(ThreadingHTTPServer):
            daemon_threads = True
            allow_reuse_address = True

            def __init__(self, server_address: Tuple[str, int]) -> None:
                super().__init__(server_address, BridgeHandler)
                self.app = app

        class BridgeHandler(BaseHTTPRequestHandler):
            protocol_version = "HTTP/1.1"

            def do_POST(self) -> None:
                path = urlparse(self.path).path
                if path == "/api/agri/events/vision":
                    self._handle_json_body(self.server.app.http_ingest_vision)
                    return
                if path == "/api/agri/events/modbus-snapshot":
                    self._handle_json_body(self.server.app.http_ingest_sensor)
                    return
                if path == "/api/agri/decisions/analyze":
                    self._handle_json_body(self.server.app.http_analyze)
                    return
                if path == "/api/agri/chat":
                    self._handle_json_body(self.server.app.http_chat)
                    return
                if path == "/api/agri/actions/execute":
                    self.server.app.http_execute_disabled(self)
                    return
                self._write_json(404, {"code": 404, "msg": "not found"})

            def do_GET(self) -> None:
                parsed = urlparse(self.path)
                path = parsed.path
                query = parse_qs(parsed.query)
                if path == "/healthz":
                    self._write_json(200, self.server.app.http_healthz())
                    return
                if path == "/api/agri/reports/latest":
                    payload = self.server.app.http_latest_report(query)
                    if payload is None:
                        self._write_json(404, {"code": 404, "msg": "report not found"})
                    else:
                        self._write_json(200, payload)
                    return
                if path.startswith("/api/agri/reports/"):
                    report_id = path.rsplit("/", 1)[-1]
                    payload = self.server.app.http_get_report(report_id)
                    if payload is None:
                        self._write_json(404, {"code": 404, "msg": "report not found"})
                    else:
                        self._write_json(200, payload)
                    return
                if path == "/api/agri/stream":
                    self.server.app.http_stream(self, query)
                    return
                if path == "/api/agri/tools/latest-environment":
                    self._write_json(200, self.server.app.get_latest_environment())
                    return
                if path == "/api/agri/tools/recent-vision-events":
                    kind = query.get("type", [""])[0]
                    window = coerce_int(query.get("windowMinutes", ["10"])[0]) or 10
                    self._write_json(200, self.server.app.get_recent_vision_events(kind, window))
                    return
                if path == "/api/agri/tools/recent-sensor-history":
                    metric = query.get("metric", ["temperature"])[0]
                    window = coerce_int(query.get("windowMinutes", ["60"])[0]) or 60
                    self._write_json(200, self.server.app.get_recent_sensor_history(metric, window))
                    return
                if path == "/api/agri/tools/recent-decision-reports":
                    window = coerce_int(query.get("windowHours", ["24"])[0]) or 24
                    self._write_json(200, self.server.app.get_recent_decision_reports(window))
                    return
                if path == "/api/agri/tools/crop-profile":
                    crop_id = query.get("cropId", [self.server.app.config.domain.default_crop_id])[0]
                    self._write_json(200, self.server.app.get_crop_profile(crop_id))
                    return
                if path == "/api/agri/tools/crop-knowledge":
                    crop_id = query.get("cropId", [self.server.app.config.domain.default_crop_id])[0]
                    self._write_json(200, self.server.app.get_crop_knowledge(crop_id))
                    return
                if path == "/api/agri/tools/knowledge-sources":
                    self._write_json(200, self.server.app.get_knowledge_sources())
                    return
                if path == "/api/agri/tools/greenhouse-profile":
                    zone_id = query.get("zoneId", [self.server.app.config.domain.default_zone_id])[0]
                    self._write_json(200, self.server.app.get_greenhouse_profile(zone_id))
                    return
                self._write_json(404, {"code": 404, "msg": "not found"})

            def _handle_json_body(self, handler: Any) -> None:
                try:
                    content_length = int(self.headers.get("Content-Length", "0"))
                except ValueError:
                    self._write_json(400, {"code": 400, "msg": "invalid content-length"})
                    return
                if content_length <= 0 or content_length > MAX_BODY_BYTES:
                    self._write_json(400, {"code": 400, "msg": "invalid body length"})
                    return
                raw = self.rfile.read(content_length)
                try:
                    body = json.loads(raw.decode("utf-8"))
                except (UnicodeDecodeError, json.JSONDecodeError):
                    self._write_json(400, {"code": 400, "msg": "invalid json"})
                    return
                try:
                    payload = handler(body)
                except ValueError as exc:
                    self._write_json(400, {"code": 400, "msg": str(exc)})
                    return
                except Exception as exc:  # pragma: no cover
                    logging.exception("request failed: %s", exc)
                    self._write_json(500, {"code": 500, "msg": "internal error"})
                    return
                self._write_json(200, payload)

            def log_message(self, format: str, *args: Any) -> None:
                logging.info("http %s - %s", self.address_string(), format % args)

            def _write_json(self, status: int, payload: Dict[str, Any]) -> None:
                encoded = json.dumps(payload, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
                self.send_response(status)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.send_header("Content-Length", str(len(encoded)))
                self.end_headers()
                self.wfile.write(encoded)

        self.http_server = BridgeHTTPServer((self.config.http.bind_host, self.config.http.bind_port))
        self.http_thread = threading.Thread(target=self.http_server.serve_forever, name="agri-http", daemon=True)
        self.http_thread.start()
        logging.info(
            "agri context bridge listening on %s:%s",
            self.config.http.bind_host,
            self.config.http.bind_port,
        )

    def http_healthz(self) -> Dict[str, Any]:
        return {
            "code": 0,
            "service": "agri-context-bridge",
            "openclawEnabled": self.config.openclaw.enabled,
            "agentId": self.config.openclaw.agent_id,
            "hasEnvironment": bool(self.get_latest_environment()),
            "hasKnowledgeBase": bool(self.knowledge.get_sources()),
            "latestReportId": (self.repo.get_latest_report() or {}).get("reportId"),
        }

    def http_ingest_vision(self, body: Dict[str, Any]) -> Dict[str, Any]:
        event = self.normalize_vision_event(body)
        inserted, event_id = self.repo.insert_event(event)
        self.maybe_prune_old_data()
        crop_id = str(body.get("cropId") or self.config.domain.default_crop_id)
        zone_id = str(body.get("zoneId") or self.config.domain.default_zone_id)
        triggered = False
        if self.config.analysis.auto_analyze_vision:
            triggered = self.queue_analysis(
                reason="vision-event",
                mode="analysis",
                session_id=f"agri-analysis:{zone_id}",
                question="请基于当前视觉和传感上下文生成最新农业处置建议。",
                crop_id=crop_id,
                zone_id=zone_id,
            )
        logging.info("vision event accepted: eventId=%s inserted=%s type=%s", event_id, inserted, event.event_type)
        return {
            "code": 0,
            "msg": "accepted",
            "eventId": event_id,
            "inserted": inserted,
            "analysisTriggered": triggered,
        }

    def http_ingest_sensor(self, body: Dict[str, Any]) -> Dict[str, Any]:
        event = self.normalize_sensor_event(body)
        inserted, event_id = self.repo.insert_event(event)
        self.repo.upsert_state("environment", event.payload["environment"], updated_at=event.ts)
        self.maybe_prune_old_data()
        crop_id = str(body.get("cropId") or self.config.domain.default_crop_id)
        zone_id = str(body.get("zoneId") or self.config.domain.default_zone_id)
        recent_vision = self.get_recent_vision_events("", self.config.analysis.recent_vision_window_minutes)
        triggered = False
        if self.config.analysis.auto_analyze_sensor and recent_vision:
            triggered = self.queue_analysis(
                reason="sensor-snapshot",
                mode="analysis",
                session_id=f"agri-analysis:{zone_id}",
                question="请结合最近视觉告警和最新环境状态刷新农业处置建议。",
                crop_id=crop_id,
                zone_id=zone_id,
            )
        logging.info("sensor snapshot accepted: eventId=%s inserted=%s", event_id, inserted)
        return {
            "code": 0,
            "msg": "accepted",
            "eventId": event_id,
            "inserted": inserted,
            "analysisTriggered": triggered,
        }

    def http_analyze(self, body: Dict[str, Any]) -> Dict[str, Any]:
        crop_id = str(body.get("cropId") or self.config.domain.default_crop_id)
        zone_id = str(body.get("zoneId") or self.config.domain.default_zone_id)
        session_id = str(body.get("sessionId") or f"agri-analysis:{zone_id}")
        question = str(body.get("query") or "请基于当前上下文生成一份农业处置建议。")
        return self.generate_report("analysis", session_id, question, crop_id, zone_id)

    def http_chat(self, body: Dict[str, Any]) -> Dict[str, Any]:
        question = str(body.get("query") or body.get("question") or "").strip()
        if not question:
            raise ValueError("query is required")
        crop_id = str(body.get("cropId") or self.config.domain.default_crop_id)
        zone_id = str(body.get("zoneId") or self.config.domain.default_zone_id)
        session_id = str(body.get("sessionId") or f"agri-chat:{uuid.uuid4().hex[:12]}")
        return self.generate_report("chat", session_id, question, crop_id, zone_id)

    def http_execute_disabled(self, handler: BaseHTTPRequestHandler) -> None:
        payload = {
            "code": 501,
            "msg": "execute disabled by policy",
            "executeEnabled": False,
            "executionStatus": "disabled_by_policy",
        }
        encoded = json.dumps(payload, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        handler.send_response(501)
        handler.send_header("Content-Type", "application/json; charset=utf-8")
        handler.send_header("Content-Length", str(len(encoded)))
        handler.end_headers()
        handler.wfile.write(encoded)

    def http_latest_report(self, query: Dict[str, list[str]]) -> Optional[Dict[str, Any]]:
        mode = query.get("mode", [None])[0]
        return self.repo.get_latest_report(mode=mode if mode else None)

    def http_get_report(self, report_id: str) -> Optional[Dict[str, Any]]:
        return self.repo.get_report(report_id)

    def http_stream(self, handler: BaseHTTPRequestHandler, query: Dict[str, list[str]]) -> None:
        session_id = str(query.get("sessionId", [""])[0]).strip()
        if not session_id:
            payload = json.dumps({"code": 400, "msg": "sessionId is required"}, ensure_ascii=False).encode("utf-8")
            handler.send_response(400)
            handler.send_header("Content-Type", "application/json; charset=utf-8")
            handler.send_header("Content-Length", str(len(payload)))
            handler.end_headers()
            handler.wfile.write(payload)
            return

        sink: queue.Queue[str] = queue.Queue()
        self.add_subscriber(session_id, sink)
        handler.send_response(200)
        handler.send_header("Content-Type", "text/event-stream; charset=utf-8")
        handler.send_header("Cache-Control", "no-cache")
        handler.send_header("Connection", "keep-alive")
        handler.end_headers()
        try:
            hello = f"event: ready\ndata: {json_dumps({'sessionId': session_id})}\n\n".encode("utf-8")
            handler.wfile.write(hello)
            handler.wfile.flush()
            while not self.stop_event.is_set():
                try:
                    item = sink.get(timeout=KEEPALIVE_SECONDS)
                    chunk = f"event: report\ndata: {item}\n\n".encode("utf-8")
                except queue.Empty:
                    chunk = b": keepalive\n\n"
                handler.wfile.write(chunk)
                handler.wfile.flush()
        except (BrokenPipeError, ConnectionResetError):
            return
        finally:
            self.remove_subscriber(session_id, sink)

    def normalize_vision_event(self, body: Dict[str, Any]) -> NormalizedEvent:
        event_name = str(body.get("event") or "").strip()
        pest_type = str(body.get("type") or "").strip()
        if not event_name:
            raise ValueError("event is required")
        if not pest_type:
            raise ValueError("type is required")
        confidence = coerce_float(body.get("confidence"))
        ts = normalize_event_ts(body.get("ts") or body.get("timestamp") or body.get("timestampMs"))
        payload = {
            "event": event_name,
            "type": pest_type,
            "confidence": confidence,
            "frameId": body.get("frameId"),
            "stream": body.get("stream"),
            "raw": body,
        }
        severity = "warn" if (confidence or 0) >= 0.7 else "info"
        device_id = str(body.get("deviceId") or "k230-01")
        dedupe_source = json_dumps(
            {
                "source": "k230",
                "eventType": f"vision.{event_name}",
                "deviceId": device_id,
                "ts": ts,
                "frameId": body.get("frameId"),
                "payload": payload,
            }
        )
        return NormalizedEvent(
            event_id=str(body.get("eventId") or make_event_id()),
            source="k230",
            event_type=f"vision.{event_name}",
            device_id=device_id,
            ts=ts,
            severity=severity,
            payload=payload,
            dedupe_key=sha256_text(dedupe_source),
        )

    def normalize_sensor_event(self, body: Dict[str, Any]) -> NormalizedEvent:
        envelope = body
        payload = body.get("payload") if isinstance(body.get("payload"), dict) else body
        if body.get("type") and body.get("type") != "MODBUS_SNAPSHOT":
            raise ValueError("unsupported type")
        if not isinstance(payload, dict):
            raise ValueError("payload must be an object")
        environment = self.extract_environment(payload)
        ts = normalize_event_ts(envelope.get("ts") or envelope.get("timestamp"))
        severity = self.infer_environment_severity(environment)
        normalized_payload = {
            "environment": environment,
            "messageId": envelope.get("messageId"),
            "cycleId": payload.get("cycleId"),
            "raw": body,
        }
        device_id = str(envelope.get("deviceId") or "stm32f4")
        dedupe_source = json_dumps(
            {
                "source": "stm32",
                "eventType": "sensor.snapshot",
                "deviceId": device_id,
                "ts": ts,
                "messageId": envelope.get("messageId"),
                "payload": normalized_payload,
            }
        )
        return NormalizedEvent(
            event_id=str(envelope.get("eventId") or make_event_id()),
            source="stm32",
            event_type="sensor.snapshot",
            device_id=device_id,
            ts=ts,
            severity=severity,
            payload=normalized_payload,
            dedupe_key=sha256_text(dedupe_source),
        )

    def extract_environment(self, payload: Dict[str, Any]) -> Dict[str, Any]:
        slave1 = payload.get("slave1") if isinstance(payload.get("slave1"), dict) else {}
        slave2 = payload.get("slave2") if isinstance(payload.get("slave2"), dict) else {}
        slave3 = payload.get("slave3") if isinstance(payload.get("slave3"), dict) else {}
        return {
            "cycleId": payload.get("cycleId"),
            "temperature": slave2.get("temperature"),
            "humidity": slave2.get("humidity"),
            "light": slave1.get("lightAdc"),
            "mq2": slave3.get("mq2Ppm"),
            "slave1Online": slave1.get("online"),
            "slave2Online": slave2.get("online"),
            "slave3Online": slave3.get("online"),
        }

    @staticmethod
    def infer_environment_severity(environment: Dict[str, Any]) -> str:
        temperature = coerce_float(environment.get("temperature"))
        humidity = coerce_float(environment.get("humidity"))
        if temperature is not None and temperature >= 32:
            return "warn"
        if humidity is not None and humidity <= 40:
            return "warn"
        return "info"

    def get_latest_environment(self) -> Dict[str, Any]:
        return self.repo.get_latest_state("environment")

    def get_recent_vision_events(self, event_type: str, window_minutes: int) -> list[Dict[str, Any]]:
        events = self.repo.get_recent_events("vision.", window_minutes)
        if not event_type:
            return events
        return [item for item in events if lower_text(item["payload"].get("type")) == lower_text(event_type)]

    def get_recent_sensor_history(self, metric: str, window_minutes: int) -> Dict[str, Any]:
        return {
            "metric": metric,
            "windowMinutes": window_minutes,
            "points": self.repo.get_sensor_history(metric, window_minutes),
        }

    def get_recent_decision_reports(self, window_hours: int) -> Dict[str, Any]:
        reports = self.repo.get_recent_reports(window_hours)
        return {"windowHours": window_hours, "reports": reports}

    def get_crop_profile(self, crop_id: str) -> Dict[str, Any]:
        return {"cropId": crop_id, "profile": self.profiles.get_crop_profile(crop_id)}

    def get_crop_knowledge(self, crop_id: str) -> Dict[str, Any]:
        return {"cropId": crop_id, "knowledge": self.knowledge.get_crop_knowledge(crop_id)}

    def get_knowledge_sources(self) -> Dict[str, Any]:
        return {"sources": self.knowledge.get_sources()}

    def get_greenhouse_profile(self, zone_id: str) -> Dict[str, Any]:
        return {"zoneId": zone_id, "profile": self.profiles.get_greenhouse_profile(zone_id)}

    def build_context(self, crop_id: str, zone_id: str, mode: str, question: str) -> Dict[str, Any]:
        latest_environment = self.get_latest_environment()
        vision_events = self.get_recent_vision_events("", self.config.analysis.recent_vision_window_minutes)
        history_reports = self.repo.get_recent_reports(24)
        history_summary = [
            {
                "reportId": report["reportId"],
                "ts": report["ts"],
                "severity": report["severity"],
                "summary": report["summary"],
            }
            for report in history_reports[:5]
        ]
        sensor_history = {
            "temperature": self.repo.get_sensor_history("temperature", 60),
            "humidity": self.repo.get_sensor_history("humidity", 60),
        }
        crop_profile = self.profiles.get_crop_profile(crop_id)
        crop_knowledge = self.knowledge.get_crop_knowledge(crop_id)
        greenhouse_profile = self.profiles.get_greenhouse_profile(zone_id)
        knowledge_highlights = crop_knowledge.get("knowledgeHighlights")
        if not isinstance(knowledge_highlights, list):
            knowledge_highlights = []
        prompt_summary = self.build_natural_language_summary(
            latest_environment=latest_environment,
            vision_events=vision_events,
            crop_profile=crop_profile,
            greenhouse_profile=greenhouse_profile,
            question=question,
        )
        return {
            "mode": mode,
            "question": question,
            "cropId": crop_id,
            "zoneId": zone_id,
            "sensorSnapshot": latest_environment,
            "visionEvents": vision_events,
            "sensorHistory": sensor_history,
            "historySummary": history_summary,
            "cropProfile": crop_profile,
            "cropKnowledge": crop_knowledge,
            "knowledgeHighlights": knowledge_highlights[:8],
            "greenhouseProfile": greenhouse_profile,
            "promptSummary": prompt_summary,
        }

    @staticmethod
    def build_natural_language_summary(
        latest_environment: Dict[str, Any],
        vision_events: Iterable[Dict[str, Any]],
        crop_profile: Dict[str, Any],
        greenhouse_profile: Dict[str, Any],
        question: str,
    ) -> str:
        temperature = latest_environment.get("temperature", "未知")
        humidity = latest_environment.get("humidity", "未知")
        light = latest_environment.get("light", "未知")
        pest_line = "视觉侧暂无明确病虫害事件。"
        first_event = next(iter(vision_events), None)
        if first_event:
            pest_type = first_event.get("payload", {}).get("type", "unknown")
            confidence = first_event.get("payload", {}).get("confidence")
            confidence_text = "未知"
            if isinstance(confidence, (int, float)):
                confidence_text = f"{confidence:.2f}"
            pest_line = f"视觉终端最近检测到 {pest_type} 迹象，置信度 {confidence_text}。"
        crop_name = crop_profile.get("name", "石斛")
        zone_name = greenhouse_profile.get("name", "大棚")
        return (
            f"当前{zone_name}种植作物为{crop_name}，温度 {temperature}℃，湿度 {humidity}% ，光照 {light}。"
            f"{pest_line} 用户问题：{question}"
        )

    def build_agent_message(self, context: Dict[str, Any]) -> str:
        schema = {
            "summary": "一句话总结",
            "severity": "info|warn|critical",
            "decision": {
                "conclusion": "结论代码",
                "confidence": 0.0,
                "recommendedActions": [
                    {
                        "actionType": "fan.on",
                        "targetDevice": "top_vent_fan",
                        "priority": 1,
                        "reason": "原因说明",
                        "executeEnabled": False,
                        "executionStatus": "disabled_by_policy",
                    }
                ],
            },
            "humanMessage": "给农业人员或 APP 用户看的大白话解释",
        }
        return (
            "你是 OpenClaw 上的农业边缘决策 agent，角色是只读决策大脑，不是执行器。\n"
            "严格要求：\n"
            "1. 只根据给定上下文推理，不要编造未观测到的数据。\n"
            "2. 不允许建议修改网关配置、系统配置、Nginx、systemd、OpenClaw 配置，也不允许删除或编辑任何文件。\n"
            "3. 可以给出推荐动作，但必须把 executeEnabled 保持为 false，executionStatus 固定为 disabled_by_policy。\n"
            "4. 如果证据不足，要明确表达不确定性。\n"
            "5. 只输出 JSON，不要输出 Markdown，不要输出额外解释。\n"
            f"输出 JSON 模板：{json_dumps(schema)}\n"
            f"上下文 JSON：{json_dumps(context)}"
        )

    def invoke_openclaw(self, session_id: str, prompt: str) -> Dict[str, Any]:
        if not self.config.openclaw.enabled:
            raise RuntimeError("openclaw disabled")
        result = self.openclaw.invoke(session_id=session_id, message=prompt)
        text = walk_for_text(result) or json_dumps(result)
        parsed = parse_json_loose(text)
        if isinstance(parsed, dict):
            return parsed
        raise RuntimeError(f"unexpected openclaw response: {text}")

    def fallback_decision(self, context: Dict[str, Any], error_text: str) -> Dict[str, Any]:
        sensor = context["sensorSnapshot"]
        vision_events = context["visionEvents"]
        conclusion = "observe_only"
        severity = "info"
        summary = "当前数据量有限，建议继续观察。"
        if vision_events:
            pest_type = vision_events[0]["payload"].get("type", "unknown")
            conclusion = f"possible_{pest_type}"
            summary = f"检测到疑似 {pest_type}，建议人工复核并继续监测。"
            severity = "warn"
        temperature = coerce_float(sensor.get("temperature"))
        humidity = coerce_float(sensor.get("humidity"))
        actions = []
        if temperature is not None and temperature >= 32:
            actions.append(
                {
                    "actionType": "fan.on",
                    "targetDevice": "top_vent_fan",
                    "priority": 1,
                    "reason": "温度偏高，建议降温通风。",
                    "executeEnabled": False,
                    "executionStatus": "disabled_by_policy",
                }
            )
            severity = "warn"
        if humidity is not None and humidity <= 40:
            actions.append(
                {
                    "actionType": "pump.start",
                    "targetDevice": "humidifying_pump",
                    "priority": 2,
                    "reason": "湿度偏低，建议增湿并持续观察。",
                    "executeEnabled": False,
                    "executionStatus": "disabled_by_policy",
                }
            )
            severity = "warn"
        return {
            "summary": summary,
            "severity": severity,
            "decision": {
                "conclusion": conclusion,
                "confidence": 0.35,
                "recommendedActions": actions,
            },
            "humanMessage": f"{summary} 当前结果来自降级规则，原因：{error_text}",
        }

    def normalize_report_payload(
        self,
        model_output: Dict[str, Any],
        context: Dict[str, Any],
        mode: str,
        session_id: str,
        question: str,
    ) -> Dict[str, Any]:
        decision = model_output.get("decision") if isinstance(model_output.get("decision"), dict) else {}
        actions = decision.get("recommendedActions") if isinstance(decision.get("recommendedActions"), list) else []
        normalized_actions = []
        for item in actions:
            if not isinstance(item, dict):
                continue
            normalized_actions.append(
                {
                    "actionType": str(item.get("actionType") or "manual.check"),
                    "targetDevice": str(item.get("targetDevice") or "unassigned"),
                    "priority": coerce_int(item.get("priority")) or len(normalized_actions) + 1,
                    "reason": str(item.get("reason") or "No reason provided."),
                    "executeEnabled": False,
                    "executionStatus": "disabled_by_policy",
                }
            )
        return {
            "reportId": make_event_id(),
            "ts": now_iso(),
            "mode": mode,
            "sessionId": session_id,
            "question": question,
            "summary": str(model_output.get("summary") or "未生成摘要。"),
            "severity": normalize_severity(model_output.get("severity"), default="info"),
            "decision": {
                "conclusion": str(decision.get("conclusion") or "observe_only"),
                "confidence": coerce_float(decision.get("confidence")) or 0.0,
                "recommendedActions": normalized_actions,
            },
            "evidence": {
                "visionEvents": context["visionEvents"],
                "sensorSnapshot": context["sensorSnapshot"],
                "historySummary": context["historySummary"],
                "knowledgeHighlights": context.get("knowledgeHighlights", []),
            },
            "humanMessage": str(model_output.get("humanMessage") or model_output.get("summary") or ""),
        }

    def generate_report(
        self,
        mode: str,
        session_id: str,
        question: str,
        crop_id: str,
        zone_id: str,
    ) -> Dict[str, Any]:
        context = self.build_context(crop_id=crop_id, zone_id=zone_id, mode=mode, question=question)
        prompt = self.build_agent_message(context)
        try:
            model_output = self.invoke_openclaw(session_id=session_id, prompt=prompt)
        except Exception as exc:
            logging.warning("openclaw invoke failed, using fallback: %s", exc)
            model_output = self.fallback_decision(context, str(exc))
        report = self.normalize_report_payload(model_output, context, mode, session_id, question)
        self.repo.insert_report(report)
        self.maybe_prune_old_data()
        with self.state.lock:
            self.state.last_report_ts_by_session[session_id] = time.time()
        self.publish_report(report)
        return report


def load_config(path: str) -> BridgeConfig:
    parser = configparser.ConfigParser()
    if not parser.read(path, encoding="utf-8"):
        raise FileNotFoundError(path)
    return BridgeConfig(
        http=HttpConfig(
            bind_host=parser.get("http", "bind_host", fallback="127.0.0.1"),
            bind_port=parser.getint("http", "bind_port", fallback=18081),
        ),
        storage=StorageConfig(
            db_path=parser.get(
                "storage",
                "db_path",
                fallback="/home/linaro/project/EdgeLink_RK3568/data/agri-context-bridge.sqlite",
            ),
            profiles_path=parser.get(
                "storage",
                "profiles_path",
                fallback="/home/linaro/project/EdgeLink_RK3568/config/agri-profiles.json",
            ),
            knowledge_path=parser.get(
                "storage",
                "knowledge_path",
                fallback="/home/linaro/project/EdgeLink_RK3568/config/agri-knowledge/curated/铁皮石斛知识库.json",
            ),
            retention_hours=parser.getint("storage", "retention_hours", fallback=168),
            prune_interval_seconds=parser.getint("storage", "prune_interval_seconds", fallback=300),
        ),
        openclaw=OpenClawConfig(
            enabled=parser.getboolean("openclaw", "enabled", fallback=True),
            bin_path=parser.get("openclaw", "bin_path", fallback="/home/linaro/openclaw/bin/openclaw"),
            node_bin_dir=parser.get("openclaw", "node_bin_dir", fallback="/home/linaro/node-v22/bin"),
            config_path=parser.get(
                "openclaw",
                "config_path",
                fallback="/home/linaro/openclaw/config/openclaw.json",
            ),
            state_dir=parser.get("openclaw", "state_dir", fallback="/home/linaro/openclaw/var"),
            agent_id=parser.get("openclaw", "agent_id", fallback="agri-orchestrator"),
            timeout_seconds=parser.getint("openclaw", "timeout_seconds", fallback=120),
        ),
        analysis=AnalysisConfig(
            auto_analyze_vision=parser.getboolean("analysis", "auto_analyze_vision", fallback=True),
            auto_analyze_sensor=parser.getboolean("analysis", "auto_analyze_sensor", fallback=True),
            recent_vision_window_minutes=parser.getint(
                "analysis", "recent_vision_window_minutes", fallback=10
            ),
            report_cooldown_seconds=parser.getint("analysis", "report_cooldown_seconds", fallback=60),
        ),
        domain=DomainConfig(
            default_crop_id=parser.get("domain", "default_crop_id", fallback="huoshan-shihu"),
            default_zone_id=parser.get("domain", "default_zone_id", fallback="default-greenhouse"),
        ),
    )


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Run the RK3568 agri context bridge")
    parser.add_argument(
        "--config",
        default="/home/linaro/project/EdgeLink_RK3568/config/agri-context-bridge.ini",
        help="INI config path",
    )
    parser.add_argument("--check-config", action="store_true", help="Validate config and exit")
    return parser


def configure_logging(level_name: str = "INFO") -> None:
    level = getattr(logging, level_name.upper(), logging.INFO)
    logging.basicConfig(level=level, format="%(asctime)s %(levelname)s %(message)s")


def main() -> int:
    args = build_arg_parser().parse_args()
    config = load_config(args.config)
    configure_logging()
    app = AgriContextBridgeApp(config)
    if args.check_config:
        app.check_config()
        print("config ok")
        return 0

    def handle_signal(signum: int, frame: Any) -> None:
        logging.info("signal received: %s", signum)
        app.close()
        raise SystemExit(0)

    signal.signal(signal.SIGTERM, handle_signal)
    signal.signal(signal.SIGINT, handle_signal)
    app.start()
    try:
        while True:
            time.sleep(1)
    finally:
        app.close()


if __name__ == "__main__":
    raise SystemExit(main())

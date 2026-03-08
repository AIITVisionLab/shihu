#!/usr/bin/env python3
"""EdgeLink RK3568 gateway service.

Responsibilities:
- Accept STM32F429 MODBUS_SNAPSHOT over HTTP.
- Accept K230 AI_DETECTIONS over HTTP.
- Bridge telemetry to OneNET MQTT using the 09-1 field names.
- Subscribe to property/set and property/post/reply.
- Reply set_reply with "not implemented" until a southbound executor exists.
"""

from __future__ import annotations

import argparse
import configparser
import json
import logging
import signal
import sys
import threading
import time
from dataclasses import dataclass, field
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any, Dict, Optional, Tuple

import paho.mqtt.client as mqtt


def now_ms() -> int:
    return int(time.time() * 1000)


@dataclass
class LatestSnapshot:
    raw: Dict[str, Any] = field(default_factory=dict)
    received_at_ms: int = 0


@dataclass
class LatestAiResult:
    raw: Dict[str, Any] = field(default_factory=dict)
    received_at_ms: int = 0


@dataclass
class TelemetryState:
    temp: Optional[int] = None
    hum: Optional[int] = None
    light: Optional[int] = None
    mq2: Optional[int] = None
    error: int = 1


@dataclass
class CloudCommand:
    request_id: str
    params: Dict[str, Any]
    received_at_ms: int


class SouthboundDispatcher:
    """Placeholder for future RK3568 -> F429 -> PLC control flow."""

    def dispatch(self, command: CloudCommand) -> Tuple[bool, str]:
        logging.warning(
            "southbound dispatch not implemented: request_id=%s params=%s",
            command.request_id,
            json.dumps(command.params, ensure_ascii=False, separators=(",", ":")),
        )
        return False, "not implemented"


class GatewayState:
    def __init__(self) -> None:
        self.lock = threading.Lock()
        self.latest_snapshot = LatestSnapshot()
        self.latest_ai_result = LatestAiResult()
        self.telemetry = TelemetryState()
        self.last_command: Optional[CloudCommand] = None
        self.pending_publish = False
        self.mqtt_connected = False


class GatewayApp:
    def __init__(self, config: configparser.ConfigParser) -> None:
        self.config = config
        self.state = GatewayState()
        self.dispatcher = SouthboundDispatcher()
        self._http_server: Optional[ThreadingHTTPServer] = None
        self._http_thread: Optional[threading.Thread] = None
        self._mqtt_client = self._build_mqtt_client()

        self.http_host = config.get("http", "bind_host", fallback="0.0.0.0")
        self.http_port = config.getint("http", "bind_port", fallback=8080)

        self.product_id = config.get("onenet", "product_id")
        self.device_name = config.get("onenet", "device_name")
        self.token = config.get("onenet", "token")
        self.broker = config.get("onenet", "broker")
        self.broker_port = config.getint("onenet", "port", fallback=1883)
        self.keepalive = config.getint("onenet", "keepalive", fallback=120)
        self.publish_qos = config.getint("onenet", "qos", fallback=0)

        self.topic_post = f"$sys/{self.product_id}/{self.device_name}/thing/property/post"
        self.topic_post_reply = f"$sys/{self.product_id}/{self.device_name}/thing/property/post/reply"
        self.topic_set = f"$sys/{self.product_id}/{self.device_name}/thing/property/set"
        self.topic_set_reply = f"$sys/{self.product_id}/{self.device_name}/thing/property/set_reply"

    def _build_mqtt_client(self) -> mqtt.Client:
        client = mqtt.Client(client_id=self.config.get("onenet", "device_name", fallback=""), protocol=mqtt.MQTTv311)
        client.username_pw_set(
            username=self.config.get("onenet", "product_id", fallback=""),
            password=self.config.get("onenet", "token", fallback=""),
        )
        client.on_connect = self._on_mqtt_connect
        client.on_disconnect = self._on_mqtt_disconnect
        client.on_message = self._on_mqtt_message
        client.reconnect_delay_set(min_delay=1, max_delay=30)
        return client

    def _on_mqtt_connect(self, client: mqtt.Client, userdata: Any, flags: Dict[str, Any], reason_code: int) -> None:
        with self.state.lock:
            self.state.mqtt_connected = reason_code == 0

        if reason_code != 0:
            logging.error("mqtt connect failed: rc=%s", reason_code)
            return

        logging.info("mqtt connected to %s:%s", self.broker, self.broker_port)
        client.subscribe(self.topic_post_reply, qos=0)
        client.subscribe(self.topic_set, qos=0)
        logging.info("mqtt subscribed: %s", self.topic_post_reply)
        logging.info("mqtt subscribed: %s", self.topic_set)
        self._publish_pending_if_needed()

    def _on_mqtt_disconnect(self, client: mqtt.Client, userdata: Any, reason_code: int) -> None:
        with self.state.lock:
            self.state.mqtt_connected = False
        logging.warning("mqtt disconnected: rc=%s", reason_code)

    def _on_mqtt_message(self, client: mqtt.Client, userdata: Any, msg: mqtt.MQTTMessage) -> None:
        payload = msg.payload.decode("utf-8", errors="replace")
        if msg.topic == self.topic_post_reply:
            logging.info("onenet ack: %s", payload)
            return

        if msg.topic == self.topic_set:
            self._handle_property_set(payload)
            return

        logging.warning("ignore unexpected topic=%s payload=%s", msg.topic, payload)

    def _handle_property_set(self, payload_text: str) -> None:
        logging.info("property/set received: %s", payload_text)
        try:
            data = json.loads(payload_text)
        except json.JSONDecodeError:
            logging.error("property/set invalid json: %s", payload_text)
            self._publish_set_reply("1", -1, "invalid json")
            return

        request_id = str(data.get("id", "1"))
        params = data.get("params")
        if not isinstance(params, dict):
            logging.error("property/set invalid params: %s", payload_text)
            self._publish_set_reply(request_id, -1, "invalid params")
            return

        known = [key for key in ("Brightness", "Led") if key in params]
        unknown = [key for key in params.keys() if key not in {"Brightness", "Led"}]
        if known:
            logging.info("property/set known keys: %s", ",".join(known))
        if unknown:
            logging.warning("property/set unknown keys: %s", ",".join(unknown))

        command = CloudCommand(request_id=request_id, params=params, received_at_ms=now_ms())
        with self.state.lock:
            self.state.last_command = command

        ok, message = self.dispatcher.dispatch(command)
        code = 0 if ok else -2
        self._publish_set_reply(request_id, code, message)

    def _publish_set_reply(self, request_id: str, code: int, message: str) -> None:
        payload = json.dumps(
            {"id": request_id, "code": code, "msg": message},
            ensure_ascii=False,
            separators=(",", ":"),
        )
        result = self._mqtt_client.publish(self.topic_set_reply, payload=payload, qos=0)
        logging.info("set_reply published rc=%s payload=%s", result.rc, payload)

    def start(self) -> None:
        self._mqtt_client.connect_async(self.broker, self.broker_port, keepalive=self.keepalive)
        self._mqtt_client.loop_start()
        self._start_http_server()

    def stop(self) -> None:
        if self._http_server is not None:
            self._http_server.shutdown()
            self._http_server.server_close()
        if self._http_thread is not None:
            self._http_thread.join(timeout=5)
        self._mqtt_client.loop_stop()
        try:
            self._mqtt_client.disconnect()
        except Exception:
            logging.exception("mqtt disconnect failed")

    def _start_http_server(self) -> None:
        app = self

        class GatewayHTTPServer(ThreadingHTTPServer):
            daemon_threads = True
            allow_reuse_address = True

            def __init__(self, server_address: Tuple[str, int]) -> None:
                super().__init__(server_address, GatewayHandler)
                self.app = app

        class GatewayHandler(BaseHTTPRequestHandler):
            protocol_version = "HTTP/1.1"

            def do_POST(self) -> None:
                if self.path == "/api/uplink":
                    handler = self.server.app.handle_snapshot
                elif self.path == "/api/ai":
                    handler = self.server.app.handle_ai_result
                else:
                    self._write_json(404, {"code": 404, "msg": "not found"})
                    return

                try:
                    content_length = int(self.headers.get("Content-Length", "0"))
                except ValueError:
                    self._write_json(400, {"code": 400, "msg": "invalid content-length"})
                    return

                if content_length <= 0 or content_length > 64 * 1024:
                    self._write_json(400, {"code": 400, "msg": "invalid body length"})
                    return

                raw = self.rfile.read(content_length)
                try:
                    body = json.loads(raw.decode("utf-8"))
                except (UnicodeDecodeError, json.JSONDecodeError):
                    self._write_json(400, {"code": 400, "msg": "invalid json"})
                    return

                ok, message = handler(body)
                if ok:
                    self._write_json(200, {"code": 0, "msg": message})
                else:
                    self._write_json(400, {"code": 400, "msg": message})

            def do_GET(self) -> None:
                if self.path != "/healthz":
                    self._write_json(404, {"code": 404, "msg": "not found"})
                    return

                with self.server.app.state.lock:
                    response = {
                        "code": 0,
                        "mqttConnected": self.server.app.state.mqtt_connected,
                        "hasSnapshot": bool(self.server.app.state.latest_snapshot.raw),
                        "hasAiResult": bool(self.server.app.state.latest_ai_result.raw),
                        "videoTodo": True,
                    }
                self._write_json(200, response)

            def log_message(self, format: str, *args: Any) -> None:
                logging.info("http %s - %s", self.address_string(), format % args)

            def _write_json(self, status: int, payload: Dict[str, Any]) -> None:
                encoded = json.dumps(payload, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
                self.send_response(status)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.send_header("Content-Length", str(len(encoded)))
                self.end_headers()
                self.wfile.write(encoded)

        self._http_server = GatewayHTTPServer((self.http_host, self.http_port))
        self._http_thread = threading.Thread(target=self._http_server.serve_forever, name="http-server", daemon=True)
        self._http_thread.start()
        logging.info("http server listening on %s:%s", self.http_host, self.http_port)

    def handle_snapshot(self, body: Dict[str, Any]) -> Tuple[bool, str]:
        if body.get("type") != "MODBUS_SNAPSHOT":
            return False, "unsupported type"
        payload = body.get("payload")
        if not isinstance(payload, dict):
            return False, "payload must be an object"

        with self.state.lock:
            self.state.latest_snapshot = LatestSnapshot(raw=body, received_at_ms=now_ms())
            self._apply_snapshot_locked(payload)
            self.state.pending_publish = True

        self._publish_pending_if_needed()
        message_id = body.get("messageId", "-")
        logging.info("snapshot accepted: deviceId=%s messageId=%s", body.get("deviceId", "-"), message_id)
        return True, "accepted"

    def handle_ai_result(self, body: Dict[str, Any]) -> Tuple[bool, str]:
        if body.get("type") != "AI_DETECTIONS":
            return False, "unsupported type"
        detections = body.get("detections")
        if not isinstance(detections, list):
            return False, "detections must be an array"
        image = body.get("image")
        if image is not None and not isinstance(image, dict):
            return False, "image must be an object"

        with self.state.lock:
            self.state.latest_ai_result = LatestAiResult(raw=body, received_at_ms=now_ms())

        logging.info(
            "ai result accepted: deviceId=%s stream=%s frameId=%s detections=%s",
            body.get("deviceId", "-"),
            body.get("stream", "-"),
            body.get("frameId", "-"),
            len(detections),
        )
        return True, "accepted"

    def _apply_snapshot_locked(self, payload: Dict[str, Any]) -> None:
        slave1 = payload.get("slave1", {})
        slave2 = payload.get("slave2", {})
        slave3 = payload.get("slave3", {})

        ok1 = self._slave_is_ok(slave1)
        ok2 = self._slave_is_ok(slave2)
        ok3 = self._slave_is_ok(slave3)

        if ok1 and "lightAdc" in slave1:
            self.state.telemetry.light = int(slave1["lightAdc"])
        else:
            logging.warning("slave1 invalid or missing lightAdc: %s", slave1)

        if ok2:
            if "temperature" in slave2:
                self.state.telemetry.temp = int(slave2["temperature"])
            else:
                logging.warning("slave2 missing temperature: %s", slave2)
            if "humidity" in slave2:
                self.state.telemetry.hum = int(slave2["humidity"])
            else:
                logging.warning("slave2 missing humidity: %s", slave2)
        else:
            logging.warning("slave2 invalid: %s", slave2)

        if ok3 and "mq2Ppm" in slave3:
            self.state.telemetry.mq2 = int(slave3["mq2Ppm"])
        else:
            logging.warning("slave3 invalid or missing mq2Ppm: %s", slave3)

        self.state.telemetry.error = 0 if (ok1 and ok2 and ok3) else 1
        logging.info(
            "telemetry state updated: Temp=%s Hum=%s Light=%s MQ2=%s Error=%s",
            self.state.telemetry.temp,
            self.state.telemetry.hum,
            self.state.telemetry.light,
            self.state.telemetry.mq2,
            self.state.telemetry.error,
        )

    @staticmethod
    def _slave_is_ok(slave: Dict[str, Any]) -> bool:
        if not isinstance(slave, dict):
            return False
        online = int(slave.get("online", 0)) == 1
        valid = int(slave.get("valid", 0)) == 1
        last_error = str(slave.get("lastError", "NONE")).upper()
        return online and valid and last_error == "NONE"

    def _publish_pending_if_needed(self) -> None:
        with self.state.lock:
            if not self.state.pending_publish or not self.state.mqtt_connected:
                return
            payload = self._build_post_payload_locked()
            self.state.pending_publish = False

        result = self._mqtt_client.publish(self.topic_post, payload=payload, qos=self.publish_qos)
        logging.info("telemetry published rc=%s topic=%s payload=%s", result.rc, self.topic_post, payload)

    def _build_post_payload_locked(self) -> str:
        snapshot = self.state.latest_snapshot.raw
        message_id = snapshot.get("messageId") or snapshot.get("payload", {}).get("cycleId") or now_ms()
        params: Dict[str, Dict[str, int]] = {}
        if self.state.telemetry.temp is not None:
            params["Temp"] = {"value": self.state.telemetry.temp}
        if self.state.telemetry.hum is not None:
            params["Hum"] = {"value": self.state.telemetry.hum}
        if self.state.telemetry.light is not None:
            params["Light"] = {"value": self.state.telemetry.light}
        if self.state.telemetry.mq2 is not None:
            params["MQ2"] = {"value": self.state.telemetry.mq2}
        params["Error"] = {"value": self.state.telemetry.error}
        return json.dumps({"id": str(message_id), "params": params}, ensure_ascii=False, separators=(",", ":"))

    def check_config(self) -> None:
        logging.info(
            "config loaded: http=%s:%s broker=%s:%s device=%s video.enabled=%s",
            self.http_host,
            self.http_port,
            self.broker,
            self.broker_port,
            self.device_name,
            self.config.getboolean("video", "enabled", fallback=False),
        )


def load_config(config_path: str) -> configparser.ConfigParser:
    parser = configparser.ConfigParser(interpolation=None)
    read_files = parser.read(config_path, encoding="utf-8")
    if not read_files:
        raise FileNotFoundError(f"config file not found: {config_path}")
    for section in ("http", "onenet", "video"):
        if not parser.has_section(section):
            raise ValueError(f"missing config section: {section}")
    return parser


def setup_logging(level_name: str) -> None:
    level = getattr(logging, level_name.upper(), logging.INFO)
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)s %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="EdgeLink RK3568 gateway")
    parser.add_argument("--config", default="config/edgelink.ini", help="INI config path")
    parser.add_argument("--check-config", action="store_true", help="load the configuration and exit")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    config = load_config(args.config)
    setup_logging(config.get("log", "level", fallback="INFO"))
    app = GatewayApp(config)
    app.check_config()

    if args.check_config:
        return 0

    stop_event = threading.Event()

    def handle_signal(signum: int, frame: Any) -> None:
        logging.info("signal received: %s", signum)
        stop_event.set()

    signal.signal(signal.SIGINT, handle_signal)
    signal.signal(signal.SIGTERM, handle_signal)

    app.start()
    try:
        while not stop_event.is_set():
            time.sleep(1)
    finally:
        app.stop()
    return 0


if __name__ == "__main__":
    sys.exit(main())

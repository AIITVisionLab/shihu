from libs.PipeLine import PipeLine
from libs.AIBase import AIBase
from libs.AI2D import Ai2d
from libs.Utils import *
from libs.WBCRtsp import WBCRtsp
from media.media import *
import nncase_runtime as nn
import ulab.numpy as np
import aidemo
import gc
import os
import sys
import time
import ujson
import _thread
import network

try:
    import socket
except ImportError:
    import usocket as socket


LAN_ENABLED = True
LAN_STATIC_IP = "172.18.8.103"
LAN_NETMASK = "255.255.255.0"
LAN_GATEWAY = "172.18.8.1"
LAN_DNS = "172.18.8.1"
LAN_CONNECT_TIMEOUT_S = 8

WIFI_SSID = "A6N107"
WIFI_PASSWORD = "A6N107666#"
WIFI_CONNECT_TIMEOUT_S = 20
WIFI_CONNECT_RETRIES = 3
WIFI_RETRY_DELAY_MS = 1500

RK3568_HOST = "172.18.8.19"
RK3568_PORT = 8080
RK3568_AI_PATH = "/api/ai"
HTTP_TIMEOUT_S = 2

DEVICE_ID = "k230"
STREAM_NAME = "k230"
RTSP_PORT = 8554
RTSP_SESSION = "test"

DISPLAY_MODE = "virt"
DISPLAY_SIZE = [ALIGN_UP(1920, 16), 1080]
RGB888P_SIZE = [1280, 720]
TO_IDE = False
WIFI_CHECK_INTERVAL_FRAMES = 30
AI_POST_INTERVAL_MS = 1000

KMODEL_PATH = "/sdcard/examples/kmodel/yolo11n-obb.kmodel"
LABELS = [
    "plane",
    "ship",
    "storage tank",
    "baseball diamond",
    "tennis court",
    "basketball court",
    "ground track field",
    "harbor",
    "bridge",
    "large vehicle",
    "small vehicle",
    "helicopter",
    "roundabout",
    "soccer ball field",
    "swimming pool",
]
MODEL_INPUT_SIZE = [320, 320]
CONFIDENCE_THRESHOLD = 0.1
NMS_THRESHOLD = 0.6
MAX_BOXES_NUM = 100


def sleep_ms(ms):
    try:
        time.sleep_ms(ms)
    except AttributeError:
        time.sleep(ms / 1000.0)


def now_ms():
    try:
        current = time.time()
        if current > 100000:
            return int(current * 1000)
    except Exception:
        pass
    try:
        return time.ticks_ms()
    except Exception:
        return 0


def normalize_size(size):
    return [int(size[0]), int(size[1])]


class LanClient:
    def __init__(self):
        self.iface = None
        self._init_error = None
        self._init_iface()

    def mode(self):
        return "lan"

    def connect(self, timeout_s=LAN_CONNECT_TIMEOUT_S):
        if self.iface is None:
            raise RuntimeError("LAN interface unavailable: %s" % self._init_error)

        self._prepare()
        deadline = now_ms() + timeout_s * 1000
        while now_ms() < deadline:
            if self._is_connected():
                ip_info = self.iface.ifconfig()
                if ip_info[0] != "0.0.0.0":
                    self._print_ip("LAN connected")
                    return True
            sleep_ms(500)

        raise RuntimeError("LAN link timeout")

    def ensure_connected(self):
        if self.iface is None:
            return False
        if self._is_connected():
            try:
                if self.iface.ifconfig()[0] != "0.0.0.0":
                    return True
            except Exception:
                pass
        try:
            self.connect(timeout_s=4)
            return True
        except Exception as err:
            print("LAN reconnect failed:", err)
            return False

    def ip(self):
        if self.iface is None:
            return "0.0.0.0"
        try:
            return self.iface.ifconfig()[0]
        except Exception:
            return "0.0.0.0"

    def _init_iface(self):
        if not hasattr(network, "LAN"):
            self._init_error = "network.LAN not found"
            return

        creators = []
        creators.append(lambda: network.LAN())
        creators.append(lambda: network.LAN(0))
        for attr in ("ETH", "LAN"):
            if hasattr(network, attr):
                value = getattr(network, attr)
                creators.append(lambda value=value: network.LAN(value))

        for create in creators:
            try:
                self.iface = create()
                self._init_error = None
                return
            except Exception as err:
                self._init_error = err

    def _prepare(self):
        try:
            if hasattr(self.iface, "active"):
                self.iface.active(True)
                sleep_ms(300)
        except Exception:
            pass

        try:
            self.iface.ifconfig((LAN_STATIC_IP, LAN_NETMASK, LAN_GATEWAY, LAN_DNS))
        except Exception as err:
            print("LAN static IP apply failed:", err)

    def _is_connected(self):
        try:
            if hasattr(self.iface, "isconnected"):
                return bool(self.iface.isconnected())
        except Exception:
            pass
        try:
            return self.iface.ifconfig()[0] != "0.0.0.0"
        except Exception:
            return False

    def _print_ip(self, prefix):
        ip_info = self.iface.ifconfig()
        print(prefix)
        print("IP:", ip_info[0])
        print("Netmask:", ip_info[1])
        print("Gateway:", ip_info[2])
        print("DNS:", ip_info[3])


class WiFiStaClient:
    def __init__(self, ssid, password):
        self.ssid = ssid
        self.password = password
        self.sta = network.WLAN(network.STA_IF)

    def mode(self):
        return "wifi"

    def connect(self, timeout_s=WIFI_CONNECT_TIMEOUT_S, retries=WIFI_CONNECT_RETRIES):
        if self.sta.isconnected() and self.sta.ifconfig()[0] != "0.0.0.0":
            self._print_ip("Wi-Fi already connected")
            return True

        last_error = None
        for attempt in range(1, retries + 1):
            self._reset_interface()
            if self._scan_target():
                print("Wi-Fi target detected:", self.ssid)
            else:
                print("Wi-Fi target not seen, still trying:", self.ssid)

            print("Connecting Wi-Fi (%d/%d): %s" % (attempt, retries, self.ssid))
            try:
                self.sta.connect(self.ssid, self.password)
            except Exception as err:
                last_error = err

            deadline = now_ms() + timeout_s * 1000
            while now_ms() < deadline:
                if self.sta.isconnected():
                    ip_info = self.sta.ifconfig()
                    if ip_info[0] != "0.0.0.0":
                        self._print_ip("Wi-Fi connected")
                        return True
                sleep_ms(500)

            try:
                self.sta.disconnect()
            except Exception:
                pass

            last_error = RuntimeError("Wi-Fi connect timeout")
            if attempt < retries:
                print("Wi-Fi connect failed, retrying")
                sleep_ms(WIFI_RETRY_DELAY_MS)

        raise last_error

    def ensure_connected(self):
        if self.sta.isconnected() and self.sta.ifconfig()[0] != "0.0.0.0":
            return True
        try:
            self.connect(timeout_s=10, retries=2)
            return True
        except Exception as err:
            print("Wi-Fi reconnect failed:", err)
            return False

    def ip(self):
        try:
            return self.sta.ifconfig()[0]
        except Exception:
            return "0.0.0.0"

    def _print_ip(self, prefix):
        ip_info = self.sta.ifconfig()
        print(prefix)
        print("IP:", ip_info[0])
        print("Netmask:", ip_info[1])
        print("Gateway:", ip_info[2])
        print("DNS:", ip_info[3])

    def _reset_interface(self):
        try:
            if self.sta.isconnected():
                try:
                    self.sta.disconnect()
                except Exception:
                    pass
                sleep_ms(300)
        except Exception:
            pass

        try:
            if not self.sta.active():
                self.sta.active(True)
                sleep_ms(300)
        except Exception:
            pass

    def _scan_target(self):
        try:
            results = self.sta.scan()
        except Exception:
            return False

        for item in results:
            ssid = None
            try:
                ssid = item[0]
            except Exception:
                if hasattr(item, "ssid"):
                    ssid = item.ssid
                elif hasattr(item, "info") and hasattr(item.info, "ssid"):
                    ssid = item.info.ssid

            if ssid is None:
                continue
            if isinstance(ssid, bytes):
                try:
                    ssid = ssid.decode("utf-8")
                except Exception:
                    ssid = ssid.decode("utf-8", "ignore")
            if ssid == self.ssid:
                return True
        return False


class NetworkManager:
    def __init__(self):
        self.lan = LanClient() if LAN_ENABLED else None
        self.wifi = WiFiStaClient(WIFI_SSID, WIFI_PASSWORD)
        self.active_client = None

    def connect(self):
        if self.lan is not None:
            try:
                print("Trying LAN first")
                self.lan.connect()
                self.active_client = self.lan
                return True
            except Exception as err:
                print("LAN unavailable, fallback to Wi-Fi:", err)

        self.wifi.connect()
        self.active_client = self.wifi
        return True

    def ensure_connected(self):
        if self.active_client is not None and self.active_client.ensure_connected():
            return True
        return self.connect()

    def ip(self):
        if self.active_client is None:
            return "0.0.0.0"
        return self.active_client.ip()

    def mode(self):
        if self.active_client is None:
            return "unknown"
        return self.active_client.mode()


class AiResultPublisher:
    def __init__(self, net_client):
        self.net_client = net_client
        self._lock = _thread.allocate_lock()
        self._latest_payload = None
        self._latest_seq = 0
        self._last_sent_seq = -1
        self._running = False

    def start(self):
        if self._running:
            return
        self._running = True
        _thread.start_new_thread(self._worker, ())

    def stop(self):
        self._running = False

    def update_latest(self, payload):
        self._lock.acquire()
        try:
            self._latest_payload = payload
            self._latest_seq += 1
        finally:
            self._lock.release()

    def _worker(self):
        while self._running:
            payload = None
            seq = -1
            self._lock.acquire()
            try:
                payload = self._latest_payload
                seq = self._latest_seq
            finally:
                self._lock.release()

            if payload is not None and seq != self._last_sent_seq:
                if self.net_client.ensure_connected():
                    try:
                        self._post_json(payload)
                        self._last_sent_seq = seq
                        print(
                            "AI result posted: frameId=%s detections=%s"
                            % (payload.get("frameId", -1), len(payload.get("detections", [])))
                        )
                    except Exception as err:
                        print("AI result post failed:", err)

            sleep_ms(AI_POST_INTERVAL_MS)

    def _post_json(self, payload):
        body = ujson.dumps(payload)
        if isinstance(body, str):
            body_bytes = body.encode()
        else:
            body_bytes = body

        request = (
            "POST %s HTTP/1.1\r\n"
            "Host: %s:%d\r\n"
            "Content-Type: application/json\r\n"
            "Content-Length: %d\r\n"
            "Connection: close\r\n\r\n"
            % (RK3568_AI_PATH, RK3568_HOST, RK3568_PORT, len(body_bytes))
        ).encode() + body_bytes

        addr = socket.getaddrinfo(RK3568_HOST, RK3568_PORT)[0][-1]
        sock = socket.socket()
        try:
            try:
                sock.settimeout(HTTP_TIMEOUT_S)
            except Exception:
                pass
            sock.connect(addr)
            self._send_all(sock, request)
            status_line = self._recv_status_line(sock)
            if b" 200 " not in status_line:
                raise OSError("HTTP status invalid: %s" % status_line.decode(errors="ignore"))
        finally:
            try:
                sock.close()
            except Exception:
                pass

    @staticmethod
    def _send_all(sock, data):
        total = 0
        length = len(data)
        while total < length:
            sent = sock.send(data[total:])
            if sent <= 0:
                raise OSError("socket send failed")
            total += sent

    @staticmethod
    def _recv_status_line(sock):
        data = b""
        while b"\r\n" not in data:
            chunk = sock.recv(128)
            if not chunk:
                break
            data += chunk
        return data.split(b"\r\n", 1)[0]


class ObbDetectionApp(AIBase):
    def __init__(
        self,
        kmodel_path,
        labels,
        model_input_size,
        max_boxes_num,
        confidence_threshold=0.5,
        nms_threshold=0.2,
        rgb888p_size=[224, 224],
        display_size=[1920, 1080],
        debug_mode=0,
    ):
        super().__init__(kmodel_path, model_input_size, rgb888p_size, debug_mode)
        self.kmodel_path = kmodel_path
        self.labels = labels
        self.counts = {i: 0 for i in range(len(self.labels))}
        self.model_input_size = model_input_size
        self.confidence_threshold = confidence_threshold
        self.nms_threshold = nms_threshold
        self.max_boxes_num = max_boxes_num
        self.rgb888p_size = [rgb888p_size[0], rgb888p_size[1]]
        self.display_size = [display_size[0], display_size[1]]
        self.debug_mode = debug_mode
        self.color_four = get_colors(len(self.labels))
        self.scale = 1.0
        self.ai2d = Ai2d(debug_mode)
        self.ai2d.set_ai2d_dtype(
            nn.ai2d_format.NCHW_FMT,
            nn.ai2d_format.NCHW_FMT,
            np.uint8,
            np.uint8,
        )

    def config_preprocess(self, input_image_size=None):
        with ScopedTiming("set preprocess config", self.debug_mode > 0):
            ai2d_input_size = input_image_size if input_image_size else self.rgb888p_size
            top, bottom, left, right, self.scale = letterbox_pad_param(
                self.rgb888p_size, self.model_input_size
            )
            self.ai2d.pad([0, 0, 0, 0, top, bottom, left, right], 0, [128, 128, 128])
            self.ai2d.resize(nn.interp_method.tf_bilinear, nn.interp_mode.half_pixel)
            self.ai2d.build(
                [1, 3, ai2d_input_size[1], ai2d_input_size[0]],
                [1, 3, self.model_input_size[1], self.model_input_size[0]],
            )

    def postprocess(self, results):
        with ScopedTiming("postprocess", self.debug_mode > 0):
            new_result = results[0][0].transpose()
            return aidemo.yolo_obb_postprocess(
                new_result.copy(),
                [self.rgb888p_size[1], self.rgb888p_size[0]],
                [self.model_input_size[1], self.model_input_size[0]],
                [self.display_size[1], self.display_size[0]],
                len(self.labels),
                self.confidence_threshold,
                self.nms_threshold,
                self.max_boxes_num,
            )

    def draw_result(self, pl, dets):
        with ScopedTiming("display_draw", self.debug_mode > 0):
            pl.osd_img.clear()
            if not dets or len(dets) < 2:
                return

            quads = dets[0]
            class_ids = dets[1]
            count = min(len(quads), len(class_ids))
            for i in range(count):
                quad = [int(round(v, 0)) for v in quads[i][:8]]
                class_id = int(class_ids[i])
                color = self.color_four[class_id]
                pl.osd_img.draw_line(quad[0], quad[1], quad[2], quad[3], color=color, thickness=4)
                pl.osd_img.draw_line(quad[2], quad[3], quad[4], quad[5], color=color, thickness=4)
                pl.osd_img.draw_line(quad[4], quad[5], quad[6], quad[7], color=color, thickness=4)
                pl.osd_img.draw_line(quad[6], quad[7], quad[0], quad[1], color=color, thickness=4)
                pl.osd_img.draw_string_advanced(
                    quad[0],
                    quad[1],
                    24,
                    self.labels[class_id],
                    color=color,
                )
                self.counts[class_id] += 1

            summary = ""
            for class_id in range(len(self.labels)):
                if self.counts[class_id] != 0:
                    summary += self.labels[class_id] + ": " + str(self.counts[class_id]) + ";  "
                    self.counts[class_id] = 0
            if summary:
                pl.osd_img.draw_string_advanced(50, 50, 24, summary, color=[0, 255, 0])

    def build_ai_payload(self, dets, frame_id):
        detections = []
        if dets and len(dets) >= 2:
            quads = dets[0]
            class_ids = dets[1]
            confidences = dets[2] if len(dets) > 2 else None
            count = min(len(quads), len(class_ids))
            for i in range(count):
                quad = [int(round(v, 0)) for v in quads[i][:8]]
                xs = [quad[0], quad[2], quad[4], quad[6]]
                ys = [quad[1], quad[3], quad[5], quad[7]]
                class_id = int(class_ids[i])
                item = {
                    "classId": class_id,
                    "className": self.labels[class_id],
                    "quad": quad,
                    "bbox": [
                        min(xs),
                        min(ys),
                        max(xs) - min(xs),
                        max(ys) - min(ys),
                    ],
                }
                if confidences is not None and i < len(confidences):
                    try:
                        item["confidence"] = round(float(confidences[i]), 4)
                    except Exception:
                        pass
                detections.append(item)

        return {
            "type": "AI_DETECTIONS",
            "deviceId": DEVICE_ID,
            "stream": STREAM_NAME,
            "timestampMs": now_ms(),
            "frameId": frame_id,
            "image": {
                "width": self.display_size[0],
                "height": self.display_size[1],
            },
            "detections": detections,
        }


def print_banner():
    print("========================================")
    print("K230 LAN/Wi-Fi + RTSP + AI JSON gateway")
    print("LAN preferred:", LAN_ENABLED)
    print("LAN static IP:", LAN_STATIC_IP)
    print("Wi-Fi SSID:", WIFI_SSID)
    print("RK3568 AI endpoint: http://%s:%d%s" % (RK3568_HOST, RK3568_PORT, RK3568_AI_PATH))
    print("Display mode:", DISPLAY_MODE)
    print("========================================")


def main():
    os.exitpoint(os.EXITPOINT_ENABLE)
    print_banner()

    net_client = NetworkManager()
    publisher = AiResultPublisher(net_client)
    pl = None
    detector = None
    frame_id = 0

    net_client.connect()

    try:
        requested_display_size = normalize_size(DISPLAY_SIZE)
        print("Requested display size:", requested_display_size)

        WBCRtsp.configure(
            wbc_width=requested_display_size[0], wbc_height=requested_display_size[1]
        )

        pl = PipeLine(
            rgb888p_size=RGB888P_SIZE,
            display_mode=DISPLAY_MODE,
            display_size=DISPLAY_SIZE,
        )
        pl.create(to_ide=TO_IDE)
        actual_display_size = normalize_size(pl.get_display_size())
        print("Actual display size:", actual_display_size)
        if actual_display_size != requested_display_size:
            raise RuntimeError(
                "Display.VIRT size mismatch: requested=%s actual=%s"
                % (requested_display_size, actual_display_size)
            )

        WBCRtsp.start()
        print("Active network mode:", net_client.mode())
        print("RTSP endpoint: rtsp://%s:%d/%s" % (net_client.ip(), RTSP_PORT, RTSP_SESSION))

        detector = ObbDetectionApp(
            KMODEL_PATH,
            labels=LABELS,
            model_input_size=MODEL_INPUT_SIZE,
            max_boxes_num=MAX_BOXES_NUM,
            confidence_threshold=CONFIDENCE_THRESHOLD,
            nms_threshold=NMS_THRESHOLD,
            rgb888p_size=RGB888P_SIZE,
            display_size=actual_display_size,
            debug_mode=0,
        )
        detector.config_preprocess()
        publisher.start()

        while True:
            with ScopedTiming("total", 1):
                os.exitpoint()
                img = pl.get_frame()
                res = detector.run(img)
                detector.draw_result(pl, res)
                pl.show_image()
                publisher.update_latest(detector.build_ai_payload(res, frame_id))
                frame_id += 1

                if frame_id % WIFI_CHECK_INTERVAL_FRAMES == 0:
                    net_client.ensure_connected()

                gc.collect()
    except KeyboardInterrupt as err:
        print("Stopped by user:", err)
    except BaseException as err:
        sys.print_exception(err)
    finally:
        publisher.stop()
        if detector is not None:
            detector.deinit()
        try:
            WBCRtsp.stop()
        except Exception:
            pass
        if pl is not None:
            pl.destroy()
        gc.collect()


if __name__ == "__main__":
    main()

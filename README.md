# K230 RTSP AI Gateway

该目录存放 `K230` 端单文件脚本，用于把端侧视觉能力接入当前石斛平台链路。

当前实现的职责有三项：
- `K230 -> RK3568/go2rtc`：输出 `RTSP(H264)` 视频流
- `K230 -> RK3568 /api/ai`：上送逐帧 `AI JSON`
- 本地执行 `YOLO11 OBB` 推理，并把检测框叠加到 RTSP 画面

## 当前网络方案

当前脚本采用“有线优先，Wi-Fi 兜底”的接入策略：
- 优先尝试 `USB-RJ45` 有线网卡
- 有线成功时固定使用 `172.18.8.103/24`
- RK3568 默认目标地址固定为 `172.18.8.19`
- 若有线不可用，再回退到 `WIFI_SSID/WIFI_PASSWORD` 指定的 Wi-Fi
- 无论当前走有线还是 Wi-Fi，K230 只负责持续输出 `RTSP` 和 `POST /api/ai`
- RK3568 会根据 `/api/ai` 的来源地址自动更新 `go2rtc` 的 `streams.k230`，然后重启 `go2rtc`
- 因此 K230 不需要在有线和 Wi-Fi 之间切换时手动修改 RK3568 配置

默认网络参数：
- `LAN_STATIC_IP = 172.18.8.103`
- `LAN_NETMASK = 255.255.255.0`
- `LAN_GATEWAY = 172.18.8.1`
- `LAN_DNS = 172.18.8.1`
- `RK3568_HOST = 172.18.8.19`
- `RK3568_AI_PATH = /api/ai`

## 运行链路

```text
K230 --RTSP(H264)--> RK3568 go2rtc --WebRTC/MSE--> 浏览器
  \
   +--HTTP POST /api/ai--> RK3568 edgelink-gateway
```

当 K230 的活动接口变化时，链路实际行为如下：
- K230 有线在线时，`/api/ai` 来源地址通常为 `172.18.8.103`
- K230 回退到 Wi-Fi 时，`/api/ai` 来源地址会变成 Wi-Fi 网段地址，例如 `192.168.1.103`
- RK3568 收到连续稳定的来源地址后，会自动把 `go2rtc` 源流切换到对应的 `rtsp://<来源IP>:8554/test`
- 浏览器和 Java 协作者继续使用原有播放入口，不需要感知底层源地址切换

RTSP 访问地址固定格式：
```text
rtsp://<K230_IP>:8554/test
```

## 主要配置项

脚本顶部需要按现场修改的常量：
- `LAN_ENABLED`
- `LAN_STATIC_IP`
- `LAN_NETMASK`
- `LAN_GATEWAY`
- `LAN_DNS`
- `WIFI_SSID`
- `WIFI_PASSWORD`
- `RK3568_HOST`
- `KMODEL_PATH`
- `LABELS`

## AI JSON 结构

K230 上送到 RK3568 的 JSON 保持当前网关既有格式：

```json
{
  "type": "AI_DETECTIONS",
  "deviceId": "k230",
  "stream": "k230",
  "timestampMs": 1710000000123,
  "frameId": 12,
  "image": {
    "width": 1920,
    "height": 1080
  },
  "detections": [
    {
      "classId": 0,
      "className": "plane",
      "quad": [100, 100, 200, 100, 200, 180, 100, 180],
      "bbox": [100, 100, 100, 80]
    }
  ]
}
```

说明：
- `detections` 表示当前帧全部检测目标
- `quad` 为 OBB 四点坐标
- `bbox` 为轴对齐外接框
- 当前帧无目标时，仍会上送空数组 `[]`
- `confidence` 只有在运行时拿到时才附带

## 运行步骤

1. 将 `k230_rtsp_ai_gateway.py` 放到 K230 的运行目录
2. 确认模型文件存在：`/sdcard/examples/kmodel/yolo11n-obb.kmodel`
3. 连接 USB-RJ45 到 `172.18.8.x` 局域网
4. 运行脚本，观察启动日志中的网络模式与 RTSP 地址
5. 在 RK3568 上确认：
   - `go2rtc` 已拉取 `rtsp://172.18.8.103:8554/test`
   - `/api/ai` 能持续收到数据

## 排障优先级

1. 先确认 K230 当前使用的是 `lan` 还是 `wifi`
2. 再确认 RTSP 地址是否与 RK3568 `go2rtc.yaml` 一致
3. 再确认 `POST /api/ai` 来源地址是否与当前活动接口一致
4. 最后再看公网 `go2rtc + frp` 是否正常

## 与 RK3568 的自动联动

RK3568 当前已经实现了基于 `/api/ai` 来源地址的自动切换逻辑：
- 只对 `deviceId == "k230"` 的 AI 请求生效
- 同一候选来源地址需要连续命中多次后才触发切换
- 切换后会自动重启 `go2rtc`，更新 `streams.k230`
- 如果 `go2rtc` 重启失败，RK3568 会在 `/healthz` 中暴露切换失败状态

这意味着 K230 侧只要满足两件事即可：
- RTSP 一直输出到 `rtsp://<当前活动IP>:8554/test`
- `/api/ai` 一直发到 `http://172.18.8.19:8080/api/ai`

其余的源地址同步由 RK3568 完成。

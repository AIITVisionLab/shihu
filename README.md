# K230 RTSP AI Gateway

该目录存放 `K230` 端单文件脚本，用于把端侧视觉能力接入当前石斛平台链路。

当前实现的职责有三项：
- `K230 -> RK3568/go2rtc`：输出 `RTSP(H264)` 视频流
- `K230 -> RK3568 /api/ai`：上送逐帧 `AI JSON`
- 本地执行 `YOLO11 OBB` 推理，并把检测框叠加到 RTSP 画面

## 当前网络方案

当前脚本默认采用“Wi-Fi 单路径”策略：
- 当前默认运行只使用 `WIFI_SSID/WIFI_PASSWORD` 指定的 Wi-Fi
- K230 当前 Wi-Fi 地址建议固定为 `192.168.1.103`
- RK3568 Wi-Fi 目标地址固定为 `192.168.1.111`
- K230 只负责持续输出 `RTSP` 和 `POST /api/ai`
- RK3568 初始从 `rtsp://192.168.1.103:8554/test` 拉流，并可在 `192.168.1.0/24` 网段内自动更新 `go2rtc`

默认网络参数：
- `WIFI_SSID = A6N107`
- `RK3568_HOST = 192.168.1.111`
- `RK3568_AI_PATH = /api/ai`

## 运行链路

```text
K230 --RTSP(H264)--> RK3568 go2rtc --WebRTC/MSE--> 浏览器
  \
   +--HTTP POST /api/ai--> RK3568 edgelink-gateway
```

当前链路固定行为如下：
- K230 当前通过 Wi-Fi 接入
- `/api/ai` 来源地址通常为 `192.168.1.103`
- RK3568 初始把 `go2rtc` 源流保持为 `rtsp://192.168.1.103:8554/test`
- 浏览器和 Java 协作者继续使用原有播放入口，不需要感知底层源地址变化

RTSP 访问地址固定格式：
```text
rtsp://<K230_IP>:8554/test
```

## 主要配置项

脚本顶部需要按现场修改的常量：
- `LAN_ENABLED`
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
3. 确认 K230 能连上目标 Wi-Fi
4. 运行脚本，观察启动日志中是否拿到预期 Wi-Fi 地址
6. 在 RK3568 上确认：
   - `go2rtc` 已拉取 `rtsp://192.168.1.103:8554/test`
   - `/api/ai` 能持续收到数据

## 排障优先级

1. 先确认 K230 是否拿到了预期 Wi-Fi 地址
2. 再确认 RTSP 地址是否为 `rtsp://192.168.1.103:8554/test`
3. 再确认 `POST /api/ai` 来源地址是否为 `192.168.1.103`
4. 最后再看公网 `go2rtc + frp` 是否正常

## 与 RK3568 的当前对接

RK3568 当前已回退为 Wi-Fi 对接：
- `streams.k230` 初始为 `rtsp://192.168.1.103:8554/test`
- `video_source_switch.enabled = true`
- `allowed_source_cidrs = 192.168.1.0/24`
- `/api/ai` 继续用于 AI 结果接收与转发，并参与源地址切换

这意味着 K230 侧只要满足两件事即可：
- RTSP 一直输出到 `rtsp://<当前Wi-Fi-IP>:8554/test`
- `/api/ai` 一直发到 `http://192.168.1.111:8080/api/ai`

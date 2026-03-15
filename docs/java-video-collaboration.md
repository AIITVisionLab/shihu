# Java 后端与前端视频协作说明

## 当前已打通链路

当前边缘侧已稳定运行以下链路：
- `K230 -> RK3568 go2rtc -> 浏览器`
- `K230 -> RK3568 /api/ai`
- `STM32F429 -> RK3568 -> OneNET`

需要明确：
- K230 的 AI JSON 先到 RK3568 `/api/ai`
- RK3568 可按配置继续转发 AI 到 Java 后端
- 当前临时回退为 Wi-Fi 路径，初始源地址为 `rtsp://192.168.1.103:8554/test`，前端播放入口不变

## 职责边界

- RK3568：负责视频网关、`go2rtc` 播放入口、AI 结果接收
- Java 后端：负责业务元数据接口，不代理媒体流
- 前端：根据 Java 后端下发的 `playerUrl` 直接访问 `go2rtc/frp`

明确约束：
- Java 后端不代理 `8555` 的 WebRTC 媒体流
- 前端不需要感知 K230 的局域网地址，只使用固定播放入口

## Java 后端建议暴露的最小接口

### 查询全部视频流
- `GET /api/video/streams`

建议返回示例：

```json
{
  "code": 0,
  "msg": "ok",
  "data": [
    {
      "streamId": "k230",
      "deviceId": "k230",
      "displayName": "K230 实时视频流",
      "gatewayPageUrl": "http://101.35.79.76:1984/",
      "playerUrl": "http://101.35.79.76:1984/stream.html?src=k230&mode=webrtc,mse",
      "preferredMode": "webrtc",
      "fallbackMode": "mse",
      "publicHost": "101.35.79.76",
      "webrtcPort": 8555,
      "available": true,
      "aiResultForwarded": true
    }
  ]
}
```

### 查询单路视频流
- `GET /api/video/streams/{streamId}`

当前 `streamId` 固定为：`k230`

## 前端接入方式

前端固定按以下方式接入：
1. 调用 Java 后端的视频流信息接口
2. 读取 `playerUrl`
3. 直接打开或嵌入该地址

当前推荐播放地址：
- `http://101.35.79.76:1984/stream.html?src=k230&mode=webrtc,mse`

调试入口：
- `http://101.35.79.76:1984/`
- `http://101.35.79.76:1984/api/streams`

前端使用原则：
- 优先 `WebRTC`
- 浏览器或网络不稳时回退 `MSE`
- 不通过 Java 业务服务中转视频字节流

## 关于 K230 当前 Wi-Fi 路径

当前视频链路临时回退为 Wi-Fi 路径：
- K230 当前 Wi-Fi 地址：`192.168.1.103`
- RK3568 初始从 `rtsp://192.168.1.103:8554/test` 拉流
- `video_source_switch` 已重新打开，并只接受 `192.168.1.0/24` 来源地址
- 对 Java 后端和前端来说，播放入口保持不变
- Java 后端不应缓存或暴露 K230 的局域网 RTSP 地址

## 当前 AI 与 Java 协作

RK3568 当前支持：
- 接收 `POST /api/ai`
- 根据配置将非空检测结果转发到 Java 后端

当前推荐 Java AI 接口：
- `POST /api/edge/ai-detections`
- 地址：`http://101.35.79.76:19081/api/edge/ai-detections`

前端本轮不直接消费 AI JSON；如需展示 AI 结果，由 Java 后端自行存储并定义查询接口。

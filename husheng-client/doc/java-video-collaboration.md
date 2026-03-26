# Java 后端与前端视频协作说明

## 1. 当前已打通的链路

当前边缘侧已经稳定运行以下链路：

- `K230 -> RK3568 go2rtc -> 浏览器`
- `K230 -> RK3568 /api/ai`
- `STM32F429 -> RK3568 -> OneNET`

需要特别说明的一点：

- `K230` 的 AI 检测结果 JSON 先发送到 RK3568 的 `POST /api/ai`
- RK3568 会在网关进程内存中保存 `latest_ai_result`，并写入运行日志
- RK3568 已支持可配置的 AI 上送能力，但默认配置模板建议 `ai_forward.enabled = false`
- 如果现场把 `ai_forward.enabled` 改成 `true`，RK3568 才会把非空检测结果继续转发到 Java 后端

## 2. 职责边界

- RK3568：负责视频网关、go2rtc 播放入口、边缘 AI 结果接收
- Java 后端：负责业务接口、设备信息管理、向前端下发视频访问入口；后续按需接收 AI 结果
- 前端：根据 Java 后端下发的 URL 直接访问 `go2rtc/frp` 公网入口

明确约束：

- Java 后端不代理 WebRTC 媒体流
- Java 后端不承担 `8555` 端口的媒体转发
- 前端播放视频时，媒体链路直接走 `go2rtc/frp`

## 3. Java 后端建议暴露的最小接口

### 3.1 查询全部视频流

建议接口：

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
      "aiResultForwarded": false
    }
  ]
}
```

### 3.2 查询单路视频流

建议接口：

- `GET /api/video/streams/{streamId}`

当前 `streamId` 固定可先使用：

- `k230`

## 4. 前端接入方式

前端接入方式固定如下：

1. 先调用 Java 后端的流信息接口
2. 读取 `playerUrl`
3. 直接在浏览器中打开或嵌入该地址

当前推荐播放地址：

- `http://101.35.79.76:1984/stream.html?src=k230&mode=webrtc,mse`

调试辅助入口：

- `http://101.35.79.76:1984/`
- `http://101.35.79.76:1984/api/streams`

前端使用原则：

- 优先使用 `WebRTC`
- 如果浏览器环境或网络质量不稳定，则回退使用 `MSE`
- 前端不要通过 Java 业务服务中转视频字节流

## 5. 当前 AI 现状与 Java 协作

### 5.1 当前现状

当前 RK3568 已实现：

- `POST /api/ai`
- 接收 `K230` 发送的 `AI_DETECTIONS` JSON
- 保存 `latest_ai_result`
- 按配置决定是否继续上送到 Java 后端

当前推荐配置口径：

- 模板默认建议 `ai_forward.enabled = false`
- 只有在填写真实 Java 目标地址并显式启用后，RK3568 才会把非空检测结果继续转发出去

### 5.2 Java 后端接收接口

Java 后端建议实现：

- `POST /api/edge/ai-detections`

当前推荐目标地址：

- `http://101.35.79.76:19081/api/edge/ai-detections`

协议约定：

- `Content-Type: application/json`
- RK3568 原样透传 `AI_DETECTIONS`
- RK3568 按 HTTP `2xx` 视为成功
- 建议响应：`{"code":0,"msg":"accepted"}`

详细接口说明参见：

- `docs/java-ai-collaboration.md`

### 5.3 前端范围说明

这一轮不定义前端 AI 查询接口。

也就是说：

- 前端当前继续只通过视频 URL 看视频
- Java 后端如需展示 AI 结果，应先自行接收、存储，再定义自己的查询接口或推送接口
- 当前前端不直接从 RK3568 拉取 AI JSON

## 6. 协作注意事项

当前正式公网视频入口：

- 页面：`http://101.35.79.76:1984/`
- 播放页：`http://101.35.79.76:1984/stream.html?src=k230&mode=webrtc,mse`
- WebRTC 媒体端口：`101.35.79.76:8555`

协作时必须遵守以下约束：

- Java 后端不要尝试代理 `8555` 的 WebRTC 媒体流
- 如果后续要统一域名，应优先由 `Nginx` 或网关层处理，而不是让 Spring Boot 直接承接媒体代理
- 当前视频链路与 `F429 -> RK3568 -> OneNET` 链路相互独立，不要在业务实现上把二者耦合
- 当前若前端需要播放视频，只需要依赖 Java 后端下发 `playerUrl`，不需要感知 K230 的内网 RTSP 地址

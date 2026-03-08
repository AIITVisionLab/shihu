# EdgeLink_RK3568 架构说明

## 目标

- 阶段 1：接收 STM32F429 的 `MODBUS_SNAPSHOT` 并上报到 OneNET
- 阶段 2：拉取 K230 的 RTSP(H264) 主码流，并由 RK3568 提供 WebRTC/MSE/HLS
- 数据链路和视频链路保持解耦，互不影响

## 双链路结构

```text
STM32F429 --HTTP POST /api/uplink--> RK3568 EdgeLink --MQTT--> OneNET

K230 --RTSP(H264)--> RK3568 go2rtc --WebRTC/MSE/HLS--> 浏览器
                                  \
                                   +--frpc--> 腾讯云 frps --> 公网
```

## 阶段 1 字段映射

- `Temp` <- `payload.slave2.temperature`
- `Hum` <- `payload.slave2.humidity`
- `Light` <- `payload.slave1.lightAdc`
- `MQ2` <- `payload.slave3.mq2Ppm`
- `Error` <- 任一从站离线、无效或 `lastError != NONE` 时置为 `1`

## 阶段 2 原则

- RK3568 只负责拉流和协议转换，不负责云端转码
- 腾讯云只运行 `frps`，不做媒体处理
- 阶段 2 v1 不做录像、不做音频转码、不做多路摄像头调度
- 如果需求继续增长，再从 `go2rtc` 升级到 `ZLMediaKit`

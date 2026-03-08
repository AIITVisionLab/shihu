# EdgeLink_RK3568 测试计划

## 阶段 1：OneNET 网关

### 1. 配置检查

```bash
python3 src/edgelink_gateway.py --config config/edgelink.ini --check-config
```

### 2. HTTP 自测

```bash
curl -sS -X POST http://127.0.0.1:8080/api/uplink \
  -H 'Content-Type: application/json' \
  -d '{
    "deviceId":"stm32f4",
    "messageId":1,
    "ts":123456,
    "type":"MODBUS_SNAPSHOT",
    "payload":{
      "cycleId":12,
      "slave1":{"online":1,"valid":1,"lastError":"NONE","lastUpdateMs":1234,"lightAdc":1024},
      "slave2":{"online":1,"valid":1,"lastError":"NONE","lastUpdateMs":1234,"temperature":26,"humidity":61},
      "slave3":{"online":1,"valid":1,"lastError":"NONE","lastUpdateMs":1234,"mq2Ppm":350}
    }
  }'
```

预期：

- 返回 `{"code":0,"msg":"accepted"}`
- 日志打印 `Temp/Hum/Light/MQ2/Error` 的映射结果
- MQTT 在线时立即上报到 OneNET

## 阶段 2：K230 视频流 v1

### 1. 本地拉流验证

```bash
./scripts/install_video_runtime.sh
./scripts/run_go2rtc.sh
```

预期：

- go2rtc 正常启动
- `http://RK3568_IP:1984/` 可访问
- `k230` 流可以在本地播放

### 2. frp 公网映射验证

```bash
./scripts/run_frpc.sh
```

预期：

- frpc 成功连接腾讯云 frps
- 公网可以访问映射后的 `1984/tcp`
- 浏览器可通过 `8555/tcp+udp` 建立 WebRTC

### 3. 退化场景

- K230 RTSP 掉流：go2rtc 日志能明确报拉流失败
- UDP 不通：回退到 MSE/HLS
- 重启 `go2rtc` 或 `frpc`：不影响 `edgelink-gateway`

### 4. 前提条件

- K230 主码流必须为 `H264`
- 如果音频与浏览器不兼容，先关闭音频，只验证视频链路

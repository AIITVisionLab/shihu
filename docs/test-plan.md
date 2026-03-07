# 一期测试计划

## 1. 配置检查

```bash
python3 src/edgelink_gateway.py --config config/edgelink.ini --check-config
```

## 2. HTTP ingest 自测

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
- 日志打印最新 `Temp/Hum/Light/MQ2/Error` 映射
- MQTT 在线时会立即上报到 OneNET

## 3. property/set 自测

- 在 OneNET 平台下发 `Brightness` 或 `Led`
- 预期日志能看到原始 `property/set`
- 预期 `set_reply` 返回 `code=-2,msg=not implemented`

## 4. 断网回归

- MQTT 断开后继续发 HTTP POST
- 预期 HTTP 入口仍返回 `200`
- 网络恢复后只补发最新一条快照

## 5. 视频 TODO 验证

- 服务启动时不会打开任何 RTMP/视频端口
- `[video]` 仅作为配置占位存在

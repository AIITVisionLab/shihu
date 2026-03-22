# HTTP 上报格式

## 事件类型

- `MODBUS_SNAPSHOT`

## 外层结构

```json
{
  "deviceId": "stm32f4",
  "messageId": 1,
  "ts": 123456,
  "type": "MODBUS_SNAPSHOT",
  "payload": {}
}
```

## payload 结构

```json
{
  "cycleId": 12,
  "slave1": {
    "online": 1,
    "valid": 1,
    "lastError": "NONE",
    "lastUpdateMs": 1234,
    "lightAdc": 1024
  },
  "slave2": {
    "online": 1,
    "valid": 1,
    "lastError": "NONE",
    "lastUpdateMs": 1234,
    "temperature": 26,
    "humidity": 61
  },
  "slave3": {
    "online": 0,
    "valid": 1,
    "lastError": "TIMEOUT",
    "lastUpdateMs": 1220,
    "mq2Ppm": 350
  },
  "slave4": {
    "online": 1,
    "valid": 1,
    "lastError": "NONE",
    "lastUpdateMs": 1234,
    "homed": 1,
    "busy": 0,
    "pumpOn": 1,
    "statusWord": 5,
    "faultWord": 0,
    "pumpState": 1,
    "stepperState": "IDLE",
    "positionPulse": 3200,
    "lastCommandSeq": 7,
    "lastCommandResult": "DONE",
    "lastCommandResultCode": 3
  }
}
```

## HTTP 响应扩展

RK3568 会在 `POST /api/uplink` 的成功响应中按需附带待执行命令：

```json
{
  "code": 0,
  "msg": "accepted",
  "pendingCommand": {
    "seq": 7,
    "code": 2,
    "arg1": 3200,
    "arg2": 1200,
    "arg3": 0
  }
}
```

没有待执行命令时仅返回：

```json
{
  "code": 0,
  "msg": "accepted"
}
```

## 队列策略

- 同类型 `MODBUS_SNAPSHOT` 若已有待发消息，新的快照会直接覆盖旧快照。
- 正在发送中的那一条不会被覆盖；新的快照会替换其后的待发快照。

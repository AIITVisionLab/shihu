# EdgeLink_RK3568 一期架构

## 目标

- 接收 STM32F429 的 `MODBUS_SNAPSHOT`。
- 映射到 `09-1` 已验证的 OneNET 物模型字段：`Temp/Hum/Light/MQ2/Error`。
- 订阅 `property/post/reply` 与 `property/set`。
- 为未来的 `RK3568 -> F429 -> PLC` 控制链路预留空执行器。
- K230/视频链路仅保留 TODO。

## 数据流

```text
STM32F429 --HTTP POST /api/uplink--> RK3568 EdgeLink --MQTT--> OneNET
                                                     \
                                                      --TODO--> K230/云视频链路
```

## 上报映射

- `Temp` <- `payload.slave2.temperature`
- `Hum` <- `payload.slave2.humidity`
- `Light` <- `payload.slave1.lightAdc`
- `MQ2` <- `payload.slave3.mq2Ppm`
- `Error` <- 只要任一从站 `online!=1`、`valid!=1` 或 `lastError!=NONE` 就置 `1`

## 下行预留

- 订阅 `property/set`
- 解析 `id` 与 `params`
- 兼容 `Brightness` 与 `Led`
- 当前统一回复 `{"id":"...","code":-2,"msg":"not implemented"}`
- 将来只需要替换 `SouthboundDispatcher`，不改 MQTT 层

## 视频 TODO

- `config/edgelink.ini` 已预留 `[video]` 段
- 本期不安装 `nginx-rtmp`
- 本期不实现 K230 接流和云端转推

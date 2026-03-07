# 系统架构

## 任务划分

- `Task_Modbus`
  - 轮询 3 个从站。
  - 调用 `middleware/Modbus-RTU` 完成事务。
  - 更新 `app_data` 快照。
  - 生成 `MODBUS_SNAPSHOT` JSON 并入队。
- `Task_Uplink`
  - 周期调用 `uplink_poll()`。
  - 通过 LwIP netconn 发送 HTTP POST。

## 分层

- `mcu/bsp/rs485`
  - 管理 `USART2`、`PB8(DE/RE)`、`TIM6`。
  - ISR 只做收字节、发字节、T3.5 到期通知。
- `mcu/middleware/Modbus-RTU`
  - `modbus_crc`：CRC16
  - `modbus_rtu_link`：帧缓存、CRC 校验、任务通知
  - `modbus_protocol`：响应解析
  - `modbus_master`：事务、超时、重试
  - `modbus_timebase`：RTOS 时间基准
- `mcu/app`
  - `app_data`：共享采集快照
  - `task_modbus_master`：轮询策略
  - `task_uplink`：上报调度

## 设计原则

- 总线上固定只保留一个未完成请求。
- 协议状态机不放到中断里执行。
- 单从站异常只影响该从站状态，不阻塞其他从站。

# 17-competition

STM32F429 Modbus-RTU 采集网关工程。

## 项目目标

- STM32F429 作为 Modbus-RTU 主站。
- 3 个 STM32F103 作为 Modbus-RTU 从站。
- F429 通过以太网直连 RK3568，把采集快照通过 HTTP 上报到边缘网关。
- RK3568 的另一个网口或其他上行口负责转发到外部网络。

## 当前功能

- FreeRTOS 任务模型。
- LwIP `NO_SYS=0 + netconn` 网络栈。
- RS485 驱动：`USART2 + PB8(DE/RE) + TIM6 T3.5`。
- Modbus-RTU 主站事务：超时、重试、CRC 校验、异常响应处理。
- 3 从站固定轮询：
  - 从站1：`40001`
  - 从站2：`40011`、`40012`
  - 从站3：`40021`
- HTTP 上报类型：`MODBUS_SNAPSHOT`。
- 上报队列采用“最新快照覆盖旧快照”的策略，避免积压过期数据。

## 目录说明

- `mcu/app/app_data`：采集快照共享数据。
- `mcu/app/task_modbus_master`：主站轮询任务。
- `mcu/app/task_uplink`：HTTP 上报调度任务。
- `mcu/bsp/rs485`：RS485 硬件驱动。
- `mcu/middleware/Modbus-RTU`：Modbus-RTU 协议栈。
- `mcu/middleware/LwIP`：LwIP 网络协议栈。
- `docs/`：项目文档。

## 默认网络配置

- F429：`172.18.8.240/24`
- RK3568 直连接口：`172.18.8.18/24`
- F429 默认网关：`172.18.8.18`
- HTTP 目标：`172.18.8.18:8080/api/uplink`

## 文档

- `docs/overview.md`
- `docs/architecture.md`
- `docs/modbus-register-map.md`
- `docs/network-plan.md`
- `docs/uplink-format.md`
- `docs/build-and-flash.md`


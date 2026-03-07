# 项目概览

`17-competition` 当前定位为 STM32F429 Modbus-RTU 采集网关。

## 目标

- F429 主站轮询 3 个 F103 从站。
- 采集结果在 F429 内部整理成统一快照。
- 快照通过 HTTP 上传到 RK3568。
- RK3568 负责继续向外部网络转发。

## 已移除内容

- 旧 `server/`
- 旧 `docs/`
- RC522 相关代码
- LCD / Touch / LVGL
- RFID / 鉴权 / 门锁旧业务

## 保留内容

- FreeRTOS
- ETH + LwIP
- uplink HTTP 队列
- 调试串口和基础 LED

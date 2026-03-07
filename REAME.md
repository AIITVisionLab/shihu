# EdgeLink_RK3568

RK3568 边缘网关一期实现，当前只解决 `STM32F429 -> RK3568 -> OneNET` 数据上报，并预留 OneNET 下行订阅入口。

## 目录

```text
config/    运行配置
src/       网关主程序
systemd/   systemd 单元文件
scripts/   安装依赖与启动脚本
docs/      一期架构与测试说明
```

## 当前能力

- 接收 F429 的 `POST /api/uplink`
- 兼容 `17-competition` 当前 `MODBUS_SNAPSHOT`
- 映射到 `09-1` 的 OneNET 字段：`Temp/Hum/Light/MQ2/Error`
- 订阅 `thing/property/post/reply`
- 订阅 `thing/property/set`
- 下行统一回复 `not implemented`
- 视频链路仅保留 TODO

## OneNET 约定

- `client_id = device_name`
- `username = product_id`
- `password = token`
- `broker = uCq21dfshX.mqtts.acc.cmcconenet.cn:1883`

## 运行方式

1. 安装依赖：`./scripts/install_deps.sh`
2. 检查配置：`python3 src/edgelink_gateway.py --config config/edgelink.ini --check-config`
3. 前台运行：`./scripts/run_gateway.sh`
4. 作为服务运行：
   - `sudo cp systemd/edgelink-gateway.service /etc/systemd/system/`
   - `sudo systemctl daemon-reload`
   - `sudo systemctl enable --now edgelink-gateway`

## HTTP 入口

- 路径：`POST /api/uplink`
- 成功返回：`{"code":0,"msg":"accepted"}`
- 健康检查：`GET /healthz`

## TODO

- K230 视频接入
- 云服务器 RTMP 链路
- `RK3568 -> F429 -> PLC` 南向控制执行器

# EdgeLink_RK3568

当前 `EdgeLink_RK3568` 分为两条彼此独立的链路：

- 阶段 1：`STM32F429 -> RK3568 -> OneNET`
- 阶段 2：`K230 RTSP(H264) -> RK3568/go2rtc -> WebRTC/MSE/HLS -> 浏览器`

## 目录结构

```text
config/    OneNET、go2rtc、frp 运行配置
src/       阶段 1 的 Python 网关主程序
systemd/   systemd 单元文件
scripts/   安装与前台运行脚本
docs/      架构与测试文档
```

## 阶段 1：OneNET 数据桥接

- 接收 F429 的 `POST /api/uplink`
- 兼容 `17-competition` 当前 `MODBUS_SNAPSHOT`
- 映射到 OneNET 字段：`Temp/Hum/Light/MQ2/Error`
- 订阅 `thing/property/post/reply`
- 订阅 `thing/property/set`
- 当前下行统一回复 `not implemented`

## 阶段 2：K230 视频流 v1

- RK3568 使用 `go2rtc` 主动拉取 K230 的 H264 RTSP 主码流
- RK3568 对外提供 `WebRTC/MSE/HLS`
- 使用 `frpc` 把播放端口映射到腾讯云 `frps`
- 腾讯云只做端口转发，不做媒体转码

## 阶段 1 运行方式

1. 安装依赖：`./scripts/install_deps.sh`
2. 检查配置：`python3 src/edgelink_gateway.py --config config/edgelink.ini --check-config`
3. 前台运行：`./scripts/run_gateway.sh`
4. 作为服务运行：
   - `sudo cp systemd/edgelink-gateway.service /etc/systemd/system/`
   - `sudo systemctl daemon-reload`
   - `sudo systemctl enable --now edgelink-gateway`

## 阶段 2 运行方式

1. 填写 `config/go2rtc.yaml`
2. 填写 `config/frpc.toml`
3. 在腾讯云部署 `frps`，参考 `config/frps.toml.example`
4. 安装视频运行时：`./scripts/install_video_runtime.sh`
5. 前台调试：
   - `./scripts/run_go2rtc.sh`
   - `./scripts/run_frpc.sh`
6. 作为服务运行：
   - `sudo cp systemd/go2rtc.service /etc/systemd/system/`
   - `sudo cp systemd/frpc.service /etc/systemd/system/`
   - `sudo systemctl daemon-reload`
   - `sudo systemctl enable --now go2rtc frpc`

## 阶段 1 HTTP 入口

- 路径：`POST /api/uplink`
- 成功返回：`{"code":0,"msg":"accepted"}`
- 健康检查：`GET /healthz`

## 阶段 2 视频端口

- `1984/tcp`：go2rtc Web/API
- `8555/tcp+udp`：WebRTC
- `8554/tcp`：本地 RTSP 重流

## 注意事项

- 阶段 2 的 v1 默认不做转码，因此 K230 主码流必须为 `H264`
- 如果后续需要多路、多协议、录像、回调或更复杂的协议分发，再从 `go2rtc` 升级到 `ZLMediaKit`

# EdgeLink_RK3568

当前 `EdgeLink_RK3568` 分为两条彼此独立的链路：

- 阶段 1：`STM32F429 -> RK3568 -> OneNET`
- 阶段 2：`K230 RTSP(H264) -> RK3568/go2rtc -> WebRTC/MSE/HLS -> 浏览器`

## 目录结构

```text
config/    OneNET、go2rtc、frp、AI 转发运行配置
src/       Python 网关主程序
systemd/   systemd 单元文件
scripts/   安装与前台运行脚本
docs/      架构与协作文档
```

## OneNET 数据桥接

- 接收 F429 的 `POST /api/uplink`
- 兼容 `17-competition` 当前 `MODBUS_SNAPSHOT`
- 映射到 OneNET 字段：`Temp/Hum/Light/MQ2/Error`
- 订阅 `thing/property/post/reply`
- 订阅 `thing/property/set`
- 当前下行统一回复 `not implemented`

## K230 视频链路

- RK3568 使用 `go2rtc` 主动拉取 K230 的 H264 RTSP 主码流
- RK3568 对外提供 `WebRTC/MSE/HLS`
- 使用 `frpc` 把播放端口映射到腾讯云 `frps`
- 腾讯云只做端口转发，不做媒体转码

当前公网视频入口：

- 页面：`http://101.35.79.76:1984/`
- 播放页：`http://101.35.79.76:1984/stream.html?src=k230&mode=webrtc,mse`
- WebRTC 媒体端口：`101.35.79.76:8555`

## HTTP 入口

- `POST /api/uplink`
- `POST /api/ai`
- `GET /healthz`

成功返回格式：

```json
{"code":0,"msg":"accepted"}
```

## AI 结果当前状态

- `K230` 的 AI 检测结果始终先发送到 RK3568 的 `POST /api/ai`
- RK3568 会在网关进程内存中保存 `latest_ai_result`
- RK3568 已支持按配置把非空检测结果继续转发到 Java 后端
- 配置模板建议保持 `ai_forward.enabled = false`
- 需要对接 Java 后端时，再把目标地址改成真实值并启用转发

当前推荐的 Java AI 接口：

- `http://101.35.79.76:19081/api/edge/ai-detections`

## 运行方式

网关服务：

1. 安装依赖：`./scripts/install_deps.sh`
2. 检查配置：`python3 src/edgelink_gateway.py --config config/edgelink.ini --check-config`
3. 前台运行：`./scripts/run_gateway.sh`
4. systemd 运行：
   - `sudo cp systemd/edgelink-gateway.service /etc/systemd/system/`
   - `sudo systemctl daemon-reload`
   - `sudo systemctl enable --now edgelink-gateway`

视频服务：

1. 填写 `config/go2rtc.yaml`
2. 填写 `config/frpc.toml`
3. 在腾讯云部署 `frps`，参考 `config/frps.toml.example`
4. 安装视频运行时：`./scripts/install_video_runtime.sh`
5. 前台调试：
   - `./scripts/run_go2rtc.sh`
   - `./scripts/run_frpc.sh`
6. systemd 运行：
   - `sudo cp systemd/go2rtc.service /etc/systemd/system/`
   - `sudo cp systemd/frpc.service /etc/systemd/system/`
   - `sudo systemctl daemon-reload`
   - `sudo systemctl enable --now go2rtc frpc`

## 协作文档

- Java 后端/前端视频协作说明：`docs/java-video-collaboration.md`
- Java 后端接收 AI 结果说明：`docs/java-ai-collaboration.md`
- K230 与腾讯云协同配置：`docs/k230-tencent-cloud-cooperation.md`
- 视频阶段说明：`docs/video-v1.md`

## 注意事项

- 阶段 2 的 v1 默认不做转码，因此 K230 主码流必须为 `H264`
- 如果后续需要多路、多协议、录像、回调或更复杂的协议分发，再从 `go2rtc` 升级到 `ZLMediaKit`

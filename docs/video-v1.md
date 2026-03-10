# K230 视频阶段 v1

## 目标

- RK3568 主动拉取 K230 的 H264 RTSP 主码流
- RK3568 通过 go2rtc 对外提供 WebRTC、MSE、HLS 播放能力
- 腾讯云只运行 `frps` 做端口映射
- 现有 OneNET 网关链路继续独立运行

## 推荐链路

```text
K230 --RTSP(H264)--> RK3568/go2rtc --WebRTC/MSE/HLS--> 浏览器
                                 \
                                  +--frpc--> 腾讯云 frps --> 公网
```

## 端口说明

- `1984/tcp`：go2rtc Web、API、播放器页面
- `8555/tcp`：WebRTC TCP 候选
- `8555/udp`：WebRTC UDP 候选
- `8554/tcp`：本地 RTSP 重流，仅用于局域网调试
- `7000/tcp`：frps 控制端口
- `7500/tcp`：可选 frps 管理页面端口

## 当前局域网源流

- K230 当前采用“有线优先，Wi-Fi 兜底”的接入方式
- 当前初始局域网源流地址：`rtsp://172.18.8.103:8554/test`
- `edgelink-gateway` 会根据 `POST /api/ai` 的来源地址自动更新 `config/go2rtc.yaml` 中的 `streams.k230`
- 当 K230 从有线回退到 Wi-Fi 时，RK3568 会在确认来源地址稳定后重启一次 `go2rtc` 完成切换
- 播放入口不变，前端和 Java 后端不需要感知底层源地址变化

## 配置顺序

1. 在 `config/go2rtc.yaml` 中填写 K230 的 RTSP 地址
2. 把 `webrtc.candidates` 改成腾讯云公网地址加 `:8555`
3. 在 `config/frpc.toml` 中填写腾讯云主机地址和 token
4. 参考 `config/frps.toml.example` 在腾讯云部署 `frps`
5. 运行 `./scripts/install_video_runtime.sh`
6. 先运行 `./scripts/run_go2rtc.sh`，确认本地拉流成功
7. 再运行 `./scripts/run_frpc.sh`，确认公网映射成功
8. 前台验证通过后，再安装 `systemd/go2rtc.service` 和 `systemd/frpc.service`

## 当前公网入口

- 页面：`http://101.35.79.76:1984/`
- 播放页：`http://101.35.79.76:1984/stream.html?src=k230&mode=webrtc,mse`
- WebRTC 媒体端口：`101.35.79.76:8555`

## 对 Java 后端和前端协作者的要求

- Java 后端只负责业务元数据接口，不直接代理媒体流
- 前端通过 Java 后端下发的 `playerUrl` 直连 `go2rtc/frp`
- Java 后端不要代理 `8555` 的 WebRTC 媒体端口
- 如需详细协作约定，参见：
  - `docs/java-video-collaboration.md`
  - `docs/java-ai-collaboration.md`

## 当前 AI 结果状态

- K230 会把 AI 检测结果发送到 RK3568 的 `POST /api/ai`
- RK3568 始终保存 `latest_ai_result` 并写日志
- RK3568 已支持按配置把非空检测结果转发到 Java 后端
- 配置模板建议保持 `ai_forward.enabled = false`
- 当前推荐的 Java AI 接口为 `http://101.35.79.76:19081/api/edge/ai-detections`

## 约束

- 阶段 2 v1 不做转码
- K230 主码流必须保持 `H264`
- 如果浏览器音频兼容性有问题，优先在 K230 侧关闭音频
- frp 只降低云端 CPU 压力，不降低媒体带宽占用

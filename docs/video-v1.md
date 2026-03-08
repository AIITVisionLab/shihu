# K230 视频阶段 v1

## 目标

- RK3568 主动拉取 K230 的 H264 RTSP 主码流
- RK3568 通过 go2rtc 对外提供 WebRTC/MSE/HLS
- 腾讯云只运行 `frps` 做端口映射
- 现有 OneNET 网关链路继续独立运行

## 推荐链路

```text
K230 --RTSP(H264)--> RK3568/go2rtc --WebRTC/MSE/HLS--> 浏览器
                                 \
                                  +--frpc--> 腾讯云 frps --> 公网
```

## 端口说明

- `1984/tcp`：go2rtc Web/API/播放器页面
- `8555/tcp`：WebRTC TCP 候选
- `8555/udp`：WebRTC UDP 候选
- `8554/tcp`：本地 RTSP 重流，仅用于局域网调试
- `7000/tcp`：frps 控制端口
- `7500/tcp`：可选 frps 管理页面端口

## 配置顺序

1. 在 `config/go2rtc.yaml` 中填写 K230 的 RTSP 地址
2. 把 `webrtc.candidates` 改成腾讯云公网 IP 或域名加 `:8555`
3. 在 `config/frpc.toml` 中填写腾讯云主机地址和 token
4. 参考 `config/frps.toml.example` 在腾讯云部署 `frps`
5. 运行 `./scripts/install_video_runtime.sh`
6. 先运行 `./scripts/run_go2rtc.sh`，确认本地拉流成功
7. 再运行 `./scripts/run_frpc.sh`，确认公网映射成功
8. 前台验证通过后，再安装 `systemd/go2rtc.service` 和 `systemd/frpc.service`

## 约束

- 阶段 2 v1 不做转码
- K230 主码流必须保持 `H264`
- 如果浏览器音频兼容性有问题，优先在 K230 侧关闭音频
- frp 只降低云端 CPU 压力，不降低媒体带宽占用

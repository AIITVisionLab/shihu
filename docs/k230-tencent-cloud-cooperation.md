# K230 与腾讯云协同配置说明

## 1. 目标与总体拓扑

本阶段目标是：

- K230 提供 RTSP 主码流
- RK3568 使用 go2rtc 主动拉流
- RK3568 将 RTSP 转为 WebRTC/MSE/HLS
- 腾讯云只运行 frps 做公网端口映射
- 浏览器最终通过腾讯云公网入口访问 RK3568 的视频服务

总体拓扑如下：

```text
K230 --RTSP(H264)--> RK3568 go2rtc --WebRTC/MSE/HLS--> 浏览器
                                  \
                                   +--frpc--> 腾讯云 frps --> 公网
```

## 2. K230 侧需要完成的配置

K230 侧至少需要满足以下条件：

- 主码流必须为 `H264`
- 能稳定提供 RTSP 地址
- RTSP 地址格式类似：
  - `rtsp://192.168.x.x:554/live/main`
  - 或 `rtsp://用户名:密码@192.168.x.x:554/live/main`
- 如果音频编码与浏览器兼容性不确定，建议先关闭音频，只验证视频

如果 K230 主码流不是 `H264`，当前 v1 方案不能直接验收，必须先调整 K230 编码，或者后续改成转码方案。

## 3. RK3568 侧需要完成的配置

RK3568 侧主要填写这两个配置文件：

### `config/go2rtc.yaml`

需要填写：

- `streams.k230`：K230 的实际 RTSP 地址
- `webrtc.candidates`：腾讯云公网 IP 或域名加 `:8555`

例如：

```yaml
webrtc:
  listen: ":8555"
  candidates:
    - "1.2.3.4:8555"

streams:
  k230:
    - "rtsp://192.168.10.50:554/live/main"
```

### `config/frpc.toml`

需要填写：

- `serverAddr`：腾讯云公网 IP 或域名
- `auth.token`：你自己设定的 frp token

### systemd 服务

验证前台跑通后，再启用：

- `systemd/go2rtc.service`
- `systemd/frpc.service`

## 4. 腾讯云服务器侧需要完成的配置

腾讯云服务器需要做这些事情：

- 部署 `frps`
- 按 `config/frps.toml.example` 配置 token 和监听端口
- 在安全组/防火墙中开放以下端口：
  - `7000/tcp`：frps 控制端口
  - `1984/tcp`：go2rtc Web 页面
  - `8555/tcp`：WebRTC TCP
  - `8555/udp`：WebRTC UDP
  - `7500/tcp`：可选 frps dashboard

是否启用 dashboard 取决于你是否需要观察 frp 的连接状态，不是必须项。

## 5. 推荐联调顺序

必须按这个顺序联调：

1. 先确认 K230 本地 RTSP 可拉通
2. 在 RK3568 上只启动 go2rtc，先验证本地播放
3. 本地播放正常后，再启动 frpc
4. 在腾讯云确认 frps 已接入 RK3568
5. 最后用公网浏览器访问腾讯云暴露出来的入口

不要一开始就同时拉 K230、开 frp、开公网播放。先本地，后公网，这样定位最省时间。

## 6. 你需要提供给我的 3 项信息

请你把下面这 3 项信息直接发给我：

1. `K230` 的实际 RTSP 地址
   - 例如：`rtsp://192.168.x.x:554/live/main`
2. 腾讯云服务器的公网 `IP` 或域名
   - 用于填写 `go2rtc.yaml` 的 `webrtc.candidates`
   - 也用于填写 `frpc.toml` 的 `serverAddr`
3. `frps/frpc` 共用的 `token`
   - 用于公网穿透认证

你可以直接按下面这个模板回复我：

```text
K230_RTSP=rtsp://...
CLOUD_HOST=...
FRP_TOKEN=...
```

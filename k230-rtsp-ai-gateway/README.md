# K230_RTSP

这个目录用于放置 `K230` 侧的单文件脚本。当前目标是和 `EdgeLink_RK3568` 联动，完成两条并行链路：

- `K230 -> RK3568/go2rtc`：输出带框 `RTSP(H264)` 视频流
- `K230 -> RK3568/edgelink-gateway`：按帧批量上送 `AI JSON`

## 参考资料

- RK3568 联动说明：
  - `Z:\home\linaro\project\EdgeLink_RK3568\docs\k230-tencent-cloud-cooperation.md`
- 庐山派 K230 Wi-Fi STA 说明：
  - `network.WLAN(network.STA_IF)`、`sta.connect()`、`sta.ifconfig()`
- 官方 RTSP/WBCRtsp 示例：
  - CanMV K230 `AI+RTSP推流`
- 官方显示模块说明：
  - `Display.VIRT` 支持无实体屏的虚拟显示

## 当前设计

脚本固定完成这几件事：

1. `K230` 以 `STA` 模式连接现有 `2.4G Wi-Fi`
2. 使用 `PipeLine + WBCRtsp + Display.VIRT` 输出带框 `RTSP`
3. 在本地执行 `YOLO11 OBB` 推理
4. 将当前帧全部检测结果批量 `HTTP POST` 到 `RK3568`

`RK3568` 侧约定如下：

- RTSP 由 `go2rtc` 主动拉取
- AI 结果发送到：
  - `POST http://<RK3568_LAN_IP>:8080/api/ai`

## 文件说明

- `k230_rtsp_ai_gateway.py`
  - 当前主入口脚本
  - 直接在脚本顶部修改 Wi-Fi、RTSP、RK3568 地址、模型路径等常量

## 需要修改的常量

脚本顶部需要按现场修改这些值：

- `WIFI_SSID`
- `WIFI_PASSWORD`
- `RK3568_HOST`
- `RK3568_PORT`
- `RK3568_AI_PATH`
- `KMODEL_PATH`
- `LABELS`

当前默认值按现有联调环境写死为：

- `WIFI_SSID = "A6N107"`
- `WIFI_PASSWORD = "A6N107666#"`
- `RK3568_HOST = "172.18.8.19"`
- `RK3568_PORT = 8080`
- `RK3568_AI_PATH = "/api/ai"`

## AI JSON 协议

K230 上送到 RK3568 的 JSON 结构如下：

```json
{
  "type": "AI_DETECTIONS",
  "deviceId": "k230",
  "stream": "k230",
  "timestampMs": 1710000000123,
  "frameId": 12,
  "image": {
    "width": 1920,
    "height": 1080
  },
  "detections": [
    {
      "classId": 0,
      "className": "plane",
      "quad": [100, 100, 200, 100, 200, 180, 100, 180],
      "bbox": [100, 100, 100, 80]
    }
  ]
}
```

说明：

- `detections` 是“当前帧全部目标”的数组
- `quad` 是 OBB 四点坐标
- `bbox` 是外接矩形，便于 RK3568 后续处理
- 如果当前帧没有目标，仍会上送空数组 `[]`
- `confidence` 只有在运行时确实拿到时才会附带，不会伪造

## 运行步骤

1. 把脚本放到 K230 的 CanMV 运行目录
2. 确认模型路径可访问
3. 修改脚本顶部常量
4. 运行 `k230_rtsp_ai_gateway.py`
5. 观察串口输出：
   - Wi-Fi 是否连通
   - 分配到的 IP
   - RTSP 地址
   - AI JSON 是否投递成功

## 预期联动结果

### RTSP

脚本启动后，`WBCRtsp` 会在 K230 上开启 RTSP 推流。默认按官方示例约定，访问地址形如：

```text
rtsp://<K230_IP>:8554/test
```

RK3568 的 `go2rtc` 直接填这个地址即可。

### AI 结果

RK3568 的 `edgelink-gateway` 需要已经实现：

- `POST /api/ai`

并返回：

```json
{"code":0,"msg":"accepted"}
```

## 排障顺序

1. 先确认 K230 已连上 Wi-Fi 并获得 IP
2. 再确认 `WBCRtsp` 已成功启动
3. 再确认 RK3568 的 `/api/ai` 已可访问
4. 最后再联动 `go2rtc + frp`

如果 `Display.VIRT + WBCRtsp` 现场不稳定：

- 不在同一版脚本里强塞第二套实现
- 下一版直接切换到“底层 RTSP 编码 + AI JSON 上送”的回退方案

# Java 后端接收 AI 结果协作说明

## 1. 当前状态

当前边缘链路已经实现：

- `K230 -> RK3568 /api/ai`
- RK3568 接收并保存 `latest_ai_result`
- RK3568 可选地把非空检测结果继续转发到 Java 后端

需要明确两点：

- RK3568 配置模板建议 `ai_forward.enabled = false`
- 也就是说，默认口径下 AI 结果先停留在网关内存和日志中

只有在你们提供真实 Java 服务地址并把 `ai_forward.enabled` 打开之后，RK3568 才会向业务后端继续上送 AI 结果。

## 2. Java 后端需要提供的接口

建议接口固定为：

- `POST /api/edge/ai-detections`

当前推荐的部署参数固定为：

- 服务器公网 IP：`101.35.79.76`
- Java 服务端口：`19081/tcp`
- 完整目标地址：`http://101.35.79.76:19081/api/edge/ai-detections`

默认约定：

- 协议：`HTTP`
- 鉴权：无鉴权
- 请求头：`Content-Type: application/json`

RK3568 按 `HTTP 2xx` 判定成功，不强依赖响应体中的业务字段。

推荐响应示例：

```json
{
  "code": 0,
  "msg": "accepted"
}
```

如果 Java 后端只返回空响应体，但状态码是 `200`、`201`、`202`、`204`，RK3568 也会视为成功。

## 3. RK3568 到 Java 的转发规则

RK3568 不是把所有帧都转给 Java 后端，而是采用以下策略：

- 只转发 `detections` 非空的 AI 结果
- `detections = []` 的空结果只保存在网关，不继续上送
- Java 后端不可达时，不堆积历史帧
- 网关只保留最近一条待发送的非空结果，后来的结果会覆盖之前未发出的结果
- 后台线程按固定间隔重试

这套策略的目的很明确：

- 不把空结果刷爆后端
- 不把高频视频帧变成历史消息队列
- 保持“最新结果优先”

## 4. Java 后端会收到什么 JSON

RK3568 原样透传当前 K230 和 RK3568 已使用的 `AI_DETECTIONS` 结构，不重新包装 DTO。

请求体示例：

```json
{
  "type": "AI_DETECTIONS",
  "deviceId": "k230",
  "stream": "k230",
  "timestampMs": 1710000000123,
  "frameId": 123,
  "image": {
    "width": 1920,
    "height": 1080
  },
  "detections": [
    {
      "classId": 0,
      "className": "target",
      "quad": [100, 100, 200, 100, 200, 200, 100, 200],
      "bbox": [100, 100, 100, 100],
      "confidence": 0.92
    }
  ]
}
```

字段说明：

- `type`：固定为 `AI_DETECTIONS`
- `deviceId`：设备标识，当前可先使用 `k230`
- `stream`：视频流标识，当前可先使用 `k230`
- `timestampMs`：毫秒时间戳
- `frameId`：帧序号
- `image.width / image.height`：图像尺寸
- `detections[]`：当前帧目标列表
- `classId`：类别编号
- `className`：类别名称
- `quad`：旋转框四点坐标
- `bbox`：轴对齐外接框 `[x, y, w, h]`
- `confidence`：置信度，可选字段

## 5. Java 后端建议实现方式

建议 Java 后端直接实现一个轻量接收接口，不要在第一版里做复杂流式处理。

### 5.0 Java 服务端当前必须满足的条件

为了让 RK3568 当前版本可以直接把 AI 检测结果推过去，Java 服务端至少要满足下面这些条件：

- 监听地址：`0.0.0.0`
- 监听端口：`19081`
- 对外路径：`POST /api/edge/ai-detections`
- 协议：`HTTP`
- 鉴权：当前无鉴权
- 返回状态码：任意 `2xx` 都可以

如果你们部署在腾讯云服务器 `101.35.79.76` 上，那么外部实际访问地址就是：

- `http://101.35.79.76:19081/api/edge/ai-detections`

同时还要完成两项环境配置：

- 腾讯云安全组放行 `19081/tcp`
- 服务器本机防火墙放行 `19081/tcp`，或明确关闭该端口拦截

### 5.1 最小 Controller 语义

建议语义：

- 接收 JSON
- 记录来源设备、流标识、时间戳、帧号
- 存储或转交到你们自己的业务服务
- 立即返回 `HTTP 200`

最小可验收标准：

- 用 `curl` 或 Postman 对 `http://101.35.79.76:19081/api/edge/ai-detections` 发一条示例 JSON 时，接口能稳定返回 `200`
- Java 服务日志里能看到请求命中
- RK3568 开启 `ai_forward` 后，日志能出现 `ai result forwarded`

### 5.2 不建议做的事

当前阶段不建议：

- 在接口里做耗时图像处理
- 在接口里同步调用大模型或规则引擎
- 把 AI 上送接口和视频媒体转发耦合在一起
- 要求 RK3568 等待复杂业务成功后才返回

理由很简单：K230 的结果是持续流式产生的，接口必须轻、快、可降级。

## 6. RK3568 配置方式

RK3568 通过 `config/edgelink.ini` 控制是否启用 AI 上送。

配置段如下：

```ini
[ai_forward]
enabled = false
target_url = http://<java-host>:<port>/api/edge/ai-detections
auth_mode = none
timeout_s = 2
retry_interval_ms = 1000
only_non_empty = true
```

当前推荐直接改成：

```ini
[ai_forward]
enabled = true
target_url = http://101.35.79.76:19081/api/edge/ai-detections
```

当前版本只支持：

- `auth_mode = none`

如果后续要加 Token 或 Bearer，再单独扩展，不在本轮混进去。

## 7. 健康检查与排障

RK3568 的 `GET /healthz` 已增加 AI 转发状态字段：

- `aiForwardEnabled`
- `aiForwardPending`
- `lastAiForwardOk`
- `lastAiForwardMs`

排障时可以这样理解：

- `aiForwardEnabled = false`
  - 说明网关没有开启对 Java 的转发
- `aiForwardPending = true`
  - 说明当前有待发送结果，还没成功送到 Java
- `lastAiForwardOk = true`
  - 说明最近一次 AI 转发成功
- `lastAiForwardOk = false`
  - 说明最近一次 AI 转发失败

同时看 RK3568 日志，关键字固定为：

- `ai result queued for backend`
- `ai result skipped because detections is empty`
- `ai result forwarded`
- `ai result forward failed`

## 8. 前端范围说明

这一轮只定义 Java 后端接收 AI 结果，不定义前端 AI 查询接口。

也就是说：

- 前端当前继续只通过视频 URL 看视频
- Java 后端如果要让前端显示 AI 检测结果，需要你们自己在服务端落库或缓存
- 然后再由你们定义新的查询接口或推送接口提供给前端
- 当前前端不直接从 RK3568 拉 AI JSON

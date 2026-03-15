# EdgeLink_RK3568 测试计划

## 阶段 1：OneNET 网关

### 1. 配置检查

```bash
python3 src/edgelink_gateway.py --config config/edgelink.ini --check-config
```

### 2. HTTP 自测

```bash
curl -sS -X POST http://127.0.0.1:8080/api/uplink \
  -H 'Content-Type: application/json' \
  -d '{
    "deviceId":"stm32f4",
    "messageId":1,
    "ts":123456,
    "type":"MODBUS_SNAPSHOT",
    "payload":{
      "cycleId":12,
      "slave1":{"online":1,"valid":1,"lastError":"NONE","lastUpdateMs":1234,"lightAdc":1024},
      "slave2":{"online":1,"valid":1,"lastError":"NONE","lastUpdateMs":1234,"temperature":26,"humidity":61},
      "slave3":{"online":1,"valid":1,"lastError":"NONE","lastUpdateMs":1234,"mq2Ppm":350}
    }
  }'
```

预期：

- 返回 `{"code":0,"msg":"accepted"}`
- 日志打印 `Temp/Hum/Light/MQ2/Error` 的映射结果
- MQTT 在线时立即上报到 OneNET

## 阶段 2：K230 视频流 v1

### 1. 本地拉流验证

```bash
./scripts/install_video_runtime.sh
./scripts/run_go2rtc.sh
```

预期：

- go2rtc 正常启动
- `http://RK3568_IP:1984/` 可访问
- `k230` 流可以在本地播放

### 2. frp 公网映射验证

```bash
./scripts/run_frpc.sh
```

预期：

- frpc 成功连接腾讯云 frps
- 公网可以访问映射后的 `1984/tcp`
- 浏览器可通过 `8555/tcp+udp` 建立 WebRTC

### 3. 退化场景

- K230 RTSP 掉流：go2rtc 日志能明确报拉流失败
- UDP 不通：回退到 MSE/HLS
- 重启 `go2rtc` 或 `frpc`：不影响 `edgelink-gateway`

### 4. 前提条件

- K230 主码流必须为 `H264`
- 如果音频与浏览器不兼容，先关闭音频，只验证视频链路

## 阶段 3：OpenClaw 农业边缘大脑

### 1. 配置检查

```bash
python3 src/agri_context_bridge.py --config config/agri-context-bridge.ini --check-config
```

预期：

- 返回 `config ok`
- 自动创建 SQLite 所在目录
- `config/agri-profiles.json` 可被正常读取

### 2. 视觉事件接入

```bash
curl -sS -X POST http://127.0.0.1:18081/api/agri/events/vision \
  -H 'Content-Type: application/json' \
  -d '{
    "event":"pest_detected",
    "type":"spider_mite",
    "confidence":0.85,
    "deviceId":"k230-01",
    "cropId":"huoshan-shihu",
    "zoneId":"default-greenhouse"
  }'
```

预期：

- 返回 `{"code":0,"msg":"accepted",...}`
- `analysisTriggered = true`

### 3. 传感快照接入

```bash
curl -sS -X POST http://127.0.0.1:18081/api/agri/events/modbus-snapshot \
  -H 'Content-Type: application/json' \
  -d '{
    "deviceId":"stm32f4",
    "messageId":101,
    "ts":1710000000123,
    "type":"MODBUS_SNAPSHOT",
    "payload":{
      "cycleId":12,
      "slave1":{"online":1,"valid":1,"lightAdc":1024},
      "slave2":{"online":1,"valid":1,"temperature":32,"humidity":40},
      "slave3":{"online":1,"valid":1,"mq2Ppm":350}
    }
  }'
```

预期：

- 返回 `{"code":0,"msg":"accepted",...}`
- 最新环境状态可从 `GET /api/agri/tools/latest-environment` 读到

### 4. 主动分析

```bash
curl -sS -X POST http://127.0.0.1:18081/api/agri/decisions/analyze \
  -H 'Content-Type: application/json' \
  -d '{
    "sessionId":"agri-analysis:default-greenhouse",
    "cropId":"huoshan-shihu",
    "zoneId":"default-greenhouse",
    "query":"当前发现红蜘蛛迹象，请生成处理建议。"
  }'
```

预期：

- 返回结构化报告对象
- `recommendedActions[*].executeEnabled = false`
- `recommendedActions[*].executionStatus = "disabled_by_policy"`
- 如果引用了知识库，`summary` 或 `humanMessage` 中显式包含“根据当前知识库中的信息”

### 5. 交互式问答

```bash
curl -sS -X POST http://127.0.0.1:18081/api/agri/chat \
  -H 'Content-Type: application/json' \
  -d '{
    "sessionId":"app-user-001",
    "query":"今天石斛长势怎么样？需要浇水吗？"
  }'
```

预期：

- 返回 `mode = "chat"` 的报告对象
- `humanMessage` 为适合 APP 展示的自然语言
- 数据不足时明确表达不确定性

### 6. 向量知识库重建与检索

```bash
python3 scripts/build_agri_vector_index.py --config config/agri-context-bridge.ini
curl -sS 'http://127.0.0.1:18081/api/agri/tools/knowledge-search?q=霍山石斛适宜环境&cropId=huoshan-shihu&topK=5'
```

预期：

- 重建后生成 `data/agri-vectordb/manifest.json`
- 检索接口返回非空 `matches`
- `matches[*]` 包含 `chunkId/sourceId/sourceTitle/docType/filePath/score/text`

### 7. 安全验证

- `POST /api/agri/actions/execute` 返回 `501`
- OpenClaw `agri-orchestrator` 不允许写文件、改配置、执行系统命令
- 决策报告中可以出现推荐动作，但不得直接执行

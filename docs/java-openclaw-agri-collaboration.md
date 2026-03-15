# Java 后端 / APP 接入 OpenClaw 农业大脑说明

## 1. 角色边界

当前农业能力拆成三层：

- `K230 / STM32`：产生视觉事件和传感快照
- `agri-context-bridge`：归一化、存储、上下文组装、调用 OpenClaw
- `OpenClaw agri-orchestrator`：只读推理，输出建议和解释

当前版本明确不做物理执行：

- 不直接控制 PLC
- 不修改网关配置、系统配置、Nginx、systemd
- 推荐动作中的 `executeEnabled` 固定为 `false`

Java 后端和 APP 不要直接连 OpenClaw Gateway，统一接 `agri-context-bridge`。

## 2. 本地服务地址

默认本地监听：

- `http://127.0.0.1:18081`

接口：

- `POST /api/agri/events/vision`
- `POST /api/agri/events/modbus-snapshot`
- `POST /api/agri/decisions/analyze`
- `POST /api/agri/chat`
- `GET /api/agri/reports/{reportId}`
- `GET /api/agri/reports/latest`
- `GET /api/agri/stream?sessionId=...`
- `POST /api/agri/actions/execute`
- `GET /api/agri/tools/knowledge-search?q=...&cropId=...&topK=...`

## 3. 视觉事件接入

请求路径：

- `POST /api/agri/events/vision`

请求示例：

```json
{
  "event": "pest_detected",
  "type": "spider_mite",
  "confidence": 0.85,
  "deviceId": "k230-01",
  "cropId": "huoshan-shihu",
  "zoneId": "default-greenhouse"
}
```

返回示例：

```json
{
  "code": 0,
  "msg": "accepted",
  "eventId": "1d62c3f8-6f3f-4a95-a66e-2b1e8d9f73ce",
  "inserted": true,
  "analysisTriggered": true
}
```

## 4. 传感快照接入

请求路径：

- `POST /api/agri/events/modbus-snapshot`

兼容当前 STM32 `MODBUS_SNAPSHOT`：

```json
{
  "deviceId": "stm32f4",
  "messageId": 101,
  "ts": 1710000000123,
  "type": "MODBUS_SNAPSHOT",
  "payload": {
    "cycleId": 12,
    "slave1": {
      "online": 1,
      "valid": 1,
      "lightAdc": 1024
    },
    "slave2": {
      "online": 1,
      "valid": 1,
      "temperature": 32,
      "humidity": 40
    },
    "slave3": {
      "online": 1,
      "valid": 1,
      "mq2Ppm": 350
    }
  }
}
```

## 5. 主动分析

请求路径：

- `POST /api/agri/decisions/analyze`

请求示例：

```json
{
  "sessionId": "agri-analysis:default-greenhouse",
  "cropId": "huoshan-shihu",
  "zoneId": "default-greenhouse",
  "query": "当前发现红蜘蛛迹象，请生成处理建议。"
}
```

返回固定为结构化报告对象：

```json
{
  "reportId": "uuid",
  "ts": "2026-03-10T21:00:00+08:00",
  "mode": "analysis",
  "sessionId": "agri-analysis:default-greenhouse",
  "question": "当前发现红蜘蛛迹象，请生成处理建议。",
  "summary": "检测到红蜘蛛风险，建议先降温增湿并人工复核。",
  "severity": "warn",
  "decision": {
    "conclusion": "high_risk_spider_mite",
    "confidence": 0.86,
    "recommendedActions": [
      {
        "actionType": "fan.on",
        "targetDevice": "top_vent_fan",
        "priority": 1,
        "reason": "高温低湿有利于红蜘蛛繁殖",
        "executeEnabled": false,
        "executionStatus": "disabled_by_policy"
      }
    ]
  },
  "evidence": {
    "visionEvents": [],
    "sensorSnapshot": {},
    "historySummary": [],
    "knowledgeHighlights": [],
    "knowledgeMatches": []
  },
  "humanMessage": "当前棚内偏热偏干，同时视觉侧发现红蜘蛛迹象，建议先降温增湿并安排人工复核。"
}
```

## 6. 交互式对话

请求路径：

- `POST /api/agri/chat`

请求示例：

```json
{
  "sessionId": "app-user-001",
  "cropId": "huoshan-shihu",
  "zoneId": "default-greenhouse",
  "query": "今天石斛长势怎么样？需要浇水吗？"
}
```

返回结构与 `analysis` 相同，只是 `mode = "chat"`。

## 7. SSE 流式返回

路径：

- `GET /api/agri/stream?sessionId=app-user-001`

行为：

- 服务端先发送 `event: ready`
- 新报告生成后发送 `event: report`
- `data` 为整份报告 JSON

Java 后端可以自己消费 SSE，再转发给 APP。

## 8. 只读工具契约

桥接服务已经固化了供后续 OpenClaw Tool 注册使用的只读查询面：

- `GET /api/agri/tools/latest-environment`
- `GET /api/agri/tools/recent-vision-events?type=spider_mite&windowMinutes=10`
- `GET /api/agri/tools/recent-sensor-history?metric=temperature&windowMinutes=60`
- `GET /api/agri/tools/recent-decision-reports?windowHours=24`
- `GET /api/agri/tools/crop-profile?cropId=huoshan-shihu`
- `GET /api/agri/tools/knowledge-search?q=霍山石斛适宜环境&cropId=huoshan-shihu&topK=5`
- `GET /api/agri/tools/greenhouse-profile?zoneId=default-greenhouse`

## 9. 控制接口预留

预留路径：

- `POST /api/agri/actions/execute`

当前固定返回：

```json
{
  "code": 501,
  "msg": "execute disabled by policy",
  "executeEnabled": false,
  "executionStatus": "disabled_by_policy"
}
```

## 只读知识接口

桥接层当前除了实时传感和历史报告，还提供了本地石斛知识库查询接口，供 Java 后端或调试工具只读访问：

- `GET /api/agri/tools/latest-environment`
- `GET /api/agri/tools/recent-vision-events?type=spider_mite&windowMinutes=10`
- `GET /api/agri/tools/recent-sensor-history?metric=temperature&windowMinutes=60`
- `GET /api/agri/tools/recent-decision-reports?windowHours=24`
- `GET /api/agri/tools/crop-profile?cropId=huoshan-shihu`
- `GET /api/agri/tools/crop-knowledge?cropId=huoshan-shihu`
- `GET /api/agri/tools/knowledge-sources`
- `GET /api/agri/tools/knowledge-search?q=霍山石斛适宜环境&cropId=huoshan-shihu&topK=5`
- `GET /api/agri/tools/greenhouse-profile?zoneId=default-greenhouse`

说明：
- 未显式指定 `cropId` 时，系统默认按 `huoshan-shihu`（霍山石斛）处理。
- `crop-profile` 返回项目运行基线，例如棚内温湿度目标。
- `crop-knowledge` 返回根据文献整理后的本地知识条目。
- `knowledge-sources` 返回当前知识库来源索引，便于前后端展示“依据哪篇资料得出结论”。
- `knowledge-search` 返回文献向量检索召回片段，适合用于展示“模型参考了哪些知识片段”。

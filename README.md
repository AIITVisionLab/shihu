# IoT OneNET Refactor

这是基于你原始代码重新整理的一套 Spring Boot 项目，目标是：

- **不改动核心功能**：保留登录、状态查询、LED 下发、OneNET API 调用、Pulsar 消费、AES 解密、set_reply 回填。
- **只优化结构**：按 `api / application / infrastructure / config / bootstrap` 重新分层。

## 目录结构

```text
com.aurora.iotonenet
├── api
│   ├── controller
│   ├── dto
│   └── exception
├── application
│   └── service
├── bootstrap
├── config
└── infrastructure
    ├── onenet
    └── pulsar
        ├── auth
        ├── client
        ├── consumer
        ├── handler
        ├── model
        └── parser
```

## 保留的接口

- `POST /api/login`
- `GET /api/check-login`
- `POST /api/logout`
- `GET /api/status`
- `POST /api/ops/led`
- `GET /api/health`

## 相比原项目的结构优化

1. 控制器只保留 HTTP 输入输出。
2. 登录与 LED 下发拆到独立 Application Service。
3. OneNET OpenAPI 调用下沉到 `infrastructure.onenet`。
4. Pulsar 接入、鉴权、消息模型、解析器、消息处理器拆分。
5. OneNET + Pulsar 配置统一进入 `OneNetProperties`。
6. 增加全局异常处理，避免控制器散落校验代码。
7. 保持 `SecurityConfig` 当前“全部放行”的行为，不擅自改变认证策略。

## 需要你补的配置

编辑 `src/main/resources/application.yml`：

- `onenet.product-id`
- `onenet.authorization`
- `onenet.pulsar.access-id`
- `onenet.pulsar.secret-key`
- `onenet.pulsar.subscription-name`
- `app.login.username`
- `app.login.password`

## 说明

这个版本重点是“**结构重组**”，不是“功能重写”。
部分前端静态页这里只放了占位文件，方便你把原来的 `login.html / index.html / js / css` 直接覆盖进去。

# 斛生跨平台客户端

## 项目定位

这是一个面向石斛幼苗培育场景的 Flutter 跨平台客户端，当前版本已经收口为可直接值守的工作台软件，而不是继续保留识别、历史记录等未接通模块。

当前代码与后端只围绕 `../shihu-web` 的 `origin/web` 源码对齐。

## 当前交付范围

已交付能力：

- 启动初始化与登录守卫
- 登录、注册、会话恢复、退出登录
- 工作台首页
- 实时监控主控台
- 视频中心与软件内视频查看
- 运维设置
- 系统总览
- 设备状态轮询、异常等级展示、LED 控制
- 服务健康检查、本地设置和记住账号持久化
- 统一 Material 3 工作台壳层、统一背景系统、统一入场动效

已删除能力：

- 单图识别
- 识别结果页
- 识别历史记录
- 与以上模块对应的模型、测试、端点解析和共享组件

## 当前后端契约

当前真实接口只有 7 个：

- `POST /api/login`
- `POST /api/register`
- `GET /api/check-login`
- `POST /api/logout`
- `GET /api/status`
- `POST /api/ops/led`
- `GET /api/health`

认证方式：

- `HttpSession + JSESSIONID`

说明：

- Web 端认证请求使用浏览器 Cookie
- 非 Web 端会提取并保存 `JSESSIONID`
- 当前后端不是 Bearer Token 模式
- 当前默认设备服务地址仍为 `http://101.35.79.76:8082`
- Android / iOS 原生端如果不放开明文 HTTP，请求会在系统网络层被拦截，表现为手机端无法登录
- Web 端若不是与后端同源部署，跨站 Cookie 可能在部分手机浏览器上被更严格限制，部署时优先使用同源反向代理或统一 HTTPS

## 平台范围

目标平台：

- Android
- iOS
- macOS
- Web
- Windows
- Linux
- OpenHarmony / 鸿蒙

当前策略：

- 业务逻辑尽量全平台复用
- 桌面端使用侧边导航，紧凑宽度下自动切换为底部导航
- 主视觉使用青绿色主色，辅助色使用暖砂色和冷蓝灰
- 页面、卡片、背景和动效统一保持同一套软件视觉语言

## 本地运行

安装依赖：

```bash
flutter pub get
```

说明：

- 当前仓库不再内置 `third_party` Flutter 插件源码，依赖统一通过 `pub` 获取

本地启动：

```bash
flutter run
```

切换设备服务地址：

```bash
flutter run --dart-define=BASE_URL=http://127.0.0.1:8082
```

开发 / 测试环境启用本地联调登录：

```bash
flutter run --dart-define=USE_MOCK_AUTH=true
```

移动端网络说明：

- Android 发布包需要在 `android/app/src/main/AndroidManifest.xml` 中保留 `INTERNET` 权限，并允许当前 HTTP 设备服务的明文访问
- iOS 原生端需要在 `ios/Runner/Info.plist` 中配置 ATS 例外，否则默认会拦截 `http://` 设备服务
- 如果后端未来统一切到 HTTPS，可回收以上明文访问放行配置

## 当前验证结果

以下结果已于 `2026-03-14` 在当前 Linux 开发环境验证通过：

- `dart format lib test`
- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build web`
- `flutter build linux --debug`

未在当前环境验证的平台：

- iOS
- macOS
- Windows
- OpenHarmony / 鸿蒙

原因：

- Android 已补齐本机构建验证，但当前仍未在真机上逐项回归登录、会话恢复和退出链路
- iOS、macOS、Windows、OpenHarmony / 鸿蒙 仍需要对应主机、SDK、签名和平台工具链

## 文档导航

核心中文文档：

- [功能设计文档](doc/功能设计文档.md)
- [接口契约文档](doc/接口契约文档.md)
- [数据字典与枚举规范](doc/数据字典与枚举规范.md)
- [页面规格与交互文档](doc/页面规格与交互文档.md)
- [架构设计文档](doc/架构设计文档.md)
- [代码规范与开发规范](doc/代码规范与开发规范.md)
- [开发任务拆分](doc/开发任务拆分.md)

两份英文命名协作文档保留在 `doc/` 下，仅作为未来协作参考，不属于当前运行时能力。

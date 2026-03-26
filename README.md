# 斛生跨平台客户端

> 版权所有：安徽信息工程学院计算机视觉实验室

## 项目定位

这是一个面向石斛幼苗培育场景的 Flutter 跨平台客户端，当前版本已经收口为可直接值守的工作台软件，而不是继续保留识别、历史记录等未接通模块。

当前代码已按 `CjhAIIt/iot-onenet-refact-main` 后端契约对齐。

补充说明：

- 当前主分支已合入跨平台客户端代码，后续客户端构建、打包和发布均以本目录下 Flutter 工程为准
- 仓库内如保留其他历史协作目录，仅作为云边端联调参考，不参与当前客户端发布产物构建

## 声明

- 本项目除子目录另有许可证声明外，默认使用 [GNU Affero General Public License v3.0](LICENSE) 开源
- 本项目 logo 并非使用 AGPL-3.0 协议开源，安徽信息工程学院计算机视觉实验室及项目全体开发者保留所有权利。不得以 AGPL-3.0 已授权为由在未经授权的情况下使用本项目 logo，不得在未经授权的情况下将本项目 logo 用于任何商业用途
- 本项目开源以学习交流为主要目的。若您遇到商家使用本项目进行收费，产生的问题及后果与本项目无关

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
- AI 巡检结果查看、平台日志筛选、最近事件查看
- 本地设置和记住账号持久化
- 统一 Material 3 工作台壳层、统一背景系统、统一入场动效

已删除能力：

- 单图识别
- 识别结果页
- 识别历史记录
- 与以上模块对应的模型、测试、端点解析和共享组件

## 当前后端契约

当前前端直接使用 11 个接口：

- `POST /api/login`
- `POST /api/register`
- `GET /api/check-login`
- `POST /api/logout`
- `GET /api/status`
- `POST /api/ops/led`
- `GET /api/video/streams`
- `GET /api/edge/ai-detections/latest`
- `GET /api/edge/ai-detections/history`
- `GET /api/logs`
- `GET /api/logs/summary`

认证方式：

- `HttpSession + JSESSIONID`

说明：

- Web 端认证请求使用浏览器 Cookie
- 非 Web 端会提取并保存 `JSESSIONID`
- 当前后端不是 Bearer Token 模式
- `/api/health` 当前保留为内部联调接口，不在普通用户界面直接暴露
- `/api/edge/ai-detections` 的 `POST` 上送链路属于边缘端到 Java 后端的写入接口，Flutter 客户端当前不直接调用
- 当前默认设备服务地址已经切到公网反向代理入口 `http://101.35.79.76`
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
- 主视觉严格收敛到 `#518463 / #A7D3B2 / #CBF2E0 / #D2C8AC / #CEBBD8` 这组品牌色
- 背景统一使用偏冷雾白纸感底色，不再回到偏黄暖灰底
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

切回本地联调地址：

```bash
flutter run --dart-define=BASE_URL=http://127.0.0.1:8085
```

视频接口暂未接入业务后端时，可直接指定公网视频网关兜底：

```bash
flutter run \
  --dart-define=BASE_URL=http://127.0.0.1:8085 \
  --dart-define=VIDEO_GATEWAY_URL=http://101.35.79.76:1984 \
  --dart-define=VIDEO_DEFAULT_STREAM_ID=k230
```

开发 / 测试环境启用本地联调登录：

```bash
flutter run --dart-define=USE_MOCK_AUTH=true
```

移动端网络说明：

- Android 发布包需要在 `android/app/src/main/AndroidManifest.xml` 中保留 `INTERNET` 权限，并允许当前 HTTP 设备服务的明文访问
- iOS 原生端需要在 `ios/Runner/Info.plist` 中配置 ATS 例外，否则默认会拦截 `http://` 设备服务
- 如果后端未来统一切到 HTTPS，可回收以上明文访问放行配置
- Web 端当前优先在应用内播放页里直接承接视频地址，必要时可再从播放页新开标签排障

## GitHub Release 自动发布

主分支提交约定：

- 主分支只合并源码、必要工程文件和项目文档
- 编译产物不入库，本地发包统一落到 `release/`
- 本地编辑器配置和带机器路径的生成配置不提交
- 正式对外交付统一走 GitHub Release，不把安装包直接提交到主分支

仓库已补充 GitHub Actions 发布工作流：

- 推送 `v*` 标签时自动构建并上传到 GitHub Release
- 也可手动执行 `发布安装包` 工作流，并传入发布标签

默认构建并上传的安装包：

- Android 按架构拆分 `APK`
- Linux `deb`
- Linux `rpm`
- Linux `pacman`
- Linux `AppImage`
- Linux `Flatpak`
- Linux 便携二进制包 `tar.gz`
- Windows 安装器 `exe`
- macOS 安装盘镜像 `dmg`
- iOS 未签名 `IPA`

当前不再上传：

- `AAB`
- Web 静态资源
- 校验说明附件

OpenHarmony / 鸿蒙说明：

- GitHub 官方 runner 不自带 `flutter-ohos` 与 HarmonyOS SDK
- 如需把 `HAP` 一起发到 Release，需要启用带 `self-hosted`、`linux`、`ohos` 标签的自托管 runner
- 需要额外配置仓库变量 `ENABLE_OHOS_RELEASE=true`、`FLUTTER_OHOS_HOME`、`OHOS_SDK_HOME`
- 当前 OpenHarmony Flutter 官方分支最高到 `3.35.x-ohos`，仍基于 Dart `3.9`；仓库已补 `tool/build_ohos_release.sh`，会在临时工作区裁掉仅用于开发的依赖并固定 Dart `3.9` 可编译的运行时包版本
- 本地或 CI 构建 HAP 时统一执行 `tool/build_ohos_release.sh <输出文件>`，默认输出到 `release/`，不要再直接跑仓库根目录下的 `flutter build hap --release`

iOS 说明：

- 当前工作流会生成未签名 `IPA`
- 如需直接安装到真机或对外分发，仍需要按你的 Apple 分发流程重新签名

冷门 Linux 架构说明：

- 当前 Flutter 官方工具链只能直接构建 `linux-x64`、`linux-arm64`
- `loong64`、`riscv64` 这类冷门架构不能在当前官方 Flutter 发行版上直接交叉构建
- 仓库已补 `tool/package_linux_all.sh`，如果你有对应架构机器上产出的原生 Linux bundle，可继续一键封装成 `deb`、`rpm`、`pacman`、`portable`
- `AppImage`、`Flatpak` 目前只在仓库脚本里支持 `x86_64`、`aarch64`
- 仓库内 Linux runner 已固定 `PIE` 编译和链接参数，Fedora / RHEL 这类默认启用硬化策略的宿主机不需要再额外传 `CFLAGS`、`CXXFLAGS`、`LDFLAGS`

## 当前验证结果

以下结果已于 `2026-03-14` 在当前 Linux 开发环境验证通过：

- `dart format lib test`
- `flutter analyze`
- `flutter test`
- `flutter build apk --release`
- `flutter build web`
- `flutter build linux --debug`

以下结果已于 `2026-03-20` 在当前 Linux 开发环境补充验证通过：

- `flutter build appbundle --release`
- `flutter build apk --release --split-per-abi`
- `flutter build linux --release`
- `tool/package_linux_all.sh build/linux/x64/release/bundle release 0.1.7+1 x64`

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

## 历史主分支说明

以下内容保留主分支原有模块说明，作为云边端协同链路的历史文档，不参与当前客户端发布产物构建。

### 原主分支标题

基于云边端协同与自主决策驱动的多模态石斛培育平台

### 原主分支说明

当前 `main` 分支只合并了 3 个已经完成集成的模块，用于设备侧采集、边缘网关和端侧视觉能力联调。其余模块尚未合并到本仓库，因此当前这里不是完整项目全貌，而是当前已收敛的核心代码集合。

### 原主分支已合并模块

#### `stm32f429-modbus-gateway`

该模块对应 `STM32F429` 采集网关工程，负责：

- 作为 `Modbus-RTU` 主站轮询 3 个 `STM32F103` 从站
- 采集光照、温湿度、气体等寄存器数据
- 通过以太网把 `MODBUS_SNAPSHOT` 快照上报到 `RK3568`

适合阅读对象：

- 嵌入式采集侧开发
- Modbus-RTU 主从通信联调
- STM32 与 RK3568 边缘上报链路联调

入口文件：

- `stm32f429-modbus-gateway/README.md`

#### `rk3568-edgelink-gateway`

该模块对应 `RK3568` 边缘网关工程，负责：

- 接收 `STM32F429` 的 HTTP 上报并桥接到 `OneNET`
- 接收 `K230` 的 `AI JSON`
- 使用 `go2rtc + frp` 提供视频流接入与公网播放能力
- 预留 AI 结果继续转发到 Java 后端的能力

适合阅读对象：

- 边缘网关与云平台对接开发
- 视频接入与公网映射联调
- Java 后端、前端协作者

入口文件：

- `rk3568-edgelink-gateway/README.md`
- `rk3568-edgelink-gateway/docs/video-v1.md`
- `rk3568-edgelink-gateway/docs/java-video-collaboration.md`
- `rk3568-edgelink-gateway/docs/java-ai-collaboration.md`

#### `k230-rtsp-ai-gateway`

该模块对应 `K230` 侧脚本工程，负责：

- 通过 `Wi-Fi` 入网
- 本地执行 `YOLO11 OBB` 推理
- 通过 `RTSP` 输出视频流
- 把检测结果按帧批量上送到 `RK3568 /api/ai`

适合阅读对象：

- K230 端侧 AI 开发
- 视频流输出与边缘网关联调
- 目标检测结果结构化上送联调

入口文件：

- `k230-rtsp-ai-gateway/README.md`

### 原主分支模块关系

当前仓库中的 3 个模块构成了两条并行链路：

1. `STM32F429 -> RK3568 -> OneNET`
2. `K230 -> RK3568 /api/ai`
3. `K230 -> RK3568 go2rtc/frp -> 浏览器`

对应职责：

- `stm32f429-modbus-gateway` 负责采集和上报
- `rk3568-edgelink-gateway` 负责接收、转换和上云，以及视频接入、公网映射和播放入口
- `k230-rtsp-ai-gateway` 负责本地推理、RTSP 输出和 AI 结果上送

### 原主分支目录导航

原主分支根目录结构如下：

```text
README.md
stm32f429-modbus-gateway/
rk3568-edgelink-gateway/
k230-rtsp-ai-gateway/
```

建议阅读顺序：

1. 先看本文件，了解仓库整体结构
2. 再看 `stm32f429-modbus-gateway/README.md`，了解采集侧链路
3. 再看 `rk3568-edgelink-gateway/README.md` 和 `docs/`，了解边缘网关、视频链路和协作接口
4. 最后看 `k230-rtsp-ai-gateway/README.md`，了解 K230 侧运行方式

### 原主分支边界说明

- 当前仓库只包含已经合并进 `main` 的 3 个模块，不代表整体项目全部代码
- Java 后端和前端的协作接口说明写在 `rk3568-edgelink-gateway/docs/` 中，它们不是本仓库下独立模块目录
- AI 检测结果默认先到 `RK3568` 网关；是否继续转发到 Java 后端取决于网关配置
- 公网视频访问当前依赖 `go2rtc + frp`，不是由 Java 服务代理媒体流
- 后续若有其他模块合并进仓库，应继续按目录级独立收纳，并在本 README 中补充说明，而不是把不同模块的职责混写到一起

# 基于云-边-端协同驱动的多模态石斛智慧培育平台

> 版权所有：安徽信息工程学院计算机视觉实验室

当前 `main` 分支只合并了 3 个已经完成集成的模块，用于设备侧采集、边缘网关和端侧视觉能力联调。其余模块尚未合并到本仓库，因此当前这里不是完整项目全貌，而是当前已收敛的核心代码集合。

## 声明

- 本项目除子目录另有许可证声明外，默认使用 [GNU Affero General Public License v3.0](LICENSE) 开源。

- 本项目 logo 并非使用 AGPL-3.0 协议开源，安徽信息工程学院计算机视觉实验室及项目全体开发者保留所有权利。不得以 AGPL-3.0 已授权为由在未经授权的情况下使用本项目 logo，不得在未经授权的情况下将本项目 logo 用于任何商业用途。

- 本项目开源以学习交流为主要目的。若您遇到商家使用本项目进行收费，产生的问题及后果与本项目无关。

## 当前已合并模块

### `stm32f429-modbus-gateway`

该模块对应 `STM32F429` 采集网关工程，负责：

- 作为 `Modbus-RTU` 主站轮询 3 个 `STM32F103` 从站
- 采集光照、温湿度、气体等寄存器数据
- 通过以太网把 `MODBUS_SNAPSHOT` 快照上报到 `RK3568`

适合阅读对象：

- 嵌入式采集侧开发
- Modbus-RTU 主从通信联调
- STM32 与 RK3568 边缘上报链路联调

入口文件：

- [`stm32f429-modbus-gateway/README.md`](stm32f429-modbus-gateway/README.md)

### `rk3568-edgelink-gateway`

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

- [`rk3568-edgelink-gateway/README.md`](rk3568-edgelink-gateway/README.md)
- [`rk3568-edgelink-gateway/docs/video-v1.md`](rk3568-edgelink-gateway/docs/video-v1.md)
- [`rk3568-edgelink-gateway/docs/java-video-collaboration.md`](rk3568-edgelink-gateway/docs/java-video-collaboration.md)
- [`rk3568-edgelink-gateway/docs/java-ai-collaboration.md`](rk3568-edgelink-gateway/docs/java-ai-collaboration.md)

### `k230-rtsp-ai-gateway`

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

- [`k230-rtsp-ai-gateway/README.md`](k230-rtsp-ai-gateway/README.md)

## 模块之间的关系

当前仓库中的 3 个模块构成了两条并行链路：

1. `STM32F429 -> RK3568 -> OneNET`
   - `stm32f429-modbus-gateway` 负责采集和上报
   - `rk3568-edgelink-gateway` 负责接收、转换和上云

2. `K230 -> RK3568 /api/ai`
   - `k230-rtsp-ai-gateway` 负责本地推理并上送 AI 结果
   - `rk3568-edgelink-gateway` 负责接收 AI 结果，并可按配置继续转发到 Java 后端

3. `K230 -> RK3568 go2rtc/frp -> 浏览器`
   - `k230-rtsp-ai-gateway` 提供 `RTSP`
   - `rk3568-edgelink-gateway` 负责视频接入、公网映射和播放入口

## 目录导航

当前 `main` 根目录结构如下：

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

## 当前边界

为避免误导协作者，这里明确几点：

- 当前仓库只包含已经合并进 `main` 的 3 个模块，不代表整体项目全部代码
- Java 后端和前端的协作接口说明写在 `rk3568-edgelink-gateway/docs/` 中，它们不是本仓库下独立模块目录
- AI 检测结果默认先到 `RK3568` 网关；是否继续转发到 Java 后端取决于网关配置
- 公网视频访问当前依赖 `go2rtc + frp`，不是由 Java 服务代理媒体流

后续若有其他模块合并进仓库，应继续按目录级独立收纳，并在本 README 中补充说明，而不是把不同模块的职责混写到一起。

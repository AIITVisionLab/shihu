# 多模态石斛培育平台仓库

> 版权所有：安徽信息工程学院计算机视觉实验室

## 仓库说明

当前仓库已经按模块级目录重新收口，客户端源码不再直接铺在仓库根目录。

当前目录划分：

- `husheng-client/`：Flutter 跨平台客户端工程
- `stm32f429-modbus-gateway/`：STM32F429 采集网关工程
- `rk3568-edgelink-gateway/`：RK3568 边缘网关工程
- `k230-rtsp-ai-gateway/`：K230 端侧 AI 与 RTSP 脚本工程

客户端入口：

- [husheng-client/README.md](husheng-client/README.md)

## 声明

- 本项目除子目录另有许可证声明外，默认使用 [GNU Affero General Public License v3.0](LICENSE) 开源
- 本项目 logo 并非使用 AGPL-3.0 协议开源，安徽信息工程学院计算机视觉实验室及项目全体开发者保留所有权利。不得以 AGPL-3.0 已授权为由在未经授权的情况下使用本项目 logo，不得在未经授权的情况下将本项目 logo 用于任何商业用途
- 本项目开源以学习交流为主要目的。若您遇到商家使用本项目进行收费，产生的问题及后果与本项目无关

## 客户端说明

当前主线客户端已经独立放入 `husheng-client/`，后续客户端开发、构建、打包和发布均以该目录为准，不再直接依赖仓库根目录。

客户端相关中文文档位于：

- `husheng-client/doc/`

客户端发布工作流仍保留在仓库根目录：

- `.github/workflows/release.yml`

## 历史模块说明

以下内容保留原主分支模块级说明，作为云边端协同链路参考。

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

- `stm32f429-modbus-gateway/README.md`

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

- `rk3568-edgelink-gateway/README.md`
- `rk3568-edgelink-gateway/docs/video-v1.md`
- `rk3568-edgelink-gateway/docs/java-video-collaboration.md`
- `rk3568-edgelink-gateway/docs/java-ai-collaboration.md`

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

- `k230-rtsp-ai-gateway/README.md`

## 模块关系

当前仓库中的云边端链路主要包括：

1. `STM32F429 -> RK3568 -> OneNET`
2. `K230 -> RK3568 /api/ai`
3. `K230 -> RK3568 go2rtc/frp -> 浏览器`
4. `Flutter Client -> Java Backend / Edge Gateway`

对应职责：

- `stm32f429-modbus-gateway` 负责采集和上报
- `rk3568-edgelink-gateway` 负责接收、转换和上云，以及视频接入、公网映射和播放入口
- `k230-rtsp-ai-gateway` 负责本地推理、RTSP 输出和 AI 结果上送
- `husheng-client` 负责多平台客户端值守、监控、视频查看和配置操作

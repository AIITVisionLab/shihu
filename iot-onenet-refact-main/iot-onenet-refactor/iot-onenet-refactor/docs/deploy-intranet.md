# 内网服务器部署

这套项目适合用单 `jar` 直接部署到内网 Linux 服务器。仓库里已经补了可直接使用的部署模板：

- `deploy/linux/application-prod.yml`
- `deploy/linux/iot-onenet.env.example`
- `deploy/linux/start.sh`
- `deploy/linux/iot-onenet.service`
- `deploy/linux/install.sh`

默认方案是：

- 应用目录：`/opt/iot-onenet`
- 配置目录：`/etc/iot-onenet`
- 业务日志文件：`/var/log/iot-onenet/platform-events.jsonl`
- 进程管理：`systemd`
- 服务端口：`8085`

`application-prod.yml` 已经把 `onenet.pulsar.auto-open-dashboard` 默认改成 `false`，避免在无桌面的服务器上启动时尝试打开浏览器。

## 1. 构建可运行包

如果内网服务器不能访问 Maven 仓库，建议在当前开发机先打包，再把 `target/*.jar` 和 `deploy/linux` 目录拷到服务器。

在项目根目录执行：

```bash
./.tools/apache-maven-3.9.9/bin/mvn clean package -DskipTests
```

Windows 下可执行：

```powershell
.\.tools\apache-maven-3.9.9\bin\mvn.cmd clean package -DskipTests
```

打包完成后会生成：

```text
target/iot-onenet-refactor-1.0.0.jar
```

## 2. 服务器准备

服务器至少需要：

- Linux
- JDK 17
- `systemd`
- 能访问 OneNET OpenAPI 和 OneNET Pulsar
- 防火墙放行应用端口，比如 `8085`

安装 JDK 后确认：

```bash
java -version
systemctl --version
```

## 3. 上传文件

把下面这些内容上传到服务器同一个目录：

- `target/iot-onenet-refactor-1.0.0.jar`
- `deploy/linux/`

例如上传到 `/tmp/iot-onenet/`。

## 4. 安装 systemd 服务

进入上传目录后执行：

```bash
sudo bash deploy/linux/install.sh
```

这个脚本会自动完成：

- 创建系统用户 `iot-onenet`
- 安装 jar 到 `/opt/iot-onenet/app.jar`
- 安装启动脚本到 `/opt/iot-onenet/bin/start.sh`
- 安装配置到 `/etc/iot-onenet/`
- 安装 systemd 服务 `iot-onenet.service`
- 设置开机自启

如果你要改安装路径，可以先导出环境变量再执行，例如：

```bash
sudo APP_HOME=/data/iot-onenet CONF_HOME=/data/iot-onenet/conf bash deploy/linux/install.sh
```

## 5. 修改生产配置

安装完成后，先编辑：

```bash
sudo vi /etc/iot-onenet/iot-onenet.env
```

至少需要填写这些值：

```dotenv
ONENET_PRODUCT_ID=你的产品ID
ONENET_AUTHORIZATION=你的OneNET授权头
ONENET_PULSAR_ACCESS_ID=你的Pulsar AccessId
ONENET_PULSAR_SECRET_KEY=你的Pulsar SecretKey
ONENET_PULSAR_SUBSCRIPTION_NAME=你的订阅名
APP_LOGIN_USERNAME=后台登录用户名
APP_LOGIN_PASSWORD=后台登录密码
```

如果视频流地址、日志路径、端口要改，也在这个文件里调整。

`/etc/iot-onenet/application-prod.yml` 一般不需要改；它主要负责生产环境默认值和 Spring Boot 结构化配置。

## 6. 重启并验证

修改配置后执行：

```bash
sudo systemctl start iot-onenet
sudo systemctl status iot-onenet --no-pager
sudo journalctl -u iot-onenet -n 200 --no-pager
```

健康检查：

```bash
curl http://127.0.0.1:8085/api/health
```

如果返回 `ok`，说明 HTTP 服务已经起来。

内网其他机器访问时，把 `127.0.0.1` 换成服务器内网 IP：

```text
http://<server-ip>:8085/login.html
```

## 7. 常用运维命令

```bash
sudo systemctl start iot-onenet
sudo systemctl stop iot-onenet
sudo systemctl restart iot-onenet
sudo systemctl status iot-onenet --no-pager
sudo journalctl -u iot-onenet -f
```

## 8. 可选：放到 Nginx 后面

如果你不想让用户直接访问 `8085`，可以让 Nginx 反向代理到本机：

```nginx
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8085;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

这样内网用户就可以直接通过 `http://<server-ip>/login.html` 访问。

## 9. 常见问题

### 启动后马上退出

先看：

```bash
sudo journalctl -u iot-onenet -n 200 --no-pager
```

常见原因：

- `ONENET_*` 凭据没填
- JDK 版本低于 17
- `/etc/iot-onenet/iot-onenet.env` 权限不对
- 服务器无法连通 OneNET 或 Pulsar

### 服务起来了但设备状态没更新

重点检查：

- `ONENET_PULSAR_ACCESS_ID`
- `ONENET_PULSAR_SECRET_KEY`
- `ONENET_PULSAR_SUBSCRIPTION_NAME`
- 服务器到 `iot-north-mq.heclouds.com:6651` 的网络连通性

### 页面能打开但视频不可用

默认生产配置里 `APP_VIDEO_AVAILABLE=false`。如果内网环境里有可用的视频网关，再把下面这些值改成你的地址：

```dotenv
APP_VIDEO_AVAILABLE=true
APP_VIDEO_GATEWAY_PAGE_URL=http://你的网关地址/
APP_VIDEO_PLAYER_URL=http://你的播放器地址/
APP_VIDEO_PUBLIC_HOST=你的公网或内网主机名
APP_VIDEO_WEBRTC_PORT=你的webrtc端口
```

/// 应用级常量定义，避免业务代码散落硬编码值。
class AppConstants {
  /// 应用中文名称。
  static const String appName = '斛生';

  /// 应用默认包名，供不支持原生版本插件的平台兜底使用。
  static const String defaultPackageName = 'com.aiitvisionlab.husheng';

  /// 首页与启动页使用的项目标语。
  static const String appTagline = '石斛培育环境监测与远程调控';

  /// 当前应用语义化版本号，默认跟随 `pubspec.yaml` 的 `version`。
  static const String appVersion = String.fromEnvironment(
    'FLUTTER_BUILD_NAME',
    defaultValue: '0.1.0',
  );

  /// 当前应用构建号，默认跟随 `pubspec.yaml` 的 `version`。
  static const String appBuildNumber = String.fromEnvironment(
    'FLUTTER_BUILD_NUMBER',
    defaultValue: '1',
  );

  /// 设置项本地存储键。
  static const String settingsStorageKey = 'app_settings';

  /// 登录会话本地存储键。
  static const String authSessionStorageKey = 'auth_session';

  /// 登录页记住用户名的本地存储键。
  static const String rememberedAccountStorageKey = 'remembered_account';

  /// 当前默认公网业务服务地址。
  ///
  /// Flutter 客户端正式接入 `iot-onenet-refact-main` 这套业务后端，
  /// 默认优先指向当前已部署的公网反向代理入口。
  static const String defaultBaseUrl = 'http://101.35.79.76';

  /// 本地联调时使用的业务服务地址。
  ///
  /// 如需切回本机 Spring Boot 服务，可通过 `--dart-define=BASE_URL=...`
  /// 或设置页把地址改回这里。
  static const String localDevelopmentBaseUrl = 'http://127.0.0.1:8085';

  /// 当前默认公网视频网关地址。
  static const String defaultVideoGatewayUrl = 'http://101.35.79.76:1984';

  /// 当前默认视频流标识。
  static const String defaultVideoStreamId = 'k230';

  /// 当前默认视频流展示名称。
  static const String defaultVideoDisplayName = 'K230 实时视频流';

  /// 当前默认视频优先播放模式。
  static const String defaultVideoPreferredMode = 'webrtc';

  /// 当前默认视频回退播放模式。
  static const String defaultVideoFallbackMode = 'mse';

  /// 当前默认视频 WebRTC 端口。
  static const int defaultVideoWebrtcPort = 8555;

  /// 默认连接超时时间。
  static const int defaultConnectTimeoutMs = 10000;

  /// 默认接收超时时间。
  static const int defaultReceiveTimeoutMs = 15000;

  /// 启动页最小停留时长。
  static const Duration splashDuration = Duration(milliseconds: 1400);
}

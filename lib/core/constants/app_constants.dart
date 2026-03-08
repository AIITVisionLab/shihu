/// 应用级常量定义，避免业务代码散落硬编码值。
class AppConstants {
  /// 应用中文名称。
  static const String appName = '石斛病虫害识别';

  /// 应用默认包名，供不支持原生版本插件的平台兜底使用。
  static const String defaultPackageName = 'com.example.sickandflutter';

  /// 首页与启动页使用的项目标语。
  static const String appTagline = '面向石斛种植场景的病害、虫害与健康状态识别';

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

  /// 历史记录本地存储键。
  static const String historyStorageKey = 'history_records';

  /// 设置项本地存储键。
  static const String settingsStorageKey = 'app_settings';

  /// 登录会话本地存储键。
  static const String authSessionStorageKey = 'auth_session';

  /// 默认基础服务地址。
  static const String defaultBaseUrl = 'http://127.0.0.1:8080';

  /// 默认连接超时时间。
  static const int defaultConnectTimeoutMs = 10000;

  /// 默认接收超时时间。
  static const int defaultReceiveTimeoutMs = 15000;

  /// 启动页最小停留时长。
  static const Duration splashDuration = Duration(milliseconds: 1400);
}

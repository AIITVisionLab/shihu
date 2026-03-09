/// 应用级常量定义，避免业务代码散落硬编码值。
class AppConstants {
  /// 应用中文名称。
  static const String appName = '石斛幼苗智能培育管理平台';

  /// 应用默认包名，供不支持原生版本插件的平台兜底使用。
  static const String defaultPackageName = 'com.example.sickandflutter';

  /// 首页与启动页使用的项目标语。
  static const String appTagline = '面向石斛培育场景的设备监测、环境采集与远程控制';

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

  /// 登录页记住用户名的本地存储键。
  static const String rememberedAccountStorageKey = 'remembered_account';

  /// 默认基础服务地址。
  ///
  /// 当前仓库默认对接已经部署的 `web` 后端，
  /// 避免开发环境误连到本机无关端口。
  static const String defaultBaseUrl = 'http://101.35.79.76:8082';

  /// 默认连接超时时间。
  static const int defaultConnectTimeoutMs = 10000;

  /// 默认接收超时时间。
  static const int defaultReceiveTimeoutMs = 15000;

  /// 启动页最小停留时长。
  static const Duration splashDuration = Duration(milliseconds: 1400);
}

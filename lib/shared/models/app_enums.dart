/// 构建环境枚举。
enum BuildFlavor {
  /// 开发环境。
  development,

  /// 测试环境。
  staging,

  /// 正式环境。
  production,
}

/// 根据字符串解析构建环境。
BuildFlavor buildFlavorFromValue(String? value) {
  switch (value) {
    case 'production':
      return BuildFlavor.production;
    case 'staging':
      return BuildFlavor.staging;
    default:
      return BuildFlavor.development;
  }
}

/// 提供构建环境的标准值和展示文案。
extension BuildFlavorX on BuildFlavor {
  /// 接口和存储使用的原始值。
  String get value {
    switch (this) {
      case BuildFlavor.development:
        return 'development';
      case BuildFlavor.staging:
        return 'staging';
      case BuildFlavor.production:
        return 'production';
    }
  }

  /// 面向界面的中文文案。
  String get label {
    switch (this) {
      case BuildFlavor.development:
        return '开发环境';
      case BuildFlavor.staging:
        return '测试环境';
      case BuildFlavor.production:
        return '正式环境';
    }
  }

  /// 是否为正式环境。
  bool get isProduction => this == BuildFlavor.production;
}

/// 登录模式枚举。
enum AuthLoginMode {
  /// 在线服务登录。
  real,

  /// 联调登录。
  mock,
}

/// 根据字符串解析登录模式。
AuthLoginMode authLoginModeFromValue(String? value) {
  switch (value) {
    case 'mock':
    case '联调登录':
    case '受控演示登录':
      return AuthLoginMode.mock;
    case 'real':
    case '在线服务登录':
    case '真实接口登录':
    default:
      return AuthLoginMode.real;
  }
}

/// 提供登录模式的标准值和展示文案。
extension AuthLoginModeX on AuthLoginMode {
  /// 接口和存储使用的原始值。
  String get value {
    switch (this) {
      case AuthLoginMode.real:
        return 'real';
      case AuthLoginMode.mock:
        return 'mock';
    }
  }

  /// 面向界面的中文文案。
  String get label {
    switch (this) {
      case AuthLoginMode.real:
        return '在线服务登录';
      case AuthLoginMode.mock:
        return '联调登录';
    }
  }
}

/// 平台类型枚举。
enum PlatformType {
  /// Android。
  android,

  /// iOS。
  ios,

  /// macOS。
  macos,

  /// Web。
  web,

  /// Windows。
  windows,

  /// Linux。
  linux,

  /// OpenHarmony / 鸿蒙。
  ohos,
}

/// 根据字符串解析平台类型。
PlatformType? tryPlatformTypeFromValue(String? value) {
  switch (value) {
    case 'android':
      return PlatformType.android;
    case 'ios':
      return PlatformType.ios;
    case 'macos':
      return PlatformType.macos;
    case 'web':
      return PlatformType.web;
    case 'windows':
      return PlatformType.windows;
    case 'linux':
      return PlatformType.linux;
    case 'openharmony':
    case 'harmonyos':
    case 'ohos':
      return PlatformType.ohos;
    default:
      return null;
  }
}

/// 提供平台类型的标准值。
extension PlatformTypeX on PlatformType {
  /// 接口和存储使用的原始值。
  String get value {
    switch (this) {
      case PlatformType.android:
        return 'android';
      case PlatformType.ios:
        return 'ios';
      case PlatformType.macos:
        return 'macos';
      case PlatformType.web:
        return 'web';
      case PlatformType.windows:
        return 'windows';
      case PlatformType.linux:
        return 'linux';
      case PlatformType.ohos:
        return 'ohos';
    }
  }

  /// 面向界面的中文文案。
  String get label {
    switch (this) {
      case PlatformType.android:
        return 'Android';
      case PlatformType.ios:
        return 'iOS';
      case PlatformType.macos:
        return 'macOS';
      case PlatformType.web:
        return 'Web';
      case PlatformType.windows:
        return 'Windows';
      case PlatformType.linux:
        return 'Linux';
      case PlatformType.ohos:
        return 'OpenHarmony / 鸿蒙';
    }
  }
}

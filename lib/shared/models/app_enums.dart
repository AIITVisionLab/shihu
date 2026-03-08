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

/// 识别任务来源枚举。
enum SourceType {
  /// 单图识别来源。
  image,

  /// 实时识别来源。
  realtime,

  /// 历史记录详情来源。
  history,
}

/// 根据字符串解析识别任务来源。
SourceType sourceTypeFromValue(String? value) {
  switch (value) {
    case 'realtime':
      return SourceType.realtime;
    case 'history':
      return SourceType.history;
    default:
      return SourceType.image;
  }
}

/// 提供识别任务来源的标准值。
extension SourceTypeX on SourceType {
  /// 接口和存储使用的原始值。
  String get value {
    switch (this) {
      case SourceType.image:
        return 'image';
      case SourceType.realtime:
        return 'realtime';
      case SourceType.history:
        return 'history';
    }
  }
}

/// 识别类别枚举。
enum DetectionCategory {
  /// 病害。
  disease,

  /// 虫害。
  insect,

  /// 健康。
  healthy,

  /// 未知。
  unknown,
}

/// 根据字符串解析识别类别。
DetectionCategory detectionCategoryFromValue(String? value) {
  switch (value) {
    case 'insect':
      return DetectionCategory.insect;
    case 'healthy':
      return DetectionCategory.healthy;
    case 'unknown':
      return DetectionCategory.unknown;
    default:
      return DetectionCategory.disease;
  }
}

/// 提供识别类别的标准值和展示文案。
extension DetectionCategoryX on DetectionCategory {
  /// 接口和存储使用的原始值。
  String get value {
    switch (this) {
      case DetectionCategory.disease:
        return 'disease';
      case DetectionCategory.insect:
        return 'insect';
      case DetectionCategory.healthy:
        return 'healthy';
      case DetectionCategory.unknown:
        return 'unknown';
    }
  }

  /// 面向界面的中文文案。
  String get label {
    switch (this) {
      case DetectionCategory.disease:
        return '病害';
      case DetectionCategory.insect:
        return '虫害';
      case DetectionCategory.healthy:
        return '健康';
      case DetectionCategory.unknown:
        return '未知';
    }
  }
}

/// 严重程度枚举。
enum SeverityLevel {
  /// 无明显异常。
  none,

  /// 轻度。
  low,

  /// 中度。
  medium,

  /// 重度。
  high,

  /// 严重。
  critical,
}

/// 根据字符串解析严重程度。
SeverityLevel severityLevelFromValue(String? value) {
  switch (value) {
    case 'none':
      return SeverityLevel.none;
    case 'low':
      return SeverityLevel.low;
    case 'high':
      return SeverityLevel.high;
    case 'critical':
      return SeverityLevel.critical;
    default:
      return SeverityLevel.medium;
  }
}

/// 提供严重程度的标准值和展示文案。
extension SeverityLevelX on SeverityLevel {
  /// 接口和存储使用的原始值。
  String get value {
    switch (this) {
      case SeverityLevel.none:
        return 'none';
      case SeverityLevel.low:
        return 'low';
      case SeverityLevel.medium:
        return 'medium';
      case SeverityLevel.high:
        return 'high';
      case SeverityLevel.critical:
        return 'critical';
    }
  }

  /// 面向界面的中文文案。
  String get label {
    switch (this) {
      case SeverityLevel.none:
        return '无明显异常';
      case SeverityLevel.low:
        return '轻度';
      case SeverityLevel.medium:
        return '中度';
      case SeverityLevel.high:
        return '重度';
      case SeverityLevel.critical:
        return '严重';
    }
  }
}

/// 健康状态枚举。
enum HealthStatus {
  /// 健康。
  healthy,

  /// 风险。
  risk,

  /// 异常。
  abnormal,

  /// 未知。
  unknown,
}

/// 根据字符串解析健康状态。
HealthStatus healthStatusFromValue(String? value) {
  switch (value) {
    case 'healthy':
      return HealthStatus.healthy;
    case 'risk':
      return HealthStatus.risk;
    case 'unknown':
      return HealthStatus.unknown;
    default:
      return HealthStatus.abnormal;
  }
}

/// 提供健康状态的标准值和展示文案。
extension HealthStatusX on HealthStatus {
  /// 接口和存储使用的原始值。
  String get value {
    switch (this) {
      case HealthStatus.healthy:
        return 'healthy';
      case HealthStatus.risk:
        return 'risk';
      case HealthStatus.abnormal:
        return 'abnormal';
      case HealthStatus.unknown:
        return 'unknown';
    }
  }

  /// 面向界面的中文文案。
  String get label {
    switch (this) {
      case HealthStatus.healthy:
        return '健康';
      case HealthStatus.risk:
        return '风险';
      case HealthStatus.abnormal:
        return '异常';
      case HealthStatus.unknown:
        return '未知';
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

/// 识别任务执行状态枚举。
enum DetectTaskStatus {
  /// 未开始。
  idle,

  /// 进行中。
  running,

  /// 已成功。
  success,

  /// 已失败。
  failed,
}

/// 提供识别任务状态的标准值。
extension DetectTaskStatusX on DetectTaskStatus {
  /// 接口和存储使用的原始值。
  String get value {
    switch (this) {
      case DetectTaskStatus.idle:
        return 'idle';
      case DetectTaskStatus.running:
        return 'running';
      case DetectTaskStatus.success:
        return 'success';
      case DetectTaskStatus.failed:
        return 'failed';
    }
  }
}

/// 实时识别会话状态枚举。
enum RealtimeSessionStatus {
  /// 未开始。
  idle,

  /// 正在初始化。
  initializing,

  /// 运行中。
  running,

  /// 已暂停。
  paused,

  /// 权限受限。
  permissionDenied,

  /// 已失败。
  error,
}

/// 提供实时识别会话状态的标准值和展示文案。
extension RealtimeSessionStatusX on RealtimeSessionStatus {
  /// 接口和存储使用的原始值。
  String get value {
    switch (this) {
      case RealtimeSessionStatus.idle:
        return 'idle';
      case RealtimeSessionStatus.initializing:
        return 'initializing';
      case RealtimeSessionStatus.running:
        return 'running';
      case RealtimeSessionStatus.paused:
        return 'paused';
      case RealtimeSessionStatus.permissionDenied:
        return 'permissionDenied';
      case RealtimeSessionStatus.error:
        return 'error';
    }
  }

  /// 面向界面的中文文案。
  String get label {
    switch (this) {
      case RealtimeSessionStatus.idle:
        return '未开始';
      case RealtimeSessionStatus.initializing:
        return '初始化中';
      case RealtimeSessionStatus.running:
        return '运行中';
      case RealtimeSessionStatus.paused:
        return '已暂停';
      case RealtimeSessionStatus.permissionDenied:
        return '权限受限';
      case RealtimeSessionStatus.error:
        return '异常';
    }
  }
}

import 'package:sickandflutter/shared/models/model_utils.dart';

/// 设备运行等级。
enum DeviceAlertLevel {
  /// 正常。
  safe,

  /// 预警。
  warning,

  /// 告警。
  danger,

  /// 未知。
  unknown,
}

/// 后端 `/api/status` 返回的设备运行时状态实体。
class DeviceStatus {
  /// 创建设备状态对象。
  const DeviceStatus({
    required this.deviceId,
    required this.deviceName,
    required this.temperature,
    this.temperatureUnit = '°C',
    required this.humidity,
    this.humidityUnit = '%',
    required this.light,
    this.lightUnit = 'Lux',
    required this.mq2,
    this.mq2Unit = 'ppm',
    required this.errorCode,
    required this.ledOn,
    required this.updatedAt,
  });

  /// 从 JSON 构建设备状态对象。
  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      deviceId: asString(json['deviceId']),
      deviceName: asString(json['deviceName']),
      temperature: _sensorValue(json['temperature']),
      temperatureUnit: _sensorUnit(json['temperature'], fallback: '°C'),
      humidity: _sensorValue(json['humidity']),
      humidityUnit: _sensorUnit(json['humidity'], fallback: '%'),
      light: _sensorValue(json['light']),
      lightUnit: _sensorUnit(json['light'], fallback: 'Lux'),
      mq2: _sensorValue(json['mq2']),
      mq2Unit: _sensorUnit(json['mq2'], fallback: 'ppm'),
      errorCode: _intValue(json['error']),
      ledOn: _boolValue(json['led']),
      updatedAt: asInt(json['updatedAt'], fallback: 0),
    );
  }

  /// 设备 ID。
  final String deviceId;

  /// 设备名称。
  final String deviceName;

  /// 温度值。
  final double? temperature;

  /// 温度单位。
  final String temperatureUnit;

  /// 湿度值。
  final double? humidity;

  /// 湿度单位。
  final String humidityUnit;

  /// 光照值。
  final double? light;

  /// 光照单位。
  final String lightUnit;

  /// MQ2 值。
  final double? mq2;

  /// MQ2 单位。
  final String mq2Unit;

  /// 错误码。
  final int? errorCode;

  /// LED 是否开启。
  final bool? ledOn;

  /// 更新时间戳（毫秒）。
  final int updatedAt;

  /// 更新时间。
  DateTime? get updatedAtTime {
    if (updatedAt <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(updatedAt).toLocal();
  }

  /// 当前数据距参考时间已经过了多久。
  Duration? ageSince([DateTime? referenceTime]) {
    final updatedAtTime = this.updatedAtTime;
    if (updatedAtTime == null) {
      return null;
    }

    final now = referenceTime ?? DateTime.now();
    final difference = now.difference(updatedAtTime);
    if (difference.isNegative) {
      return Duration.zero;
    }
    return difference;
  }

  /// 当前状态是否仍在新鲜窗口内。
  bool isFresh({
    DateTime? referenceTime,
    Duration threshold = const Duration(seconds: 18),
  }) {
    final age = ageSince(referenceTime);
    if (age == null) {
      return false;
    }
    return age <= threshold;
  }

  /// 当前运行等级。
  DeviceAlertLevel get alertLevel {
    switch (errorCode) {
      case 0:
        return DeviceAlertLevel.safe;
      case 1:
        return DeviceAlertLevel.warning;
      case 2:
        return DeviceAlertLevel.danger;
      default:
        return DeviceAlertLevel.unknown;
    }
  }

  /// 当前是否满足 LED 控制接口的最小请求条件。
  bool get canControlLed => deviceId.trim().isNotEmpty;

  /// 是否已收到后端设备上报。
  bool get hasReportedState =>
      deviceId.trim().isNotEmpty ||
      deviceName.trim().isNotEmpty ||
      updatedAt > 0 ||
      temperature != null ||
      humidity != null ||
      light != null ||
      mq2 != null;

  static double? _sensorValue(Object? rawValue) {
    final json = asStringMap(rawValue);
    if (json == null) {
      return null;
    }
    final value = json['value'];
    if (value == null) {
      return null;
    }
    return asDouble(value);
  }

  static String _sensorUnit(Object? rawValue, {required String fallback}) {
    final json = asStringMap(rawValue);
    if (json == null) {
      return fallback;
    }
    final unit = asString(json['unit'], fallback: fallback).trim();
    return unit.isEmpty ? fallback : unit;
  }

  static int? _intValue(Object? rawValue) {
    final json = asStringMap(rawValue);
    if (json == null || json['value'] == null) {
      return null;
    }
    return asInt(json['value']);
  }

  static bool? _boolValue(Object? rawValue) {
    final json = asStringMap(rawValue);
    if (json == null || json['value'] == null) {
      return null;
    }
    return asBool(json['value']);
  }
}

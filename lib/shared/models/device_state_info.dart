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

/// 后端 `/api/status` 返回的设备状态信息。
class DeviceStateInfo {
  /// 创建设备状态对象。
  const DeviceStateInfo({
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
  factory DeviceStateInfo.fromJson(Map<String, dynamic> json) {
    return DeviceStateInfo(
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
    return DateTime.fromMillisecondsSinceEpoch(updatedAt);
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

  /// 当前运行状态标题。
  String get alertTitle {
    switch (errorCode) {
      case 0:
        return '系统运行正常';
      case 1:
        return '设备需要人工复核';
      case 2:
        return '设备处于告警状态';
      default:
        return '状态来源待确认';
    }
  }

  /// 当前运行状态说明。
  String get alertDescription {
    switch (errorCode) {
      case 0:
        return '当前采集和控制链路处于正常区间，可以继续观察环境波动。';
      case 1:
        return '后端标记为预警状态，建议尽快复核设备环境并关注后续变化。';
      case 2:
        return '后端标记为严重告警，应优先处理设备或环境异常。';
      default:
        return '后端尚未返回可识别的异常码，当前前端按未知状态展示。';
    }
  }

  /// LED 状态文案。
  String get ledLabel {
    if (ledOn == null) {
      return '未知';
    }
    return ledOn! ? '已开启' : '已关闭';
  }

  /// 是否已收到后端设备上报。
  bool get hasReportedState =>
      deviceId.trim().isNotEmpty ||
      deviceName.trim().isNotEmpty ||
      updatedAt > 0 ||
      temperature != null ||
      humidity != null ||
      light != null ||
      mq2 != null;

  /// 以“值 + 单位”形式格式化传感器展示值。
  String formatMetric(
    double? value,
    String unit, {
    int fractionDigits = 1,
    String fallback = '--',
  }) {
    if (value == null) {
      return fallback;
    }

    final normalizedValue = value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(fractionDigits);
    final normalizedUnit = unit.trim();
    if (normalizedUnit.isEmpty) {
      return normalizedValue;
    }
    return '$normalizedValue $normalizedUnit';
  }

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

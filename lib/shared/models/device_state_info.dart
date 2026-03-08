import 'package:sickandflutter/shared/models/model_utils.dart';

/// 设备状态信息。
class DeviceStateInfo {
  /// 创建设备状态对象。
  const DeviceStateInfo({
    required this.deviceId,
    required this.deviceName,
    required this.temperature,
    required this.humidity,
    required this.light,
    required this.mq2,
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
      humidity: _sensorValue(json['humidity']),
      light: _sensorValue(json['light']),
      mq2: _sensorValue(json['mq2']),
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

  /// 湿度值。
  final double? humidity;

  /// 光照值。
  final double? light;

  /// MQ2 值。
  final double? mq2;

  /// 错误码。
  final int? errorCode;

  /// LED 是否开启。
  final bool? ledOn;

  /// 更新时间戳（毫秒）。
  final int updatedAt;

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

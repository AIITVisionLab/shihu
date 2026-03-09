import 'package:flutter/material.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';

/// 实时监控页使用的告警色板。
class RealtimeAlertPalette {
  /// 创建实时监控页告警色板。
  const RealtimeAlertPalette({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  /// 背景色。
  final Color backgroundColor;

  /// 前景色。
  final Color foregroundColor;
}

/// 根据告警等级返回展示色板。
RealtimeAlertPalette resolveRealtimeAlertPalette(DeviceAlertLevel? level) {
  switch (level) {
    case DeviceAlertLevel.safe:
      return const RealtimeAlertPalette(
        backgroundColor: Color(0xFFE8F7EB),
        foregroundColor: Color(0xFF166534),
      );
    case DeviceAlertLevel.warning:
      return const RealtimeAlertPalette(
        backgroundColor: Color(0xFFFFF4E5),
        foregroundColor: Color(0xFFB45309),
      );
    case DeviceAlertLevel.danger:
      return const RealtimeAlertPalette(
        backgroundColor: Color(0xFFFEEBEC),
        foregroundColor: Color(0xFFB91C1C),
      );
    case DeviceAlertLevel.unknown:
    case null:
      return const RealtimeAlertPalette(
        backgroundColor: Color(0xFFE5ECF5),
        foregroundColor: Color(0xFF475569),
      );
  }
}

/// 格式化设备文本，空值统一展示为 `--`。
String formatRealtimeDisplayText(String? value) {
  final normalizedValue = value?.trim() ?? '';
  return normalizedValue.isEmpty ? '--' : normalizedValue;
}

/// 格式化设备错误码。
String formatRealtimeErrorCode(DeviceStateInfo? deviceState) {
  final errorCode = deviceState?.errorCode;
  if (errorCode == null) {
    return '--';
  }
  return '$errorCode';
}

/// 格式化设备更新时间。
String formatRealtimeTimestamp(DateTime? value) {
  if (value == null) {
    return '--';
  }

  String twoDigits(int input) => input.toString().padLeft(2, '0');

  final year = value.year;
  final month = twoDigits(value.month);
  final day = twoDigits(value.day);
  final hour = twoDigits(value.hour);
  final minute = twoDigits(value.minute);
  final second = twoDigits(value.second);
  return '$year-$month-$day $hour:$minute:$second';
}

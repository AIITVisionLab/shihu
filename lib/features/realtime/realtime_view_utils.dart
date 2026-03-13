import 'package:flutter/material.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';

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
        backgroundColor: Color(0xFFEAF1EB),
        foregroundColor: Color(0xFF375844),
      );
    case DeviceAlertLevel.warning:
      return const RealtimeAlertPalette(
        backgroundColor: Color(0xFFF4EEDF),
        foregroundColor: Color(0xFF8A6633),
      );
    case DeviceAlertLevel.danger:
      return const RealtimeAlertPalette(
        backgroundColor: Color(0xFFF5E8E6),
        foregroundColor: Color(0xFF90514A),
      );
    case DeviceAlertLevel.unknown:
    case null:
      return const RealtimeAlertPalette(
        backgroundColor: Color(0xFFE7EBE6),
        foregroundColor: Color(0xFF556258),
      );
  }
}

/// 格式化设备文本，空值统一展示为 `--`。
String formatRealtimeDisplayText(String? value) {
  final normalizedValue = value?.trim() ?? '';
  return normalizedValue.isEmpty ? '--' : normalizedValue;
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

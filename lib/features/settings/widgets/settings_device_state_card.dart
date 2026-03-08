import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/settings/widgets/settings_setting_row.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 设备状态卡片。
class SettingsDeviceStateCard extends StatelessWidget {
  /// 创建设备状态卡片。
  const SettingsDeviceStateCard({
    required this.deviceStateAsync,
    required this.onRefresh,
    required this.onToggleLed,
    super.key,
  });

  /// 设备状态异步对象。
  final AsyncValue<DeviceStateInfo> deviceStateAsync;

  /// 刷新回调。
  final VoidCallback onRefresh;

  /// LED 开关回调。
  final Future<void> Function(DeviceStateInfo state, bool ledOn) onToggleLed;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '设备状态',
      subtitle: '来自 /api/status 与 /api/ops/led',
      child: deviceStateAsync.when(
        loading: () => const Text('正在拉取设备状态...'),
        error: (error, stackTrace) {
          final message = error is ApiException ? error.message : '$error';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          );
        },
        data: (state) {
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      state.deviceName.isEmpty
                          ? state.deviceId
                          : state.deviceName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Switch(
                    value: state.ledOn ?? false,
                    onChanged: (value) => onToggleLed(state, value),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SettingsSettingRow(
                title: '温度',
                value: _displayValue(state.temperature),
              ),
              const SizedBox(height: 8),
              SettingsSettingRow(
                title: '湿度',
                value: _displayValue(state.humidity),
              ),
              const SizedBox(height: 8),
              SettingsSettingRow(
                title: '光照',
                value: _displayValue(state.light),
              ),
              const SizedBox(height: 8),
              SettingsSettingRow(title: 'MQ2', value: _displayValue(state.mq2)),
              const SizedBox(height: 8),
              SettingsSettingRow(
                title: '错误码',
                value: state.errorCode == null ? '--' : '${state.errorCode}',
              ),
            ],
          );
        },
      ),
    );
  }

  String _displayValue(double? value) {
    if (value == null) {
      return '--';
    }
    return value.toStringAsFixed(2);
  }
}

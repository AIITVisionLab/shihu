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
      subtitle: '查看设备实时数据，并在状态完整时提交补光控制。',
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
                    onChanged: state.canControlLed
                        ? (value) => onToggleLed(state, value)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SettingsSettingRow(
                title: '温度',
                value: state.formatMetric(
                  state.temperature,
                  state.temperatureUnit,
                ),
              ),
              const SizedBox(height: 8),
              SettingsSettingRow(
                title: '湿度',
                value: state.formatMetric(state.humidity, state.humidityUnit),
              ),
              const SizedBox(height: 8),
              SettingsSettingRow(
                title: '光照',
                value: state.formatMetric(
                  state.light,
                  state.lightUnit,
                  fractionDigits: 0,
                ),
              ),
              const SizedBox(height: 8),
              SettingsSettingRow(
                title: 'MQ2',
                value: state.formatMetric(state.mq2, state.mq2Unit),
              ),
              const SizedBox(height: 8),
              SettingsSettingRow(
                title: '错误码',
                value: state.errorCode == null
                    ? '--'
                    : '${state.errorCode} · ${state.alertTitle}',
              ),
              const SizedBox(height: 8),
              SettingsSettingRow(
                title: 'LED 控制',
                value: state.canControlLed ? '可用' : '等待设备身份上报',
              ),
            ],
          );
        },
      ),
    );
  }
}

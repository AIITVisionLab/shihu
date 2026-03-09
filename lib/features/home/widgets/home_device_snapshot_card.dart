import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 首页设备快照卡片。
class HomeDeviceSnapshotCard extends StatelessWidget {
  /// 创建首页设备快照卡片。
  const HomeDeviceSnapshotCard({
    required this.deviceStateAsync,
    required this.onRefresh,
    super.key,
  });

  /// 设备状态异步值。
  final AsyncValue<DeviceStateInfo> deviceStateAsync;

  /// 刷新回调。
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '设备摘要',
      subtitle: '首页直接展示当前设备上报快照，完整监控和控制请进入主控台。',
      child: deviceStateAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
        error: (error, stackTrace) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('设备状态获取失败：$error'),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重新拉取'),
            ),
          ],
        ),
        data: (deviceState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  deviceState.deviceName.trim().isEmpty
                      ? deviceState.deviceId
                      : deviceState.deviceName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                _SnapshotStatusChip(deviceState: deviceState),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '最近上报：${_formatDateTime(deviceState.updatedAtTime)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _MetricPill(
                  label:
                      '温度 ${deviceState.formatMetric(deviceState.temperature, deviceState.temperatureUnit)}',
                ),
                _MetricPill(
                  label:
                      '湿度 ${deviceState.formatMetric(deviceState.humidity, deviceState.humidityUnit)}',
                ),
                _MetricPill(
                  label:
                      '光照 ${deviceState.formatMetric(deviceState.light, deviceState.lightUnit, fractionDigits: 0)}',
                ),
                _MetricPill(
                  label:
                      'MQ2 ${deviceState.formatMetric(deviceState.mq2, deviceState.mq2Unit)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotStatusChip extends StatelessWidget {
  const _SnapshotStatusChip({required this.deviceState});

  final DeviceStateInfo deviceState;

  @override
  Widget build(BuildContext context) {
    final colors = _chipColors(deviceState.alertLevel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        deviceState.alertTitle,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colors.$2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE6F2)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

(Color, Color) _chipColors(DeviceAlertLevel level) {
  switch (level) {
    case DeviceAlertLevel.safe:
      return (const Color(0xFFE8F7EB), const Color(0xFF166534));
    case DeviceAlertLevel.warning:
      return (const Color(0xFFFFF4E5), const Color(0xFFB45309));
    case DeviceAlertLevel.danger:
      return (const Color(0xFFFEEBEC), const Color(0xFFB91C1C));
    case DeviceAlertLevel.unknown:
      return (const Color(0xFFE5ECF5), const Color(0xFF475569));
  }
}

String _formatDateTime(DateTime? value) {
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

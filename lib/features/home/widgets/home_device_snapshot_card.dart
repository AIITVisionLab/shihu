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
      title: '实时快照',
      subtitle: '这里保留当前设备的简要快照；如果需要操作，请直接进入主控台。',
      child: deviceStateAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
        error: (error, stackTrace) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('监测数据获取失败：$error'),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重新同步'),
            ),
          ],
        ),
        data: (deviceState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    deviceState.deviceName.trim().isEmpty
                        ? deviceState.deviceId
                        : deviceState.deviceName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('同步'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _StatusChip(
                  label: deviceState.alertTitle,
                  level: deviceState.alertLevel,
                ),
                _FreshnessChip(deviceState: deviceState),
                _BasicChip(label: 'LED ${deviceState.ledLabel}'),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: '最近上报',
              value: _formatDateTime(deviceState.updatedAtTime),
            ),
            const SizedBox(height: 10),
            _InfoRow(label: '设备 ID', value: deviceState.deviceId),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 620 ? 2 : 1;
                final itemWidth =
                    (constraints.maxWidth - ((columns - 1) * 12)) / columns;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _MetricTile(
                      width: itemWidth,
                      label: '温度',
                      value: deviceState.formatMetric(
                        deviceState.temperature,
                        deviceState.temperatureUnit,
                      ),
                    ),
                    _MetricTile(
                      width: itemWidth,
                      label: '湿度',
                      value: deviceState.formatMetric(
                        deviceState.humidity,
                        deviceState.humidityUnit,
                      ),
                    ),
                    _MetricTile(
                      width: itemWidth,
                      label: '光照',
                      value: deviceState.formatMetric(
                        deviceState.light,
                        deviceState.lightUnit,
                        fractionDigits: 0,
                      ),
                    ),
                    _MetricTile(
                      width: itemWidth,
                      label: 'MQ2',
                      value: deviceState.formatMetric(
                        deviceState.mq2,
                        deviceState.mq2Unit,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasicChip extends StatelessWidget {
  const _BasicChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.level});

  final String label;
  final DeviceAlertLevel level;

  @override
  Widget build(BuildContext context) {
    final colors = _chipColors(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colors.$2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FreshnessChip extends StatelessWidget {
  const _FreshnessChip({required this.deviceState});

  final DeviceStateInfo deviceState;

  @override
  Widget build(BuildContext context) {
    final isFresh = deviceState.isFresh();
    final backgroundColor = isFresh
        ? const Color(0xFFE6F3F1)
        : const Color(0xFFFFF0E2);
    final foregroundColor = isFresh
        ? const Color(0xFF176255)
        : const Color(0xFFB45309);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        deviceState.freshnessLabel(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

(Color, Color) _chipColors(DeviceAlertLevel level) {
  switch (level) {
    case DeviceAlertLevel.safe:
      return (const Color(0xFFE6F3F1), const Color(0xFF176255));
    case DeviceAlertLevel.warning:
      return (const Color(0xFFFFF0E2), const Color(0xFFB45309));
    case DeviceAlertLevel.danger:
      return (const Color(0xFFFBE6E5), const Color(0xFFB42318));
    case DeviceAlertLevel.unknown:
      return (const Color(0xFFE8ECF1), const Color(0xFF475467));
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

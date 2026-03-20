import 'package:flutter/material.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';

/// 首页设备快照摘要区。
class HomeSnapshotSummary extends StatelessWidget {
  /// 创建首页设备快照摘要区。
  const HomeSnapshotSummary({
    required this.deviceState,
    required this.viewData,
    required this.onRefresh,
    super.key,
  });

  /// 当前设备状态。
  final DeviceStatus deviceState;

  /// 当前设备展示派生。
  final DeviceStatusViewData viewData;

  /// 刷新回调。
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                resolveHomeSnapshotDeviceLabel(deviceState),
                style: theme.textTheme.titleLarge?.copyWith(
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
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            HomeSnapshotStatusChip(
              label: viewData.alertTitle,
              level: viewData.alertLevel,
            ),
            HomeSnapshotFreshnessChip(viewData: viewData),
            HomeSnapshotBasicChip(label: 'LED ${viewData.ledLabel}'),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  HomeSnapshotInfoBlock(
                    label: '当前结论',
                    value: viewData.alertDescription,
                  ),
                  const SizedBox(height: 10),
                  HomeSnapshotInfoBlock(
                    label: '最近上报',
                    value: formatHomeSnapshotDateTime(
                      deviceState.updatedAtTime,
                    ),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: HomeSnapshotInfoBlock(
                    label: '当前结论',
                    value: viewData.alertDescription,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: HomeSnapshotInfoBlock(
                    label: '最近上报',
                    value: formatHomeSnapshotDateTime(
                      deviceState.updatedAtTime,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// 首页设备快照信息块。
class HomeSnapshotInfoBlock extends StatelessWidget {
  /// 创建首页设备快照信息块。
  const HomeSnapshotInfoBlock({
    required this.label,
    required this.value,
    super.key,
  });

  /// 标题。
  final String label;

  /// 值文案。
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.24),
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
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 首页设备快照基础标签。
class HomeSnapshotBasicChip extends StatelessWidget {
  /// 创建首页设备快照基础标签。
  const HomeSnapshotBasicChip({required this.label, super.key});

  /// 文案。
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

/// 首页设备快照状态标签。
class HomeSnapshotStatusChip extends StatelessWidget {
  /// 创建首页设备快照状态标签。
  const HomeSnapshotStatusChip({
    required this.label,
    required this.level,
    super.key,
  });

  /// 文案。
  final String label;

  /// 告警等级。
  final DeviceAlertLevel level;

  @override
  Widget build(BuildContext context) {
    final colors = _chipColors(context, level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
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

/// 首页设备快照新鲜度标签。
class HomeSnapshotFreshnessChip extends StatelessWidget {
  /// 创建首页设备快照新鲜度标签。
  const HomeSnapshotFreshnessChip({required this.viewData, super.key});

  /// 当前设备展示派生。
  final DeviceStatusViewData viewData;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = viewData.isFresh
        ? colorScheme.primaryContainer.withValues(alpha: 0.82)
        : colorScheme.inversePrimary.withValues(alpha: 0.2);
    final foregroundColor = viewData.isFresh
        ? colorScheme.onPrimaryContainer
        : colorScheme.inversePrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        viewData.freshnessLabel,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// 解析首页设备快照展示名称。
String resolveHomeSnapshotDeviceLabel(DeviceStatus state) {
  final deviceName = state.deviceName.trim();
  if (deviceName.isNotEmpty) {
    return deviceName;
  }

  return '当前设备';
}

/// 格式化首页设备快照时间。
String formatHomeSnapshotDateTime(DateTime? value) {
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

(Color, Color) _chipColors(BuildContext context, DeviceAlertLevel level) {
  final colorScheme = Theme.of(context).colorScheme;

  switch (level) {
    case DeviceAlertLevel.safe:
      return (
        colorScheme.primaryContainer.withValues(alpha: 0.86),
        colorScheme.onPrimaryContainer,
      );
    case DeviceAlertLevel.warning:
      return (
        colorScheme.inversePrimary.withValues(alpha: 0.2),
        colorScheme.inversePrimary,
      );
    case DeviceAlertLevel.danger:
      return (
        colorScheme.errorContainer.withValues(alpha: 0.94),
        colorScheme.onErrorContainer,
      );
    case DeviceAlertLevel.unknown:
      return (
        colorScheme.surfaceContainerHigh.withValues(alpha: 0.82),
        colorScheme.onSurfaceVariant,
      );
  }
}

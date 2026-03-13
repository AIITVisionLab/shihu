import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';

/// 首页设备快照指标区。
class HomeSnapshotMetrics extends StatelessWidget {
  /// 创建首页设备快照指标区。
  const HomeSnapshotMetrics({required this.viewData, super.key});

  /// 当前设备展示派生。
  final DeviceStatusViewData viewData;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 420 ? 2 : 1;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * 12)) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            HomeSnapshotMetricTile(
              width: itemWidth,
              label: '温度',
              value: viewData.temperatureLabel,
              accentColor: AppPalette.softPine,
            ),
            HomeSnapshotMetricTile(
              width: itemWidth,
              label: '湿度',
              value: viewData.humidityLabel,
              accentColor: AppPalette.mistMint,
            ),
            HomeSnapshotMetricTile(
              width: itemWidth,
              label: '光照',
              value: viewData.lightLabel,
              accentColor: AppPalette.linenOlive,
            ),
            HomeSnapshotMetricTile(
              width: itemWidth,
              label: 'MQ2',
              value: viewData.mq2Label,
              accentColor: AppPalette.softLavender,
            ),
          ],
        );
      },
    );
  }
}

/// 首页设备快照指标项。
class HomeSnapshotMetricTile extends StatelessWidget {
  /// 创建首页设备快照指标项。
  const HomeSnapshotMetricTile({
    required this.width,
    required this.label,
    required this.value,
    required this.accentColor,
    super.key,
  });

  /// 宽度。
  final double width;

  /// 标题。
  final String label;

  /// 值文案。
  final String value;

  /// 强调色。
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              accentColor.withValues(alpha: 0.16),
              colorScheme.surfaceContainerLowest,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 34,
              height: 3,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
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

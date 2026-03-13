import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 实时监控页环境指标区。
class RealtimeMetricsSection extends StatelessWidget {
  /// 创建实时监控页环境指标区。
  const RealtimeMetricsSection({required this.deviceState, super.key});

  /// 当前设备状态。
  final DeviceStatus? deviceState;

  @override
  Widget build(BuildContext context) {
    final viewData = deviceState == null
        ? null
        : DeviceStatusViewData.fromState(deviceState!);
    final items = <({IconData icon, String title, String value, Color accent})>[
      (
        icon: Icons.thermostat_rounded,
        title: '温度',
        value: viewData?.temperatureLabel ?? '--',
        accent: AppPalette.softPine,
      ),
      (
        icon: Icons.water_drop_rounded,
        title: '湿度',
        value: viewData?.humidityLabel ?? '--',
        accent: AppPalette.mistMint,
      ),
      (
        icon: Icons.light_mode_rounded,
        title: '光照',
        value: viewData?.lightLabel ?? '--',
        accent: AppPalette.linenOlive,
      ),
      (
        icon: Icons.sensors_rounded,
        title: 'MQ2',
        value: viewData?.mq2Label ?? '--',
        accent: AppPalette.softLavender,
      ),
    ];

    return CommonCard(
      title: '环境指标',
      subtitle: '核心指标集中成矩阵，进入值守后先横向读数，再决定是否处理。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FeatureInsetPanel(
            padding: const EdgeInsets.all(18),
            borderRadius: 24,
            accentColor: AppPalette.linenOlive,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppPalette.linenOlive.withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.grid_3x3_rounded),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    deviceState == null
                        ? '设备接入后会在这里显示四项核心指标。'
                        : '当前已经回到四项主指标视图，避免在值守页堆叠过多解释型内容。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.56,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 860
                  ? 2
                  : constraints.maxWidth >= 420
                  ? 2
                  : 1;
              final itemWidth =
                  (constraints.maxWidth - ((columns - 1) * 14)) / columns;

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: itemWidth,
                        child: _MetricTile(
                          icon: item.icon,
                          title: item.title,
                          value: item.value,
                          accentColor: item.accent,
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const Spacer(),
              Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

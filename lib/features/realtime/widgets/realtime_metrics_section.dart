import 'package:flutter/material.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 实时监控页环境指标区。
class RealtimeMetricsSection extends StatelessWidget {
  /// 创建实时监控页环境指标区。
  const RealtimeMetricsSection({required this.deviceState, super.key});

  /// 当前设备状态。
  final DeviceStateInfo? deviceState;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String title, String value, Color accent})>[
      (
        icon: Icons.thermostat_rounded,
        title: '温度',
        value:
            deviceState?.formatMetric(
              deviceState?.temperature,
              deviceState?.temperatureUnit ?? '°C',
            ) ??
            '--',
        accent: const Color(0xFFB95C3C),
      ),
      (
        icon: Icons.water_drop_rounded,
        title: '湿度',
        value:
            deviceState?.formatMetric(
              deviceState?.humidity,
              deviceState?.humidityUnit ?? '%',
            ) ??
            '--',
        accent: const Color(0xFF2F7D82),
      ),
      (
        icon: Icons.light_mode_rounded,
        title: '光照',
        value:
            deviceState?.formatMetric(
              deviceState?.light,
              deviceState?.lightUnit ?? 'Lux',
              fractionDigits: 0,
            ) ??
            '--',
        accent: const Color(0xFFBF8A29),
      ),
      (
        icon: Icons.sensors_rounded,
        title: 'MQ2',
        value:
            deviceState?.formatMetric(
              deviceState?.mq2,
              deviceState?.mq2Unit ?? 'ppm',
            ) ??
            '--',
        accent: const Color(0xFF556D5D),
      ),
    ];

    return CommonCard(
      title: '环境指标',
      subtitle: '核心指标收在一个面板里，减少页面碎片。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? 2 : 1;
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

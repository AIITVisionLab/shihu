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
    final cards = <Widget>[
      _MetricCard(
        icon: Icons.thermostat_rounded,
        title: '温度',
        value: deviceState?.formatMetric(
          deviceState?.temperature,
          deviceState?.temperatureUnit ?? '°C',
        ),
        helperText: '来自设备温度上报',
        accentColor: const Color(0xFFB95C3C),
      ),
      _MetricCard(
        icon: Icons.water_drop_rounded,
        title: '湿度',
        value: deviceState?.formatMetric(
          deviceState?.humidity,
          deviceState?.humidityUnit ?? '%',
        ),
        helperText: '来自设备湿度上报',
        accentColor: const Color(0xFF2F7D82),
      ),
      _MetricCard(
        icon: Icons.light_mode_rounded,
        title: '光照',
        value: deviceState?.formatMetric(
          deviceState?.light,
          deviceState?.lightUnit ?? 'Lux',
          fractionDigits: 0,
        ),
        helperText: '来自设备光照上报',
        accentColor: const Color(0xFFBF8A29),
      ),
      _MetricCard(
        icon: Icons.sensors_rounded,
        title: 'MQ2',
        value: deviceState?.formatMetric(
          deviceState?.mq2,
          deviceState?.mq2Unit ?? 'ppm',
        ),
        helperText: '来自设备气体传感器上报',
        accentColor: const Color(0xFF556D5D),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        final medium = constraints.maxWidth >= 600;
        final columns = isWide ? 4 : (medium ? 2 : 1);
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map((item) => SizedBox(width: itemWidth, child: item))
              .toList(growable: false),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.helperText,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String helperText;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CommonCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value ?? '--',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            helperText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

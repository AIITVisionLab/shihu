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
      ),
      _MetricCard(
        icon: Icons.water_drop_rounded,
        title: '湿度',
        value: deviceState?.formatMetric(
          deviceState?.humidity,
          deviceState?.humidityUnit ?? '%',
        ),
        helperText: '来自设备湿度上报',
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
      ),
      _MetricCard(
        icon: Icons.sensors_rounded,
        title: 'MQ2',
        value: deviceState?.formatMetric(
          deviceState?.mq2,
          deviceState?.mq2Unit ?? 'ppm',
        ),
        helperText: '来自设备气体传感器上报',
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
  });

  final IconData icon;
  final String title;
  final String? value;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            value ?? '--',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(helperText, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

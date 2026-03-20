import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 实时监控页环境指标区。
class RealtimeMetricsSection extends StatelessWidget {
  /// 创建实时监控页环境指标区。
  const RealtimeMetricsSection({
    required this.deviceState,
    this.compactDesktop = false,
    super.key,
  });

  /// 当前设备状态。
  final DeviceStatus? deviceState;

  /// 是否启用桌面端紧凑排布。
  final bool compactDesktop;

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
    final metricGrid = LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth) {
          >= 720 => 4,
          >= 560 when compactDesktop => 4,
          >= 420 => 2,
          _ => 1,
        };
        final gap = compactDesktop ? 10.0 : 12.0;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * gap)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: FeatureSummaryTile(
                    icon: item.icon,
                    label: item.title,
                    value: item.value,
                    accentColor: item.accent,
                    padding: EdgeInsets.all(compactDesktop ? 14 : 16),
                    borderRadius: compactDesktop ? 18 : 20,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );

    final cardBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        metricGrid,
        SizedBox(height: compactDesktop ? 12 : 14),
        FeatureInsetPanel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          borderRadius: 20,
          accentColor: AppPalette.linenOlive,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _MetricFooterPill(
                icon: Icons.schedule_rounded,
                label: '最近同步',
                value: deviceState == null ? '等待同步' : '已接入',
              ),
              _MetricFooterPill(
                icon: Icons.lightbulb_outline_rounded,
                label: '补光',
                value: viewData?.ledLabel ?? '待同步',
              ),
            ],
          ),
        ),
      ],
    );

    return CommonCard(
      title: '环境指标',
      accentColor: AppPalette.softPine,
      padding: const EdgeInsets.all(18),
      child: cardBody,
    );
  }
}

class _MetricFooterPill extends StatelessWidget {
  const _MetricFooterPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.linenOlive,
          opacity: 0.12,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.linenOlive.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$label · $value',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

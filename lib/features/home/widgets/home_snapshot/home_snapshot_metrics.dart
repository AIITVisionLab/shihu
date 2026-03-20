import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

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
        final columns = switch (constraints.maxWidth) {
          >= 760 => 4,
          >= 420 => 2,
          _ => 1,
        };
        final gap = 10.0;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * gap)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
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
    return SizedBox(
      width: width,
      child: FeatureSummaryTile(
        label: label,
        value: value,
        accentColor: accentColor,
        padding: const EdgeInsets.all(14),
        borderRadius: 18,
        shadow: false,
      ),
    );
  }
}

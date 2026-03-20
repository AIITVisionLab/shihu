import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 首页 Hero 右侧信号盘面。
class HomeSummaryBoard extends StatelessWidget {
  /// 创建首页 Hero 右侧信号盘面。
  const HomeSummaryBoard({
    required this.deviceStatus,
    required this.viewData,
    super.key,
  });

  /// 当前设备状态。
  final DeviceStatus? deviceStatus;

  /// 当前设备展示派生。
  final DeviceStatusViewData? viewData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusTitle = viewData?.alertTitle ?? '等待状态';
    final statusDescription = deviceStatus == null
        ? '等待设备上报后再展示当前结论。'
        : '状态依据最新上报结果生成，可直接作为值守判断基线。';

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: 28,
      accentColor: AppPalette.softLavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '后端状态摘要',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            statusTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            statusDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.58,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 320 ? 3 : 1;
              final gap = 10.0;
              final itemWidth = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - ((columns - 1) * gap)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  HomeSummaryValueCard(
                    width: itemWidth,
                    title: '最近同步',
                    value: deviceStatus == null
                        ? '等待数据'
                        : viewData!.freshnessLabel,
                    accentColor: AppPalette.linenOlive,
                  ),
                  HomeSummaryValueCard(
                    width: itemWidth,
                    title: '补光状态',
                    value: deviceStatus == null ? '待同步' : viewData!.ledLabel,
                    accentColor: AppPalette.softLavender,
                  ),
                  HomeSummaryValueCard(
                    width: itemWidth,
                    title: '当前结论',
                    value: statusTitle,
                    accentColor: AppPalette.mistMint,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 首页 Hero 指标值卡片。
class HomeSummaryValueCard extends StatelessWidget {
  /// 创建首页 Hero 指标值卡片。
  const HomeSummaryValueCard({
    required this.width,
    required this.title,
    required this.value,
    required this.accentColor,
    super.key,
  });

  /// 宽度。
  final double width;

  /// 标题。
  final String title;

  /// 文案。
  final String value;

  /// 强调色。
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: FeatureSummaryTile(
        label: title,
        value: value,
        accentColor: accentColor,
        padding: const EdgeInsets.all(14),
        borderRadius: 18,
        shadow: false,
      ),
    );
  }
}

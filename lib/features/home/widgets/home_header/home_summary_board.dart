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

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: 28,
      accentColor: AppPalette.softLavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '值守摘要',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FeatureInsetPanel(
            padding: const EdgeInsets.all(18),
            borderRadius: 22,
            accentColor: AppPalette.softPine,
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppPalette.softPine.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.eco_outlined, color: AppPalette.pineGreen),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        viewData?.alertTitle ?? '等待状态',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        deviceStatus == null
                            ? '等待数据返回'
                            : '把当前状态、同步和补光收成一眼可读的摘要。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.58,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          HomeSummaryValueCard(
            title: '最近同步',
            value: deviceStatus == null ? '等待数据' : viewData!.freshnessLabel,
            accentColor: AppPalette.linenOlive,
          ),
          const SizedBox(height: 12),
          HomeSummaryValueCard(
            title: '补光状态',
            value: deviceStatus == null ? '待同步' : viewData!.ledLabel,
            accentColor: AppPalette.softLavender,
          ),
          const SizedBox(height: 12),
          HomeSummaryValueCard(
            title: '下一步',
            value: deviceStatus == null ? '等待设备接入' : '先看值守台，再决定操作',
            accentColor: AppPalette.mistMint,
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
    required this.title,
    required this.value,
    required this.accentColor,
    super.key,
  });

  /// 标题。
  final String title;

  /// 文案。
  final String value;

  /// 强调色。
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      accentColor: accentColor,
      shadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

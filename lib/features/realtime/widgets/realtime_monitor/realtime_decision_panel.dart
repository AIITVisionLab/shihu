import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/realtime/realtime_view_utils.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 值守 Hero 右侧结论区。
class RealtimeDecisionPanel extends StatelessWidget {
  /// 创建值守 Hero 右侧结论区。
  const RealtimeDecisionPanel({
    required this.palette,
    required this.deviceStatus,
    required this.viewData,
    super.key,
  });

  /// 告警色板。
  final RealtimeAlertPalette palette;

  /// 当前设备状态。
  final DeviceStatus? deviceStatus;

  /// 当前设备展示派生。
  final DeviceStatusViewData? viewData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: 28,
      accentColor: palette.foregroundColor,
      shadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '当前结论',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: palette.backgroundColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: palette.foregroundColor.withValues(alpha: 0.22),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: palette.foregroundColor.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  viewData?.alertTitle ?? '等待状态返回',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: palette.foregroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  deviceStatus == null ? '暂无结论。' : viewData!.alertDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.foregroundColor.withValues(alpha: 0.9),
                    height: 1.58,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _DecisionStep(
            index: '01',
            title: '先读结论',
            description: '确认当前是正常、注意还是严重，再决定操作。',
          ),
          const SizedBox(height: 12),
          _DecisionStep(
            index: '02',
            title: '确认补光',
            description: deviceStatus == null
                ? '等待设备状态后再决定是否调整补光。'
                : '结合当前补光状态和环境指标，避免无效切换。',
          ),
          const SizedBox(height: 12),
          _DecisionStep(
            index: '03',
            title: '等待回写',
            description: deviceStatus == null
                ? '状态接入后会继续同步。'
                : '下发指令后等待状态回写，再看是否继续处理。',
          ),
        ],
      ),
    );
  }
}

class _DecisionStep extends StatelessWidget {
  const _DecisionStep({
    required this.index,
    required this.title,
    required this.description,
  });

  final String index;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.softPine.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              index,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.54,
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

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

    final chips = <({String label, IconData icon, bool active})>[
      (label: '先看结论', icon: Icons.visibility_outlined, active: true),
      (
        label: deviceStatus?.ledOn == true ? '补光已开启' : '补光未开启',
        icon: Icons.lightbulb_outline_rounded,
        active: deviceStatus?.ledOn == true,
      ),
      (
        label: viewData?.freshnessLabel ?? '等待同步',
        icon: Icons.schedule_rounded,
        active: viewData?.isFresh == true,
      ),
    ];

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 22,
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
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  palette.backgroundColor.withValues(alpha: 0.98),
                  palette.backgroundColor.withValues(alpha: 0.84),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: palette.foregroundColor.withValues(alpha: 0.22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  viewData?.alertTitle ?? '等待状态返回',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: palette.foregroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  deviceStatus == null ? '暂无结论。' : viewData!.alertDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.foregroundColor.withValues(alpha: 0.92),
                    height: 1.52,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (chip) => _DecisionChip(
                    label: chip.label,
                    icon: chip.icon,
                    active: chip.active,
                    foregroundColor: palette.foregroundColor,
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _DecisionChip extends StatelessWidget {
  const _DecisionChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final bool active;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: active
            ? AppPalette.blendOnPaper(
                foregroundColor,
                opacity: 0.14,
                base: colorScheme.surfaceContainerLowest,
              )
            : AppPalette.blendOnPaper(
                AppPalette.softLavender,
                opacity: 0.08,
                base: colorScheme.surfaceContainerLowest,
              ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? foregroundColor.withValues(alpha: 0.28)
              : AppPalette.softLavender.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: foregroundColor),
          const SizedBox(width: 7),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/realtime_view_utils.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 实时监控页设备信息与补光控制区。
class RealtimeControlsSection extends StatelessWidget {
  /// 创建实时监控页设备信息与补光控制区。
  const RealtimeControlsSection({
    required this.state,
    required this.onToggleLed,
    this.compactDesktop = false,
    super.key,
  });

  /// 实时监控页状态。
  final RealtimeDetectState state;

  /// LED 开关切换回调。
  final Future<void> Function(bool ledOn) onToggleLed;

  /// 是否启用桌面端紧凑排布。
  final bool compactDesktop;

  @override
  Widget build(BuildContext context) {
    final deviceState = state.deviceState;
    final viewData = deviceState == null
        ? null
        : DeviceStatusViewData.fromState(deviceState);

    return CommonCard(
      title: '设备与补光',
      accentColor: AppPalette.mistMint,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _StatusOverviewPanel(
            deviceState: deviceState,
            viewData: viewData,
            compact: compactDesktop,
          ),
          SizedBox(height: compactDesktop ? 14 : 16),
          _LedControlPanel(
            state: state,
            compact: compactDesktop,
            onToggleLed: onToggleLed,
          ),
        ],
      ),
    );
  }
}

class _StatusOverviewPanel extends StatelessWidget {
  const _StatusOverviewPanel({
    required this.deviceState,
    required this.viewData,
    this.compact = false,
  });

  final DeviceStatus? deviceState;
  final DeviceStatusViewData? viewData;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final palette = resolveRealtimeAlertPalette(deviceState?.alertLevel);
    final deviceName = formatRealtimeDisplayText(deviceState?.deviceName);

    return FeatureInsetPanel(
      padding: EdgeInsets.all(compact ? 12 : 14),
      borderRadius: 22,
      accentColor: palette.foregroundColor,
      shadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: compact ? 38 : 42,
                height: compact ? 38 : 42,
                decoration: BoxDecoration(
                  color: palette.foregroundColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.eco_outlined,
                  color: palette.foregroundColor,
                  size: compact ? 18 : 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      deviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        height: 1.12,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      viewData?.alertTitle ?? '等待状态返回',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            deviceState == null ? '等待设备状态后再决定是否补光。' : '状态、同步和补光都收在这里。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _OverviewBadge(
                icon: Icons.schedule_rounded,
                label: viewData?.freshnessLabel ?? '等待同步',
              ),
              _OverviewBadge(
                icon: Icons.lightbulb_outline_rounded,
                label: viewData?.ledLabel ?? '补光待同步',
              ),
              _OverviewBadge(
                icon: Icons.gpp_good_outlined,
                label: viewData?.alertTitle ?? '待确认',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewBadge extends StatelessWidget {
  const _OverviewBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.softPine,
          opacity: 0.12,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.softPine.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: colorScheme.primary),
          const SizedBox(width: 6),
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

class _LedControlPanel extends StatelessWidget {
  const _LedControlPanel({
    required this.state,
    required this.onToggleLed,
    this.compact = false,
  });

  final RealtimeDetectState state;
  final Future<void> Function(bool ledOn) onToggleLed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deviceState = state.deviceState;
    final viewData = deviceState == null
        ? null
        : DeviceStatusViewData.fromState(deviceState);

    final action = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.mistMint,
          opacity: 0.12,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.mistMint.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Switch.adaptive(
            value: deviceState?.ledOn ?? false,
            onChanged:
                deviceState == null ||
                    !deviceState.canControlLed ||
                    state.isSubmittingLed
                ? null
                : (value) {
                    onToggleLed(value);
                  },
          ),
          const SizedBox(width: 6),
          Text(
            viewData == null ? '当前已关闭' : '当前${viewData.ledLabel}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    return FeatureInsetPanel(
      padding: EdgeInsets.all(compact ? 12 : 14),
      borderRadius: 22,
      accentColor: AppPalette.mistMint,
      shadow: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final description = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'LED 补光控制',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                deviceState == null
                    ? '还没有设备状态，暂时无法下发补光指令。'
                    : !deviceState.canControlLed
                    ? '当前还不能调整补光，请先等状态稳定。'
                    : '切换后会自动回刷。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          );

          final tag = Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppPalette.blendOnPaper(
                AppPalette.linenOlive,
                opacity: 0.12,
                base: colorScheme.surfaceContainerLowest,
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppPalette.linenOlive.withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              state.isSubmittingLed ? '指令提交中' : '状态稳定后可切换',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          );

          if (constraints.maxWidth < 620) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                description,
                const SizedBox(height: 12),
                action,
                const SizedBox(height: 10),
                tag,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: description),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[action, const SizedBox(height: 12), tag],
              ),
            ],
          );
        },
      ),
    );
  }
}

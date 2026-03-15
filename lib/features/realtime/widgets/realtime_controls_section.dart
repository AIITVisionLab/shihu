import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
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
    super.key,
  });

  /// 实时监控页状态。
  final RealtimeDetectState state;

  /// LED 开关切换回调。
  final Future<void> Function(bool ledOn) onToggleLed;

  @override
  Widget build(BuildContext context) {
    final deviceState = state.deviceState;
    final viewData = deviceState == null
        ? null
        : DeviceStatusViewData.fromState(deviceState);

    return CommonCard(
      title: '设备与补光',
      subtitle: '把设备摘要和补光控制收在一起，避免在不同卡片来回切换。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FeatureInsetPanel(
            padding: const EdgeInsets.all(18),
            borderRadius: 24,
            accentColor: AppPalette.softPine,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '当前操作面板',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  viewData?.alertTitle ?? '等待状态返回',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  deviceState == null
                      ? '设备状态接入后，补光控制会在这里变为可用。'
                      : '先确认设备状态与补光状态，再决定是否切换 LED。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.56,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720 ? 2 : 1;
              final itemWidth =
                  (constraints.maxWidth - ((columns - 1) * 12)) / columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _DetailTile(
                    width: itemWidth,
                    label: '设备名称',
                    value: formatRealtimeDisplayText(deviceState?.deviceName),
                  ),
                  _DetailTile(
                    width: itemWidth,
                    label: '当前状态',
                    value: viewData?.alertTitle ?? '等待状态返回',
                  ),
                  _DetailTile(
                    width: itemWidth,
                    label: '补光状态',
                    value: viewData?.ledLabel ?? '待同步',
                  ),
                  _DetailTile(
                    width: itemWidth,
                    label: '最近同步',
                    value: formatRealtimeTimestamp(deviceState?.updatedAtTime),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _LedControlPanel(state: state, onToggleLed: onToggleLed),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: FeatureInsetPanel(
        padding: const EdgeInsets.all(14),
        borderRadius: 18,
        accentColor: AppPalette.mistMint,
        shadow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedControlPanel extends StatelessWidget {
  const _LedControlPanel({required this.state, required this.onToggleLed});

  final RealtimeDetectState state;
  final Future<void> Function(bool ledOn) onToggleLed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deviceState = state.deviceState;
    final viewData = deviceState == null
        ? null
        : DeviceStatusViewData.fromState(deviceState);

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      accentColor: AppPalette.softLavender,
      shadow: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final description = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'LED 补光控制',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                deviceState == null
                    ? '当前还没有设备状态，暂时无法下发控制命令。'
                    : !deviceState.canControlLed
                    ? '当前还不能调整补光，请先等待状态稳定。'
                    : '指令提交后界面会继续刷新，等待设备状态回写。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.54,
                ),
              ),
            ],
          );

          final action = Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );

          final stateTag = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppPalette.softPine.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              state.isSubmittingLed ? '指令提交中' : '可以随时切换',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          );

          if (constraints.maxWidth < 580) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                description,
                const SizedBox(height: 14),
                action,
                const SizedBox(height: 12),
                stateTag,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: description),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  action,
                  const SizedBox(height: 12),
                  stateTag,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

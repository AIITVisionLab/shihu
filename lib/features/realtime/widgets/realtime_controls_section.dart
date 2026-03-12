import 'package:flutter/material.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/realtime_view_utils.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 实时监控页运行明细与远程控制区。
class RealtimeControlsSection extends StatelessWidget {
  /// 创建实时监控页运行明细与远程控制区。
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

    return CommonCard(
      title: '运行明细与远程控制',
      subtitle: '先核对设备身份，再执行补光。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 620 ? 2 : 1;
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
                    label: '设备 ID',
                    value: formatRealtimeDisplayText(deviceState?.deviceId),
                  ),
                  _DetailTile(
                    width: itemWidth,
                    label: '错误码',
                    value: formatRealtimeErrorCode(deviceState),
                  ),
                  _DetailTile(
                    width: itemWidth,
                    label: '更新时间',
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
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.32),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final description = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'LED 补光控制',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                deviceState == null
                    ? '当前还没有设备状态，暂时无法下发控制命令。'
                    : !deviceState.canControlLed
                    ? '等待设备身份完整回传后再开放控制。'
                    : '指令提交后界面会继续刷新，等待设备状态回写。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          );

          final action = Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
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
              Text(
                (deviceState?.ledOn ?? false) ? '当前已开启' : '当前已关闭',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 540) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                description,
                const SizedBox(height: 14),
                action,
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: description),
              const SizedBox(width: 16),
              action,
            ],
          );
        },
      ),
    );
  }
}

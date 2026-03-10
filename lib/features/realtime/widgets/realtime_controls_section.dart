import 'package:flutter/material.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/realtime_view_utils.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/responsive_info_row.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final deviceState = state.deviceState;

    return CommonCard(
      title: '运行明细与远程控制',
      subtitle: '在同一视图中核对设备身份、运行状态与补光控制结果。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ControlRow(
            icon: Icons.memory_rounded,
            label: '设备名称',
            value: formatRealtimeDisplayText(deviceState?.deviceName),
          ),
          const SizedBox(height: 12),
          _ControlRow(
            icon: Icons.badge_rounded,
            label: '设备 ID',
            value: formatRealtimeDisplayText(deviceState?.deviceId),
          ),
          const SizedBox(height: 12),
          _ControlRow(
            icon: Icons.error_outline_rounded,
            label: '错误码',
            value: formatRealtimeErrorCode(deviceState),
          ),
          const SizedBox(height: 12),
          _ControlRow(
            icon: Icons.update_rounded,
            label: '更新时间',
            value: formatRealtimeTimestamp(deviceState?.updatedAtTime),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.42),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 520;
                final description = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'LED 补光控制',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      deviceState == null
                          ? '当前还没有设备状态，暂时无法下发控制命令。'
                          : !deviceState.canControlLed
                          ? '当前设备身份尚未补齐，待状态完整回传后再开放控制。'
                          : '指令提交后界面会继续刷新，并等待设备状态回写。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
                final ledSwitch = Switch.adaptive(
                  value: deviceState?.ledOn ?? false,
                  onChanged:
                      deviceState == null ||
                          !deviceState.canControlLed ||
                          state.isSubmittingLed
                      ? null
                      : (value) {
                          onToggleLed(value);
                        },
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      description,
                      const SizedBox(height: 14),
                      ledSwitch,
                    ],
                  );
                }

                return Row(
                  children: <Widget>[
                    Expanded(child: description),
                    const SizedBox(width: 16),
                    ledSwitch,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: ResponsiveInfoRow(
        icon: icon,
        label: label,
        value: value,
        emphasizeValue: true,
        compactBreakpoint: 420,
        labelWidth: 76,
      ),
    );
  }
}

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
    final colorScheme = Theme.of(context).colorScheme;
    final deviceState = state.deviceState;

    return CommonCard(
      title: '运行明细与远程控制',
      subtitle: '设备状态来自 /api/status，LED 开关通过 /api/ops/led 提交。',
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
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'LED 补光控制',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        deviceState == null
                            ? '当前还没有设备状态，暂时无法下发控制命令。'
                            : !deviceState.canControlLed
                            ? '后端要求 LED 指令必须携带非空 deviceId，当前先等待设备状态补齐后再开放控制。'
                            : '后端返回 202 Accepted 后，前端会继续刷新并等待状态回写。',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
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
              ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

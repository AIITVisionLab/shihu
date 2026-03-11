import 'package:flutter/material.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/realtime_view_utils.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';

/// 实时监控页主状态区，汇总设备核心状态与当前告警说明。
class RealtimeMonitorHero extends StatelessWidget {
  /// 创建实时监控页主状态区。
  const RealtimeMonitorHero({required this.state, super.key});

  /// 实时监控页状态。
  final RealtimeDetectState state;

  @override
  Widget build(BuildContext context) {
    final deviceState = state.deviceState;
    final palette = resolveRealtimeAlertPalette(deviceState?.alertLevel);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.38),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C172019),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 860;
          final summary = _MonitorSummary(
            deviceState: deviceState,
            errorMessage: state.errorMessage,
          );
          final decision = _DecisionPanel(
            palette: palette,
            deviceState: deviceState,
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 11, child: summary),
                const SizedBox(width: 20),
                Expanded(flex: 7, child: decision),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[summary, const SizedBox(height: 20), decision],
          );
        },
      ),
    );
  }
}

class _MonitorSummary extends StatelessWidget {
  const _MonitorSummary({
    required this.deviceState,
    required this.errorMessage,
  });

  final DeviceStateInfo? deviceState;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          deviceState?.deviceName.trim().isNotEmpty == true
              ? deviceState!.deviceName
              : '等待设备状态上报',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          deviceState == null
              ? '系统正在等待设备第一条状态上报。收到后会自动进入值守判断。'
              : '当前主状态区只保留值守判断需要的关键信息：设备身份、最近上报、数据新鲜度和 LED 状态。',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.58,
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720 ? 4 : 2;
            final itemWidth =
                (constraints.maxWidth - ((columns - 1) * 12)) / columns;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _FactTile(
                  width: itemWidth,
                  label: '设备 ID',
                  value: formatRealtimeDisplayText(deviceState?.deviceId),
                ),
                _FactTile(
                  width: itemWidth,
                  label: '最近上报',
                  value: formatRealtimeTimestamp(deviceState?.updatedAtTime),
                ),
                _FactTile(
                  width: itemWidth,
                  label: '数据状态',
                  value: deviceState?.freshnessLabel() ?? '--',
                ),
                _FactTile(
                  width: itemWidth,
                  label: 'LED 状态',
                  value: deviceState?.ledLabel ?? '--',
                ),
              ],
            );
          },
        ),
        if (errorMessage != null) ...<Widget>[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({
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
          color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.22),
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
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionPanel extends StatelessWidget {
  const _DecisionPanel({required this.palette, required this.deviceState});

  final RealtimeAlertPalette palette;
  final DeviceStateInfo? deviceState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '当前结论',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  deviceState?.alertTitle ?? '等待状态返回',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: palette.foregroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  deviceState?.alertDescription ?? '收到设备状态后会显示当前值守结论。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.foregroundColor,
                    height: 1.54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DecisionStep(
            index: '1',
            title: '先看状态',
            description: '确认错误码、数据新鲜度和最近上报时间是否合理。',
          ),
          const SizedBox(height: 12),
          _DecisionStep(
            index: '2',
            title: '再做操作',
            description: '如果环境偏离目标区间，再进入下方控制区处理补光。',
          ),
          const SizedBox(height: 12),
          _DecisionStep(
            index: '3',
            title: '最后确认',
            description: '操作后等待状态回写，不要连续重复下发指令。',
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              index,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

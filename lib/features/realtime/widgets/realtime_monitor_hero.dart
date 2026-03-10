import 'package:flutter/material.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/realtime_view_utils.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/widgets/responsive_info_row.dart';

/// 实时监控页主 Hero，汇总设备核心状态与当前告警说明。
class RealtimeMonitorHero extends StatelessWidget {
  /// 创建实时监控页主 Hero。
  const RealtimeMonitorHero({required this.state, super.key});

  /// 实时监控页状态。
  final RealtimeDetectState state;

  @override
  Widget build(BuildContext context) {
    final deviceState = state.deviceState;
    final palette = resolveRealtimeAlertPalette(deviceState?.alertLevel);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.primary,
            colorScheme.primaryContainer,
            colorScheme.tertiaryContainer,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;
            final summary = _HeroSummary(
              deviceState: deviceState,
              errorMessage: state.errorMessage,
            );
            final banner = _HeroStatusBanner(
              palette: palette,
              deviceState: deviceState,
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 3, child: summary),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: banner),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[summary, const SizedBox(height: 20), banner],
            );
          },
        ),
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({required this.deviceState, required this.errorMessage});

  final DeviceStateInfo? deviceState;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '设备运行主链路',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          deviceState?.deviceName.trim().isNotEmpty == true
              ? deviceState!.deviceName
              : '等待设备状态上报',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          deviceState == null
              ? '当前页面会持续同步设备状态；若现场设备尚未上报，这里会先显示等待状态。'
              : '当前页面会持续同步设备状态，并依据错误码把运行情况映射为正常、预警和告警视图。',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary.withValues(alpha: 0.92),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _HeroInfoChip(
              label:
                  '设备 ID：${formatRealtimeDisplayText(deviceState?.deviceId)}',
            ),
            _HeroInfoChip(
              label:
                  '最近上报：${formatRealtimeTimestamp(deviceState?.updatedAtTime)}',
            ),
            _HeroInfoChip(label: 'LED：${deviceState?.ledLabel ?? '--'}'),
          ],
        ),
        if (errorMessage != null) ...<Widget>[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF3C1218).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFAB3144)),
            ),
            child: Text(
              errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFFFD5D8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeroInfoChip extends StatelessWidget {
  const _HeroInfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
      ),
    );
  }
}

class _HeroStatusBanner extends StatelessWidget {
  const _HeroStatusBanner({required this.palette, required this.deviceState});

  final RealtimeAlertPalette palette;
  final DeviceStateInfo? deviceState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '运行状态',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.84),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: palette.backgroundColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              deviceState?.alertTitle ?? '等待设备上报',
              style: theme.textTheme.titleMedium?.copyWith(
                color: palette.foregroundColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            deviceState?.alertDescription ?? '尚未收到设备状态上报，当前先保持等待视图。',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.92),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 18),
          _StatusMiniRow(
            label: '错误码',
            value: formatRealtimeErrorCode(deviceState),
          ),
          const SizedBox(height: 12),
          _StatusMiniRow(label: 'LED 状态', value: deviceState?.ledLabel ?? '--'),
          const SizedBox(height: 12),
          const _StatusMiniRow(label: '状态来源', value: '在线设备上报'),
        ],
      ),
    );
  }
}

class _StatusMiniRow extends StatelessWidget {
  const _StatusMiniRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveInfoRow(
      label: label,
      value: value,
      compactBreakpoint: 320,
      labelWidth: 78,
      emphasizeValue: true,
      labelTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: colorScheme.onPrimary.withValues(alpha: 0.74),
      ),
      valueTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: colorScheme.onPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

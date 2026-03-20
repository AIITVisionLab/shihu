import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/realtime_view_utils.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_monitor/realtime_decision_panel.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_monitor/realtime_monitor_summary.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';
import 'package:sickandflutter/shared/widgets/workspace_layout.dart';

/// 实时监控页主状态区，汇总设备核心状态与当前告警说明。
class RealtimeMonitorHero extends StatelessWidget {
  /// 创建实时监控页主状态区。
  const RealtimeMonitorHero({
    required this.state,
    required this.onRefresh,
    required this.onToggleAutoRefresh,
    super.key,
  });

  /// 实时监控页状态。
  final RealtimeDetectState state;

  /// 手动刷新回调。
  final Future<void> Function() onRefresh;

  /// 自动刷新开关回调。
  final Future<void> Function(bool enabled) onToggleAutoRefresh;

  @override
  Widget build(BuildContext context) {
    final deviceStatus = state.deviceState;
    final palette = resolveRealtimeAlertPalette(deviceStatus?.alertLevel);
    final viewData = deviceStatus == null
        ? null
        : DeviceStatusViewData.fromState(deviceStatus);

    return FeatureHeroCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 30,
      accentColor: AppPalette.pineGreen,
      child: WorkspaceTwoPane(
        breakpoint: 1040,
        primary: RealtimeMonitorSummary(
          state: state,
          deviceStatus: deviceStatus,
          viewData: viewData,
          errorMessage: state.errorMessage,
          onRefresh: onRefresh,
          onToggleAutoRefresh: onToggleAutoRefresh,
        ),
        secondary: RealtimeDecisionPanel(
          palette: palette,
          deviceStatus: deviceStatus,
          viewData: viewData,
        ),
      ),
    );
  }
}

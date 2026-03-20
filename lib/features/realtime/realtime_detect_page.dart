import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/ai/application/ai_detection_providers.dart';
import 'package:sickandflutter/features/auth/application/current_user_label_provider.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_ai_detection_section.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_controls_section.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_metrics_section.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_monitor_hero.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/workspace_layout.dart';

/// 实时监控页，负责展示设备状态、轮询结果与远程控制入口。
class RealtimeDetectPage extends ConsumerWidget {
  /// 创建实时监控页。
  const RealtimeDetectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(realtimeDetectControllerProvider);
    final currentUser = ref.watch(currentUserLabelProvider);
    final aiOverviewAsync = ref.watch(aiDetectionOverviewProvider);
    final controller = ref.read(realtimeDetectControllerProvider.notifier);
    final compactDesktop = MediaQuery.sizeOf(context).width >= 1020;

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.realtime,
      title: '值守台',
      subtitle: '查看实时状态，必要时处理补光。',
      currentUser: currentUser,
      child: RefreshIndicator(
        onRefresh: controller.refreshNow,
        child: ListView(
          padding: resolveWorkspacePagePadding(context),
          children: <Widget>[
            RealtimeMonitorHero(
              state: state,
              onRefresh: controller.refreshNow,
              onToggleAutoRefresh: controller.setAutoRefreshEnabled,
            ),
            const SizedBox(height: 20),
            if (!state.hasDeviceState && state.isRefreshing)
              const CommonCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
              )
            else
              WorkspaceBalancedColumns(
                breakpoint: 1020,
                primary: RealtimeMetricsSection(
                  deviceState: state.deviceState,
                  compactDesktop: compactDesktop,
                ),
                secondary: RealtimeControlsSection(
                  state: state,
                  compactDesktop: compactDesktop,
                  onToggleLed: (ledOn) =>
                      _handleToggleLed(context, controller, ledOn),
                ),
              ),
            const SizedBox(height: 20),
            RealtimeAiDetectionSection(
              overviewAsync: aiOverviewAsync,
              onRefresh: () => _refreshAiOverview(ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshAiOverview(WidgetRef ref) async {
    ref.invalidate(aiDetectionOverviewProvider);
    await ref.read(aiDetectionOverviewProvider.future);
  }

  Future<void> _handleToggleLed(
    BuildContext context,
    RealtimeDetectController controller,
    bool ledOn,
  ) async {
    try {
      final message = await controller.toggleLed(ledOn);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      final message = error is ApiException ? error.message : '$error';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

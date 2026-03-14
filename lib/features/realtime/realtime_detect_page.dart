import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/auth/application/current_user_label_provider.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_controls_section.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_metrics_section.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_monitor_hero.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_status_guide_section.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 实时监控页，负责展示设备状态、轮询结果与远程控制入口。
class RealtimeDetectPage extends ConsumerWidget {
  /// 创建实时监控页。
  const RealtimeDetectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(realtimeDetectControllerProvider);
    final currentUser = ref.watch(currentUserLabelProvider);
    final controller = ref.read(realtimeDetectControllerProvider.notifier);

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.realtime,
      title: '值守台',
      subtitle: '查看实时状态，必要时处理补光。',
      currentUser: currentUser,
      maxContentWidth: 1180,
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 980;
                  final metrics = RealtimeMetricsSection(
                    deviceState: state.deviceState,
                  );
                  final sideColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RealtimeControlsSection(
                        state: state,
                        onToggleLed: (ledOn) =>
                            _handleToggleLed(context, controller, ledOn),
                      ),
                      const SizedBox(height: 20),
                      RealtimeStatusGuideSection(
                        deviceState: state.deviceState,
                      ),
                    ],
                  );

                  if (!isWide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        metrics,
                        const SizedBox(height: 20),
                        sideColumn,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 11, child: metrics),
                      const SizedBox(width: 20),
                      Expanded(flex: 10, child: sideColumn),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
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

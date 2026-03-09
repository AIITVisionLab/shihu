import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_controls_section.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_metrics_section.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_monitor_hero.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_monitor_top_bar.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_status_guide_section.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 实时监控页，对齐后端 `index.html` 的设备监控主控台。
class RealtimeDetectPage extends ConsumerStatefulWidget {
  /// 创建实时监控页。
  const RealtimeDetectPage({super.key});

  @override
  ConsumerState<RealtimeDetectPage> createState() => _RealtimeDetectPageState();
}

class _RealtimeDetectPageState extends ConsumerState<RealtimeDetectPage> {
  late final RealtimeDetectController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(realtimeDetectControllerProvider.notifier);
    Future<void>.microtask(_controller.startMonitoring);
  }

  @override
  void dispose() {
    _controller.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(realtimeDetectControllerProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('实时监控主控台')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.refreshNow,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  RealtimeMonitorTopBar(
                    currentUser:
                        authState.session?.user.displayName ??
                        authState.session?.user.account ??
                        '--',
                    state: state,
                    onOpenOverview: () => context.goNamed(AppRoutes.home),
                    onOpenSettings: () => context.pushNamed(AppRoutes.settings),
                    onRefresh: _controller.refreshNow,
                    onToggleAutoRefresh: _controller.setAutoRefreshEnabled,
                    onLogout: _handleLogout,
                  ),
                  const SizedBox(height: 20),
                  RealtimeMonitorHero(state: state),
                  const SizedBox(height: 20),
                  if (!state.hasDeviceState && state.isRefreshing)
                    const CommonCard(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
                    )
                  else ...<Widget>[
                    RealtimeMetricsSection(deviceState: state.deviceState),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 900;
                        final controls = RealtimeControlsSection(
                          state: state,
                          onToggleLed: _handleToggleLed,
                        );
                        final guide = RealtimeStatusGuideSection(
                          deviceState: state.deviceState,
                        );

                        if (!isWide) {
                          return Column(
                            children: <Widget>[
                              controls,
                              const SizedBox(height: 20),
                              guide,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: controls),
                            const SizedBox(width: 20),
                            Expanded(child: guide),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleToggleLed(bool ledOn) async {
    try {
      final message = await _controller.toggleLed(ledOn);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is ApiException ? error.message : '$error';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _handleLogout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) {
      return;
    }

    context.goNamed(AppRoutes.login);
  }
}

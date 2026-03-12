import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_controls_section.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_metrics_section.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_monitor_hero.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_monitor_top_bar.dart';
import 'package:sickandflutter/features/realtime/widgets/realtime_status_guide_section.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/reveal_on_mount.dart';

/// 实时监控页，负责展示设备状态、轮询结果与远程控制入口。
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
    final currentUser =
        authState.session?.user.displayName ??
        authState.session?.user.account ??
        '--';

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.realtime,
      title: '值守台',
      subtitle: '查看实时状态，必要时处理补光。',
      currentUser: currentUser,
      child: RefreshIndicator(
        onRefresh: _controller.refreshNow,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: <Widget>[
            RevealOnMount(
              child: RealtimeMonitorTopBar(
                state: state,
                onRefresh: _controller.refreshNow,
                onToggleAutoRefresh: _controller.setAutoRefreshEnabled,
                onLogout: _handleLogout,
              ),
            ),
            const SizedBox(height: 20),
            RevealOnMount(
              delay: const Duration(milliseconds: 80),
              child: RealtimeMonitorHero(state: state),
            ),
            const SizedBox(height: 20),
            if (!state.hasDeviceState && state.isRefreshing)
              const RevealOnMount(
                delay: Duration(milliseconds: 140),
                child: CommonCard(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
                ),
              )
            else ...<Widget>[
              RevealOnMount(
                delay: const Duration(milliseconds: 140),
                child: RealtimeMetricsSection(deviceState: state.deviceState),
              ),
              const SizedBox(height: 20),
              RevealOnMount(
                delay: const Duration(milliseconds: 200),
                child: LayoutBuilder(
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
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleToggleLed(bool ledOn) async {
    try {
      final message = await _controller.toggleLed(ledOn);
      unawaited(_refreshAfterLedCommand());
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

  Future<void> _refreshAfterLedCommand() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    await _controller.refreshNow();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('退出后需要重新登录才能继续使用，是否继续？'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认退出'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) {
      return;
    }

    context.goNamed(AppRoutes.login);
  }
}

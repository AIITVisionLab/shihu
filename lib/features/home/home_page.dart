import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/home/widgets/home_device_snapshot_card.dart';
import 'package:sickandflutter/features/home/widgets/home_entry_card.dart';
import 'package:sickandflutter/features/home/widgets/home_header_card.dart';
import 'package:sickandflutter/features/settings/device_state_repository.dart';
import 'package:sickandflutter/shared/widgets/adaptive_wrap_grid.dart';

/// 首页，作为培育管理平台的总览入口。
class HomePage extends ConsumerStatefulWidget {
  /// 创建首页。
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) {
        return;
      }
      _refreshOverview();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshOverview() {
    ref.invalidate(deviceStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final deviceStateAsync = ref.watch(deviceStateProvider);
    final currentUser =
        authState.session?.user.displayName ??
        authState.session?.user.account ??
        '--';

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.home,
      title: '总览',
      subtitle: '先看当前状态，再决定是否进入值守。',
      currentUser: currentUser,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HomeHeaderCard(
              currentUser: currentUser,
              deviceStateAsync: deviceStateAsync,
              onRefresh: _refreshOverview,
            ),
            const SizedBox(height: 16),
            AdaptiveWrapGrid(
              minItemWidth: 300,
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                HomeEntryCard(
                  icon: Icons.monitor_heart_rounded,
                  title: AppCopy.homeRealtimeTitle,
                  subtitle: '查看实时状态，必要时处理补光。',
                  onTap: () => context.goNamed(AppRoutes.realtimeDetect),
                ),
                HomeEntryCard(
                  icon: Icons.info_outline_rounded,
                  title: AppCopy.homePreviewTitle,
                  subtitle: '快速了解页面怎么用。',
                  onTap: () => context.goNamed(AppRoutes.about),
                ),
                HomeEntryCard(
                  icon: Icons.settings_rounded,
                  title: AppCopy.homeSettingsTitle,
                  subtitle: '管理账号、设备和本机偏好。',
                  onTap: () => context.goNamed(AppRoutes.settings),
                ),
              ],
            ),
            const SizedBox(height: 18),
            HomeDeviceSnapshotCard(
              deviceStateAsync: deviceStateAsync,
              onRefresh: _refreshOverview,
            ),
          ],
        ),
      ),
    );
  }
}

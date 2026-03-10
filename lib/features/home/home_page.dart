import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/home/widgets/home_capability_card.dart';
import 'package:sickandflutter/features/home/widgets/home_device_snapshot_card.dart';
import 'package:sickandflutter/features/home/widgets/home_entry_card.dart';
import 'package:sickandflutter/features/home/widgets/home_header_card.dart';
import 'package:sickandflutter/features/settings/device_state_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/widgets/adaptive_wrap_grid.dart';

/// 首页，作为培育管理平台的总览入口。
class HomePage extends ConsumerWidget {
  /// 创建首页。
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version =
        ref.watch(packageInfoProvider).asData?.value.version ?? '--';
    final authState = ref.watch(authControllerProvider);
    final deviceStateAsync = ref.watch(deviceStateProvider);
    final currentUser =
        authState.session?.user.displayName ??
        authState.session?.user.account ??
        '--';

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.home,
      title: '工作台首页',
      subtitle: '汇总当前设备链路、关键入口和运行基线，作为值守与排障的统一起点。',
      currentUser: currentUser,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: <Widget>[
          HomeHeaderCard(version: version, currentUser: currentUser),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 920;
              final snapshot = HomeDeviceSnapshotCard(
                deviceStateAsync: deviceStateAsync,
                onRefresh: () => ref.invalidate(deviceStateProvider),
              );
              const capability = HomeCapabilityCard();

              if (!isWide) {
                return Column(
                  children: <Widget>[
                    capability,
                    const SizedBox(height: 18),
                    snapshot,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Expanded(child: capability),
                  const SizedBox(width: 18),
                  Expanded(child: snapshot),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          const _ActionSectionHeader(),
          const SizedBox(height: 16),
          AdaptiveWrapGrid(
            minItemWidth: 300,
            spacing: 16,
            runSpacing: 16,
            children: <Widget>[
              HomeEntryCard(
                icon: Icons.videocam_rounded,
                title: AppCopy.homeVideoTitle,
                subtitle: AppCopy.homeVideoSubtitle,
                onTap: () => context.pushNamed(AppRoutes.video),
              ),
              HomeEntryCard(
                icon: Icons.monitor_heart_rounded,
                title: AppCopy.homeRealtimeTitle,
                subtitle: '查看实时设备状态、告警等级和补光控制。',
                onTap: () => context.pushNamed(AppRoutes.realtimeDetect),
              ),
              HomeEntryCard(
                icon: Icons.info_outline_rounded,
                title: AppCopy.homePreviewTitle,
                subtitle: AppCopy.homePreviewSubtitle,
                onTap: () => context.pushNamed(AppRoutes.about),
              ),
              HomeEntryCard(
                icon: Icons.settings_rounded,
                title: AppCopy.homeSettingsTitle,
                subtitle: '检查服务健康、当前会话与基础配置。',
                onTap: () => context.pushNamed(AppRoutes.settings),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionSectionHeader extends StatelessWidget {
  const _ActionSectionHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '进入工作台',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '所有入口都直接落到当前版本可直接使用的业务能力，不再暴露未接入模块。',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

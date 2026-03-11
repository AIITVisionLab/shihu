import 'dart:async';

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
import 'package:sickandflutter/features/settings/service_health_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/widgets/adaptive_wrap_grid.dart';
import 'package:sickandflutter/shared/widgets/reveal_on_mount.dart';

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
    ref.invalidate(serviceHealthProvider);
  }

  @override
  Widget build(BuildContext context) {
    final version =
        ref.watch(packageInfoProvider).asData?.value.version ?? '--';
    final authState = ref.watch(authControllerProvider);
    final deviceStateAsync = ref.watch(deviceStateProvider);
    final serviceHealthAsync = ref.watch(serviceHealthProvider);
    final currentUser =
        authState.session?.user.displayName ??
        authState.session?.user.account ??
        '--';

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.home,
      title: '监测总览',
      subtitle: '先看实时状态和巡检结果，再决定进入主控台处置还是进入设置页排障。',
      currentUser: currentUser,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RevealOnMount(
              child: HomeHeaderCard(
                version: version,
                currentUser: currentUser,
                deviceStateAsync: deviceStateAsync,
                serviceHealthAsync: serviceHealthAsync,
                onRefresh: _refreshOverview,
              ),
            ),
            const SizedBox(height: 22),
            const RevealOnMount(
              delay: Duration(milliseconds: 80),
              child: _ActionSectionHeader(),
            ),
            const SizedBox(height: 16),
            AdaptiveWrapGrid(
              minItemWidth: 300,
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                RevealOnMount(
                  delay: const Duration(milliseconds: 140),
                  child: HomeEntryCard(
                    icon: Icons.monitor_heart_rounded,
                    title: AppCopy.homeRealtimeTitle,
                    subtitle: '查看实时设备状态、告警等级和补光控制。',
                    onTap: () => context.goNamed(AppRoutes.realtimeDetect),
                  ),
                ),
                RevealOnMount(
                  delay: const Duration(milliseconds: 200),
                  child: HomeEntryCard(
                    icon: Icons.info_outline_rounded,
                    title: AppCopy.homePreviewTitle,
                    subtitle: AppCopy.homePreviewSubtitle,
                    onTap: () => context.goNamed(AppRoutes.about),
                  ),
                ),
                RevealOnMount(
                  delay: const Duration(milliseconds: 260),
                  child: HomeEntryCard(
                    icon: Icons.settings_rounded,
                    title: AppCopy.homeSettingsTitle,
                    subtitle: '检查服务健康、当前会话与基础配置。',
                    onTap: () => context.goNamed(AppRoutes.settings),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            RevealOnMount(
              delay: const Duration(milliseconds: 320),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 920;
                  final snapshot = HomeDeviceSnapshotCard(
                    deviceStateAsync: deviceStateAsync,
                    onRefresh: _refreshOverview,
                  );
                  const capability = HomeCapabilityCard();

                  if (!isWide) {
                    return Column(
                      children: <Widget>[
                        snapshot,
                        const SizedBox(height: 18),
                        capability,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: snapshot),
                      const SizedBox(width: 18),
                      const Expanded(child: capability),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionSectionHeader extends StatelessWidget {
  const _ActionSectionHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.38),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 560;
          final titleBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '值守入口',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '先进入主控台处理实时告警，再用设置页做巡检和切换，总览页只负责补充背景信息。',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
          final badge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '3 个值守入口',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _buildHeaderIcon(colorScheme),
                    const Spacer(),
                    badge,
                  ],
                ),
                const SizedBox(height: 16),
                titleBlock,
              ],
            );
          }

          return Row(
            children: <Widget>[
              _buildHeaderIcon(colorScheme),
              const SizedBox(width: 16),
              Expanded(child: titleBlock),
              const SizedBox(width: 16),
              badge,
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderIcon(ColorScheme colorScheme) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        Icons.dashboard_customize_outlined,
        color: colorScheme.primary,
      ),
    );
  }
}

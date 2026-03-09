import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/home/widgets/home_capability_card.dart';
import 'package:sickandflutter/features/home/widgets/home_device_snapshot_card.dart';
import 'package:sickandflutter/features/home/widgets/home_entry_card.dart';
import 'package:sickandflutter/features/home/widgets/home_header_card.dart';
import 'package:sickandflutter/features/settings/device_state_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/widgets/adaptive_wrap_grid.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';

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

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: AppBackdrop()),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: <Widget>[
                    HomeHeaderCard(
                      version: version,
                      currentUser:
                          authState.session?.user.displayName ??
                          authState.session?.user.account ??
                          '--',
                    ),
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
                          icon: Icons.monitor_heart_rounded,
                          title: '监控主控台',
                          subtitle: '查看实时设备状态、告警等级和补光控制。',
                          onTap: () =>
                              context.pushNamed(AppRoutes.realtimeDetect),
                        ),
                        HomeEntryCard(
                          icon: Icons.info_outline_rounded,
                          title: '公开预览',
                          subtitle: '查看项目背景、架构说明和研究叙事。',
                          onTap: () => context.pushNamed(AppRoutes.about),
                        ),
                        HomeEntryCard(
                          icon: Icons.settings_rounded,
                          title: '运维设置',
                          subtitle: '检查服务健康、当前会话与基础配置。',
                          onTap: () => context.pushNamed(AppRoutes.settings),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
            '进入工作流',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '所有入口都直接落到真实可用页面，不再暴露后端没有支撑的能力。',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

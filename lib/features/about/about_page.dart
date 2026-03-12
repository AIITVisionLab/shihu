import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/features/about/widgets/about_capability_section.dart';
import 'package:sickandflutter/features/about/widgets/about_collaboration_section.dart';
import 'package:sickandflutter/features/about/widgets/about_hero_section.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';

/// 系统总览页，承接主路径说明与后端协作边界说明。
class AboutPage extends ConsumerWidget {
  /// 创建系统总览页。
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUser =
        authState.session?.user.displayName ??
        authState.session?.user.account ??
        '--';

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.about,
      title: '工作说明',
      subtitle: '把日常使用路径和后端协作边界放到一页讲清楚。',
      currentUser: currentUser,
      maxContentWidth: 1240,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFF050B13),
          Color(0xFF091526),
          Color(0xFF040911),
        ],
      ),
      backgroundOrbs: const <BackdropOrbData>[
        BackdropOrbData(
          alignment: Alignment(-1.02, -0.94),
          size: 340,
          color: Color(0x164CB8FF),
        ),
        BackdropOrbData(
          alignment: Alignment(1.0, -0.38),
          size: 280,
          color: Color(0x1456D3FF),
        ),
        BackdropOrbData(
          alignment: Alignment(0.86, 1.12),
          size: 260,
          color: Color(0x12318BFF),
        ),
      ],
      showGrid: true,
      headerActions: <Widget>[
        if (authState.isAuthenticated)
          OutlinedButton.icon(
            onPressed: () => context.goNamed(AppRoutes.home),
            icon: const Icon(Icons.dashboard_outlined),
            label: const Text('返回总览'),
          ),
        FilledButton.icon(
          onPressed: () => context.goNamed(
            authState.isAuthenticated
                ? AppRoutes.realtimeDetect
                : AppRoutes.login,
          ),
          icon: Icon(
            authState.isAuthenticated
                ? Icons.monitor_heart_rounded
                : Icons.login_rounded,
          ),
          label: Text(authState.isAuthenticated ? '进入值守' : '立即登录'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: <Widget>[
          const AboutHeroSection(),
          const SizedBox(height: 22),
          const AboutCapabilitySection(),
          const SizedBox(height: 18),
          const AboutCollaborationSection(),
          const SizedBox(height: 18),
          Center(
            child: Text(
              '${AppConstants.appName}工作说明 · 当前版本先把主路径讲清楚，未来视频与 AI 协作只保留边界说明',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

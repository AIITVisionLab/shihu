import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/features/about/widgets/about_capability_section.dart';
import 'package:sickandflutter/features/about/widgets/about_hero_section.dart';
import 'package:sickandflutter/features/about/widgets/about_research_section.dart';
import 'package:sickandflutter/features/about/widgets/about_target_section.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';

/// 系统总览页，承接产品定位、业务架构和栽培背景说明。
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
      title: '系统总览',
      subtitle: '围绕栽培背景、业务闭环和调控目标理解整套软件与设备协同方式。',
      currentUser: currentUser,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFF6F1E5),
          Color(0xFFF7F4EC),
          Color(0xFFECE5D8),
        ],
      ),
      backgroundOrbs: const <BackdropOrbData>[
        BackdropOrbData(
          alignment: Alignment(-1.05, -0.95),
          size: 300,
          color: Color(0x2981C18B),
        ),
        BackdropOrbData(
          alignment: Alignment(1.0, -0.45),
          size: 260,
          color: Color(0x24B98B50),
        ),
        BackdropOrbData(
          alignment: Alignment(0.88, 1.12),
          size: 240,
          color: Color(0x175C8B75),
        ),
      ],
      headerActions: <Widget>[
        if (authState.isAuthenticated)
          OutlinedButton.icon(
            onPressed: () => context.goNamed(AppRoutes.home),
            icon: const Icon(Icons.dashboard_outlined),
            label: const Text('平台首页'),
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
          label: Text(authState.isAuthenticated ? '进入主控台' : '立即登录'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: <Widget>[
          const AboutHeroSection(),
          const SizedBox(height: 22),
          const AboutCapabilitySection(),
          const SizedBox(height: 22),
          const AboutResearchSection(),
          const SizedBox(height: 22),
          const AboutTargetSection(),
          const SizedBox(height: 18),
          Center(
            child: Text(
              '${AppConstants.appName}系统总览 · 聚焦环境监测、风险预警与远程调控',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B756F)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

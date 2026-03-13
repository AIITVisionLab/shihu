import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/features/about/widgets/about_help_hero.dart';
import 'package:sickandflutter/features/about/widgets/about_information_section.dart';
import 'package:sickandflutter/features/about/widgets/about_usage_tracks_section.dart';
import 'package:sickandflutter/features/auth/application/current_user_label_provider.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';

/// 使用帮助页，集中说明主路径和查看重点。
class AboutPage extends ConsumerWidget {
  /// 创建使用帮助页。
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUser = ref.watch(currentUserLabelProvider);

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.settings,
      title: '使用帮助',
      subtitle: '把日常查看、值守和账号设置说清楚。',
      currentUser: currentUser,
      maxContentWidth: 1120,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          AppPalette.paperSnow,
          AppPalette.paperMist,
          AppPalette.paper,
        ],
      ),
      headerActions: <Widget>[
        if (authState.isAuthenticated)
          OutlinedButton.icon(
            onPressed: () => context.goNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            label: const Text('返回我的'),
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
        children: const <Widget>[
          AboutHelpHero(),
          SizedBox(height: 18),
          AboutUsageTracksSection(),
          SizedBox(height: 18),
          AboutInformationSection(),
        ],
      ),
    );
  }
}

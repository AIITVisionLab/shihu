import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/core/storage/sensitive_storage.dart';
import 'package:sickandflutter/features/auth/application/current_user_label_provider.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/remembered_account_repository.dart';
import 'package:sickandflutter/features/device/application/device_runtime_providers.dart';
import 'package:sickandflutter/features/platform_logs/application/platform_log_providers.dart';
import 'package:sickandflutter/features/settings/application/settings_page_actions.dart';
import 'package:sickandflutter/features/settings/domain/settings_profile_snapshot.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/features/settings/widgets/settings_overview_card.dart';
import 'package:sickandflutter/features/settings/widgets/settings_platform_log_card.dart';
import 'package:sickandflutter/features/settings/widgets/settings_profile_card.dart';
import 'package:sickandflutter/shared/widgets/loading_view.dart';

/// 设置页，负责展示当前使用、账号信息和本机偏好。
class SettingsPage extends ConsumerWidget {
  /// 创建设置页。
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final deviceStateAsync = ref.watch(deviceStatusProvider);
    final rememberedAccountAsync = ref.watch(
      rememberedAccountControllerProvider,
    );
    final authState = ref.watch(authControllerProvider);
    final supportsPersistentSession = ref.watch(
      supportsPersistentSensitiveStorageProvider,
    );
    final currentUser = ref.watch(currentUserLabelProvider);
    final platformLogAsync = ref.watch(platformLogOverviewProvider);
    final actions = SettingsPageActions(context: context, ref: ref);

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.settings,
      title: AppCopy.settingsPageTitle,
      subtitle: '查看当前设备状态，管理账号和本机偏好。',
      currentUser: currentUser,
      child: settingsAsync.when(
        loading: () => const LoadingView(message: AppCopy.settingsLoading),
        error: (error, stackTrace) =>
            Center(child: Text(AppCopy.settingsLoadFailed(error))),
        data: (_) {
          final rememberedAccount = rememberedAccountAsync.asData?.value;
          final profileSnapshot = SettingsProfileSnapshot.fromState(
            authState: authState,
            supportsPersistentSession: supportsPersistentSession,
            rememberedAccount: rememberedAccount,
          );
          final profileCard = SettingsProfileCard(
            snapshot: profileSnapshot,
            isSubmitting: authState.isSubmitting,
            onLogout: actions.logout,
            onOpenAbout: () => context.goNamed(AppRoutes.about),
            onClearRememberedAccount: () => actions.clearRememberedAccount(
              rememberedAccount: rememberedAccount,
            ),
            onResetSettings: actions.resetSettings,
          );
          final platformLogCard = SettingsPlatformLogCard(
            overviewAsync: platformLogAsync,
            onRefresh: actions.refreshPlatformLogs,
          );

          return SingleChildScrollView(
            padding: resolveWorkspacePagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SettingsOverviewCard(
                  currentUser: currentUser,
                  deviceStateAsync: deviceStateAsync,
                ),
                const SizedBox(height: 14),
                profileCard,
                const SizedBox(height: 14),
                platformLogCard,
              ],
            ),
          );
        },
      ),
    );
  }
}

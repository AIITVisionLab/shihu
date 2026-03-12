import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/remembered_account_repository.dart';
import 'package:sickandflutter/features/settings/device_state_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/features/settings/widgets/settings_auth_session_card.dart';
import 'package:sickandflutter/features/settings/widgets/settings_local_data_card.dart';
import 'package:sickandflutter/features/settings/widgets/settings_overview_card.dart';
import 'package:sickandflutter/shared/widgets/loading_view.dart';

/// 设置页，负责展示当前设备、账号和本地偏好。
class SettingsPage extends ConsumerWidget {
  /// 创建设置页。
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final packageInfo = ref.watch(packageInfoProvider).asData?.value;
    final deviceStateAsync = ref.watch(deviceStateProvider);
    final rememberedAccountAsync = ref.watch(
      rememberedAccountControllerProvider,
    );
    final authState = ref.watch(authControllerProvider);
    final currentUser =
        authState.session?.user.displayName ??
        authState.session?.user.account ??
        '--';

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.settings,
      title: AppCopy.settingsPageTitle,
      subtitle: '管理当前设备、登录账号和本机偏好。',
      currentUser: currentUser,
      maxContentWidth: 920,
      child: settingsAsync.when(
        loading: () => const LoadingView(message: AppCopy.settingsLoading),
        error: (error, stackTrace) =>
            Center(child: Text(AppCopy.settingsLoadFailed(error))),
        data: (_) {
          final authSessionCard = SettingsAuthSessionCard(
            authState: authState,
            onLogout: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text(AppCopy.settingsLogoutTitle),
                  content: const Text(AppCopy.settingsLogoutMessage),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text(AppCopy.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text(AppCopy.settingsLogoutConfirm),
                    ),
                  ],
                ),
              );

              if (confirmed != true) {
                return;
              }

              await ref.read(authControllerProvider.notifier).logout();
              if (!context.mounted) {
                return;
              }

              context.goNamed(AppRoutes.login);
            },
          );
          final localDataCard = SettingsLocalDataCard(
            rememberedAccount: rememberedAccountAsync.asData?.value,
            onClearRememberedAccount: () async {
              final rememberedAccount = rememberedAccountAsync.asData?.value;
              if (rememberedAccount == null || rememberedAccount.isEmpty) {
                return;
              }

              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text(
                    AppCopy.settingsClearRememberedAccountTitle,
                  ),
                  content: const Text(
                    AppCopy.settingsClearRememberedAccountMessage,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text(AppCopy.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text(AppCopy.confirm),
                    ),
                  ],
                ),
              );

              if (confirmed != true) {
                return;
              }

              await ref
                  .read(rememberedAccountControllerProvider.notifier)
                  .clear();
              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(AppCopy.settingsRememberedAccountCleared),
                  ),
                );
            },
            onResetSettings: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text(AppCopy.settingsResetDefaultsTitle),
                  content: const Text(AppCopy.settingsResetDefaultsMessage),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text(AppCopy.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text(AppCopy.confirm),
                    ),
                  ],
                ),
              );

              if (confirmed != true) {
                return;
              }

              await ref.read(settingsControllerProvider.notifier).reset();
              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(AppCopy.settingsResetDefaultsDone),
                  ),
                );
            },
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SettingsOverviewCard(
                  versionLabel: packageInfo == null
                      ? '--'
                      : '${packageInfo.version}+${packageInfo.buildNumber}',
                  deviceStateAsync: deviceStateAsync,
                ),
                const SizedBox(height: 20),
                _SettingsResponsiveRow(
                  left: authSessionCard,
                  right: localDataCard,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsResponsiveRow extends StatelessWidget {
  const _SettingsResponsiveRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1040) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[left, const SizedBox(height: 20), right],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: left),
            const SizedBox(width: 20),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

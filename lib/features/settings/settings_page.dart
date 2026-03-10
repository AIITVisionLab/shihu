import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/remembered_account_repository.dart';
import 'package:sickandflutter/features/history/history_repository.dart';
import 'package:sickandflutter/features/settings/device_state_repository.dart';
import 'package:sickandflutter/features/settings/service_health_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/features/settings/widgets/settings_about_project_card.dart';
import 'package:sickandflutter/features/settings/widgets/settings_auth_session_card.dart';
import 'package:sickandflutter/features/settings/widgets/settings_device_state_card.dart';
import 'package:sickandflutter/features/settings/widgets/settings_local_data_card.dart';
import 'package:sickandflutter/features/settings/widgets/settings_overview_card.dart';
import 'package:sickandflutter/features/settings/widgets/settings_service_config_card.dart';
import 'package:sickandflutter/features/settings/widgets/settings_service_health_card.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/widgets/loading_view.dart';

/// 设置页，负责展示环境信息、服务状态和本地配置入口。
class SettingsPage extends ConsumerWidget {
  /// 创建设置页。
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final packageInfo = ref.watch(packageInfoProvider).asData?.value;
    final envConfig = ref.watch(envConfigProvider);
    final serviceHealthAsync = ref.watch(serviceHealthProvider);
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
      subtitle: '查看运行环境、服务健康、设备状态与本机配置，集中处理日常排障动作。',
      currentUser: currentUser,
      maxContentWidth: 940,
      child: settingsAsync.when(
        loading: () => const LoadingView(message: AppCopy.settingsLoading),
        error: (error, stackTrace) =>
            Center(child: Text(AppCopy.settingsLoadFailed(error))),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: <Widget>[
              SettingsOverviewCard(
                buildFlavorLabel: settings.buildFlavor.label,
                platformLabel: currentPlatformLabel(),
                versionLabel: packageInfo == null
                    ? '--'
                    : '${packageInfo.version}+${packageInfo.buildNumber}',
              ),
              const SizedBox(height: 20),
              SettingsServiceConfigCard(
                envConfig: envConfig,
                settings: settings,
                onEditBaseUrl: envConfig.allowRiskySettings
                    ? () async {
                        final nextValue = await _showBaseUrlDialog(
                          context,
                          initialValue: settings.baseUrl,
                        );
                        if (nextValue == null || nextValue.isEmpty) {
                          return;
                        }

                        await ref
                            .read(settingsControllerProvider.notifier)
                            .updateBaseUrl(nextValue);
                      }
                    : null,
              ),
              const SizedBox(height: 20),
              SettingsServiceHealthCard(
                healthAsync: serviceHealthAsync,
                onRefresh: () => ref.invalidate(serviceHealthProvider),
              ),
              const SizedBox(height: 20),
              SettingsDeviceStateCard(
                deviceStateAsync: deviceStateAsync,
                onRefresh: () => ref.invalidate(deviceStateProvider),
                onToggleLed: (state, ledOn) async {
                  try {
                    final repository = await ref.read(
                      deviceStateRepositoryProvider.future,
                    );
                    final receipt = await repository.setLed(
                      deviceId: state.deviceId,
                      deviceName: state.deviceName,
                      ledOn: ledOn,
                    );
                    ref.invalidate(deviceStateProvider);
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(receipt.buildUserMessage(ledOn: ledOn)),
                        ),
                      );
                  } catch (error) {
                    if (!context.mounted) {
                      return;
                    }
                    final message = error is ApiException
                        ? error.message
                        : 'LED 控制失败：$error';
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(message)));
                  }
                },
              ),
              const SizedBox(height: 20),
              SettingsAuthSessionCard(
                authState: authState,
                onLogout: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text(AppCopy.settingsLogoutTitle),
                      content: const Text(AppCopy.settingsLogoutMessage),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text(AppCopy.cancel),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
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
              ),
              const SizedBox(height: 20),
              SettingsLocalDataCard(
                rememberedAccount: rememberedAccountAsync.asData?.value,
                onClearRememberedAccount: () async {
                  final rememberedAccount =
                      rememberedAccountAsync.asData?.value;
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
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text(AppCopy.cancel),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
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
                onClearHistory: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text(AppCopy.settingsClearHistoryTitle),
                      content: const Text(AppCopy.settingsClearHistoryMessage),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text(AppCopy.cancel),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text(AppCopy.confirm),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true) {
                    return;
                  }

                  await ref.read(historyControllerProvider.notifier).clearAll();
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(AppCopy.settingsHistoryCleared),
                      ),
                    );
                },
                onResetSettings: () async {
                  await ref.read(settingsControllerProvider.notifier).reset();
                },
              ),
              const SizedBox(height: 20),
              SettingsAboutProjectCard(
                onOpenAbout: () => context.pushNamed(AppRoutes.about),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<String?> _showBaseUrlDialog(
  BuildContext context, {
  required String initialValue,
}) async {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(AppCopy.settingsEditBaseUrlTitle),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: AppCopy.settingsBaseUrlHint,
        ),
        autofocus: true,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text(AppCopy.cancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(controller.text.trim()),
          child: const Text(AppCopy.save),
        ),
      ],
    ),
  );
}

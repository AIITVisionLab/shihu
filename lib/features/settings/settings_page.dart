import 'dart:async';

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
import 'package:sickandflutter/shared/widgets/reveal_on_mount.dart';

/// 设置页，负责展示环境信息、服务状态和本地配置入口。
class SettingsPage extends ConsumerStatefulWidget {
  /// 创建设置页。
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (!mounted) {
        return;
      }
      _refreshStatusCards();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshStatusCards() {
    ref.invalidate(serviceHealthProvider);
    ref.invalidate(deviceStateProvider);
  }

  Future<void> _refreshStatusCardsAfterLedCommand() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    _refreshStatusCards();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final packageInfo = ref.watch(packageInfoProvider).asData?.value;
    final envConfig = ref.watch(envConfigProvider);
    final serviceEndpoints = ref.watch(resolvedServiceEndpointsProvider);
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
      subtitle: '集中查看服务巡检、设备快照、登录会话和本机配置，作为石斛监测后台的排障入口。',
      currentUser: currentUser,
      maxContentWidth: 1180,
      child: settingsAsync.when(
        loading: () => const LoadingView(message: AppCopy.settingsLoading),
        error: (error, stackTrace) =>
            Center(child: Text(AppCopy.settingsLoadFailed(error))),
        data: (settings) {
          final serviceConfigCard = RevealOnMount(
            delay: const Duration(milliseconds: 70),
            child: SettingsServiceConfigCard(
              envConfig: envConfig,
              settings: settings,
              serviceEndpoints: serviceEndpoints,
              onEditBaseUrl: envConfig.allowRiskySettings
                  ? () async {
                      final nextValue = await _showServiceBaseUrlDialog(
                        context,
                        title: AppCopy.settingsEditBaseUrlTitle,
                        initialValue: settings.baseUrl,
                        hintText: AppCopy.settingsBaseUrlHint,
                      );
                      if (nextValue == null) {
                        return;
                      }

                      try {
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .updateBaseUrl(nextValue);
                      } on FormatException catch (error) {
                        if (!context.mounted) {
                          return;
                        }
                        _showSettingsSnackBar(
                          context,
                          _formatExceptionMessage(
                            error,
                            fallbackMessage: '设备服务地址格式不正确。',
                          ),
                        );
                      }
                    }
                  : null,
            ),
          );
          final serviceHealthCard = RevealOnMount(
            delay: const Duration(milliseconds: 120),
            child: SettingsServiceHealthCard(
              healthAsync: serviceHealthAsync,
              onRefresh: _refreshStatusCards,
            ),
          );
          final deviceStateCard = RevealOnMount(
            delay: const Duration(milliseconds: 170),
            child: SettingsDeviceStateCard(
              deviceStateAsync: deviceStateAsync,
              onRefresh: _refreshStatusCards,
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
                  _refreshStatusCards();
                  unawaited(_refreshStatusCardsAfterLedCommand());
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
          );
          final authSessionCard = RevealOnMount(
            delay: const Duration(milliseconds: 220),
            child: SettingsAuthSessionCard(
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
            ),
          );
          final localDataCard = RevealOnMount(
            delay: const Duration(milliseconds: 270),
            child: SettingsLocalDataCard(
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
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RevealOnMount(
                  child: SettingsOverviewCard(
                    buildFlavorLabel: settings.buildFlavor.label,
                    platformLabel: currentPlatformLabel(),
                    versionLabel: packageInfo == null
                        ? '--'
                        : '${packageInfo.version}+${packageInfo.buildNumber}',
                    deviceStateAsync: deviceStateAsync,
                    serviceHealthAsync: serviceHealthAsync,
                  ),
                ),
                const SizedBox(height: 20),
                serviceConfigCard,
                const SizedBox(height: 20),
                _SettingsResponsiveRow(
                  left: serviceHealthCard,
                  right: deviceStateCard,
                ),
                const SizedBox(height: 20),
                _SettingsResponsiveRow(
                  left: authSessionCard,
                  right: localDataCard,
                ),
                const SizedBox(height: 20),
                RevealOnMount(
                  delay: const Duration(milliseconds: 320),
                  child: SettingsAboutProjectCard(
                    onOpenAbout: () => context.goNamed(AppRoutes.about),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<String?> _showServiceBaseUrlDialog(
  BuildContext context, {
  required String title,
  required String initialValue,
  required String hintText,
  String? helperText,
}) async {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hintText),
            autofocus: true,
          ),
          if (helperText != null && helperText.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              helperText,
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
          ],
        ],
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

void _showSettingsSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

String _formatExceptionMessage(
  FormatException error, {
  required String fallbackMessage,
}) {
  final rawMessage = error.message;
  if (rawMessage.trim().isNotEmpty) {
    return rawMessage.trim();
  }
  return fallbackMessage;
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

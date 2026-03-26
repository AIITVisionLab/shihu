import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/remembered_account_repository.dart';
import 'package:sickandflutter/features/platform_logs/application/platform_log_providers.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';

/// 设置页动作协调器。
///
/// 统一收口确认弹窗、提示反馈和跨模块动作串联，避免页面文件继续堆叠流程代码。
class SettingsPageActions {
  /// 创建设置页动作协调器。
  const SettingsPageActions({
    required BuildContext context,
    required WidgetRef ref,
  }) : _context = context,
       _ref = ref;

  final BuildContext _context;
  final WidgetRef _ref;

  /// 退出当前登录态。
  Future<void> logout() async {
    final confirmed = await _confirmAction(
      title: AppCopy.settingsLogoutTitle,
      message: AppCopy.settingsLogoutMessage,
      confirmLabel: AppCopy.settingsLogoutConfirm,
    );
    if (!confirmed) {
      return;
    }

    await _ref.read(authControllerProvider.notifier).logout();
    if (!_context.mounted) {
      return;
    }

    _context.goNamed(AppRoutes.login);
  }

  /// 清除本机记住的账号。
  Future<void> clearRememberedAccount({
    required String? rememberedAccount,
  }) async {
    final normalizedAccount = rememberedAccount?.trim();
    if (normalizedAccount == null || normalizedAccount.isEmpty) {
      return;
    }

    final confirmed = await _confirmAction(
      title: AppCopy.settingsClearRememberedAccountTitle,
      message: AppCopy.settingsClearRememberedAccountMessage,
      confirmLabel: AppCopy.confirm,
    );
    if (!confirmed) {
      return;
    }

    await _ref.read(rememberedAccountControllerProvider.notifier).clear();
    _showMessage(AppCopy.settingsRememberedAccountCleared);
  }

  /// 恢复当前环境下的默认设置。
  Future<void> resetSettings() async {
    final confirmed = await _confirmAction(
      title: AppCopy.settingsResetDefaultsTitle,
      message: AppCopy.settingsResetDefaultsMessage,
      confirmLabel: AppCopy.confirm,
    );
    if (!confirmed) {
      return;
    }

    await _ref.read(settingsControllerProvider.notifier).reset();
    _showMessage(AppCopy.settingsResetDefaultsDone);
  }

  /// 重新拉取平台日志。
  Future<void> refreshPlatformLogs() async {
    _ref.invalidate(platformLogOverviewProvider);
    await _ref.read(platformLogOverviewProvider.future);
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: _context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppCopy.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return confirmed == true;
  }

  void _showMessage(String message) {
    if (!_context.mounted) {
      return;
    }

    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/settings/widgets/settings_setting_row.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 设置页登录会话卡片。
class SettingsAuthSessionCard extends StatelessWidget {
  /// 创建登录会话卡片。
  const SettingsAuthSessionCard({
    required this.authState,
    required this.onLogout,
    super.key,
  });

  /// 当前认证状态。
  final AuthState authState;

  /// 退出登录回调。
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final session = authState.session;

    return CommonCard(
      title: AppCopy.settingsSessionTitle,
      subtitle: session == null
          ? AppCopy.settingsNoSession
          : AppCopy.settingsSessionSubtitle,
      child: session == null
          ? const Text(AppCopy.settingsUnauthenticated)
          : Column(
              children: <Widget>[
                SettingsSettingRow(
                  title: AppCopy.settingsCurrentAccount,
                  value: session.user.account,
                ),
                const SizedBox(height: 14),
                SettingsSettingRow(
                  title: AppCopy.settingsDisplayName,
                  value: session.user.displayName,
                ),
                const SizedBox(height: 14),
                SettingsSettingRow(
                  title: AppCopy.settingsLoginMode,
                  value: session.loginModeLabel,
                ),
                const SizedBox(height: 14),
                SettingsSettingRow(
                  title: AppCopy.settingsRole,
                  value: session.user.roles.isEmpty
                      ? '--'
                      : session.user.roles.join(', '),
                ),
                const SizedBox(height: 14),
                SettingsSettingRow(
                  title: AppCopy.settingsExpiry,
                  value: _formatExpiry(session.expiresAt),
                ),
                const SizedBox(height: 16),
                CommonButton(
                  label: authState.isSubmitting
                      ? AppCopy.settingsLoggingOut
                      : AppCopy.settingsLogout,
                  tone: CommonButtonTone.secondary,
                  icon: const Icon(Icons.logout_rounded),
                  isLoading: authState.isSubmitting,
                  onPressed: authState.isSubmitting
                      ? null
                      : () async {
                          await onLogout();
                        },
                ),
              ],
            ),
    );
  }

  String _formatExpiry(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return AppCopy.settingsExpiryMissing;
    }

    final dateTime = DateTime.tryParse(rawValue);
    if (dateTime == null) {
      return rawValue;
    }

    final localDateTime = dateTime.toLocal();
    final month = localDateTime.month.toString().padLeft(2, '0');
    final day = localDateTime.day.toString().padLeft(2, '0');
    final hour = localDateTime.hour.toString().padLeft(2, '0');
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    return '${localDateTime.year}-$month-$day $hour:$minute';
  }
}

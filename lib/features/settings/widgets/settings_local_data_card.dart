import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 设置页本地数据卡片。
class SettingsLocalDataCard extends StatelessWidget {
  /// 创建本地数据卡片。
  const SettingsLocalDataCard({
    required this.rememberedAccount,
    required this.onClearRememberedAccount,
    required this.onResetSettings,
    super.key,
  });

  /// 当前已记住的账号。
  final String? rememberedAccount;

  /// 清除已记住账号回调。
  final Future<void> Function() onClearRememberedAccount;

  /// 恢复默认设置回调。
  final Future<void> Function() onResetSettings;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: AppCopy.settingsLocalDataTitle,
      subtitle: AppCopy.settingsLocalDataSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppCopy.settingsRememberedAccount,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rememberedAccount?.trim().isNotEmpty == true
                      ? rememberedAccount!
                      : AppCopy.settingsRememberedAccountMissing,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CommonButton(
            label: AppCopy.settingsClearRememberedAccount,
            tone: CommonButtonTone.danger,
            icon: const Icon(Icons.person_remove_outlined),
            onPressed: rememberedAccount?.trim().isNotEmpty == true
                ? () async {
                    await onClearRememberedAccount();
                  }
                : null,
          ),
          const SizedBox(height: 12),
          CommonButton(
            label: AppCopy.settingsResetDefaults,
            tone: CommonButtonTone.secondary,
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () async {
              await onResetSettings();
            },
          ),
        ],
      ),
    );
  }
}

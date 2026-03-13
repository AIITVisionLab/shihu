import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

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
    final hasRememberedAccount = rememberedAccount?.trim().isNotEmpty == true;

    return CommonCard(
      title: AppCopy.settingsLocalDataTitle,
      subtitle: AppCopy.settingsLocalDataSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FeatureInsetPanel(
            padding: const EdgeInsets.all(18),
            borderRadius: 24,
            accentColor: AppPalette.linenOlive,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppCopy.settingsRememberedAccount,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  hasRememberedAccount
                      ? rememberedAccount!
                      : AppCopy.settingsRememberedAccountMissing,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  hasRememberedAccount
                      ? '当前设备会在下次登录时自动回填这个账号。'
                      : '当前没有保存登录账号，需要时可以重新勾选记住账号。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical = constraints.maxWidth < 620;
              final clearButton = CommonButton(
                label: AppCopy.settingsClearRememberedAccount,
                tone: CommonButtonTone.danger,
                icon: const Icon(Icons.person_remove_outlined),
                onPressed: hasRememberedAccount
                    ? () async {
                        await onClearRememberedAccount();
                      }
                    : null,
              );
              final resetButton = CommonButton(
                label: AppCopy.settingsResetDefaults,
                tone: CommonButtonTone.secondary,
                icon: const Icon(Icons.restart_alt_rounded),
                onPressed: () async {
                  await onResetSettings();
                },
              );

              if (vertical) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: double.infinity, child: clearButton),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: resetButton),
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: clearButton),
                  const SizedBox(width: 12),
                  Expanded(child: resetButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/settings/domain/settings_profile_snapshot.dart';
import 'package:sickandflutter/features/settings/widgets/settings_setting_row.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';
import 'package:sickandflutter/shared/widgets/workspace_layout.dart';

/// 设置页账号与本机操作卡片。
class SettingsProfileCard extends StatelessWidget {
  /// 创建账号与本机操作卡片。
  const SettingsProfileCard({
    required this.snapshot,
    required this.isSubmitting,
    required this.onLogout,
    required this.onClearRememberedAccount,
    required this.onResetSettings,
    this.onOpenAbout,
    super.key,
  });

  /// 账号与本机摘要快照。
  final SettingsProfileSnapshot snapshot;

  /// 当前是否正在提交账号动作。
  final bool isSubmitting;

  /// 退出登录回调。
  final Future<void> Function() onLogout;

  /// 清除已记住账号回调。
  final Future<void> Function() onClearRememberedAccount;

  /// 恢复默认设置回调。
  final Future<void> Function() onResetSettings;

  /// 打开使用帮助回调。
  final VoidCallback? onOpenAbout;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: AppCopy.settingsProfileTitle,
      subtitle: AppCopy.settingsProfileSubtitle,
      accentColor: AppPalette.softLavender,
      padding: const EdgeInsets.all(16),
      headerIcon: Icons.manage_accounts_outlined,
      headerTag: snapshot.headerTag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          WorkspaceTwoPane(
            breakpoint: 980,
            gap: 16,
            stackSpacing: 16,
            secondaryMinWidth: 312,
            secondaryMaxWidth: 360,
            secondaryWidthFactor: 0.32,
            primary: _ProfileLeadPanel(snapshot: snapshot),
            secondary: _ProfileActionsPanel(
              isSubmitting: isSubmitting,
              hasRememberedAccount:
                  snapshot.rememberedLabel !=
                  AppCopy.settingsRememberedAccountMissing,
              onLogout: onLogout,
              onClearRememberedAccount: onClearRememberedAccount,
              onResetSettings: onResetSettings,
              onOpenAbout: onOpenAbout,
            ),
          ),
          if (snapshot.showPreviewNotice) ...<Widget>[
            const SizedBox(height: 10),
            _NoticePanel(
              accentColor: AppPalette.softLavender,
              icon: Icons.visibility_outlined,
              message: AppCopy.settingsPreviewModeNotice,
            ),
          ],
          if (snapshot.showPersistenceWarning) ...<Widget>[
            const SizedBox(height: 10),
            _NoticePanel(
              accentColor: AppPalette.linenOlive,
              icon: Icons.info_outline_rounded,
              title: AppCopy.settingsSessionPersistenceWarningTitle,
              message: AppCopy.settingsSessionPersistenceWarningMessage,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileLeadPanel extends StatelessWidget {
  const _ProfileLeadPanel({required this.snapshot});

  final SettingsProfileSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      accentColor: AppPalette.softLavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppPalette.blendOnPaper(
                    AppPalette.softLavender,
                    opacity: 0.18,
                    base: colorScheme.surfaceContainerLowest,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppPalette.softLavender.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppCopy.settingsCurrentAccount,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.accountLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.accountHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _ProfileBadge(
                label: snapshot.sessionLabel,
                accentColor: AppPalette.softPine,
              ),
              _ProfileBadge(
                label: snapshot.persistenceLabel,
                accentColor: AppPalette.mistMint,
              ),
              _ProfileBadge(
                label: snapshot.rememberedBadgeLabel,
                accentColor: AppPalette.linenOlive,
              ),
            ],
          ),
          const SizedBox(height: 12),
          FeatureInsetPanel(
            padding: const EdgeInsets.all(12),
            borderRadius: 20,
            accentColor: AppPalette.softPine,
            backgroundColor: colorScheme.surfaceContainerLowest,
            child: Column(
              children: <Widget>[
                SettingsSettingRow(title: '当前状态', value: snapshot.sessionLabel),
                const SizedBox(height: 8),
                SettingsSettingRow(
                  title: AppCopy.settingsRememberedAccount,
                  value: snapshot.rememberedLabel,
                ),
                const SizedBox(height: 8),
                SettingsSettingRow(
                  title: '本机状态',
                  value: snapshot.persistenceLabel,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            snapshot.statusMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            snapshot.rememberedHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            snapshot.persistenceHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionsPanel extends StatelessWidget {
  const _ProfileActionsPanel({
    required this.isSubmitting,
    required this.hasRememberedAccount,
    required this.onLogout,
    required this.onClearRememberedAccount,
    required this.onResetSettings,
    this.onOpenAbout,
  });

  final bool isSubmitting;
  final bool hasRememberedAccount;
  final Future<void> Function() onLogout;
  final Future<void> Function() onClearRememberedAccount;
  final Future<void> Function() onResetSettings;
  final VoidCallback? onOpenAbout;

  @override
  Widget build(BuildContext context) {
    return FeatureInsetPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 22,
      accentColor: AppPalette.linenOlive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppCopy.settingsActionsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            AppCopy.settingsActionsHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.54,
            ),
          ),
          const SizedBox(height: 12),
          _ActionButtonList(
            isSubmitting: isSubmitting,
            hasRememberedAccount: hasRememberedAccount,
            onLogout: onLogout,
            onClearRememberedAccount: onClearRememberedAccount,
            onResetSettings: onResetSettings,
            onOpenAbout: onOpenAbout,
          ),
        ],
      ),
    );
  }
}

class _ActionButtonList extends StatelessWidget {
  const _ActionButtonList({
    required this.isSubmitting,
    required this.hasRememberedAccount,
    required this.onLogout,
    required this.onClearRememberedAccount,
    required this.onResetSettings,
    this.onOpenAbout,
  });

  final bool isSubmitting;
  final bool hasRememberedAccount;
  final Future<void> Function() onLogout;
  final Future<void> Function() onClearRememberedAccount;
  final Future<void> Function() onResetSettings;
  final VoidCallback? onOpenAbout;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      CommonButton(
        label: isSubmitting
            ? AppCopy.settingsLoggingOut
            : AppCopy.settingsLogout,
        tone: CommonButtonTone.secondary,
        icon: const Icon(Icons.logout_rounded),
        isLoading: isSubmitting,
        onPressed: isSubmitting
            ? null
            : () async {
                await onLogout();
              },
      ),
      CommonButton(
        label: AppCopy.settingsClearRememberedAccount,
        tone: CommonButtonTone.danger,
        icon: const Icon(Icons.person_remove_outlined),
        onPressed: hasRememberedAccount
            ? () async {
                await onClearRememberedAccount();
              }
            : null,
      ),
      CommonButton(
        label: AppCopy.settingsResetDefaults,
        tone: CommonButtonTone.secondary,
        icon: const Icon(Icons.restart_alt_rounded),
        onPressed: () async {
          await onResetSettings();
        },
      ),
      if (onOpenAbout != null)
        FilledButton.tonalIcon(
          onPressed: onOpenAbout,
          icon: const Icon(Icons.info_outline_rounded),
          label: const Text(AppCopy.viewAboutProject),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int index = 0; index < buttons.length; index++) ...<Widget>[
                SizedBox(width: double.infinity, child: buttons[index]),
                if (index != buttons.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: buttons
              .map(
                (button) => SizedBox(
                  width: (constraints.maxWidth - 10) / 2,
                  child: button,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          accentColor,
          opacity: 0.14,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NoticePanel extends StatelessWidget {
  const _NoticePanel({
    required this.accentColor,
    required this.icon,
    required this.message,
    this.title,
  });

  final Color accentColor;
  final IconData icon;
  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return FeatureInsetPanel(
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      accentColor: accentColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppPalette.blendOnPaper(
                accentColor,
                opacity: 0.16,
                base: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.24)),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

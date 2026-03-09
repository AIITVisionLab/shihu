import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';

/// 系统总览页顶部导航条。
class AboutTopBar extends StatelessWidget {
  /// 创建顶部导航条。
  const AboutTopBar({
    required this.isAuthenticated,
    required this.currentUser,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    super.key,
  });

  /// 当前是否已登录。
  final bool isAuthenticated;

  /// 当前用户名称。
  final String currentUser;

  /// 主按钮文案。
  final String primaryActionLabel;

  /// 主按钮回调。
  final VoidCallback onPrimaryAction;

  /// 次按钮文案。
  final String? secondaryActionLabel;

  /// 次按钮回调。
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.44),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 820;
          final brand = Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    AppConstants.appName.substring(0, 1),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppConstants.appTagline,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final actions = Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              if (isAuthenticated)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '当前用户 $currentUser',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (secondaryActionLabel != null && onSecondaryAction != null)
                OutlinedButton.icon(
                  onPressed: onSecondaryAction,
                  icon: const Icon(Icons.dashboard_outlined),
                  label: Text(secondaryActionLabel!),
                ),
              FilledButton.icon(
                onPressed: onPrimaryAction,
                icon: Icon(
                  isAuthenticated
                      ? Icons.monitor_heart_rounded
                      : Icons.login_rounded,
                ),
                label: Text(primaryActionLabel),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[brand, const SizedBox(height: 16), actions],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: brand),
              const SizedBox(width: 16),
              actions,
            ],
          );
        },
      ),
    );
  }
}

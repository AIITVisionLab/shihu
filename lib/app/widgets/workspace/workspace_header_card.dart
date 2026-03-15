import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 工作台页面标题头。
class WorkspaceHeaderCard extends StatelessWidget {
  /// 创建工作台页面标题头。
  const WorkspaceHeaderCard({
    required this.title,
    required this.subtitle,
    required this.currentUser,
    required this.actions,
    this.showCurrentUserChip = true,
    super.key,
  });

  /// 页面标题。
  final String title;

  /// 页面副标题。
  final String subtitle;

  /// 当前用户。
  final String currentUser;

  /// 是否展示当前用户标签。
  final bool showCurrentUserChip;

  /// 右侧动作。
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUser = currentUser.isNotEmpty && currentUser != '--';

    return SizedBox(
      width: double.infinity,
      child: FeatureHeroCard(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        accentColor: AppPalette.mistMint,
        showPaletteBands: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 820;
            final titleBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    const _WorkspaceHeaderEyebrow(),
                    if (hasUser && showCurrentUserChip)
                      WorkspaceHeaderChip(
                        icon: Icons.person_outline_rounded,
                        label: currentUser,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isCompact ? constraints.maxWidth : 560,
                  ),
                  child: Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.56,
                    ),
                  ),
                ),
              ],
            );

            if (isCompact || actions.isEmpty) {
              return SizedBox(
                width: double.infinity,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isCompact ? constraints.maxWidth : 660,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      titleBlock,
                      if (actions.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 18),
                        Wrap(spacing: 10, runSpacing: 10, children: actions),
                      ],
                    ],
                  ),
                ),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(child: titleBlock),
                const SizedBox(width: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: FeatureInsetPanel(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 22,
                    accentColor: AppPalette.mistMint,
                    backgroundColor: theme.colorScheme.surfaceContainerLowest
                        .withValues(alpha: 0.9),
                    showHighlightLine: false,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 10,
                        runSpacing: 10,
                        children: actions,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 工作台标题头轻量标签。
class WorkspaceHeaderChip extends StatelessWidget {
  /// 创建工作台标题头轻量标签。
  const WorkspaceHeaderChip({
    required this.icon,
    required this.label,
    super.key,
  });

  /// 图标。
  final IconData icon;

  /// 文案。
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceBright.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceHeaderEyebrow extends StatelessWidget {
  const _WorkspaceHeaderEyebrow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppPalette.softPine.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.softPine.withValues(alpha: 0.28)),
      ),
      child: Text(
        '${AppConstants.appName}客户端',
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.secondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

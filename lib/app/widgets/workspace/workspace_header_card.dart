import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';

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
    final colorScheme = theme.colorScheme;
    final hasUser = currentUser.isNotEmpty && currentUser != '--';
    final borderRadius = BorderRadius.circular(28);

    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppPalette.blendOnPaper(
                AppPalette.softPine,
                opacity: 0.035,
                base: colorScheme.surfaceBright,
              ).withValues(alpha: 0.985),
              AppPalette.blendOnPaper(
                AppPalette.mistMint,
                opacity: 0.015,
                base: colorScheme.surfaceContainerLowest,
              ).withValues(alpha: 0.965),
            ],
          ),
          borderRadius: borderRadius,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.76),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppPalette.pineShadow.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.92, -0.95),
                      radius: 1.02,
                      colors: <Color>[
                        AppPalette.softPine.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 820;
                  final titleBlock = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (hasUser && showCurrentUserChip) ...<Widget>[
                        WorkspaceHeaderChip(
                          icon: Icons.person_outline_rounded,
                          label: currentUser,
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isCompact ? constraints.maxWidth : 520,
                        ),
                        child: Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  );

                  if (isCompact || actions.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        titleBlock,
                        if (actions.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 14),
                          Wrap(spacing: 10, runSpacing: 10, children: actions),
                        ],
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(child: titleBlock),
                      const SizedBox(width: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 10,
                            runSpacing: 10,
                            children: actions,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
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
        color: AppPalette.blendOnPaper(
          AppPalette.softPine,
          opacity: 0.14,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.softPine.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: AppPalette.deepPine),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppPalette.deepPine,
            ),
          ),
        ],
      ),
    );
  }
}

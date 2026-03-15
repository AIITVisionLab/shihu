import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_navigation.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/widgets/app_brand_mark.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 桌面端工作台导航仓。
class WorkspaceRailPane extends StatelessWidget {
  /// 创建桌面端工作台导航仓。
  const WorkspaceRailPane({
    required this.destination,
    required this.currentUser,
    super.key,
  });

  /// 当前导航。
  final AppWorkspaceDestination destination;

  /// 当前用户。
  final String currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasUser = currentUser.isNotEmpty && currentUser != '--';

    return FeatureHeroCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      borderRadius: 32,
      accentColor: AppPalette.pineGreen,
      showPaletteBands: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FeatureInsetPanel(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            borderRadius: 24,
            accentColor: AppPalette.softPine,
            backgroundColor: colorScheme.surfaceContainerLowest.withValues(
              alpha: 0.94,
            ),
            showHighlightLine: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const AppBrandBadge(size: 54, showShadow: false),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            AppConstants.appName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '石斛培育环境值守软件',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.42,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (hasUser) ...<Widget>[
                  const SizedBox(height: 12),
                  WorkspaceRailMetaChip(
                    icon: Icons.person_outline_rounded,
                    label: currentUser,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: FeatureInsetPanel(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
              borderRadius: 28,
              accentColor: AppPalette.mistMint,
              backgroundColor: colorScheme.surfaceContainerLowest.withValues(
                alpha: 0.9,
              ),
              showHighlightLine: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
                    child: Text(
                      '板块',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: AppWorkspaceDestination.values
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _WorkspaceRailItem(
                                item: item,
                                selected: item == destination,
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                  const _RailCaption(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceRailItem extends StatelessWidget {
  const _WorkspaceRailItem({required this.item, required this.selected});

  final AppWorkspaceDestination item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = selected
        ? item.accentColor.withValues(alpha: 0.34)
        : Colors.transparent;
    final foregroundColor = selected
        ? AppPalette.deepPine
        : colorScheme.onSurfaceVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => navigateToWorkspaceDestination(context, item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? item.accentColor.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: 3,
              height: 30,
              decoration: BoxDecoration(
                color: selected ? AppPalette.pineGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.48)
                    : item.accentColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                size: 20,
                color: selected ? AppPalette.pineGreen : foregroundColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: selected ? AppPalette.deepPine : colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              item.sectionCode,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? AppPalette.deepPine.withValues(alpha: 0.7)
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 工作台侧栏用户标签。
class WorkspaceRailMetaChip extends StatelessWidget {
  /// 创建工作台侧栏用户标签。
  const WorkspaceRailMetaChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailCaption extends StatelessWidget {
  const _RailCaption();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Text(
        '总览负责看状态，需要处理时再切到值守、视频或我的。',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),
    );
  }
}

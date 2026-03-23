import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_navigation.dart';

/// 移动端工作台底部导航。
class WorkspaceBottomNavigation extends StatelessWidget {
  /// 创建移动端工作台底部导航。
  const WorkspaceBottomNavigation({required this.destination, super.key});

  /// 当前导航。
  final AppWorkspaceDestination destination;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppPalette.blendOnPaper(
              AppPalette.softPine,
              opacity: 0.085,
              base: colorScheme.surfaceContainerLowest,
            ).withValues(alpha: 0.985),
            AppPalette.blendOnPaper(
              AppPalette.mistMint,
              opacity: 0.06,
              base: colorScheme.surfaceContainerLow,
            ).withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.88),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.pineShadow.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: AppWorkspaceDestination.values
              .map(
                (item) => Expanded(
                  child: _WorkspaceDockItem(
                    item: item,
                    selected: item == destination,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _WorkspaceDockItem extends StatelessWidget {
  const _WorkspaceDockItem({required this.item, required this.selected});

  final AppWorkspaceDestination item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => navigateToWorkspaceDestination(context, item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppPalette.blendOnPaper(
                  item.accentColor,
                  opacity: 0.14,
                  base: colorScheme.surfaceContainerLowest,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? item.accentColor.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? AppPalette.blendOnPaper(
                        item.accentColor,
                        opacity: 0.24,
                        base: colorScheme.surfaceContainerLowest,
                      )
                    : item.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? item.accentColor.withValues(alpha: 0.26)
                      : item.accentColor.withValues(alpha: 0.16),
                ),
              ),
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                size: 20,
                color: selected
                    ? AppPalette.deepPine
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected
                    ? AppPalette.deepPine
                    : colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

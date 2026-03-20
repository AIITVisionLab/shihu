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
              opacity: 0.1,
              base: colorScheme.surfaceContainerLowest,
            ).withValues(alpha: 0.985),
            AppPalette.blendOnPaper(
              AppPalette.mistMint,
              opacity: 0.08,
              base: colorScheme.surfaceContainerLow,
            ).withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.88),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.pineShadow.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
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
      borderRadius: BorderRadius.circular(22),
      onTap: () => navigateToWorkspaceDestination(context, item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppPalette.blendOnPaper(
                  item.accentColor,
                  opacity: 0.18,
                  base: colorScheme.surfaceContainerLowest,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? item.accentColor.withValues(alpha: 0.22)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? AppPalette.blendOnPaper(
                        item.accentColor,
                        opacity: 0.28,
                        base: colorScheme.surfaceContainerLowest,
                      )
                    : item.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? item.accentColor.withValues(alpha: 0.32)
                      : item.accentColor.withValues(alpha: 0.16),
                ),
              ),
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                size: 22,
                color: selected
                    ? AppPalette.deepPine
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? AppPalette.deepPine
                    : colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

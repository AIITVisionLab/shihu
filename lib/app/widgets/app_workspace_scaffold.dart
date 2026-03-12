import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';

/// 主工作台统一壳层。
///
/// 桌面端使用 `NavigationRail`，紧凑宽度下自动切换为 `NavigationBar`。
class AppWorkspaceScaffold extends StatelessWidget {
  /// 创建主工作台壳层。
  const AppWorkspaceScaffold({
    required this.destination,
    required this.title,
    required this.subtitle,
    required this.currentUser,
    required this.child,
    this.headerActions = const <Widget>[],
    this.maxContentWidth = 1100,
    this.backgroundGradient,
    this.backgroundOrbs = const <BackdropOrbData>[
      BackdropOrbData(
        alignment: Alignment(-1.0, -0.92),
        size: 380,
        color: Color(0x183C8EFF),
      ),
      BackdropOrbData(
        alignment: Alignment(1.06, -0.18),
        size: 320,
        color: Color(0x1443D3FF),
      ),
      BackdropOrbData(
        alignment: Alignment(0.86, 1.08),
        size: 280,
        color: Color(0x12205EC2),
      ),
    ],
    this.showGrid = false,
    super.key,
  });

  /// 当前选中的一级导航。
  final AppWorkspaceDestination destination;

  /// 页面标题。
  final String title;

  /// 页面副标题。
  final String subtitle;

  /// 当前用户名称。
  final String currentUser;

  /// 页面主体。
  final Widget child;

  /// 标题区右侧动作。
  final List<Widget> headerActions;

  /// 内容区最大宽度。
  final double maxContentWidth;

  /// 自定义背景渐变。
  final Gradient? backgroundGradient;

  /// 自定义背景光斑。
  final List<BackdropOrbData> backgroundOrbs;

  /// 是否展示背景网格。
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final useRail = screenWidth >= 1180;
    final contentPane = _WorkspaceContentPane(
      title: title,
      subtitle: subtitle,
      currentUser: currentUser,
      headerActions: headerActions,
      maxContentWidth: maxContentWidth,
      child: child,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: useRail
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: _WorkspaceBottomNavigation(destination: destination),
              ),
            ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AppBackdrop(
              baseGradient:
                  backgroundGradient ??
                  const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFF081017),
                      Color(0xFF0C131A),
                      Color(0xFF0A1016),
                    ],
                  ),
              orbs: backgroundOrbs,
              showGrid: showGrid,
            ),
          ),
          SafeArea(
            bottom: !useRail,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, 14, 14, useRail ? 14 : 8),
              child: useRail
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          width: 212,
                          child: _WorkspaceRailPane(
                            destination: destination,
                            currentUser: currentUser,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: contentPane),
                      ],
                    )
                  : contentPane,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceContentPane extends StatelessWidget {
  const _WorkspaceContentPane({
    required this.title,
    required this.subtitle,
    required this.currentUser,
    required this.headerActions,
    required this.maxContentWidth,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String currentUser;
  final List<Widget> headerActions;
  final double maxContentWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _WorkspaceHeaderCard(
          title: title,
          subtitle: subtitle,
          currentUser: currentUser,
          actions: headerActions,
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: SizedBox.expand(child: child),
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkspaceRailPane extends StatelessWidget {
  const _WorkspaceRailPane({
    required this.destination,
    required this.currentUser,
  });

  final AppWorkspaceDestination destination;
  final String currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasUser = currentUser.isNotEmpty && currentUser != '--';

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainerLowest.withValues(alpha: 0.94),
            colorScheme.surfaceContainerLow.withValues(alpha: 0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x36000000),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.82),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.66),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.spa_rounded,
                      color: colorScheme.onPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '蓝图值守',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (hasUser) ...<Widget>[
                    const SizedBox(height: 14),
                    _RailMetaChip(
                      icon: Icons.person_outline_rounded,
                      label: currentUser,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                extended: true,
                selectedIndex: AppWorkspaceDestination.values.indexOf(
                  destination,
                ),
                minExtendedWidth: 208,
                groupAlignment: -0.88,
                labelType: NavigationRailLabelType.none,
                onDestinationSelected: (index) {
                  _navigate(context, AppWorkspaceDestination.values[index]);
                },
                destinations: AppWorkspaceDestination.values
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspaceHeaderCard extends StatelessWidget {
  const _WorkspaceHeaderCard({
    required this.title,
    required this.subtitle,
    required this.currentUser,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final String currentUser;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasUser = currentUser.isNotEmpty && currentUser != '--';

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainerLow.withValues(alpha: 0.94),
            colorScheme.surfaceContainer.withValues(alpha: 0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x46000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 780;
            final meta = hasUser && isCompact
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      _HeaderChip(
                        icon: Icons.person_outline_rounded,
                        label: currentUser,
                      ),
                    ],
                  )
                : null;
            final titleBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.48,
                  ),
                ),
              ],
            );
            final actionWrap = actions.isEmpty
                ? const SizedBox.shrink()
                : Wrap(spacing: 10, runSpacing: 10, children: actions);

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (meta != null) ...<Widget>[
                    meta,
                    const SizedBox(height: 14),
                  ],
                  titleBlock,
                  if (actions.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    actionWrap,
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (meta != null) ...<Widget>[
                        meta,
                        const SizedBox(height: 14),
                      ],
                      titleBlock,
                    ],
                  ),
                ),
                if (actions.isNotEmpty) ...<Widget>[
                  const SizedBox(width: 16),
                  Flexible(child: actionWrap),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WorkspaceBottomNavigation extends StatelessWidget {
  const _WorkspaceBottomNavigation({required this.destination});

  final AppWorkspaceDestination destination;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x52000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        selectedIndex: AppWorkspaceDestination.values.indexOf(destination),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (index) =>
            _navigate(context, AppWorkspaceDestination.values[index]),
        destinations: AppWorkspaceDestination.values
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _RailMetaChip extends StatelessWidget {
  const _RailMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
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

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.78),
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

void _navigate(BuildContext context, AppWorkspaceDestination nextDestination) {
  final shellState = StatefulNavigationShell.maybeOf(context);
  final targetIndex = AppWorkspaceDestination.values.indexOf(nextDestination);

  if (shellState != null) {
    if (shellState.currentIndex == targetIndex) {
      return;
    }
    shellState.goBranch(targetIndex);
    return;
  }

  context.goNamed(nextDestination.routeName);
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';

/// 主工作台统一壳层。
///
/// 桌面端使用 `NavigationRail`，紧凑宽度下自动切换为 `NavigationBar`，
/// 统一保持更像客户端而不是网页的后台工作台结构。
class AppWorkspaceScaffold extends StatelessWidget {
  /// 创建主工作台壳层。
  const AppWorkspaceScaffold({
    required this.destination,
    required this.title,
    required this.subtitle,
    required this.currentUser,
    required this.child,
    this.headerActions = const <Widget>[],
    this.maxContentWidth = 1260,
    this.backgroundGradient,
    this.backgroundOrbs = const <BackdropOrbData>[
      BackdropOrbData(
        alignment: Alignment(-1.05, -0.95),
        size: 360,
        color: Color(0x1626A497),
      ),
      BackdropOrbData(
        alignment: Alignment(1.08, -0.18),
        size: 260,
        color: Color(0x14B68B63),
      ),
      BackdropOrbData(
        alignment: Alignment(0.78, 1.02),
        size: 240,
        color: Color(0x105D7E92),
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
    final useRail = screenWidth >= 980;
    final horizontalPadding = useRail ? 20.0 : 16.0;
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _WorkspaceBottomNavigation(destination: destination),
              ),
            ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AppBackdrop(
              baseGradient: backgroundGradient,
              orbs: backgroundOrbs,
              showGrid: showGrid,
            ),
          ),
          SafeArea(
            bottom: !useRail,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                useRail ? 20 : 8,
              ),
              child: useRail
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          width: 286,
                          child: _WorkspaceRailPane(
                            destination: destination,
                            currentUser: currentUser,
                          ),
                        ),
                        const SizedBox(width: 20),
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
        const SizedBox(height: 16),
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
            colorScheme.surfaceContainerLowest.withValues(alpha: 0.98),
            colorScheme.surface.withValues(alpha: 0.96),
            colorScheme.surfaceContainerLow.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C172019),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.52),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.spa_rounded,
                      color: colorScheme.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '跨平台石斛值守后台',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                extended: true,
                selectedIndex: AppWorkspaceDestination.values.indexOf(
                  destination,
                ),
                minExtendedWidth: 230,
                groupAlignment: -0.85,
                leading: Container(
                  margin: const EdgeInsets.only(left: 8, bottom: 18),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh.withValues(
                      alpha: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '导航',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _RailInfoChip(icon: Icons.grid_view_rounded, label: '统一工作台'),
                  const SizedBox(height: 10),
                  _RailInfoChip(
                    icon: Icons.schedule_rounded,
                    label: '本地时间 ${_formatHeaderTime(DateTime.now())}',
                  ),
                  if (hasUser) ...<Widget>[
                    const SizedBox(height: 10),
                    _RailInfoChip(
                      icon: Icons.person_outline_rounded,
                      label: currentUser,
                    ),
                  ],
                ],
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
            colorScheme.surfaceContainerLowest.withValues(alpha: 0.98),
            colorScheme.surface.withValues(alpha: 0.96),
            colorScheme.surfaceContainerLow.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.38),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C172019),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 780;
            final meta = Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _HeaderChip(
                  icon: Icons.spa_outlined,
                  label: '${AppConstants.appName} 工作台',
                  foregroundColor: colorScheme.onPrimaryContainer,
                  backgroundColor: colorScheme.primaryContainer.withValues(
                    alpha: 0.8,
                  ),
                ),
                _HeaderChip(
                  icon: Icons.verified_user_outlined,
                  label: '桌面工作台',
                  foregroundColor: colorScheme.onSecondaryContainer,
                  backgroundColor: colorScheme.secondaryContainer.withValues(
                    alpha: 0.84,
                  ),
                ),
                _HeaderChip(
                  icon: Icons.schedule_rounded,
                  label: '本地时间 ${_formatHeaderTime(DateTime.now())}',
                ),
                if (hasUser)
                  _HeaderChip(
                    icon: Icons.person_outline_rounded,
                    label: currentUser,
                  ),
              ],
            );
            final titleBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.58,
                  ),
                ),
              ],
            );
            final actionWrap = actions.isEmpty
                ? const SizedBox.shrink()
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.end,
                    children: actions,
                  );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  meta,
                  const SizedBox(height: 18),
                  titleBlock,
                  if (actions.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    actionWrap,
                  ],
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: meta),
                    if (actions.isNotEmpty) ...<Widget>[
                      const SizedBox(width: 16),
                      Flexible(child: actionWrap),
                    ],
                  ],
                ),
                const SizedBox(height: 18),
                titleBlock,
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
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.38),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C172019),
            blurRadius: 10,
            offset: Offset(0, 4),
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

class _RailInfoChip extends StatelessWidget {
  const _RailInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.icon,
    required this.label,
    this.foregroundColor,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveForeground = foregroundColor ?? colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            colorScheme.surfaceContainerHigh.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: effectiveForeground),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: effectiveForeground,
            ),
          ),
        ],
      ),
    );
  }
}

void _navigate(BuildContext context, AppWorkspaceDestination nextDestination) {
  context.goNamed(nextDestination.routeName);
}

String _formatHeaderTime(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');

  return '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}

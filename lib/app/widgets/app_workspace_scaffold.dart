import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';

/// 主工作台统一壳层。
///
/// 负责在桌面端提供导航栏与标题区，在移动端收口为底部导航，
/// 让首页、主控台、系统总览和设置页保持同一套软件级信息架构。
class AppWorkspaceScaffold extends StatelessWidget {
  /// 创建主工作台壳层。
  const AppWorkspaceScaffold({
    required this.destination,
    required this.title,
    required this.subtitle,
    required this.currentUser,
    required this.child,
    this.headerActions = const <Widget>[],
    this.maxContentWidth = 1180,
    this.backgroundGradient,
    this.backgroundOrbs = const <BackdropOrbData>[
      BackdropOrbData(
        alignment: Alignment(-1.1, -1.0),
        size: 320,
        color: Color(0x2B83C88C),
      ),
      BackdropOrbData(
        alignment: Alignment(1.05, -0.3),
        size: 260,
        color: Color(0x2AB98A50),
      ),
      BackdropOrbData(
        alignment: Alignment(0.75, 1.1),
        size: 220,
        color: Color(0x1E4E7E6A),
      ),
    ],
    this.showGrid = true,
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
    return Scaffold(
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 1024;
                final header = Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: _WorkspaceHeader(
                    title: title,
                    subtitle: subtitle,
                    currentUser: currentUser,
                    actions: headerActions,
                  ),
                );
                final content = Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? 0 : 0,
                      0,
                      isCompact ? 0 : 20,
                      isCompact ? 0 : 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: SizedBox.expand(child: child),
                      ),
                    ),
                  ),
                );

                if (isCompact) {
                  return Column(
                    children: <Widget>[
                      header,
                      content,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: _WorkspaceBottomNavigation(
                          destination: destination,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
                      child: _WorkspaceRail(
                        destination: destination,
                        currentUser: currentUser,
                      ),
                    ),
                    Expanded(
                      child: Column(children: <Widget>[header, content]),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.42),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 820;
          final summary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      AppConstants.appName,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  if (hasUser)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '当前用户 $currentUser',
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
          final actionWrap = actions.isEmpty
              ? const SizedBox.shrink()
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.end,
                  children: actions,
                );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                summary,
                if (actions.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  actionWrap,
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: summary),
              if (actions.isNotEmpty) ...<Widget>[
                const SizedBox(width: 16),
                Flexible(child: actionWrap),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WorkspaceRail extends StatelessWidget {
  const _WorkspaceRail({required this.destination, required this.currentUser});

  final AppWorkspaceDestination destination;
  final String currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 118,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 6),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  AppConstants.appName.substring(0, 1),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: NavigationRail(
              selectedIndex: AppWorkspaceDestination.values.indexOf(
                destination,
              ),
              backgroundColor: Colors.transparent,
              extended: false,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (index) =>
                  _navigate(context, AppWorkspaceDestination.values[index]),
              destinations: AppWorkspaceDestination.values
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(item.label, textAlign: TextAlign.center),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (currentUser.isNotEmpty && currentUser != '--')
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
              child: Tooltip(
                message: currentUser,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Text(
                    currentUser.substring(0, 1),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WorkspaceBottomNavigation extends StatelessWidget {
  const _WorkspaceBottomNavigation({required this.destination});

  final AppWorkspaceDestination destination;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: AppWorkspaceDestination.values.indexOf(destination),
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
          .toList(),
    );
  }
}

void _navigate(BuildContext context, AppWorkspaceDestination nextDestination) {
  context.goNamed(nextDestination.routeName);
}

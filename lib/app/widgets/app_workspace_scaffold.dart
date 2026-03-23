import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_bottom_navigation.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_content_pane.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_rail_pane.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';
import 'package:sickandflutter/shared/widgets/workspace_layout.dart';

/// 根据屏幕宽度返回工作台主体内容区的统一留白。
EdgeInsets resolveWorkspacePagePadding(
  BuildContext context, {
  double top = 0,
  double bottom = 24,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final horizontal = resolveWorkspaceHorizontalPadding(width);

  return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
}

/// 主工作台统一壳层。
///
/// 桌面端使用自定义侧栏导航，紧凑宽度下自动切换为底部 dock。
class AppWorkspaceScaffold extends StatelessWidget {
  /// 创建主工作台壳层。
  const AppWorkspaceScaffold({
    required this.destination,
    required this.title,
    required this.subtitle,
    required this.currentUser,
    required this.child,
    this.headerActions = const <Widget>[],
    this.maxContentWidth = kWorkspaceContentMaxWidth,
    this.backgroundGradient,
    this.backgroundOrbs = const <BackdropOrbData>[],
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
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final useRail = useWorkspaceRailLayout(screenWidth);
    final shellMaxWidth = useRail ? kWorkspaceDesktopShellMaxWidth : 1040.0;
    final horizontalPadding = resolveWorkspaceHorizontalPadding(screenWidth);
    final topPadding = resolveWorkspaceTopPadding(screenWidth);
    final contentPane = WorkspaceContentPane(
      title: title,
      subtitle: subtitle,
      currentUser: currentUser,
      showCurrentUserChip: !useRail,
      headerActions: headerActions,
      maxContentWidth: maxContentWidth,
      child: child,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: !useRail,
      bottomNavigationBar: useRail
          ? null
          : SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: kWorkspaceBottomNavigationMaxWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      8,
                    ),
                    child: WorkspaceBottomNavigation(destination: destination),
                  ),
                ),
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
                      AppPalette.paperSnow,
                      AppPalette.paperMist,
                      AppPalette.paper,
                    ],
                  ),
              orbs: backgroundOrbs,
              showGrid: showGrid,
            ),
          ),
          SafeArea(
            bottom: !useRail,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                useRail ? 14 : 4,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final shellWidth = constraints.maxWidth
                      .clamp(0, shellMaxWidth)
                      .toDouble();

                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: shellWidth,
                      height: constraints.maxHeight,
                      child: useRail
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                SizedBox(
                                  width: kWorkspaceDesktopRailWidth,
                                  child: WorkspaceRailPane(
                                    destination: destination,
                                    currentUser: currentUser,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(child: contentPane),
                              ],
                            )
                          : contentPane,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

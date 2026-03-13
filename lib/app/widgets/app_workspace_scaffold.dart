import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_bottom_navigation.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_content_pane.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_rail_pane.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';

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
    this.maxContentWidth = 1100,
    this.backgroundGradient,
    this.backgroundOrbs = const <BackdropOrbData>[
      BackdropOrbData(
        alignment: Alignment(-1.0, -0.96),
        size: 420,
        color: Color(0x12518463),
      ),
      BackdropOrbData(
        alignment: Alignment(1.02, -0.12),
        size: 340,
        color: Color(0x10A7D3B2),
      ),
      BackdropOrbData(
        alignment: Alignment(0.94, 1.1),
        size: 300,
        color: Color(0x10CEBBD8),
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
    final useRail = screenWidth >= 1240;
    final shellMaxWidth = useRail ? 1460.0 : 980.0;
    final horizontalPadding = switch (screenWidth) {
      < 560 => 12.0,
      < 1240 => 16.0,
      _ => 20.0,
    };
    final topPadding = screenWidth < 560 ? 12.0 : 18.0;
    final contentPane = WorkspaceContentPane(
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      14,
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
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: shellMaxWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    topPadding,
                    horizontalPadding,
                    useRail ? 18 : 8,
                  ),
                  child: useRail
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SizedBox(
                              width: 232,
                              child: WorkspaceRailPane(
                                destination: destination,
                                currentUser: currentUser,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(child: contentPane),
                          ],
                        )
                      : contentPane,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

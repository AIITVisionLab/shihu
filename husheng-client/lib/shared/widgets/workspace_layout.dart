import 'package:flutter/material.dart';

/// 工作台桌面端启用侧边导航的断点。
const double kWorkspaceRailBreakpoint = 1180;

/// 工作台桌面端最大外层宽度。
const double kWorkspaceDesktopShellMaxWidth = 1680;

/// 工作台紧凑导航区最大宽度。
const double kWorkspaceBottomNavigationMaxWidth = 860;

/// 工作台桌面端导航仓宽度。
const double kWorkspaceDesktopRailWidth = 248;

/// 工作台正文默认最大宽度。
const double kWorkspaceContentMaxWidth = 1360;

/// 工作台统一主列与侧列间距。
const double kWorkspaceSectionGap = 18;

/// 根据窗口宽度判断是否启用桌面端导航仓。
bool useWorkspaceRailLayout(double width) => width >= kWorkspaceRailBreakpoint;

/// 根据窗口宽度返回工作台统一水平留白。
double resolveWorkspaceHorizontalPadding(double width) {
  return switch (width) {
    < 560 => 10,
    < 920 => 14,
    < 1280 => 18,
    _ => 20,
  };
}

/// 根据窗口宽度返回工作台统一顶部留白。
double resolveWorkspaceTopPadding(double width) {
  return switch (width) {
    < 560 => 8,
    < 920 => 12,
    _ => 16,
  };
}

/// 根据当前可用宽度计算桌面端侧栏的统一宽度。
double resolveWorkspaceAsideWidth(
  double width, {
  double minWidth = 328,
  double maxWidth = 392,
  double widthFactor = 0.34,
}) {
  return (width * widthFactor).clamp(minWidth, maxWidth).toDouble();
}

/// 工作台统一双栏布局。
///
/// 桌面端保持“主信息区 + 固定侧区”，紧凑宽度下回落为纵向单列。
class WorkspaceTwoPane extends StatelessWidget {
  /// 创建工作台统一双栏布局。
  const WorkspaceTwoPane({
    required this.primary,
    required this.secondary,
    this.breakpoint = 1040,
    this.gap = kWorkspaceSectionGap,
    this.stackSpacing = kWorkspaceSectionGap,
    this.primaryMaxWidth,
    this.secondaryMinWidth = 328,
    this.secondaryMaxWidth = 392,
    this.secondaryWidthFactor = 0.34,
    super.key,
  });

  /// 主信息区。
  final Widget primary;

  /// 侧区。
  final Widget secondary;

  /// 切换到双栏布局的断点。
  final double breakpoint;

  /// 横向间距。
  final double gap;

  /// 纵向堆叠间距。
  final double stackSpacing;

  /// 主信息区最大宽度。
  final double? primaryMaxWidth;

  /// 侧区最小宽度。
  final double secondaryMinWidth;

  /// 侧区最大宽度。
  final double secondaryMaxWidth;

  /// 侧区宽度系数。
  final double secondaryWidthFactor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              primary,
              SizedBox(height: stackSpacing),
              secondary,
            ],
          );
        }

        final asideWidth = resolveWorkspaceAsideWidth(
          constraints.maxWidth,
          minWidth: secondaryMinWidth,
          maxWidth: secondaryMaxWidth,
          widthFactor: secondaryWidthFactor,
        );
        final constrainedPrimary = primaryMaxWidth == null
            ? primary
            : Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: primaryMaxWidth!),
                  child: primary,
                ),
              );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: constrainedPrimary),
            SizedBox(width: gap),
            SizedBox(width: asideWidth, child: secondary),
          ],
        );
      },
    );
  }
}

/// 工作台统一主体双栏区。
///
/// 用于首页、值守、设置等页面的下半部分，使两列比例和断点保持一致。
class WorkspaceBalancedColumns extends StatelessWidget {
  /// 创建工作台统一主体双栏区。
  const WorkspaceBalancedColumns({
    required this.primary,
    required this.secondary,
    this.breakpoint = 1000,
    this.gap = kWorkspaceSectionGap,
    this.stackSpacing = kWorkspaceSectionGap,
    this.primaryFlex = 1,
    this.secondaryFlex = 1,
    super.key,
  });

  /// 左侧主列。
  final Widget primary;

  /// 右侧次列。
  final Widget secondary;

  /// 切换到双栏布局的断点。
  final double breakpoint;

  /// 横向间距。
  final double gap;

  /// 纵向堆叠间距。
  final double stackSpacing;

  /// 左侧主列比例。
  final int primaryFlex;

  /// 右侧次列比例。
  final int secondaryFlex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              primary,
              SizedBox(height: stackSpacing),
              secondary,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(flex: primaryFlex, child: primary),
            SizedBox(width: gap),
            Expanded(flex: secondaryFlex, child: secondary),
          ],
        );
      },
    );
  }
}

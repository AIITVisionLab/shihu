import 'package:flutter/material.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_header_card.dart';

/// 工作台内容承载区，负责标题头和主体内容约束。
class WorkspaceContentPane extends StatelessWidget {
  /// 创建工作台内容承载区。
  const WorkspaceContentPane({
    required this.title,
    required this.subtitle,
    required this.currentUser,
    required this.headerActions,
    required this.maxContentWidth,
    required this.child,
    super.key,
  });

  /// 页面标题。
  final String title;

  /// 页面副标题。
  final String subtitle;

  /// 当前用户。
  final String currentUser;

  /// 标题区动作。
  final List<Widget> headerActions;

  /// 最大内容宽度。
  final double maxContentWidth;

  /// 页面主体。
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Column(
      children: <Widget>[
        WorkspaceHeaderCard(
          title: title,
          subtitle: subtitle,
          currentUser: currentUser,
          actions: headerActions,
        ),
        SizedBox(height: screenWidth < 720 ? 14 : 18),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
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

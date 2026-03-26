import 'package:flutter/material.dart';

/// 自适应换行网格。
///
/// 用于在不同窗口宽度下为卡片类内容自动计算列数和单项宽度，
/// 避免页面通过硬编码宽度在桌面端、平板和手机端出现溢出。
class AdaptiveWrapGrid extends StatelessWidget {
  /// 创建自适应换行网格。
  const AdaptiveWrapGrid({
    required this.children,
    required this.minItemWidth,
    this.spacing = 16,
    this.runSpacing = 16,
    super.key,
  });

  /// 网格项列表。
  final List<Widget> children;

  /// 单项最小宽度。
  final double minItemWidth;

  /// 横向间距。
  final double spacing;

  /// 纵向间距。
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (!maxWidth.isFinite || maxWidth <= 0) {
          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children,
          );
        }

        final safeMinItemWidth = minItemWidth <= 0 ? maxWidth : minItemWidth;
        final columnCount =
            ((maxWidth + spacing) / (safeMinItemWidth + spacing)).floor().clamp(
              1,
              children.isEmpty ? 1 : children.length,
            );
        final totalSpacing = spacing * (columnCount - 1);
        final itemWidth = (maxWidth - totalSpacing) / columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(growable: false),
        );
      },
    );
  }
}

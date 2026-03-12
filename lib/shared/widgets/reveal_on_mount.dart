import 'package:flutter/material.dart';

/// 页面首屏进入时的轻量揭示包装器。
///
/// 当前统一退化为静态渲染，优先保证桌面端和移动端的流畅度。
class RevealOnMount extends StatelessWidget {
  /// 创建揭示包装器。
  const RevealOnMount({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
    this.offset = const Offset(0, 16),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  /// 目标子组件。
  final Widget child;

  /// 兼容旧调用保留的延迟参数。
  final Duration delay;

  /// 兼容旧调用保留的时长参数。
  final Duration duration;

  /// 兼容旧调用保留的位移参数。
  final Offset offset;

  /// 兼容旧调用保留的曲线参数。
  final Curve curve;

  @override
  Widget build(BuildContext context) => child;
}

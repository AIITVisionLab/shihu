import 'dart:async';

import 'package:flutter/material.dart';

/// 页面首屏进入时的轻量揭示动效。
///
/// 统一用于工作台各页面的首屏区块，避免每个页面各自拼装不一致的入场动画。
class RevealOnMount extends StatefulWidget {
  /// 创建揭示动效包装器。
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

  /// 动画延迟。
  final Duration delay;

  /// 动画时长。
  final Duration duration;

  /// 初始位移。
  final Offset offset;

  /// 动画曲线。
  final Curve curve;

  @override
  State<RevealOnMount> createState() => _RevealOnMountState();
}

class _RevealOnMountState extends State<RevealOnMount>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _scale = Tween<double>(begin: 0.985, end: 1).animate(curved);
    _slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(curved);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, _controller.forward);
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Transform.translate(
              offset: Offset(_slide.value.dx, _slide.value.dy),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

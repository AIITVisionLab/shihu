import 'package:flutter/material.dart';

/// 通用按钮的视觉语义。
enum CommonButtonTone {
  /// 主操作按钮。
  primary,

  /// 次操作按钮。
  secondary,

  /// 危险操作按钮。
  danger,
}

/// 项目内统一按钮组件，约束加载态、禁用态和主次按钮风格。
class CommonButton extends StatelessWidget {
  /// 创建通用按钮。
  const CommonButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.tone = CommonButtonTone.primary,
    super.key,
  });

  /// 按钮文案。
  final String label;

  /// 点击回调。
  final VoidCallback? onPressed;

  /// 可选前置图标。
  final Widget? icon;

  /// 是否展示加载态。
  final bool isLoading;

  /// 按钮视觉语义。
  final CommonButtonTone tone;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isLoading)
          const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else ...<Widget>[?icon],
        if (isLoading || icon != null) ...<Widget>[const SizedBox(width: 10)],
        Text(label),
      ],
    );

    switch (tone) {
      case CommonButtonTone.primary:
        return FilledButton(onPressed: effectiveOnPressed, child: child);
      case CommonButtonTone.secondary:
        return OutlinedButton(onPressed: effectiveOnPressed, child: child);
      case CommonButtonTone.danger:
        return FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: effectiveOnPressed,
          child: child,
        );
    }
  }
}

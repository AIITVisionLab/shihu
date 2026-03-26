import 'package:flutter/material.dart';

/// 认证表单输入框。
class AuthTextField extends StatelessWidget {
  /// 创建认证表单输入框。
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.enabled,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction,
    this.onSubmitted,
    this.keyboardType,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
    super.key,
  });

  /// 输入控制器。
  final TextEditingController controller;

  /// 标签。
  final String label;

  /// 占位提示。
  final String hintText;

  /// 前缀图标。
  final Widget prefixIcon;

  /// 是否可用。
  final bool enabled;

  /// 是否隐藏文本。
  final bool obscureText;

  /// 后缀图标。
  final Widget? suffixIcon;

  /// 输入动作。
  final TextInputAction? textInputAction;

  /// 提交回调。
  final ValueChanged<String>? onSubmitted;

  /// 键盘类型。
  final TextInputType? keyboardType;

  /// 自动填充提示。
  final Iterable<String>? autofillHints;

  /// 是否自动纠错。
  final bool autocorrect;

  /// 是否启用建议。
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

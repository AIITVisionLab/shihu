import 'package:flutter/material.dart';

/// 认证表单提示的视觉语义。
enum AuthFeedbackTone {
  /// 错误提示。
  error,

  /// 成功提示。
  success,
}

/// 认证表单反馈提示横幅。
class AuthFeedbackBanner extends StatelessWidget {
  /// 创建认证表单反馈提示横幅。
  const AuthFeedbackBanner({
    required this.message,
    required this.tone,
    super.key,
  });

  /// 提示文案。
  final String message;

  /// 语义色调。
  final AuthFeedbackTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = tone == AuthFeedbackTone.success
        ? colorScheme.tertiaryContainer
        : colorScheme.errorContainer;
    final foregroundColor = tone == AuthFeedbackTone.success
        ? colorScheme.onTertiaryContainer
        : colorScheme.onErrorContainer;
    final icon = tone == AuthFeedbackTone.success
        ? Icons.check_circle_outline_rounded
        : Icons.error_outline_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

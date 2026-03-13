import 'package:flutter/material.dart';
import 'package:sickandflutter/features/auth/auth_form_mode.dart';

/// 认证表单顶部导语区。
class AuthFormHero extends StatelessWidget {
  /// 创建认证表单顶部导语区。
  const AuthFormHero({required this.formMode, super.key});

  /// 当前表单模式。
  final AuthFormMode formMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = formMode.isRegister ? '创建账号' : '欢迎回来';
    final description = formMode.isRegister
        ? '填写账号和密码后即可完成开通，随后直接进入主界面。'
        : '输入账号和密码后，继续查看今天的状态和画面。';
    final label = formMode.isRegister ? '新账号开通' : '账号登录';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

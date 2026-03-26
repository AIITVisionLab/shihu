import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
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
        ? '开通完成后返回登录，使用新账号进入值守台。'
        : '输入账号和密码后，直接进入值守台。';
    final label = formMode.isRegister ? '新账号开通' : '登录';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: AppPalette.blendOnPaper(
              formMode.isRegister
                  ? AppPalette.softLavender
                  : AppPalette.softPine,
              opacity: 0.16,
              base: colorScheme.surfaceContainerLowest,
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  (formMode.isRegister
                          ? AppPalette.softLavender
                          : AppPalette.softPine)
                      .withValues(alpha: 0.24),
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppPalette.deepPine,
              fontWeight: FontWeight.w800,
            ),
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

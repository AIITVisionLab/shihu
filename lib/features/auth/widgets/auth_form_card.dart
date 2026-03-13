import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_form_mode.dart';
import 'package:sickandflutter/features/auth/widgets/auth_form/auth_feedback_banner.dart';
import 'package:sickandflutter/features/auth/widgets/auth_form/auth_form_hero.dart';
import 'package:sickandflutter/features/auth/widgets/auth_form/auth_form_theme.dart';
import 'package:sickandflutter/features/auth/widgets/auth_form/auth_mode_selector.dart';
import 'package:sickandflutter/features/auth/widgets/auth_form/auth_register_rule_panel.dart';
import 'package:sickandflutter/features/auth/widgets/auth_form/auth_remember_account_tile.dart';
import 'package:sickandflutter/features/auth/widgets/auth_form/auth_text_field.dart';

/// 认证表单卡片，统一承载登录、注册、提示和本地记住用户名交互。
class AuthFormCard extends StatelessWidget {
  /// 创建认证表单卡片。
  const AuthFormCard({
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isSubmitting,
    required this.isMockMode,
    required this.formMode,
    required this.rememberAccount,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.onRememberAccountChanged,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.onSelectMode,
    required this.onSubmit,
    this.helperMessage,
    this.helperTone,
    super.key,
  });

  /// 用户名输入控制器。
  final TextEditingController usernameController;

  /// 密码输入控制器。
  final TextEditingController passwordController;

  /// 确认密码输入控制器。
  final TextEditingController confirmPasswordController;

  /// 当前是否正在提交。
  final bool isSubmitting;

  /// 当前是否为联调模式。
  final bool isMockMode;

  /// 当前登录模式标签。
  final AuthFormMode formMode;

  /// 是否记住用户名。
  final bool rememberAccount;

  /// 是否显示密码明文。
  final bool showPassword;

  /// 是否显示确认密码明文。
  final bool showConfirmPassword;

  /// 表单辅助提示。
  final String? helperMessage;

  /// 表单辅助提示语义。
  final AuthFeedbackTone? helperTone;

  /// 切换记住用户名。
  final ValueChanged<bool> onRememberAccountChanged;

  /// 切换密码显示状态。
  final VoidCallback onTogglePasswordVisibility;

  /// 切换确认密码显示状态。
  final VoidCallback onToggleConfirmPasswordVisibility;

  /// 选择表单模式。
  final ValueChanged<AuthFormMode> onSelectMode;

  /// 提交表单。
  final Future<void> Function() onSubmit;

  bool get _isRegisterMode => formMode.isRegister;

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final formTheme = buildAuthFormTheme(baseTheme);
    final helperToneOrDefault = helperTone ?? AuthFeedbackTone.error;

    return Theme(
      data: formTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AuthFormHero(formMode: formMode),
              if (!isMockMode) ...<Widget>[
                const SizedBox(height: 24),
                AuthModeSelector(
                  currentMode: formMode,
                  isEnabled: !isSubmitting,
                  onSelectMode: onSelectMode,
                ),
              ],
              if (helperMessage?.isNotEmpty ?? false) ...<Widget>[
                const SizedBox(height: 20),
                AuthFeedbackBanner(
                  message: helperMessage!,
                  tone: helperToneOrDefault,
                ),
              ],
              const SizedBox(height: 24),
              AutofillGroup(
                child: Column(
                  children: <Widget>[
                    AuthTextField(
                      controller: usernameController,
                      label: AppCopy.authUsernameLabel,
                      hintText: AppCopy.authUsernameHint,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autofillHints: const <String>[AutofillHints.username],
                      autocorrect: false,
                      enableSuggestions: false,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: passwordController,
                      label: AppCopy.authPasswordLabel,
                      hintText: AppCopy.authPasswordHint,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      enabled: !isSubmitting,
                      obscureText: !showPassword,
                      textInputAction: _isRegisterMode
                          ? TextInputAction.next
                          : TextInputAction.done,
                      autofillHints: <String>[
                        _isRegisterMode
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      autocorrect: false,
                      enableSuggestions: false,
                      suffixIcon: IconButton(
                        onPressed: isSubmitting
                            ? null
                            : onTogglePasswordVisibility,
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                      onSubmitted: (_) async {
                        if (!_isRegisterMode) {
                          await onSubmit();
                        }
                      },
                    ),
                    if (_isRegisterMode) ...<Widget>[
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: confirmPasswordController,
                        label: AppCopy.authConfirmPasswordLabel,
                        hintText: AppCopy.authConfirmPasswordHint,
                        prefixIcon: const Icon(Icons.verified_outlined),
                        enabled: !isSubmitting,
                        obscureText: !showConfirmPassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const <String>[
                          AutofillHints.newPassword,
                        ],
                        autocorrect: false,
                        enableSuggestions: false,
                        suffixIcon: IconButton(
                          onPressed: isSubmitting
                              ? null
                              : onToggleConfirmPasswordVisibility,
                          icon: Icon(
                            showConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                        onSubmitted: (_) async {
                          await onSubmit();
                        },
                      ),
                      const SizedBox(height: 16),
                      const AuthRegisterRulePanel(),
                    ] else ...<Widget>[
                      const SizedBox(height: 12),
                      AuthRememberAccountTile(
                        rememberAccount: rememberAccount,
                        isSubmitting: isSubmitting,
                        onChanged: onRememberAccountChanged,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          await onSubmit();
                        },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  icon: isSubmitting
                      ? SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Icon(
                          _isRegisterMode
                              ? Icons.person_add_alt_1_rounded
                              : Icons.login_rounded,
                        ),
                  label: Text(
                    isSubmitting
                        ? (_isRegisterMode
                              ? AppCopy.authRegistering
                              : AppCopy.authLoggingIn)
                        : (_isRegisterMode
                              ? AppCopy.authRegister
                              : AppCopy.authLogin),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (!isMockMode)
                Center(
                  child: TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => onSelectMode(
                            _isRegisterMode
                                ? AuthFormMode.login
                                : AuthFormMode.register,
                          ),
                    child: Text(_isRegisterMode ? '返回登录' : '前往注册'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

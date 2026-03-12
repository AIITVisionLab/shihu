import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_form_mode.dart';

/// 认证表单提示的视觉语义。
enum AuthFeedbackTone {
  /// 错误提示。
  error,

  /// 成功提示。
  success,
}

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
    final formTheme = _buildFormTheme(baseTheme);
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
              _FormHero(formMode: formMode, isMockMode: isMockMode),
              if (!isMockMode) ...<Widget>[
                const SizedBox(height: 24),
                _ModeSelector(
                  currentMode: formMode,
                  isEnabled: !isSubmitting,
                  onSelectMode: onSelectMode,
                ),
              ],
              if (helperMessage?.isNotEmpty ?? false) ...<Widget>[
                const SizedBox(height: 20),
                _FeedbackBanner(
                  message: helperMessage!,
                  tone: helperToneOrDefault,
                ),
              ],
              const SizedBox(height: 24),
              AutofillGroup(
                child: Column(
                  children: <Widget>[
                    _AuthTextField(
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
                    _AuthTextField(
                      controller: passwordController,
                      label: AppCopy.authPasswordLabel,
                      hintText: isMockMode
                          ? AppCopy.authMockPasswordHint
                          : AppCopy.authPasswordHint,
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
                      _AuthTextField(
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
                      const _RegisterRulePanel(),
                    ] else ...<Widget>[
                      const SizedBox(height: 12),
                      _RememberAccountTile(
                        rememberAccount: rememberAccount,
                        isMockMode: isMockMode,
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
                    minimumSize: const Size.fromHeight(54),
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

ThemeData _buildFormTheme(ThemeData baseTheme) {
  final scheme = baseTheme.colorScheme.copyWith(
    primary: const Color(0xFF57A8FF),
    onPrimary: const Color(0xFF031A31),
    surface: const Color(0xFF0D1724),
    onSurface: const Color(0xFFF0F5F7),
    onSurfaceVariant: const Color(0xFF95A8BD),
    surfaceContainerLowest: const Color(0xFF09111C),
    surfaceContainerLow: const Color(0xFF0D1724),
    surfaceContainer: const Color(0xFF111C2B),
    surfaceContainerHighest: const Color(0xFF1A2A3D),
    primaryContainer: const Color(0xFF0F2741),
    onPrimaryContainer: const Color(0xFFD6E9FF),
    secondaryContainer: const Color(0xFF112234),
    onSecondaryContainer: const Color(0xFFE7EEF2),
    tertiaryContainer: const Color(0xFF103145),
    onTertiaryContainer: const Color(0xFFD7F0FF),
    outlineVariant: const Color(0xFF263B52),
    errorContainer: const Color(0xFF45211C),
    onErrorContainer: const Color(0xFFFFDAD4),
  );

  return baseTheme.copyWith(
    colorScheme: scheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0E1826),
      hintStyle: baseTheme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF7D96AE),
      ),
      labelStyle: baseTheme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF95A8BD),
        fontWeight: FontWeight.w700,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF263B52)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF263B52)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF57A8FF), width: 1.5),
      ),
      prefixIconColor: const Color(0xFF95A8BD),
      suffixIconColor: const Color(0xFF95A8BD),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF0F2741);
          }
          return const Color(0xFF0D1724);
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFD6E9FF);
          }
          return const Color(0xFF95A8BD);
        }),
        side: const WidgetStatePropertyAll(
          BorderSide(color: Color(0x00000000)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF85BEFF)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: const WidgetStatePropertyAll(Color(0xFF57A8FF)),
      side: const BorderSide(color: Color(0xFF3E5670)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );
}

class _FormHero extends StatelessWidget {
  const _FormHero({required this.formMode, required this.isMockMode});

  final AuthFormMode formMode;
  final bool isMockMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = formMode.isRegister ? '创建账号' : '欢迎回来';
    final description = formMode.isRegister ? '填写最少信息即可开通。' : '输入账号和密码后继续。';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isMockMode ? '演示环境' : '用户登录',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.currentMode,
    required this.isEnabled,
    required this.onSelectMode,
  });

  final AuthFormMode currentMode;
  final bool isEnabled;
  final ValueChanged<AuthFormMode> onSelectMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SegmentedButton<AuthFormMode>(
        showSelectedIcon: false,
        segments: const <ButtonSegment<AuthFormMode>>[
          ButtonSegment<AuthFormMode>(
            value: AuthFormMode.login,
            label: Text(AppCopy.authLoginTab),
            icon: Icon(Icons.login_rounded),
          ),
          ButtonSegment<AuthFormMode>(
            value: AuthFormMode.register,
            label: Text(AppCopy.authRegisterTab),
            icon: Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
        selected: <AuthFormMode>{currentMode},
        onSelectionChanged: isEnabled
            ? (selection) => onSelectMode(selection.first)
            : null,
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
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
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final Widget prefixIcon;
  final bool enabled;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final bool autocorrect;
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

class _RememberAccountTile extends StatelessWidget {
  const _RememberAccountTile({
    required this.rememberAccount,
    required this.isMockMode,
    required this.isSubmitting,
    required this.onChanged,
  });

  final bool rememberAccount;
  final bool isMockMode;
  final bool isSubmitting;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isSubmitting ? null : () => onChanged(!rememberAccount),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: <Widget>[
              Checkbox(
                value: rememberAccount,
                onChanged: isSubmitting
                    ? null
                    : (value) => onChanged(value ?? false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '记住账号',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isMockMode ? '支持演示账号回填。' : '下次自动回填账号。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterRulePanel extends StatelessWidget {
  const _RegisterRulePanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.rule_rounded, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppCopy.authRegisterRules,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.message, required this.tone});

  final String message;
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

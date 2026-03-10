import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_form_mode.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

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
    required this.accountController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isSubmitting,
    required this.isMockMode,
    required this.loginModeLabel,
    required this.formMode,
    required this.rememberAccount,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.passwordStrength,
    required this.onRememberAccountChanged,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.onSelectMode,
    required this.onSubmit,
    this.helperMessage,
    this.helperTone,
    super.key,
  });

  /// 账号输入控制器。
  final TextEditingController accountController;

  /// 密码输入控制器。
  final TextEditingController passwordController;

  /// 确认密码输入控制器。
  final TextEditingController confirmPasswordController;

  /// 当前是否正在提交。
  final bool isSubmitting;

  /// 当前是否为联调模式。
  final bool isMockMode;

  /// 当前登录模式标签。
  final String loginModeLabel;

  /// 当前表单模式。
  final AuthFormMode formMode;

  /// 是否记住用户名。
  final bool rememberAccount;

  /// 是否显示密码明文。
  final bool showPassword;

  /// 是否显示确认密码明文。
  final bool showConfirmPassword;

  /// 密码强度等级。
  final int passwordStrength;

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
    final colorScheme = Theme.of(context).colorScheme;
    final helperToneOrDefault = helperTone ?? AuthFeedbackTone.error;

    return CommonCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FormHero(
            formMode: formMode,
            isMockMode: isMockMode,
            loginModeLabel: loginModeLabel,
          ),
          const SizedBox(height: 20),
          if (!isMockMode) ...<Widget>[
            _ModeSelector(
              currentMode: formMode,
              isEnabled: !isSubmitting,
              onSelectMode: onSelectMode,
            ),
            const SizedBox(height: 20),
          ],
          if (_isRegisterMode) ...<Widget>[
            const _RegisterRulePanel(),
            const SizedBox(height: 16),
          ],
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: (helperMessage?.isNotEmpty ?? false)
                ? Padding(
                    key: ValueKey<String>('helper-$helperMessage'),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _FeedbackBanner(
                      message: helperMessage!,
                      tone: helperToneOrDefault,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          _AuthTextField(
            controller: accountController,
            label: _isRegisterMode ? '用户名' : AppCopy.authAccountLabel,
            hintText: _isRegisterMode ? '例如：admin_01' : AppCopy.authAccountHint,
            prefixIcon: const Icon(Icons.person_outline_rounded),
            enabled: !isSubmitting,
            textInputAction: TextInputAction.next,
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
            suffixIcon: IconButton(
              onPressed: isSubmitting ? null : onTogglePasswordVisibility,
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
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _isRegisterMode
                ? Column(
                    children: <Widget>[
                      const SizedBox(height: 12),
                      _PasswordStrengthIndicator(level: passwordStrength),
                      const SizedBox(height: 16),
                      _AuthTextField(
                        controller: confirmPasswordController,
                        label: AppCopy.authConfirmPasswordLabel,
                        hintText: AppCopy.authConfirmPasswordHint,
                        prefixIcon: const Icon(Icons.verified_outlined),
                        enabled: !isSubmitting,
                        obscureText: !showConfirmPassword,
                        textInputAction: TextInputAction.done,
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
                    ],
                  )
                : _RememberAccountTile(
                    rememberAccount: rememberAccount,
                    isMockMode: isMockMode,
                    isSubmitting: isSubmitting,
                    onChanged: onRememberAccountChanged,
                  ),
          ),
          const SizedBox(height: 20),
          CommonButton(
            label: isSubmitting
                ? (_isRegisterMode
                      ? AppCopy.authRegistering
                      : AppCopy.authLoggingIn)
                : (_isRegisterMode ? AppCopy.authRegister : AppCopy.authLogin),
            isLoading: isSubmitting,
            icon: Icon(
              _isRegisterMode ? Icons.person_add_alt_1_rounded : Icons.login,
            ),
            onPressed: isSubmitting
                ? null
                : () async {
                    await onSubmit();
                  },
          ),
          const SizedBox(height: 12),
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
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '当前为联调登录模式，仅开放登录体验；接入在线服务后，同一张卡片会开放账号开通流程。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FormHero extends StatelessWidget {
  const _FormHero({
    required this.formMode,
    required this.isMockMode,
    required this.loginModeLabel,
  });

  final AuthFormMode formMode;
  final bool isMockMode;
  final String loginModeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = formMode.isRegister ? '创建新账号' : AppCopy.authLoginCardTitle;
    final description = formMode.isRegister
        ? '账号开通成功后会返回登录模式，并沿用同一套认证链路进入实时监控主控台。'
        : '登录成功后直接进入设备主控台，后续访问会优先恢复上一轮有效会话。';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Icon(
                formMode.isRegister
                    ? Icons.person_add_alt_1_rounded
                    : Icons.lock_person_outlined,
                color: colorScheme.primary,
              ),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              _StatusPill(
                icon: isMockMode
                    ? Icons.science_outlined
                    : Icons.cloud_done_outlined,
                label: isMockMode ? '联调模式' : '在线服务',
              ),
              _StatusPill(
                icon: Icons.info_outline_rounded,
                label: AppCopy.authCurrentMode(loginModeLabel),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
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
    return SegmentedButton<AuthFormMode>(
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

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        value: rememberAccount,
        onChanged: isSubmitting ? null : (value) => onChanged(value ?? false),
        title: const Text('记住用户名'),
        subtitle: Text(isMockMode ? '支持联调账号快速回填' : '下次打开登录页自动回填账号'),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  const _PasswordStrengthIndicator({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final values = <double>[0.0, 0.34, 0.67, 1.0];
    final labels = <String>['密码强度：待输入', '密码强度：较弱', '密码强度：中等', '密码强度：较强'];
    final colors = <Color>[
      colorScheme.outlineVariant,
      colorScheme.error,
      colorScheme.tertiary,
      colorScheme.primary,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: values[level],
              color: colors[level],
              backgroundColor: colorScheme.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 8),
          Text(labels[level], style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _RegisterRulePanel extends StatelessWidget {
  const _RegisterRulePanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.rule_rounded, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppCopy.authRegisterRules,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
                height: 1.6,
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
    final colorScheme = Theme.of(context).colorScheme;
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: foregroundColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

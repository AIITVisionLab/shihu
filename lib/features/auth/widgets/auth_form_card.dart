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
    required this.passwordStrength,
    required this.currentDeviceBaseUrl,
    required this.isUsingCustomServiceConfig,
    required this.canResetServiceConfig,
    required this.onRememberAccountChanged,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.onSelectMode,
    required this.onSubmit,
    required this.onResetServiceConfig,
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

  /// 密码强度等级。
  final int passwordStrength;

  /// 当前设备服务地址。
  final String currentDeviceBaseUrl;

  /// 当前是否使用自定义服务配置。
  final bool isUsingCustomServiceConfig;

  /// 当前是否允许恢复默认服务配置。
  final bool canResetServiceConfig;

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

  /// 恢复默认服务配置。
  final Future<void> Function() onResetServiceConfig;

  bool get _isRegisterMode => formMode.isRegister;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final helperToneOrDefault = helperTone ?? AuthFeedbackTone.error;

    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0C172019),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _FormHero(formMode: formMode, isMockMode: isMockMode),
              const SizedBox(height: 20),
              if (!isMockMode) ...<Widget>[
                _ModeSelector(
                  currentMode: formMode,
                  isEnabled: !isSubmitting,
                  onSelectMode: onSelectMode,
                ),
                const SizedBox(height: 20),
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
              if (!isMockMode) ...<Widget>[
                _ServiceAccessPanel(
                  currentDeviceBaseUrl: currentDeviceBaseUrl,
                  isUsingCustomServiceConfig: isUsingCustomServiceConfig,
                  canResetServiceConfig: canResetServiceConfig,
                  onResetServiceConfig: onResetServiceConfig,
                ),
                const SizedBox(height: 16),
              ],
              if (_isRegisterMode) ...<Widget>[
                const _RegisterRulePanel(),
                const SizedBox(height: 16),
              ],
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
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: _isRegisterMode
                          ? Column(
                              children: <Widget>[
                                const SizedBox(height: 12),
                                _PasswordStrengthIndicator(
                                  level: passwordStrength,
                                ),
                                const SizedBox(height: 16),
                                _AuthTextField(
                                  controller: confirmPasswordController,
                                  label: AppCopy.authConfirmPasswordLabel,
                                  hintText: AppCopy.authConfirmPasswordHint,
                                  prefixIcon: const Icon(
                                    Icons.verified_outlined,
                                  ),
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
                              ],
                            )
                          : _RememberAccountTile(
                              rememberAccount: rememberAccount,
                              isMockMode: isMockMode,
                              isSubmitting: isSubmitting,
                              onChanged: onRememberAccountChanged,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          await onSubmit();
                        },
                  icon: isSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
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
                _MockHintCard(colorScheme: colorScheme),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormHero extends StatelessWidget {
  const _FormHero({required this.formMode, required this.isMockMode});

  final AuthFormMode formMode;
  final bool isMockMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = formMode.isRegister ? '创建新账号' : AppCopy.authLoginCardTitle;
    final loginSceneLabel = isMockMode ? '演示模式' : '在线服务';
    final description = formMode.isRegister
        ? '账号开通完成后会回到登录模式，继续沿用同一套账号密码登录链路。'
        : '登录成功后直接进入石斛监测主控台，继续查看设备状态、告警等级和补光控制。';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.secondaryContainer.withValues(alpha: 0.92),
            colorScheme.primaryContainer.withValues(alpha: 0.76),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
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
                label: loginSceneLabel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceAccessPanel extends StatelessWidget {
  const _ServiceAccessPanel({
    required this.currentDeviceBaseUrl,
    required this.isUsingCustomServiceConfig,
    required this.canResetServiceConfig,
    required this.onResetServiceConfig,
  });

  final String currentDeviceBaseUrl;
  final bool isUsingCustomServiceConfig;
  final bool canResetServiceConfig;
  final Future<void> Function() onResetServiceConfig;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    isUsingCustomServiceConfig
                        ? Icons.tune_rounded
                        : Icons.cloud_done_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppCopy.authServicePanelTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              if (canResetServiceConfig)
                TextButton.icon(
                  onPressed: () async {
                    await onResetServiceConfig();
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text(AppCopy.authResetServiceConfig),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _ServiceAddressLine(
            label: AppCopy.authDeviceServiceLabel,
            value: currentDeviceBaseUrl,
          ),
          const SizedBox(height: 12),
          Text(
            isUsingCustomServiceConfig
                ? AppCopy.authCustomServiceConfigHint
                : AppCopy.authDefaultServiceConfigHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceAddressLine extends StatelessWidget {
  const _ServiceAddressLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
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

    return Chip(
      avatar: Icon(icon, size: 16, color: colorScheme.primary),
      label: Text(label),
      backgroundColor: colorScheme.surfaceContainerLowest,
      side: BorderSide.none,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
      ),
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        value: rememberAccount,
        onChanged: isSubmitting ? null : (value) => onChanged(value ?? false),
        title: const Text('记住账号'),
        subtitle: Text(isMockMode ? '支持演示账号快速回填' : '下次打开登录页自动回填账号'),
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
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
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
        color: colorScheme.secondaryContainer.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.16)),
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

class _MockHintCard extends StatelessWidget {
  const _MockHintCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        '当前为演示环境，仅用于体验登录流程；切换到在线服务后即可使用正式账号继续登录。',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.6,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

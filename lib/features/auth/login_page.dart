import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_form_mode.dart';
import 'package:sickandflutter/features/auth/auth_repository.dart';
import 'package:sickandflutter/features/auth/mock_auth_repository.dart';
import 'package:sickandflutter/features/auth/remembered_account_repository.dart';
import 'package:sickandflutter/features/auth/widgets/auth_entry_shell.dart';
import 'package:sickandflutter/features/auth/widgets/auth_form/auth_feedback_banner.dart';
import 'package:sickandflutter/features/auth/widgets/auth_form_card.dart';
import 'package:sickandflutter/features/auth/widgets/auth_overview_panel.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';

/// 登录页，承接用户名登录、注册和会话恢复入口。
class LoginPage extends ConsumerStatefulWidget {
  /// 创建登录页。
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  AuthFormMode _formMode = AuthFormMode.login;
  String? _localHelperMessage;
  AuthFeedbackTone? _localHelperTone;
  bool _rememberAccount = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    Future<void>.microtask(_restoreRememberedAccount);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authRepository = ref.watch(authRepositoryProvider);
    final envConfig = ref.watch(envConfigProvider);
    final settings = ref.watch(effectiveAppSettingsProvider);
    final effectiveFormMode = authRepository.isMockMode
        ? AuthFormMode.login
        : _formMode;
    final isUsingCustomServiceConfig = settings.baseUrl != envConfig.baseUrl;
    final keepAssistPanelForResetNotice =
        _localHelperMessage == AppCopy.authResetServiceConfigSuccess;
    final showAssistPanel =
        authRepository.isMockMode ||
        (envConfig.allowRiskySettings && isUsingCustomServiceConfig) ||
        keepAssistPanelForResetNotice;
    final helperMessage =
        _localHelperMessage ??
        authState.unauthorizedMessage ??
        authState.errorMessage;
    final helperTone = helperMessage == null
        ? null
        : (_localHelperMessage == null
              ? AuthFeedbackTone.error
              : (_localHelperTone ?? AuthFeedbackTone.error));

    return AuthEntryShell(
      onBackPressed: authState.isSubmitting
          ? null
          : () => context.goNamed(AppRoutes.about),
      overviewPanel: showAssistPanel
          ? AuthOverviewPanel(
              isMockMode: authRepository.isMockMode,
              isUsingCustomServiceConfig: isUsingCustomServiceConfig,
              canResetServiceConfig:
                  envConfig.allowRiskySettings &&
                  !authRepository.isMockMode &&
                  isUsingCustomServiceConfig,
              onFillDemo: _fillDemoCredentials,
              onResetServiceConfig: _resetServiceConfig,
            )
          : null,
      formPanel: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AuthFormCard(
            usernameController: _usernameController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            helperMessage: helperMessage,
            helperTone: helperTone,
            isSubmitting: authState.isSubmitting,
            isMockMode: authRepository.isMockMode,
            formMode: effectiveFormMode,
            rememberAccount: _rememberAccount,
            showPassword: _showPassword,
            showConfirmPassword: _showConfirmPassword,
            onRememberAccountChanged: (value) {
              setState(() {
                _rememberAccount = value;
              });
            },
            onTogglePasswordVisibility: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
            onToggleConfirmPasswordVisibility: () {
              setState(() {
                _showConfirmPassword = !_showConfirmPassword;
              });
            },
            onSelectMode: _switchFormMode,
            onSubmit: _submit,
          ),
          if (envConfig.allowRiskySettings) ...<Widget>[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: authState.isSubmitting
                    ? null
                    : () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .enterPreviewWorkspace();
                        if (!context.mounted) {
                          return;
                        }
                        context.goNamed(AppRoutes.home);
                      },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('先看界面'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _restoreRememberedAccount() async {
    final rememberedAccount = await ref.read(
      rememberedAccountControllerProvider.future,
    );
    if (!mounted || rememberedAccount == null || rememberedAccount.isEmpty) {
      return;
    }

    setState(() {
      _usernameController.text = rememberedAccount;
      _rememberAccount = true;
    });
  }

  Future<void> _persistRememberedAccount() async {
    final normalizedUsername = _usernameController.text.trim();
    if (_rememberAccount && normalizedUsername.isNotEmpty) {
      await ref
          .read(rememberedAccountControllerProvider.notifier)
          .save(normalizedUsername);
      return;
    }

    await ref.read(rememberedAccountControllerProvider.notifier).clear();
  }

  void _fillDemoCredentials() {
    _usernameController.text = MockAuthRepository.demoAccount;
    _passwordController.text = MockAuthRepository.demoPassword;
    _confirmPasswordController.clear();
    _clearLocalHelper();
  }

  void _switchFormMode(AuthFormMode nextMode) {
    if (_formMode == nextMode) {
      return;
    }

    ref.read(authControllerProvider.notifier).clearMessages();
    setState(() {
      _formMode = nextMode;
      _localHelperMessage = null;
      _localHelperTone = null;
      _showPassword = false;
      _showConfirmPassword = false;
    });
    _confirmPasswordController.clear();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    _clearLocalHelper();

    final controller = ref.read(authControllerProvider.notifier);
    controller.clearMessages();
    final authRepository = ref.read(authRepositoryProvider);
    final effectiveFormMode = authRepository.isMockMode
        ? AuthFormMode.login
        : _formMode;

    if (effectiveFormMode == AuthFormMode.login) {
      await _persistRememberedAccount();
      final success = await controller.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (!mounted || !success) {
        return;
      }

      context.goNamed(AppRoutes.realtimeDetect);
      return;
    }

    final registerMessage = await controller.register(
      username: _usernameController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    if (!mounted || registerMessage == null) {
      return;
    }

    setState(() {
      _formMode = AuthFormMode.login;
      _localHelperMessage = registerMessage;
      _localHelperTone = AuthFeedbackTone.success;
      _showPassword = false;
      _showConfirmPassword = false;
    });
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _resetServiceConfig() async {
    ref.read(authControllerProvider.notifier).clearMessages();
    await ref.read(settingsControllerProvider.notifier).reset();
    if (!mounted) {
      return;
    }

    setState(() {
      _localHelperMessage = AppCopy.authResetServiceConfigSuccess;
      _localHelperTone = AuthFeedbackTone.success;
    });
  }

  void _clearLocalHelper() {
    if (_localHelperMessage == null) {
      return;
    }

    setState(() {
      _localHelperMessage = null;
      _localHelperTone = null;
    });
  }
}

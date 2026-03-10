import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_form_mode.dart';
import 'package:sickandflutter/features/auth/auth_repository.dart';
import 'package:sickandflutter/features/auth/mock_auth_repository.dart';
import 'package:sickandflutter/features/auth/remembered_account_repository.dart';
import 'package:sickandflutter/features/auth/widgets/auth_entry_shell.dart';
import 'package:sickandflutter/features/auth/widgets/auth_form_card.dart';
import 'package:sickandflutter/features/auth/widgets/auth_overview_panel.dart';

/// 登录页，承接账号登录、开通和会话恢复入口。
class LoginPage extends ConsumerStatefulWidget {
  /// 创建登录页。
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _accountController;
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
    _accountController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordController.addListener(_handlePasswordChanged);
    Future<void>.microtask(_restoreRememberedAccount);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_handlePasswordChanged);
    _accountController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authRepository = ref.watch(authRepositoryProvider);
    final effectiveFormMode = authRepository.isMockMode
        ? AuthFormMode.login
        : _formMode;
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
          : () => context.pushNamed(AppRoutes.about),
      overviewPanel: AuthOverviewPanel(
        isMockMode: authRepository.isMockMode,
        supportsRegister: !authRepository.isMockMode,
        onFillDemo: _fillDemoCredentials,
      ),
      formPanel: AuthFormCard(
        accountController: _accountController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        helperMessage: helperMessage,
        helperTone: helperTone,
        isSubmitting: authState.isSubmitting,
        isMockMode: authRepository.isMockMode,
        loginModeLabel: authRepository.loginModeLabel,
        formMode: effectiveFormMode,
        rememberAccount: _rememberAccount,
        showPassword: _showPassword,
        showConfirmPassword: _showConfirmPassword,
        passwordStrength: _passwordStrengthLevel(_passwordController.text),
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
    );
  }

  void _handlePasswordChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _restoreRememberedAccount() async {
    final rememberedAccount = await ref.read(
      rememberedAccountControllerProvider.future,
    );
    if (!mounted || rememberedAccount == null || rememberedAccount.isEmpty) {
      return;
    }

    setState(() {
      _accountController.text = rememberedAccount;
      _rememberAccount = true;
    });
  }

  Future<void> _persistRememberedAccount() async {
    final normalizedAccount = _accountController.text.trim();
    if (_rememberAccount && normalizedAccount.isNotEmpty) {
      await ref
          .read(rememberedAccountControllerProvider.notifier)
          .save(normalizedAccount);
      return;
    }

    await ref.read(rememberedAccountControllerProvider.notifier).clear();
  }

  void _fillDemoCredentials() {
    _accountController.text = MockAuthRepository.demoAccount;
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
        account: _accountController.text,
        password: _passwordController.text,
      );

      if (!mounted || !success) {
        return;
      }

      context.goNamed(AppRoutes.realtimeDetect);
      return;
    }

    final registerMessage = await controller.register(
      account: _accountController.text,
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

  void _clearLocalHelper() {
    if (_localHelperMessage == null) {
      return;
    }

    setState(() {
      _localHelperMessage = null;
      _localHelperTone = null;
    });
  }

  int _passwordStrengthLevel(String value) {
    var score = 0;
    if (value.length >= 6) {
      score += 1;
    }
    if ((RegExp(r'[A-Za-z]').hasMatch(value) &&
            RegExp(r'\d').hasMatch(value)) ||
        RegExp(r'[A-Z]').hasMatch(value)) {
      score += 1;
    }
    if (RegExp(r'[^A-Za-z0-9_]').hasMatch(value) || value.length >= 10) {
      score += 1;
    }
    return score.clamp(0, 3);
  }
}

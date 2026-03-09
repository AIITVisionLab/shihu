import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_repository.dart';
import 'package:sickandflutter/features/auth/mock_auth_repository.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 登录页，负责恢复受保护页面前的账号认证入口。
class LoginPage extends ConsumerStatefulWidget {
  /// 创建登录页。
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _accountController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authRepository = ref.watch(authRepositoryProvider);
    final helperMessage =
        authState.unauthorizedMessage ?? authState.errorMessage;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFEFF6FF), Color(0xFFDCEAFE)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 760;

                    return isCompact
                        ? ListView(
                            children: <Widget>[
                              _LoginHeroCard(
                                isMockMode: authRepository.isMockMode,
                                onFillDemo: _fillDemoCredentials,
                              ),
                              const SizedBox(height: 20),
                              _LoginFormCard(
                                accountController: _accountController,
                                passwordController: _passwordController,
                                helperMessage: helperMessage,
                                isSubmitting: authState.isSubmitting,
                                isMockMode: authRepository.isMockMode,
                                loginModeLabel: authRepository.loginModeLabel,
                                onSubmit: _submit,
                                onOpenAbout: () =>
                                    context.pushNamed(AppRoutes.about),
                              ),
                            ],
                          )
                        : Row(
                            children: <Widget>[
                              Expanded(
                                child: _LoginHeroCard(
                                  isMockMode: authRepository.isMockMode,
                                  onFillDemo: _fillDemoCredentials,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _LoginFormCard(
                                  accountController: _accountController,
                                  passwordController: _passwordController,
                                  helperMessage: helperMessage,
                                  isSubmitting: authState.isSubmitting,
                                  isMockMode: authRepository.isMockMode,
                                  loginModeLabel: authRepository.loginModeLabel,
                                  onSubmit: _submit,
                                  onOpenAbout: () =>
                                      context.pushNamed(AppRoutes.about),
                                ),
                              ),
                            ],
                          );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _fillDemoCredentials() {
    _accountController.text = MockAuthRepository.demoAccount;
    _passwordController.text = MockAuthRepository.demoPassword;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    ref.read(authControllerProvider.notifier).clearErrorMessage();

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(
          account: _accountController.text,
          password: _passwordController.text,
        );

    if (!mounted || !success) {
      return;
    }

    context.goNamed(AppRoutes.home);
  }
}

class _LoginHeroCard extends StatelessWidget {
  const _LoginHeroCard({required this.isMockMode, required this.onFillDemo});

  final bool isMockMode;
  final VoidCallback onFillDemo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CommonCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1D4ED8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.lock_open_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppConstants.appName,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppCopy.authLoginOverview,
            style: textTheme.titleMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const <Widget>[
              Chip(label: Text(AppCopy.authRestoreChip)),
              Chip(label: Text(AppCopy.authUnauthorizedChip)),
              Chip(label: Text(AppCopy.authTokenChip)),
            ],
          ),
          if (isMockMode) ...<Widget>[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppCopy.authMockModeTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppCopy.authMockAccountHint,
                    style: textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: onFillDemo,
                    icon: const Icon(Icons.auto_fix_high_rounded),
                    label: const Text(AppCopy.authFillDemoAccount),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({
    required this.accountController,
    required this.passwordController,
    required this.helperMessage,
    required this.isSubmitting,
    required this.isMockMode,
    required this.loginModeLabel,
    required this.onSubmit,
    required this.onOpenAbout,
  });

  final TextEditingController accountController;
  final TextEditingController passwordController;
  final String? helperMessage;
  final bool isSubmitting;
  final bool isMockMode;
  final String loginModeLabel;
  final Future<void> Function() onSubmit;
  final VoidCallback onOpenAbout;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: AppCopy.authLoginCardTitle,
      subtitle: AppCopy.authCurrentMode(loginModeLabel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: accountController,
            decoration: const InputDecoration(
              labelText: AppCopy.authAccountLabel,
              hintText: AppCopy.authAccountHint,
            ),
            enabled: !isSubmitting,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: AppCopy.authPasswordLabel,
              hintText: isMockMode
                  ? AppCopy.authMockPasswordHint
                  : AppCopy.authPasswordHint,
            ),
            obscureText: true,
            enabled: !isSubmitting,
            onSubmitted: (_) async {
              await onSubmit();
            },
          ),
          if (helperMessage?.isNotEmpty ?? false) ...<Widget>[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                helperMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          CommonButton(
            label: isSubmitting ? AppCopy.authLoggingIn : AppCopy.authLogin,
            icon: const Icon(Icons.login_rounded),
            isLoading: isSubmitting,
            onPressed: isSubmitting
                ? null
                : () async {
                    await onSubmit();
                  },
          ),
          const SizedBox(height: 12),
          CommonButton(
            label: AppCopy.viewAboutProject,
            tone: CommonButtonTone.secondary,
            icon: const Icon(Icons.info_outline),
            onPressed: isSubmitting ? null : onOpenAbout,
          ),
        ],
      ),
    );
  }
}

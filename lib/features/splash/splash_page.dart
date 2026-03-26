import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';
import 'package:sickandflutter/shared/widgets/app_brand_mark.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 启动页，负责初始化本地设置和基础运行信息。
class SplashPage extends ConsumerStatefulWidget {
  /// 创建启动页。
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await Future.wait<dynamic>(<Future<dynamic>>[
        ref.read(settingsControllerProvider.future),
        ref.read(packageInfoProvider.future),
        ref.read(authControllerProvider.notifier).ensureInitialized(),
      ]);
      await Future<void>.delayed(AppConstants.splashDuration);

      if (!mounted) {
        return;
      }

      final authState = ref.read(authControllerProvider);
      context.goNamed(
        authState.isAuthenticated ? AppRoutes.realtimeDetect : AppRoutes.login,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = AppCopy.splashInitFailed(error);
      });
    }
  }

  void _retry() {
    setState(() {
      _errorMessage = null;
    });
    _bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useSplitLayout = width >= 980;
    final compact = width < 640;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AppBackdrop(
              baseGradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppPalette.paperSnow,
                  AppPalette.paperMist,
                  AppPalette.paper,
                ],
              ),
              orbs: const <BackdropOrbData>[
                BackdropOrbData(
                  alignment: Alignment(-1.0, -0.9),
                  size: 260,
                  color: Color(0x10518463),
                ),
                BackdropOrbData(
                  alignment: Alignment(1.02, -0.18),
                  size: 220,
                  color: Color(0x0CA7D3B2),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  compact ? 18 : 24,
                  compact ? 18 : 24,
                  compact ? 18 : 24,
                  24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: useSplitLayout
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Expanded(
                              flex: 9,
                              child: _SplashBrandStage(compact: false),
                            ),
                            const SizedBox(width: 28),
                            SizedBox(
                              width: 420,
                              child: _SplashStatusStage(
                                compact: false,
                                errorMessage: _errorMessage,
                                onRetry: _retry,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const _SplashBrandStage(compact: true),
                            const SizedBox(height: 18),
                            _SplashStatusStage(
                              compact: true,
                              errorMessage: _errorMessage,
                              onRetry: _retry,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBrandStage extends StatelessWidget {
  const _SplashBrandStage({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppBrandBadge(size: compact ? 60 : 72),
          SizedBox(height: compact ? 22 : 28),
          Text(
            AppConstants.appName,
            style:
                (compact
                        ? theme.textTheme.headlineMedium
                        : theme.textTheme.displaySmall)
                    ?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.appTagline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '正在准备页面和当前账号信息，完成后会自动进入主界面。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashStatusStage extends StatelessWidget {
  const _SplashStatusStage({
    required this.compact,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool compact;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FeatureHeroCard(
      padding: EdgeInsets.all(compact ? 24 : 28),
      borderRadius: compact ? 30 : 34,
      accentColor: AppPalette.pineGreen,
      child: errorMessage == null
          ? _SplashLoadingState(compact: compact)
          : _SplashErrorState(message: errorMessage!, onRetry: onRetry),
    );
  }
}

class _SplashLoadingState extends StatelessWidget {
  const _SplashLoadingState({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: compact ? 22 : 24,
              height: compact ? 22 : 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '正在准备',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          AppCopy.splashBootstrapping,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.58,
          ),
        ),
        const SizedBox(height: 20),
        const _SplashStepRow(icon: Icons.tune_rounded, label: '读取本机设置'),
        const SizedBox(height: 12),
        const _SplashStepRow(
          icon: Icons.account_circle_outlined,
          label: '恢复当前账号',
        ),
        const SizedBox(height: 12),
        const _SplashStepRow(
          icon: Icons.dashboard_customize_outlined,
          label: '准备页面内容',
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHigh,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _SplashStepRow extends StatelessWidget {
  const _SplashStepRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppPalette.softPine.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashErrorState extends StatelessWidget {
  const _SplashErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.error_outline_rounded, color: colorScheme.error),
            const SizedBox(width: 10),
            Text(
              '准备失败',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.56,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onRetry,
          child: const Text(AppCopy.splashRetry),
        ),
      ],
    );
  }
}

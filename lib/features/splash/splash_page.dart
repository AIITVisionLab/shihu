import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AppBackdrop(
              baseGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colorScheme.surface,
                  colorScheme.surfaceContainerLow,
                  colorScheme.surfaceContainer,
                ],
              ),
              orbs: const <BackdropOrbData>[
                BackdropOrbData(
                  alignment: Alignment(-1.0, -0.9),
                  size: 320,
                  color: Color(0x1885B28F),
                ),
                BackdropOrbData(
                  alignment: Alignment(1.0, -0.35),
                  size: 260,
                  color: Color(0x15977A58),
                ),
                BackdropOrbData(
                  alignment: Alignment(0.82, 1.0),
                  size: 250,
                  color: Color(0x12436C61),
                ),
              ],
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          colorScheme.surfaceContainerLowest.withValues(
                            alpha: 0.98,
                          ),
                          colorScheme.surfaceContainerLow.withValues(
                            alpha: 0.94,
                          ),
                        ],
                      ),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x140E1712),
                          blurRadius: 30,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 118,
                          height: 118,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.14,
                                ),
                                blurRadius: 30,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.spa_rounded,
                            size: 60,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer.withValues(
                              alpha: 0.58,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '环境初始化',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.appName,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppConstants.appTagline,
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage == null) ...<Widget>[
                          const CircularProgressIndicator.adaptive(),
                          const SizedBox(height: 18),
                          Text(
                            AppCopy.splashBootstrapping,
                            style: textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ] else ...<Widget>[
                          Text(
                            _errorMessage!,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                              });
                              _bootstrap();
                            },
                            child: const Text(AppCopy.splashRetry),
                          ),
                        ],
                      ],
                    ),
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

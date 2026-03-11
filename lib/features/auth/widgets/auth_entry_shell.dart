import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';
import 'package:sickandflutter/shared/widgets/reveal_on_mount.dart';

/// 认证入口页通用壳层，统一背景、页头和响应式双栏布局。
class AuthEntryShell extends StatelessWidget {
  /// 创建认证入口页壳层。
  const AuthEntryShell({
    required this.overviewPanel,
    required this.formPanel,
    this.onBackPressed,
    super.key,
  });

  /// 左侧说明面板。
  final Widget overviewPanel;

  /// 右侧表单面板。
  final Widget formPanel;

  /// 返回系统总览回调。
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AppBackdrop(
              baseGradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  colorScheme.surface,
                  colorScheme.surfaceContainerLowest,
                  colorScheme.surfaceContainerLow,
                ],
              ),
              orbs: const <BackdropOrbData>[
                BackdropOrbData(
                  alignment: Alignment(-1.0, -0.92),
                  size: 340,
                  color: Color(0x1626A497),
                ),
                BackdropOrbData(
                  alignment: Alignment(1.08, -0.24),
                  size: 280,
                  color: Color(0x14B68B63),
                ),
                BackdropOrbData(
                  alignment: Alignment(0.88, 1.02),
                  size: 240,
                  color: Color(0x105D7E92),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  children: <Widget>[
                    RevealOnMount(
                      child: _AuthEntryHeader(onBackPressed: onBackPressed),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 980;

                        if (isCompact) {
                          return Column(
                            children: <Widget>[
                              RevealOnMount(
                                delay: const Duration(milliseconds: 80),
                                child: formPanel,
                              ),
                              const SizedBox(height: 20),
                              RevealOnMount(
                                delay: const Duration(milliseconds: 160),
                                child: overviewPanel,
                              ),
                            ],
                          );
                        }

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                flex: 11,
                                child: RevealOnMount(
                                  delay: const Duration(milliseconds: 90),
                                  child: overviewPanel,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 9,
                                child: RevealOnMount(
                                  delay: const Duration(milliseconds: 160),
                                  child: formPanel,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthEntryHeader extends StatelessWidget {
  const _AuthEntryHeader({required this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                colorScheme.surfaceContainerLowest.withValues(alpha: 0.98),
                colorScheme.surface.withValues(alpha: 0.96),
                colorScheme.surfaceContainerLow.withValues(alpha: 0.92),
              ],
            ),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 760;
              final brand = Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.spa_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          AppConstants.appName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '石斛监测后台登录入口',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final actions = Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(
                        alpha: 0.76,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '登录与会话',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onBackPressed,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('返回系统概览'),
                  ),
                ],
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    brand,
                    const SizedBox(height: 16),
                    actions,
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: brand),
                  const SizedBox(width: 16),
                  Flexible(child: actions),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

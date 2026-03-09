import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';

/// 认证入口页通用壳层，统一背景、标题区和响应式双栏布局。
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

  /// 返回预览页回调。
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AppBackdrop(
              baseGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colorScheme.surface,
                  colorScheme.surfaceContainerLowest,
                  colorScheme.surfaceContainer,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  children: <Widget>[
                    _AuthEntryHeader(onBackPressed: onBackPressed),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 920;

                        if (isCompact) {
                          return Column(
                            children: <Widget>[
                              formPanel,
                              const SizedBox(height: 20),
                              overviewPanel,
                            ],
                          );
                        }

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(flex: 11, child: overviewPanel),
                              const SizedBox(width: 20),
                              Expanded(flex: 9, child: formPanel),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;
          final brand = Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.spa_rounded,
                  color: colorScheme.primary,
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
                      'Material 3 设备主控台认证入口',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final backButton = FilledButton.tonalIcon(
            onPressed: onBackPressed,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('返回介绍主页'),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[brand, const SizedBox(height: 16), backButton],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: brand),
              const SizedBox(width: 16),
              backButton,
            ],
          );
        },
      ),
    );
  }
}

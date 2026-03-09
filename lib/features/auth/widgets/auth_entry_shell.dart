import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';

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
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              colorScheme.surfaceContainerLowest,
              colorScheme.surface,
              colorScheme.surfaceContainerLow,
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _AuthEntryBackdrop()),
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
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.spa_rounded,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Material 3 设备主控台认证入口',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          FilledButton.tonalIcon(
            onPressed: onBackPressed,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('返回介绍主页'),
          ),
        ],
      ),
    );
  }
}

class _AuthEntryBackdrop extends StatelessWidget {
  const _AuthEntryBackdrop();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned(
            left: -80,
            top: -60,
            child: _BackdropBlob(
              size: 240,
              color: colorScheme.primaryContainer.withValues(alpha: 0.55),
            ),
          ),
          Positioned(
            right: -40,
            top: 120,
            child: _BackdropBlob(
              size: 220,
              color: colorScheme.secondaryContainer.withValues(alpha: 0.48),
            ),
          ),
          Positioned(
            right: 80,
            bottom: -20,
            child: _BackdropBlob(
              size: 180,
              color: colorScheme.tertiaryContainer.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropBlob extends StatelessWidget {
  const _BackdropBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(color: color, blurRadius: 90, spreadRadius: 12),
        ],
      ),
    );
  }
}

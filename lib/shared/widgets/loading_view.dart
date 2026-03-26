import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';

/// 通用加载视图，可用于全页或局部加载状态。
class LoadingView extends StatelessWidget {
  /// 创建加载视图。
  const LoadingView({this.message = AppCopy.loading, super.key});

  /// 加载提示文案。
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Semantics(
          liveRegion: true,
          label: message,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppPalette.blendOnPaper(
                    AppPalette.softPine,
                    opacity: 0.1,
                    base: colorScheme.surfaceBright,
                  ).withValues(alpha: 0.995),
                  AppPalette.blendOnPaper(
                    AppPalette.mistMint,
                    opacity: 0.12,
                    base: colorScheme.surfaceContainerLow,
                  ).withValues(alpha: 0.97),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.86),
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x0D131815),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

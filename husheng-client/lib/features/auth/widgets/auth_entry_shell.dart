import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';
import 'package:sickandflutter/shared/widgets/app_brand_mark.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';
import 'package:sickandflutter/shared/widgets/workspace_layout.dart';

/// 认证入口页通用壳层，统一背景与跨端布局。
class AuthEntryShell extends StatelessWidget {
  /// 创建认证入口页壳层。
  const AuthEntryShell({
    required this.formPanel,
    this.overviewPanel,
    this.onBackPressed,
    super.key,
  });

  /// 辅助说明面板。
  final Widget? overviewPanel;

  /// 表单面板。
  final Widget formPanel;

  /// 返回帮助页。
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useSplitLayout = width >= 1120;
    final compact = width < 720;
    final horizontalPadding = width < 480
        ? 16.0
        : resolveWorkspaceHorizontalPadding(width);

    return Scaffold(
      backgroundColor: AppPalette.paperSnow,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: AppBackdrop(
              baseGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppPalette.paperSnow,
                  AppPalette.paperWarm,
                  AppPalette.paper,
                ],
              ),
              orbs: <BackdropOrbData>[],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  compact ? 18 : 24,
                  horizontalPadding,
                  24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: useSplitLayout
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _AuthTopBar(
                              onBackPressed: onBackPressed,
                              compact: false,
                            ),
                            const SizedBox(height: 28),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Expanded(
                                  flex: 12,
                                  child: _DesktopIntroPanel(),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 11,
                                  child: _AuthFormColumn(
                                    compact: false,
                                    formPanel: formPanel,
                                    overviewPanel: overviewPanel,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _MobileIntroPanel(onBackPressed: onBackPressed),
                            const SizedBox(height: 18),
                            _AuthFormColumn(
                              compact: true,
                              formPanel: formPanel,
                              overviewPanel: overviewPanel,
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

class _DesktopIntroPanel extends StatelessWidget {
  const _DesktopIntroPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _IntroStage(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '登录后默认进入值守台',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '值守工作台从这里开始。',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                height: 1.16,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '登录成功后默认进入值守台；需要看总览、视频或设置时，再通过同一套导航切换，桌面和手机保持一致。',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.62,
              ),
            ),
            const SizedBox(height: 30),
            _IntroFocusPanel(
              title: '值守台',
              description: '登录成功后默认进入，先确认设备状态、最近同步和 LED 补光。',
              tags: const <String>['设备状态', '最近同步', 'LED 补光'],
            ),
            const SizedBox(height: 18),
            const _IntroListDivider(),
            const SizedBox(height: 18),
            const _IntroListItem(
              icon: Icons.dashboard_outlined,
              title: '总览',
              description: '统一查看当前设备摘要、常用入口和环境速览。',
            ),
            const SizedBox(height: 16),
            const _IntroListDivider(),
            const SizedBox(height: 16),
            const _IntroListItem(
              icon: Icons.videocam_rounded,
              title: '视频',
              description: '需要确认现场时，直接打开当前可查看的画面。',
            ),
            const SizedBox(height: 16),
            const _IntroListDivider(),
            const SizedBox(height: 16),
            const _IntroListItem(
              icon: Icons.settings_rounded,
              title: '我的',
              description: '账号、本机偏好和使用帮助都集中在这里。',
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroStage extends StatelessWidget {
  const _IntroStage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FeatureHeroCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 34,
      accentColor: AppPalette.softPine,
      child: child,
    );
  }
}

class _MobileIntroPanel extends StatelessWidget {
  const _MobileIntroPanel({required this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _AuthTopBar(onBackPressed: onBackPressed, compact: true),
        const SizedBox(height: 14),
        const _MobileRouteHint(),
      ],
    );
  }
}

class _MobileRouteHint extends StatelessWidget {
  const _MobileRouteHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureInsetPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      borderRadius: 24,
      accentColor: AppPalette.mistMint,
      showHighlightLine: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppPalette.softPine.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.monitor_heart_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '默认进入值守台',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '登录后直接进入，可从底部切到总览、视频和我的。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTopBar extends StatelessWidget {
  const _AuthTopBar({required this.onBackPressed, required this.compact});

  final VoidCallback? onBackPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AppBrandBadge(size: compact ? 52 : 60),
        SizedBox(width: compact ? 14 : 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppConstants.appName,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '石斛培育环境值守',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (onBackPressed != null)
          compact
              ? IconButton.outlined(
                  onPressed: onBackPressed,
                  icon: const Icon(Icons.help_outline_rounded),
                  tooltip: '使用帮助',
                )
              : OutlinedButton.icon(
                  onPressed: onBackPressed,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('使用帮助'),
                ),
      ],
    );
  }
}

class _AuthFormColumn extends StatelessWidget {
  const _AuthFormColumn({
    required this.compact,
    required this.formPanel,
    required this.overviewPanel,
  });

  final bool compact;
  final Widget formPanel;
  final Widget? overviewPanel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _FormStage(compact: compact, child: formPanel),
        if (overviewPanel != null) ...<Widget>[
          const SizedBox(height: 16),
          _OverviewStage(compact: compact, child: overviewPanel!),
        ],
      ],
    );
  }
}

class _FormStage extends StatelessWidget {
  const _FormStage({required this.child, required this.compact});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return FeatureHeroCard(
      padding: EdgeInsets.all(compact ? 22 : 28),
      borderRadius: compact ? 28 : 34,
      accentColor: AppPalette.mistMint,
      child: child,
    );
  }
}

class _OverviewStage extends StatelessWidget {
  const _OverviewStage({required this.child, required this.compact});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return FeatureInsetPanel(
      padding: EdgeInsets.all(compact ? 16 : 18),
      borderRadius: compact ? 24 : 28,
      accentColor: AppPalette.linenOlive,
      child: child,
    );
  }
}

class _IntroFocusPanel extends StatelessWidget {
  const _IntroFocusPanel({
    required this.title,
    required this.description,
    required this.tags,
  });

  final String title;
  final String description;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      accentColor: AppPalette.mistMint,
      showHighlightLine: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '默认进入',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.58,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags
                    .map((tag) => _IntroTag(label: tag))
                    .toList(growable: false),
              ),
            ],
          );

          final iconBadge = Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppPalette.softPine.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.monitor_heart_rounded,
              color: colorScheme.primary,
              size: 26,
            ),
          );

          if (constraints.maxWidth < 440) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                iconBadge,
                const SizedBox(height: 14),
                content,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              iconBadge,
              const SizedBox(width: 16),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}

class _IntroTag extends StatelessWidget {
  const _IntroTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.softPine,
          opacity: 0.12,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.softPine.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _IntroListItem extends StatelessWidget {
  const _IntroListItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppPalette.softPine.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.56,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IntroListDivider extends StatelessWidget {
  const _IntroListDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.72),
    );
  }
}

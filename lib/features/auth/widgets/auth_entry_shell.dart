import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';
import 'package:sickandflutter/shared/widgets/app_brand_mark.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

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
        : (useSplitLayout ? 28.0 : 20.0);

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
                  AppPalette.paperMist,
                  AppPalette.paper,
                ],
              ),
              orbs: <BackdropOrbData>[
                BackdropOrbData(
                  alignment: Alignment(-1.0, -0.9),
                  size: 260,
                  color: Color(0x10518463),
                ),
                BackdropOrbData(
                  alignment: Alignment(1.02, -0.12),
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
                  horizontalPadding,
                  compact ? 18 : 24,
                  horizontalPadding,
                  24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1220),
                  child: useSplitLayout
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 10,
                              child: _DesktopIntroPanel(
                                onBackPressed: onBackPressed,
                              ),
                            ),
                            const SizedBox(width: 28),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 462),
                              child: _AuthFormColumn(
                                compact: false,
                                formPanel: formPanel,
                                overviewPanel: overviewPanel,
                              ),
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
  const _DesktopIntroPanel({required this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _AuthTopBar(onBackPressed: onBackPressed, compact: false),
        const SizedBox(height: 44),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '把状态、画面和设置收进一块安静的工作台。',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1.16,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '先看当前状态，再决定进入值守、视频还是账号设置。桌面和手机都保持同一套阅读顺序。',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.62,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: FeatureHeroCard(
            padding: const EdgeInsets.all(22),
            borderRadius: 30,
            accentColor: AppPalette.softLavender,
            showPaletteBands: false,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _IntroListItem(
                  icon: Icons.monitor_heart_rounded,
                  title: '先看状态',
                  description: '进入后先确认当前判断、最近同步和补光状态。',
                ),
                SizedBox(height: 16),
                _IntroListDivider(),
                SizedBox(height: 16),
                _IntroListItem(
                  icon: Icons.videocam_rounded,
                  title: '再看画面',
                  description: '需要确认现场时，再直接打开当前可查看的画面。',
                ),
                SizedBox(height: 16),
                _IntroListDivider(),
                SizedBox(height: 16),
                _IntroListItem(
                  icon: Icons.settings_rounded,
                  title: '设置集中管理',
                  description: '账号、本机偏好和使用说明都集中在一个地方。',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileIntroPanel extends StatelessWidget {
  const _MobileIntroPanel({required this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _AuthTopBar(onBackPressed: onBackPressed, compact: true),
        const SizedBox(height: 18),
        Text(
          '把状态、画面和设置收进同一块界面。',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '输入账号和密码后就能继续使用，手机和电脑保持同一套阅读顺序。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.58,
          ),
        ),
      ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 22 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceBright.withValues(alpha: 0.995),
            colorScheme.surfaceContainerLow.withValues(alpha: 0.97),
            AppPalette.paperMist.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(compact ? 28 : 34),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.84),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x120F1712),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(compact ? 24 : 28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.84),
        ),
      ),
      child: child,
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

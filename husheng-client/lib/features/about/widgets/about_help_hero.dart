import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';
import 'package:sickandflutter/shared/widgets/workspace_layout.dart';

/// 帮助页顶部导览区。
class AboutHelpHero extends StatelessWidget {
  /// 创建帮助页顶部导览区。
  const AboutHelpHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureHeroCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 28,
      accentColor: AppPalette.softLavender,
      child: WorkspaceTwoPane(
        breakpoint: 980,
        gap: 16,
        stackSpacing: 16,
        secondaryWidthFactor: 0.32,
        primary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '常用功能都在这四个入口里',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '需要处理设备时直接进值守，需要看画面时直接进视频；账号和设置统一放在我的里。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.56,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const <Widget>[
                _AboutHeroPill(label: '入口顺序', value: '总览 / 值守 / 视频 / 我的'),
                _AboutHeroPill(label: '帮助口径', value: '只保留查看重点和常用操作'),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                AboutHeroBadge(
                  index: '01',
                  title: '总览',
                  description: '先看当前状态',
                  accentColor: AppPalette.softPine,
                ),
                AboutHeroBadge(
                  index: '02',
                  title: '值守',
                  description: '实时处理设备情况',
                  accentColor: AppPalette.mistMint,
                ),
                AboutHeroBadge(
                  index: '03',
                  title: '视频',
                  description: '直接查看当前画面',
                  accentColor: AppPalette.linenOlive,
                ),
                AboutHeroBadge(
                  index: '04',
                  title: '我的',
                  description: '管理账号和本机设置',
                  accentColor: AppPalette.softLavender,
                ),
              ],
            ),
          ],
        ),
        secondary: const AboutGuideMonitor(),
      ),
    );
  }
}

/// 帮助页 Hero 入口摘要项。
class AboutHeroBadge extends StatelessWidget {
  /// 创建帮助页 Hero 入口摘要项。
  const AboutHeroBadge({
    required this.index,
    required this.title,
    required this.description,
    required this.accentColor,
    super.key,
  });

  /// 序号。
  final String index;

  /// 标题。
  final String title;

  /// 描述。
  final String description;

  /// 强调色。
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 148),
      child: FeatureInsetPanel(
        padding: const EdgeInsets.all(14),
        borderRadius: 22,
        accentColor: accentColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                index,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 帮助页查看顺序示意面板。
class AboutGuideMonitor extends StatelessWidget {
  /// 创建帮助页查看顺序示意面板。
  const AboutGuideMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      accentColor: AppPalette.softPine,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '查看顺序',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          const _GuideStep(
            index: '01',
            title: '先看总览',
            description: '先读当前状态和快捷入口，再决定下一步。',
          ),
          const SizedBox(height: 12),
          const _GuideStep(
            index: '02',
            title: '需要处理时进值守',
            description: '进入值守后看结论、指标、补光和处理建议。',
          ),
          const SizedBox(height: 12),
          const _GuideStep(
            index: '03',
            title: '需要画面时进视频',
            description: '视频页先判断在线，再决定是否直接打开。',
          ),
          const SizedBox(height: 12),
          const _GuideStep(
            index: '04',
            title: '最后回到我的',
            description: '账号、本机偏好和帮助都在这里收口。',
          ),
        ],
      ),
    );
  }
}

class _AboutHeroPill extends StatelessWidget {
  const _AboutHeroPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.linenOlive,
          opacity: 0.12,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.linenOlive.withValues(alpha: 0.2)),
      ),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          children: <InlineSpan>[
            TextSpan(text: '$label  '),
            TextSpan(
              text: value,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.index,
    required this.title,
    required this.description,
  });

  final String index;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      accentColor: AppPalette.softPine,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              index,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.48,
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

import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 帮助页顶部导览区。
class AboutHelpHero extends StatelessWidget {
  /// 创建帮助页顶部导览区。
  const AboutHelpHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureHeroCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 36,
      accentColor: AppPalette.softLavender,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final badges = Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const <Widget>[
              AboutHeroBadge(index: '01', title: '总览', description: '先看当前状态'),
              AboutHeroBadge(index: '02', title: '值守', description: '实时处理设备情况'),
              AboutHeroBadge(index: '03', title: '视频', description: '直接查看当前画面'),
              AboutHeroBadge(
                index: '04',
                title: '我的',
                description: '管理账号和本机设置',
              ),
            ],
          );

          final lead = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '常用功能都在这四个入口里',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '需要处理设备时直接进值守，需要看画面时直接进视频；账号和设置统一放在我的里。',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.58,
                ),
              ),
              const SizedBox(height: 18),
              FeatureInsetPanel(
                padding: const EdgeInsets.all(18),
                borderRadius: 26,
                accentColor: AppPalette.mistMint,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _LeadPoint(
                      icon: Icons.route_rounded,
                      title: '入口顺序固定',
                      description: '总览、值守、视频、我的保持同一顺序，更容易记住。',
                    ),
                    SizedBox(height: 14),
                    _LeadPoint(
                      icon: Icons.visibility_rounded,
                      title: '只看关键信息',
                      description: '帮助页只解释查看重点和常用操作。',
                    ),
                  ],
                ),
              ),
            ],
          );

          const monitor = AboutGuideMonitor();

          if (constraints.maxWidth < 980) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                lead,
                const SizedBox(height: 20),
                monitor,
                const SizedBox(height: 18),
                badges,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[lead, const SizedBox(height: 18), badges],
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(flex: 7, child: monitor),
            ],
          );
        },
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
    super.key,
  });

  /// 序号。
  final String index;

  /// 标题。
  final String title;

  /// 描述。
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainerLowest.withValues(alpha: 0.92),
            colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            index,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
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
              height: 1.5,
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(20),
      borderRadius: 28,
      accentColor: AppPalette.softPine,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '查看顺序',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
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

class _LeadPoint extends StatelessWidget {
  const _LeadPoint({
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppPalette.softPine.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colorScheme.primary),
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
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.52,
                ),
              ),
            ],
          ),
        ),
      ],
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.52,
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

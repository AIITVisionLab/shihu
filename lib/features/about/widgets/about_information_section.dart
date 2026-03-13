import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 帮助页信息口径说明区。
class AboutInformationSection extends StatelessWidget {
  /// 创建帮助页信息口径说明区。
  const AboutInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '你会看到的信息',
      subtitle: '只保留日常判断最常用的几类信息。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final items = const <Widget>[
            AboutInfoBlock(
              title: '设备状态',
              description: '用来判断当前是否正常，是否需要马上去值守处理。',
              accentColor: AppPalette.softPine,
            ),
            AboutInfoBlock(
              title: '环境指标',
              description: '温度、湿度、光照和 MQ2 放在值守页里集中查看。',
              accentColor: AppPalette.mistMint,
            ),
            AboutInfoBlock(
              title: '实时画面',
              description: '视频页只告诉你画面能不能看，在线时直接打开即可。',
              accentColor: AppPalette.linenOlive,
            ),
            AboutInfoBlock(
              title: '账号与本机设置',
              description: '退出登录、清除记住账号和恢复默认都放在“我的”里。',
              accentColor: AppPalette.softLavender,
            ),
          ];

          if (constraints.maxWidth < 900) {
            return Column(
              children: <Widget>[
                for (int index = 0; index < items.length; index++) ...<Widget>[
                  items[index],
                  if (index != items.length - 1) const SizedBox(height: 14),
                ],
              ],
            );
          }

          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: items
                .map(
                  (item) => SizedBox(
                    width: (constraints.maxWidth - 14) / 2,
                    child: item,
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

/// 帮助页信息卡片。
class AboutInfoBlock extends StatelessWidget {
  /// 创建帮助页信息卡片。
  const AboutInfoBlock({
    required this.title,
    required this.description,
    required this.accentColor,
    super.key,
  });

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

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34,
            height: 3,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.58,
            ),
          ),
        ],
      ),
    );
  }
}

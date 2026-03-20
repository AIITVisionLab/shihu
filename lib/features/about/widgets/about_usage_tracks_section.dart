import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 帮助页主路径轨道说明区。
class AboutUsageTracksSection extends StatelessWidget {
  /// 创建帮助页主路径轨道说明区。
  const AboutUsageTracksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '软件怎么用',
      subtitle: '把常用页面收成固定顺序，平时照着这个顺序看就够了。',
      accentColor: AppPalette.softLavender,
      headerIcon: Icons.route_rounded,
      headerTag: '固定顺序',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final tiles = const <Widget>[
                AboutTrackTile(
                  index: '01',
                  icon: Icons.dashboard_rounded,
                  title: '总览',
                  description: '先看当前状态、最近同步和快捷入口，再决定下一步去哪。',
                  accentColor: AppPalette.softPine,
                ),
                AboutTrackTile(
                  index: '02',
                  icon: Icons.monitor_heart_rounded,
                  title: '值守',
                  description: '需要处理设备时就进这里，实时看状态、看指标、调补光。',
                  accentColor: AppPalette.mistMint,
                ),
                AboutTrackTile(
                  index: '03',
                  icon: Icons.videocam_rounded,
                  title: '视频',
                  description: '需要看画面时直接进这里，先看是否在线，再决定是否打开。',
                  accentColor: AppPalette.linenOlive,
                ),
                AboutTrackTile(
                  index: '04',
                  icon: Icons.settings_rounded,
                  title: '我的',
                  description: '这里只放账号、本机偏好和帮助，不把无关操作混进来。',
                  accentColor: AppPalette.softLavender,
                ),
              ];

              if (constraints.maxWidth < 900) {
                return Column(
                  children: <Widget>[
                    for (
                      int index = 0;
                      index < tiles.length;
                      index++
                    ) ...<Widget>[
                      tiles[index],
                      if (index != tiles.length - 1) const SizedBox(height: 14),
                    ],
                  ],
                );
              }

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: tiles
                    .map(
                      (tile) => SizedBox(
                        width: (constraints.maxWidth - 14) / 2,
                        child: tile,
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 18),
          Text(
            '平时重点看这些信息',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final items = const <Widget>[
                _AboutFocusInfo(
                  title: '设备状态',
                  description: '用来判断当前是否正常，是否需要马上去值守处理。',
                  accentColor: AppPalette.softPine,
                ),
                _AboutFocusInfo(
                  title: '环境指标',
                  description: '温度、湿度、光照和 MQ2 放在值守页里集中查看。',
                  accentColor: AppPalette.mistMint,
                ),
                _AboutFocusInfo(
                  title: '实时画面',
                  description: '视频页优先直接看主画面，其它画面按需切换。',
                  accentColor: AppPalette.linenOlive,
                ),
                _AboutFocusInfo(
                  title: '账号与本机设置',
                  description: '退出登录、清除记住账号和恢复默认都放在“我的”里。',
                  accentColor: AppPalette.softLavender,
                ),
              ];

              if (constraints.maxWidth < 900) {
                return Column(
                  children: <Widget>[
                    for (
                      int index = 0;
                      index < items.length;
                      index++
                    ) ...<Widget>[
                      items[index],
                      if (index != items.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: item,
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 帮助页主路径轨道项。
class AboutTrackTile extends StatelessWidget {
  /// 创建帮助页主路径轨道项。
  const AboutTrackTile({
    required this.index,
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    super.key,
  });

  /// 序号。
  final String index;

  /// 图标。
  final IconData icon;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.22),
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
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colorScheme.onSurface),
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
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.58,
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

class _AboutFocusInfo extends StatelessWidget {
  const _AboutFocusInfo({
    required this.title,
    required this.description,
    required this.accentColor,
  });

  final String title;
  final String description;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.54,
            ),
          ),
        ],
      ),
    );
  }
}

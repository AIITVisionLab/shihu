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
      child: LayoutBuilder(
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
                for (int index = 0; index < tiles.length; index++) ...<Widget>[
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              index,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: colorScheme.onPrimaryContainer),
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

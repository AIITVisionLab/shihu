import 'package:flutter/material.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 视频页空状态卡片。
class VideoEmptyCard extends StatelessWidget {
  /// 创建视频页空状态卡片。
  const VideoEmptyCard({required this.onRetry, super.key});

  /// 重试回调。
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '当前还没有可查看画面',
      subtitle: '画面准备好后会在这里出现。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('先继续值守或稍后回来刷新。'),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重新加载'),
          ),
        ],
      ),
    );
  }
}

/// 视频页错误状态卡片。
class VideoErrorCard extends StatelessWidget {
  /// 创建视频页错误状态卡片。
  const VideoErrorCard({required this.onRetry, super.key});

  /// 重试回调。
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '暂时无法读取画面',
      subtitle: '请检查网络后重试。',
      child: FilledButton.tonalIcon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('重新加载'),
      ),
    );
  }
}

/// 视频页查看提示卡片。
class VideoTipsCard extends StatelessWidget {
  /// 创建视频页查看提示卡片。
  const VideoTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '查看提示',
      subtitle: '只保留最常用的判断方法。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final items = const <Widget>[
            VideoTipRow(title: '在线', description: '说明当前画面已接通，可以直接打开。'),
            VideoTipRow(title: '离线', description: '说明当前暂未连通，稍后刷新即可。'),
            VideoTipRow(title: '备用入口', description: '主画面打不开时，再尝试备用入口。'),
          ];

          if (constraints.maxWidth < 860) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                VideoTipRow(title: '在线', description: '说明当前画面已接通，可以直接打开。'),
                SizedBox(height: 14),
                VideoTipRow(title: '离线', description: '说明当前暂未连通，稍后刷新即可。'),
                SizedBox(height: 14),
                VideoTipRow(title: '备用入口', description: '主画面打不开时，再尝试备用入口。'),
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: items[0]),
              const SizedBox(width: 14),
              Expanded(child: items[1]),
              const SizedBox(width: 14),
              Expanded(child: items[2]),
            ],
          );
        },
      ),
    );
  }
}

/// 视频页查看提示项。
class VideoTipRow extends StatelessWidget {
  /// 创建视频页查看提示项。
  const VideoTipRow({
    required this.title,
    required this.description,
    super.key,
  });

  /// 标题。
  final String title;

  /// 描述。
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      accentColor: colorScheme.tertiary,
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
              height: 1.56,
            ),
          ),
        ],
      ),
    );
  }
}

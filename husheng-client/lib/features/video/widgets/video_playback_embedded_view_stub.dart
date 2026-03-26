import 'package:flutter/widgets.dart';

/// 非 Web 平台下的视频内嵌占位实现。
class VideoPlaybackEmbeddedView extends StatelessWidget {
  /// 创建视频内嵌占位实现。
  const VideoPlaybackEmbeddedView({
    required this.url,
    this.reloadToken = 0,
    super.key,
  });

  /// 当前播放地址。
  final String url;

  /// 当前重载计数。
  final int reloadToken;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}

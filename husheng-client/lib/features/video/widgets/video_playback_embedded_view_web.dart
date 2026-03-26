import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Web 平台下的视频内嵌实现，直接使用 `iframe` 承接跨源播放页。
class VideoPlaybackEmbeddedView extends StatefulWidget {
  /// 创建 Web 平台视频内嵌实现。
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
  State<VideoPlaybackEmbeddedView> createState() =>
      _VideoPlaybackEmbeddedViewState();
}

class _VideoPlaybackEmbeddedViewState extends State<VideoPlaybackEmbeddedView> {
  static int _nextViewTypeId = 0;

  late String _viewType;

  @override
  void initState() {
    super.initState();
    _registerViewFactory();
  }

  @override
  void didUpdateWidget(covariant VideoPlaybackEmbeddedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.reloadToken != widget.reloadToken) {
      _registerViewFactory();
    }
  }

  void _registerViewFactory() {
    final viewType = 'video-playback-embedded-${_nextViewTypeId++}';
    final url = widget.url;

    ui_web.platformViewRegistry.registerViewFactory(viewType, (viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = url
        ..allow = 'autoplay; fullscreen; picture-in-picture'
        ..allowFullscreen = true
        ..loading = 'eager'
        ..referrerPolicy = 'strict-origin-when-cross-origin'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = '0'
        ..style.display = 'block'
        ..style.backgroundColor = '#000000';
      return iframe;
    });

    _viewType = viewType;
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}

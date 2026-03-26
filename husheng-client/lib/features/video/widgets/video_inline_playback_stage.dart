import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/features/video/video_playback_support.dart';
import 'package:sickandflutter/features/video/video_stream_info.dart';
import 'package:sickandflutter/features/video/widgets/video_playback_embedded_view.dart';
import 'package:sickandflutter/features/video/widgets/video_playback_native_view.dart';
import 'package:sickandflutter/features/video/widgets/video_view_primitives.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/widgets/loading_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 视频页内联播放舞台，直接在主画面卡片里承接视频流。
class VideoInlinePlaybackStage extends StatefulWidget {
  /// 创建视频页内联播放舞台。
  const VideoInlinePlaybackStage({
    required this.stream,
    this.platformTypeOverride,
    super.key,
  });

  /// 当前画面信息。
  final VideoStreamInfo stream;

  /// 仅供测试时覆盖平台判断。
  final PlatformType? platformTypeOverride;

  @override
  State<VideoInlinePlaybackStage> createState() =>
      _VideoInlinePlaybackStageState();
}

class _VideoInlinePlaybackStageState extends State<VideoInlinePlaybackStage> {
  WebViewController? _controller;
  Uri? _playbackUri;
  int _progress = 0;
  int _webReloadToken = 0;
  int _directReloadToken = 0;
  bool _isLoading = true;
  String? _errorMessage;

  PlatformType get _platformType =>
      widget.platformTypeOverride ?? currentPlatformType();

  bool get _supportsEmbeddedPlayback =>
      supportsEmbeddedVideoPlaybackOnPlatform(_platformType);

  bool get _supportsDirectPlayback =>
      supportsDirectVideoPlaybackOnPlatform(_platformType);

  @override
  void initState() {
    super.initState();
    _initializePlayback();
  }

  @override
  void didUpdateWidget(covariant VideoInlinePlaybackStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream.playerUrl != widget.stream.playerUrl ||
        oldWidget.stream.gatewayPageUrl != widget.stream.gatewayPageUrl ||
        oldWidget.stream.streamId != widget.stream.streamId) {
      _initializePlayback();
    }
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  void _initializePlayback() {
    final primaryUrl = widget.stream.hasPlayerUrl
        ? widget.stream.playerUrl
        : widget.stream.gatewayPageUrl;
    final normalizedUrl = primaryUrl.trim();
    final uri = Uri.tryParse(normalizedUrl);
    if (normalizedUrl.isEmpty || uri == null || !uri.hasScheme) {
      setState(() {
        _playbackUri = null;
        _errorMessage = AppCopy.videoPlaybackAddressInvalid;
        _isLoading = false;
      });
      return;
    }

    _playbackUri = uri;

    if (!_supportsEmbeddedPlayback && !_supportsDirectPlayback) {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    if (_platformType == PlatformType.web || _supportsDirectPlayback) {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = true;
              _progress = 0;
              _errorMessage = null;
            });
          },
          onProgress: (progress) {
            if (!mounted) {
              return;
            }
            setState(() {
              _progress = progress;
            });
          },
          onPageFinished: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = false;
              _progress = 100;
            });
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != true || !mounted) {
              return;
            }
            setState(() {
              _isLoading = false;
              _errorMessage = error.description.trim().isEmpty
                  ? AppCopy.videoPlaybackLoadFailed
                  : error.description.trim();
            });
          },
        ),
      )
      ..loadRequest(uri);

    setState(() {
      _controller = controller;
      _isLoading = true;
      _errorMessage = null;
      _progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPrimaryAction =
        widget.stream.hasPlayerUrl || widget.stream.hasGatewayPageUrl;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppPalette.pineShadow.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: _buildPlaybackBody()),
              Positioned(
                top: 14,
                left: 14,
                child: VideoStatusChip(
                  label: widget.stream.available ? '在线直看' : '离线',
                  tone: widget.stream.available
                      ? VideoStatusChipTone.active
                      : VideoStatusChipTone.muted,
                ),
              ),
              if (hasPrimaryAction)
                Positioned(
                  top: 14,
                  right: 14,
                  child: _InlineRefreshButton(onPressed: _reload),
                ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xB8141714),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          widget.stream.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.stream.available ? '正在播放' : '等待恢复',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_progress > 0 && _progress < 100)
                Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(
                    value: _progress / 100,
                    minHeight: 3,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackBody() {
    if (_errorMessage != null) {
      return _InlineMessageView(
        icon: Icons.wifi_tethering_error_rounded,
        title: AppCopy.videoPlaybackLoadFailed,
        message: _errorMessage!,
      );
    }

    final playbackUri = _playbackUri;
    if (playbackUri == null) {
      return const _InlineMessageView(
        icon: Icons.link_off_rounded,
        title: AppCopy.videoPlaybackAddressInvalid,
        message: AppCopy.videoPlaybackAddressHint,
      );
    }

    if (_platformType == PlatformType.web) {
      return VideoPlaybackEmbeddedView(
        url: playbackUri.toString(),
        reloadToken: _webReloadToken,
      );
    }

    if (_supportsDirectPlayback) {
      final directPlaybackUrl = _resolveDirectPlaybackUrl();
      if (directPlaybackUrl == null) {
        return const _InlineMessageView(
          icon: Icons.link_off_rounded,
          title: AppCopy.videoPlaybackAddressInvalid,
          message: AppCopy.videoPlaybackAddressHint,
        );
      }
      return VideoPlaybackNativeView(
        key: ValueKey<int>(_directReloadToken),
        url: directPlaybackUrl,
      );
    }

    final controller = _controller;
    if (controller == null) {
      return const _InlineMessageView(
        icon: Icons.play_disabled_rounded,
        title: AppCopy.videoPlaybackLoading,
        message: '正在准备主画面...',
      );
    }

    return Stack(
      children: <Widget>[
        Positioned.fill(child: WebViewWidget(controller: controller)),
        if (_isLoading)
          const Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: Color(0x22000000),
                child: Center(
                  child: LoadingView(message: AppCopy.videoPlaybackLoading),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _reload() async {
    if (_platformType == PlatformType.web || _supportsDirectPlayback) {
      setState(() {
        if (_platformType == PlatformType.web) {
          _webReloadToken++;
        }
        if (_supportsDirectPlayback) {
          _directReloadToken++;
        }
        _errorMessage = null;
      });
      return;
    }

    final controller = _controller;
    if (controller == null) {
      _initializePlayback();
      return;
    }

    setState(() {
      _isLoading = true;
      _progress = 0;
      _errorMessage = null;
    });
    await controller.reload();
  }

  String? _resolveDirectPlaybackUrl() {
    final playbackUri = _playbackUri;
    if (playbackUri == null) {
      return null;
    }

    if (playbackUri.path.contains('/api/stream.mp4')) {
      return playbackUri.toString();
    }

    final streamId = widget.stream.streamId.trim();
    if (streamId.isEmpty) {
      return null;
    }

    final gatewayUri = Uri.tryParse(widget.stream.gatewayPageUrl.trim());
    final baseUri = gatewayUri?.hasScheme == true
        ? gatewayUri!
        : playbackUri.replace(path: _resolveGatewayPath(playbackUri, ''));

    return baseUri
        .replace(
          path: _resolveGatewayPath(baseUri, 'api/stream.mp4'),
          queryParameters: <String, String>{'src': streamId},
        )
        .toString();
  }

  String _resolveGatewayPath(Uri uri, String leaf) {
    final rawPath = uri.path.trim();
    String basePath = rawPath;
    if (basePath.endsWith('/')) {
      basePath = basePath.substring(0, basePath.length - 1);
    }
    if (basePath.endsWith('/stream.html')) {
      basePath = basePath.substring(0, basePath.length - '/stream.html'.length);
    }
    if (basePath.endsWith('/links.html')) {
      basePath = basePath.substring(0, basePath.length - '/links.html'.length);
    }
    if (leaf.isEmpty) {
      return basePath.isEmpty ? '/' : '$basePath/';
    }
    return basePath.isEmpty ? '/$leaf' : '$basePath/$leaf';
  }
}

class _InlineRefreshButton extends StatelessWidget {
  const _InlineRefreshButton({required this.onPressed});

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xB8141714),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () async {
          await onPressed();
        },
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _InlineMessageView extends StatelessWidget {
  const _InlineMessageView({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: const Color(0xFF101210),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  icon,
                  size: 40,
                  color: Colors.white.withValues(alpha: 0.86),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/core/utils/external_link_launcher.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/features/video/video_playback_support.dart';
import 'package:sickandflutter/features/video/widgets/video_playback_embedded_view.dart';
import 'package:sickandflutter/features/video/widgets/video_playback_native_view.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/widgets/loading_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 软件内视频播放页。
class VideoPlaybackPage extends StatefulWidget {
  /// 创建软件内视频播放页。
  const VideoPlaybackPage({
    required this.title,
    required this.initialUrl,
    required this.sourceLabel,
    this.streamId,
    this.gatewayPageUrl,
    this.platformTypeOverride,
    super.key,
  });

  /// 当前画面标题。
  final String title;

  /// 初始加载地址。
  final String initialUrl;

  /// 当前入口标签。
  final String sourceLabel;

  /// 当前流标识。
  final String? streamId;

  /// 当前网关页地址。
  final String? gatewayPageUrl;

  /// 仅供测试时覆盖平台判断。
  final PlatformType? platformTypeOverride;

  @override
  State<VideoPlaybackPage> createState() => _VideoPlaybackPageState();
}

class _VideoPlaybackPageState extends State<VideoPlaybackPage> {
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

  void _initializePlayback() {
    final normalizedUrl = widget.initialUrl.trim();
    final uri = Uri.tryParse(normalizedUrl);
    if (normalizedUrl.isEmpty || uri == null || !uri.hasScheme) {
      _errorMessage = AppCopy.videoPlaybackAddressInvalid;
      _isLoading = false;
      return;
    }

    _playbackUri = uri;

    if (!_supportsEmbeddedPlayback && !_supportsDirectPlayback) {
      _isLoading = false;
      return;
    }

    if (_platformType == PlatformType.web) {
      _isLoading = false;
      return;
    }

    if (_supportsDirectPlayback) {
      _isLoading = false;
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppPalette.paperSnow)
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

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppPalette.paperSnow,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppPalette.paperSnow,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.title),
            Text(
              widget.sourceLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          if (_playbackUri != null)
            IconButton(
              tooltip: '在新页打开',
              onPressed: _openExternally,
              icon: const Icon(Icons.open_in_new_rounded),
            ),
          if ((_supportsEmbeddedPlayback || _supportsDirectPlayback) &&
              _playbackUri != null)
            IconButton(
              tooltip: AppCopy.refresh,
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppPalette.outlineSoft),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: <Widget>[
                  _PlaybackHeader(
                    sourceLabel: widget.sourceLabel,
                    title: AppCopy.videoPlaybackInlineTitle,
                    subtitle: AppCopy.videoPlaybackInlineSubtitle,
                  ),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_supportsEmbeddedPlayback && !_supportsDirectPlayback) {
      return _PlaybackMessageView(
        icon: Icons.desktop_access_disabled_outlined,
        title: AppCopy.videoPlaybackUnsupportedTitle,
        message: AppCopy.videoPlaybackUnsupportedMessage,
      );
    }

    if (_errorMessage != null) {
      return _PlaybackMessageView(
        icon: Icons.wifi_tethering_error_rounded,
        title: AppCopy.videoPlaybackLoadFailed,
        message: _errorMessage!,
        actionLabel: AppCopy.retry,
        onAction: _reload,
      );
    }

    final controller = _controller;
    final playbackUri = _playbackUri;
    if (playbackUri == null) {
      return _PlaybackMessageView(
        icon: Icons.link_off_rounded,
        title: AppCopy.videoPlaybackAddressInvalid,
        message: AppCopy.videoPlaybackAddressHint,
      );
    }

    if (_platformType == PlatformType.web) {
      return ColoredBox(
        color: Colors.black,
        child: VideoPlaybackEmbeddedView(
          url: playbackUri.toString(),
          reloadToken: _webReloadToken,
        ),
      );
    }

    if (_supportsDirectPlayback) {
      final directPlaybackUrl = _resolveDirectPlaybackUrl();
      if (directPlaybackUrl == null) {
        return _PlaybackMessageView(
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

    if (controller == null) {
      return _PlaybackMessageView(
        icon: Icons.link_off_rounded,
        title: AppCopy.videoPlaybackAddressInvalid,
        message: AppCopy.videoPlaybackAddressHint,
      );
    }

    return Stack(
      children: <Widget>[
        Positioned.fill(child: WebViewWidget(controller: controller)),
        if (_isLoading)
          const Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: Color(0x20FFFFFF),
                child: Center(
                  child: LoadingView(message: AppCopy.videoPlaybackLoading),
                ),
              ),
            ),
          ),
        if (_progress > 0 && _progress < 100)
          Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(
              value: _progress / 100,
              minHeight: 3,
              backgroundColor: AppPalette.paperMist,
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
      return;
    }

    setState(() {
      _isLoading = true;
      _progress = 0;
      _errorMessage = null;
    });
    await controller.reload();
  }

  Future<void> _openExternally() async {
    final playbackUri = _playbackUri;
    if (playbackUri == null) {
      return;
    }

    final opened = await openExternalUrl(playbackUri.toString());
    if (!opened || !mounted) {
      return;
    }
  }

  String? _resolveDirectPlaybackUrl() {
    final playbackUri = _playbackUri;
    if (playbackUri == null) {
      return null;
    }

    if (playbackUri.path.contains('/api/stream.mp4')) {
      return playbackUri.toString();
    }

    final streamId = _resolveStreamId(playbackUri);
    final gatewayUri = _resolveGatewayUri(playbackUri);
    if (streamId == null || gatewayUri == null) {
      return null;
    }

    return gatewayUri
        .replace(
          path: _resolveGatewayPath(gatewayUri, 'api/stream.mp4'),
          queryParameters: <String, String>{'src': streamId},
        )
        .toString();
  }

  String? _resolveStreamId(Uri playbackUri) {
    final configuredStreamId = widget.streamId?.trim();
    if (configuredStreamId != null && configuredStreamId.isNotEmpty) {
      return configuredStreamId;
    }

    final queryStreamId = playbackUri.queryParameters['src']?.trim();
    if (queryStreamId != null && queryStreamId.isNotEmpty) {
      return queryStreamId;
    }

    return null;
  }

  Uri? _resolveGatewayUri(Uri playbackUri) {
    final configuredGateway = widget.gatewayPageUrl?.trim();
    if (configuredGateway != null && configuredGateway.isNotEmpty) {
      final gatewayUri = Uri.tryParse(configuredGateway);
      if (gatewayUri != null && gatewayUri.hasScheme) {
        return gatewayUri;
      }
    }

    return playbackUri.replace(
      path: _resolveGatewayPath(playbackUri, ''),
      query: null,
      fragment: null,
    );
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

class _PlaybackHeader extends StatelessWidget {
  const _PlaybackHeader({
    required this.sourceLabel,
    required this.title,
    required this.subtitle,
  });

  final String sourceLabel;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: AppPalette.paperWarm.withValues(alpha: 0.9),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppPalette.mistMint.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              sourceLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybackMessageView extends StatelessWidget {
  const _PlaybackMessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: AppPalette.mistMint.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: colorScheme.primary),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              if (actionLabel != null && onAction != null) ...<Widget>[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

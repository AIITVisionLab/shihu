import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/loading_view.dart';
import 'package:video_player/video_player.dart';

/// 桌面端软件内原生播放器视图。
class VideoPlaybackNativeView extends StatefulWidget {
  /// 创建桌面端原生播放器视图。
  const VideoPlaybackNativeView({required this.url, super.key});

  /// 直接媒体流地址。
  final String url;

  @override
  State<VideoPlaybackNativeView> createState() =>
      _VideoPlaybackNativeViewState();
}

class _VideoPlaybackNativeViewState extends State<VideoPlaybackNativeView> {
  VideoPlayerController? _controller;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant VideoPlaybackNativeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    _controller = null;
    controller?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    final normalizedUrl = widget.url.trim();
    final uri = Uri.tryParse(normalizedUrl);
    if (normalizedUrl.isEmpty || uri == null || !uri.hasScheme) {
      if (!mounted) {
        return;
      }
      setState(() {
        _controller = null;
        _isInitializing = false;
        _errorMessage = AppCopy.videoPlaybackAddressInvalid;
      });
      return;
    }

    final previousController = _controller;
    final nextController = VideoPlayerController.networkUrl(uri);

    if (mounted) {
      setState(() {
        _controller = nextController;
        _isInitializing = true;
        _errorMessage = null;
      });
    }

    try {
      await nextController.initialize();
      await nextController.play();
      await nextController.setVolume(0);
    } catch (error) {
      await nextController.dispose();
      if (!mounted) {
        return;
      }
      setState(() {
        if (identical(_controller, nextController)) {
          _controller = null;
        }
        _isInitializing = false;
        _errorMessage = error.toString().trim().isEmpty
            ? AppCopy.videoPlaybackLoadFailed
            : error.toString().trim();
      });
      await previousController?.dispose();
      return;
    }

    await previousController?.dispose();
    if (!mounted) {
      return;
    }
    setState(() {
      _isInitializing = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _NativePlaybackMessage(
        icon: Icons.wifi_tethering_error_rounded,
        title: AppCopy.videoPlaybackLoadFailed,
        message: _errorMessage!,
      );
    }

    final controller = _controller;
    if (_isInitializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return const ColoredBox(
        color: Color(0xFF000000),
        child: Center(
          child: LoadingView(message: AppCopy.videoPlaybackLoading),
        ),
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio <= 0
              ? 16 / 9
              : controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

class _NativePlaybackMessage extends StatelessWidget {
  const _NativePlaybackMessage({
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
    final colorScheme = theme.colorScheme;

    return ColoredBox(
      color: AppPalette.paperSnow,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 42, color: colorScheme.primary),
                const SizedBox(height: 14),
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
                    height: 1.55,
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

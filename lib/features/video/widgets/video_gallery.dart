import 'package:flutter/material.dart';
import 'package:sickandflutter/features/video/video_stream_info.dart';
import 'package:sickandflutter/features/video/widgets/video_stream_card.dart';

/// 视频页画面列表。
class VideoGallery extends StatelessWidget {
  /// 创建视频页画面列表。
  const VideoGallery({required this.streams, super.key});

  /// 当前画面列表。
  final List<VideoStreamInfo> streams;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 820) {
          return Column(
            children: <Widget>[
              for (int index = 0; index < streams.length; index++) ...<Widget>[
                VideoStreamCard(stream: streams[index]),
                if (index != streams.length - 1) const SizedBox(height: 16),
              ],
            ],
          );
        }

        final columns = constraints.maxWidth >= 1320 ? 3 : 2;
        final spacing = 16.0;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: streams
              .map(
                (stream) => SizedBox(
                  width: itemWidth,
                  child: VideoStreamCard(stream: stream),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/video/video_stream_repository.dart';
import 'package:sickandflutter/shared/models/video_stream_info.dart';

/// 视频中心筛选类型。
enum VideoHubFilter {
  /// 展示全部视频流。
  all,

  /// 仅展示当前在线的视频流。
  availableOnly,

  /// 仅展示已开启 AI 转发的视频流。
  aiForwardedOnly,
}

/// 视频中心筛选类型的显示信息。
extension VideoHubFilterX on VideoHubFilter {
  /// 面向界面的中文文案。
  String get label {
    switch (this) {
      case VideoHubFilter.all:
        return AppCopy.videoFilterAll;
      case VideoHubFilter.availableOnly:
        return AppCopy.videoFilterAvailable;
      case VideoHubFilter.aiForwardedOnly:
        return AppCopy.videoFilterAiForwarded;
    }
  }
}

/// 视频中心的查询状态。
class VideoHubQueryState {
  /// 创建视频中心查询状态。
  const VideoHubQueryState({
    this.keyword = '',
    this.filter = VideoHubFilter.all,
  });

  /// 当前检索关键词。
  final String keyword;

  /// 当前筛选条件。
  final VideoHubFilter filter;

  /// 返回带增量修改的新状态。
  VideoHubQueryState copyWith({String? keyword, VideoHubFilter? filter}) {
    return VideoHubQueryState(
      keyword: keyword ?? this.keyword,
      filter: filter ?? this.filter,
    );
  }
}

/// 视频中心查询状态控制器。
class VideoHubQueryController extends Notifier<VideoHubQueryState> {
  /// 构建默认查询状态。
  @override
  VideoHubQueryState build() => const VideoHubQueryState();

  /// 更新检索关键词。
  void setKeyword(String keyword) {
    state = state.copyWith(keyword: _normalizeKeyword(keyword));
  }

  /// 清空检索关键词。
  void clearKeyword() {
    state = state.copyWith(keyword: '');
  }

  /// 更新筛选条件。
  void setFilter(VideoHubFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// 重置全部筛选条件。
  void reset() {
    state = const VideoHubQueryState();
  }
}

/// 视频中心查询状态 Provider。
final videoHubQueryControllerProvider =
    NotifierProvider.autoDispose<VideoHubQueryController, VideoHubQueryState>(
      VideoHubQueryController.new,
    );

/// 经过检索和筛选后的视频流列表。
final filteredVideoStreamsProvider =
    Provider.autoDispose<AsyncValue<List<VideoStreamInfo>>>((ref) {
      final streamsAsync = ref.watch(videoStreamsProvider);
      final queryState = ref.watch(videoHubQueryControllerProvider);

      return streamsAsync.whenData(
        (streams) => streams
            .where((stream) => _matchesFilter(stream, queryState.filter))
            .where((stream) => _matchesKeyword(stream, queryState.keyword))
            .toList(growable: false),
      );
    });

String _normalizeKeyword(String keyword) => keyword.trim().toLowerCase();

bool _matchesFilter(VideoStreamInfo stream, VideoHubFilter filter) {
  switch (filter) {
    case VideoHubFilter.all:
      return true;
    case VideoHubFilter.availableOnly:
      return stream.available;
    case VideoHubFilter.aiForwardedOnly:
      return stream.aiResultForwarded;
  }
}

bool _matchesKeyword(VideoStreamInfo stream, String keyword) {
  final normalizedKeyword = _normalizeKeyword(keyword);
  if (normalizedKeyword.isEmpty) {
    return true;
  }

  final haystack = <String>[
    stream.streamId,
    stream.deviceId,
    stream.displayName,
    stream.publicHost,
    stream.preferredMode,
    stream.fallbackMode,
  ].join(' ').toLowerCase();
  return haystack.contains(normalizedKeyword);
}

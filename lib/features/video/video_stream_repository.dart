import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_client_factory.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/features/video/video_stream_info.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 视频流信息仓储。
class VideoStreamRepository {
  /// 创建视频流信息仓储。
  const VideoStreamRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 拉取视频流列表。
  Future<List<VideoStreamInfo>> fetchStreams() async {
    final payload = await _apiClient.getRaw('/api/video/streams');
    final data = _resolveEnvelopeData(payload);

    if (data is List) {
      final streams = data
          .map((item) => asStringMap(item))
          .whereType<Map<String, dynamic>>()
          .map(VideoStreamInfo.fromJson)
          .toList(growable: false);
      return _sortStreams(streams);
    }

    if (data is Map) {
      final streamJson = asStringMap(data);
      if (streamJson != null) {
        return <VideoStreamInfo>[VideoStreamInfo.fromJson(streamJson)];
      }
    }

    return const <VideoStreamInfo>[];
  }

  Object? _resolveEnvelopeData(Object? payload) {
    final json = asStringMap(payload);
    if (json == null) {
      return payload;
    }

    final hasEnvelope =
        json.containsKey('data') ||
        json.containsKey('code') ||
        json.containsKey('msg') ||
        json.containsKey('message');
    if (!hasEnvelope) {
      return payload;
    }

    final code = asInt(json['code'], fallback: 0);
    final message = _resolveMessage(json);
    if (code != 0 && code != 200) {
      throw ApiException(message: message.isEmpty ? '视频流列表获取失败。' : message);
    }

    return json['data'];
  }

  String _resolveMessage(Map<String, dynamic> json) {
    final msg = asString(json['msg']).trim();
    if (msg.isNotEmpty) {
      return msg;
    }
    return asString(json['message']).trim();
  }

  List<VideoStreamInfo> _sortStreams(List<VideoStreamInfo> streams) {
    final next = streams.toList();
    next.sort((left, right) {
      if (left.available != right.available) {
        return left.available ? -1 : 1;
      }
      return left.displayName.compareTo(right.displayName);
    });
    return next;
  }
}

/// 视频流信息仓储 Provider。
final videoStreamRepositoryProvider = Provider<VideoStreamRepository>((ref) {
  final settings = ref.watch(effectiveAppSettingsProvider);
  final apiClientFactory = ref.watch(apiClientFactoryProvider);

  return VideoStreamRepository(
    apiClient: apiClientFactory.createSessionClient(settings: settings),
  );
});

/// 视频流列表 Provider。
final videoStreamListProvider =
    FutureProvider.autoDispose<List<VideoStreamInfo>>((ref) async {
      final repository = ref.watch(videoStreamRepositoryProvider);
      return repository.fetchStreams();
    });

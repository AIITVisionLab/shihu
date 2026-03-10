import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/config/video_service_endpoint.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';
import 'package:sickandflutter/shared/models/video_stream_info.dart';

/// 视频流信息仓储。
///
/// 该仓储只负责读取 Java 视频服务提供的流元数据，
/// 不直接承接媒体字节流。
class VideoStreamRepository {
  /// 创建视频流仓储。
  const VideoStreamRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 拉取视频流列表。
  Future<List<VideoStreamInfo>> fetchStreams() async {
    final payload = await _apiClient.getJson('/api/video/streams');
    _validateBusinessStatus(payload);
    final rawData = payload['data'];
    if (rawData is! List) {
      throw const ApiException(message: '视频流列表返回格式无效。');
    }

    return rawData
        .map((item) {
          final json = asStringMap(item);
          if (json == null) {
            throw const ApiException(message: '视频流列表包含无法识别的条目。');
          }
          return VideoStreamInfo.fromJson(json);
        })
        .toList(growable: false);
  }

  /// 拉取单路视频流详情。
  Future<VideoStreamInfo> fetchStreamDetail(String streamId) async {
    final normalizedStreamId = streamId.trim();
    if (normalizedStreamId.isEmpty) {
      throw const ApiException(message: '视频流标识不能为空。');
    }

    final payload = await _apiClient.getJson(
      '/api/video/streams/${Uri.encodeComponent(normalizedStreamId)}',
    );
    _validateBusinessStatus(payload);

    final rawData = payload['data'] ?? payload;
    final json = asStringMap(rawData);
    if (json == null) {
      throw const ApiException(message: '视频流详情返回格式无效。');
    }
    return VideoStreamInfo.fromJson(json);
  }

  static void _validateBusinessStatus(Map<String, dynamic> payload) {
    final hasCode = payload.containsKey('code');
    if (!hasCode) {
      return;
    }

    final code = asInt(payload['code'], fallback: -1);
    if (code == 0 || code == 200) {
      return;
    }

    final message = _extractMessage(payload);
    throw ApiException(message: message.isEmpty ? '视频服务返回异常。' : message);
  }

  static String _extractMessage(Map<String, dynamic> payload) {
    final msg = asString(payload['msg']).trim();
    if (msg.isNotEmpty) {
      return msg;
    }
    return asString(payload['message']).trim();
  }
}

/// 当前视频服务基础地址。
final videoServiceBaseUrlProvider = FutureProvider.autoDispose<String>((
  ref,
) async {
  final settings = await ref.watch(settingsControllerProvider.future);
  return VideoServiceEndpoint.resolveBaseUrl(settings.baseUrl);
});

/// 视频流仓储 Provider。
final videoStreamRepositoryProvider =
    FutureProvider.autoDispose<VideoStreamRepository>((ref) async {
      final envConfig = ref.watch(envConfigProvider);
      final settings = await ref.watch(settingsControllerProvider.future);
      return VideoStreamRepository(
        apiClient: ApiClient(
          settings: _buildVideoSettings(settings),
          envConfig: envConfig,
        ),
      );
    });

/// 视频流列表 Provider。
final videoStreamsProvider = FutureProvider.autoDispose<List<VideoStreamInfo>>((
  ref,
) async {
  final repository = await ref.watch(videoStreamRepositoryProvider.future);
  return repository.fetchStreams();
});

/// 单路视频流详情 Provider。
final videoStreamDetailProvider = FutureProvider.autoDispose
    .family<VideoStreamInfo, String>((ref, streamId) async {
      final repository = await ref.watch(videoStreamRepositoryProvider.future);
      return repository.fetchStreamDetail(streamId);
    });

AppSettings _buildVideoSettings(AppSettings settings) {
  return settings.copyWith(
    baseUrl: VideoServiceEndpoint.resolveBaseUrl(settings.baseUrl),
  );
}

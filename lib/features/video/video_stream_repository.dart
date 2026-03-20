import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_client_factory.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/preview/preview_workspace_seed.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/features/video/video_stream_info.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 视频流信息仓储。
class VideoStreamRepository {
  /// 创建视频流信息仓储。
  const VideoStreamRepository({
    required ApiClient apiClient,
    required this.fallbackGatewayUrl,
    required this.fallbackStreamId,
    required this.fallbackDisplayName,
    required this.fallbackPreferredMode,
    required this.fallbackMode,
    required this.fallbackWebrtcPort,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 业务接口缺失时使用的公网视频网关地址。
  final String fallbackGatewayUrl;

  /// 业务接口缺失时使用的默认视频流标识。
  final String fallbackStreamId;

  /// 业务接口缺失时使用的默认展示名称。
  final String fallbackDisplayName;

  /// 业务接口缺失时使用的优先播放模式。
  final String fallbackPreferredMode;

  /// 业务接口缺失时使用的回退播放模式。
  final String fallbackMode;

  /// 业务接口缺失时使用的 WebRTC 端口。
  final int fallbackWebrtcPort;

  /// 拉取视频流列表。
  Future<List<VideoStreamInfo>> fetchStreams() async {
    try {
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
    } on ApiException catch (error) {
      final fallbackStreams = _buildConfiguredFallbackStreams(error: error);
      if (fallbackStreams.isNotEmpty) {
        return fallbackStreams;
      }
      rethrow;
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

  List<VideoStreamInfo> _buildConfiguredFallbackStreams({
    required ApiException error,
  }) {
    if (!_shouldUseConfiguredFallback(error)) {
      return const <VideoStreamInfo>[];
    }

    final gatewayUri = Uri.tryParse(fallbackGatewayUrl.trim());
    final streamId = fallbackStreamId.trim();
    if (gatewayUri == null || !gatewayUri.hasScheme || streamId.isEmpty) {
      return const <VideoStreamInfo>[];
    }

    final normalizedGatewayUri = gatewayUri.replace(
      path: _resolveGatewayPath(gatewayUri, ''),
      query: null,
      fragment: null,
    );
    final playerUri = gatewayUri.replace(
      path: _resolveGatewayPath(gatewayUri, 'stream.html'),
      queryParameters: _buildPlayerQueryParameters(streamId),
      fragment: null,
    );

    final displayName = fallbackDisplayName.trim().isEmpty
        ? '${streamId.toUpperCase()} 实时视频流'
        : fallbackDisplayName.trim();

    return <VideoStreamInfo>[
      VideoStreamInfo(
        streamId: streamId,
        deviceId: streamId,
        displayName: displayName,
        gatewayPageUrl: normalizedGatewayUri.toString(),
        playerUrl: playerUri.toString(),
        preferredMode: fallbackPreferredMode.trim().toLowerCase(),
        fallbackMode: fallbackMode.trim().toLowerCase(),
        publicHost: gatewayUri.host,
        webrtcPort: fallbackWebrtcPort,
        available: true,
        aiResultForwarded: false,
      ),
    ];
  }

  bool _shouldUseConfiguredFallback(ApiException error) {
    final message = error.message.toLowerCase();
    return message.contains('no static resource api/video/streams') ||
        (error.statusCode == 404 && message.contains('video/streams'));
  }

  String _resolveGatewayPath(Uri gatewayUri, String leaf) {
    final rawPath = gatewayUri.path.trim();
    final normalizedBasePath = rawPath.isEmpty || rawPath == '/'
        ? ''
        : (rawPath.endsWith('/')
              ? rawPath.substring(0, rawPath.length - 1)
              : rawPath);
    if (leaf.isEmpty) {
      return normalizedBasePath.isEmpty ? '/' : '$normalizedBasePath/';
    }
    if (normalizedBasePath.isEmpty) {
      return '/$leaf';
    }
    return '$normalizedBasePath/$leaf';
  }

  Map<String, String> _buildPlayerQueryParameters(String streamId) {
    final modeValues = <String>[
      fallbackPreferredMode.trim(),
      fallbackMode.trim(),
    ].where((value) => value.isNotEmpty).toList(growable: false);

    return <String, String>{
      'src': streamId,
      if (modeValues.isNotEmpty) 'mode': modeValues.join(','),
    };
  }
}

/// 视频流信息仓储 Provider。
final videoStreamRepositoryProvider = Provider<VideoStreamRepository>((ref) {
  final envConfig = ref.watch(envConfigProvider);
  final settings = ref.watch(effectiveAppSettingsProvider);
  final apiClientFactory = ref.watch(apiClientFactoryProvider);

  return VideoStreamRepository(
    apiClient: apiClientFactory.create(settings: settings),
    fallbackGatewayUrl: envConfig.videoGatewayUrl,
    fallbackStreamId: envConfig.videoDefaultStreamId,
    fallbackDisplayName: envConfig.videoDisplayName,
    fallbackPreferredMode: envConfig.videoPreferredMode,
    fallbackMode: envConfig.videoFallbackMode,
    fallbackWebrtcPort: envConfig.videoWebrtcPort,
  );
});

/// 视频流列表 Provider。
final videoStreamListProvider =
    FutureProvider.autoDispose<List<VideoStreamInfo>>((ref) async {
      if (ref.watch(previewWorkspaceEnabledProvider)) {
        return ref.watch(previewVideoStreamsProvider);
      }

      final repository = ref.watch(videoStreamRepositoryProvider);
      return repository.fetchStreams();
    });

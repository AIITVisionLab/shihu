import 'package:sickandflutter/shared/models/model_utils.dart';

/// Java 视频服务返回的单路视频流信息。
class VideoStreamInfo {
  /// 创建视频流信息对象。
  const VideoStreamInfo({
    required this.streamId,
    required this.deviceId,
    required this.displayName,
    required this.gatewayPageUrl,
    required this.playerUrl,
    required this.preferredMode,
    required this.fallbackMode,
    required this.publicHost,
    required this.webrtcPort,
    required this.available,
    required this.aiResultForwarded,
  });

  /// 从 JSON 构建视频流信息对象。
  factory VideoStreamInfo.fromJson(Map<String, dynamic> json) {
    return VideoStreamInfo(
      streamId: asString(json['streamId']),
      deviceId: asString(json['deviceId']),
      displayName: asString(json['displayName']),
      gatewayPageUrl: asString(json['gatewayPageUrl']),
      playerUrl: asString(json['playerUrl']),
      preferredMode: asString(json['preferredMode']),
      fallbackMode: asString(json['fallbackMode']),
      publicHost: asString(json['publicHost']),
      webrtcPort: _nullableInt(json['webrtcPort']),
      available: asBool(json['available']),
      aiResultForwarded: asBool(json['aiResultForwarded']),
    );
  }

  /// 流标识。
  final String streamId;

  /// 设备标识。
  final String deviceId;

  /// 展示名称。
  final String displayName;

  /// 网关调试页地址。
  final String gatewayPageUrl;

  /// 推荐播放地址。
  final String playerUrl;

  /// 优先播放模式。
  final String preferredMode;

  /// 回退播放模式。
  final String fallbackMode;

  /// 公网主机地址。
  final String publicHost;

  /// WebRTC 端口。
  final int? webrtcPort;

  /// 当前流是否可用。
  final bool available;

  /// 当前流是否已开启 AI 结果转发。
  final bool aiResultForwarded;

  /// 返回适合界面展示的流名称。
  String get resolvedDisplayName {
    final normalizedDisplayName = displayName.trim();
    if (normalizedDisplayName.isNotEmpty) {
      return normalizedDisplayName;
    }
    final normalizedStreamId = streamId.trim();
    if (normalizedStreamId.isNotEmpty) {
      return normalizedStreamId;
    }
    return '未命名视频流';
  }

  /// 返回播放模式说明。
  String get playbackModeLabel {
    final primary = preferredMode.trim();
    final secondary = fallbackMode.trim();
    if (primary.isEmpty && secondary.isEmpty) {
      return '未返回';
    }
    if (primary.isEmpty || primary == secondary) {
      return secondary;
    }
    if (secondary.isEmpty) {
      return primary;
    }
    return '$primary / $secondary';
  }

  /// 返回公网访问端点说明。
  String get publicEndpointLabel {
    final normalizedHost = publicHost.trim();
    final normalizedPort = webrtcPort;
    if (normalizedHost.isEmpty && normalizedPort == null) {
      return '未返回';
    }
    if (normalizedPort == null) {
      return normalizedHost;
    }
    if (normalizedHost.isEmpty) {
      return ':$normalizedPort';
    }
    return '$normalizedHost:$normalizedPort';
  }

  /// 是否具备播放链接。
  bool get hasPlayerUrl => playerUrl.trim().isNotEmpty;

  /// 是否具备网关链接。
  bool get hasGatewayPageUrl => gatewayPageUrl.trim().isNotEmpty;

  static int? _nullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    return asInt(value);
  }
}

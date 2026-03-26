import 'package:sickandflutter/shared/models/model_utils.dart';

/// 视频流基础信息。
class VideoStreamInfo {
  /// 创建视频流基础信息。
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

  /// 从接口 JSON 解析视频流信息。
  factory VideoStreamInfo.fromJson(Map<String, dynamic> json) {
    final streamId = asString(json['streamId']).trim();
    final deviceId = asString(json['deviceId']).trim();
    final displayName = asString(json['displayName']).trim();
    final preferredMode = asString(json['preferredMode']).trim().toLowerCase();
    final fallbackMode = asString(json['fallbackMode']).trim().toLowerCase();

    return VideoStreamInfo(
      streamId: streamId.isEmpty
          ? (deviceId.isEmpty ? 'unknown' : deviceId)
          : streamId,
      deviceId: deviceId.isEmpty ? streamId : deviceId,
      displayName: displayName.isEmpty ? '未命名画面' : displayName,
      gatewayPageUrl: asString(json['gatewayPageUrl']).trim(),
      playerUrl: asString(json['playerUrl']).trim(),
      preferredMode: preferredMode,
      fallbackMode: fallbackMode,
      publicHost: asString(json['publicHost']).trim(),
      webrtcPort: asInt(json['webrtcPort']),
      available: asBool(json['available']),
      aiResultForwarded: asBool(json['aiResultForwarded']),
    );
  }

  /// 视频流标识。
  final String streamId;

  /// 设备标识。
  final String deviceId;

  /// 展示名称。
  final String displayName;

  /// 网关调试页地址。
  final String gatewayPageUrl;

  /// 推荐播放页地址。
  final String playerUrl;

  /// 推荐播放模式。
  final String preferredMode;

  /// 回退播放模式。
  final String fallbackMode;

  /// 公网主机名或 IP。
  final String publicHost;

  /// WebRTC 端口。
  final int webrtcPort;

  /// 当前流是否可用。
  final bool available;

  /// 当前是否已开启 AI 结果转发。
  final bool aiResultForwarded;

  /// 是否具备播放页地址。
  bool get hasPlayerUrl => playerUrl.isNotEmpty;

  /// 是否具备网关页地址。
  bool get hasGatewayPageUrl => gatewayPageUrl.isNotEmpty;

  /// 面向界面的可用状态。
  String get availabilityLabel => available ? '在线' : '离线';

  /// 面向界面的播放模式说明。
  String get modeSummary {
    if (preferredMode.isEmpty && fallbackMode.isEmpty) {
      return '未提供播放模式';
    }
    if (fallbackMode.isEmpty || preferredMode == fallbackMode) {
      return preferredMode.toUpperCase();
    }
    return '${preferredMode.toUpperCase()} -> ${fallbackMode.toUpperCase()}';
  }

  /// 面向界面的媒体入口说明。
  String get mediaEndpointLabel {
    final host = publicHost.trim();
    if (host.isEmpty || webrtcPort <= 0) {
      return '未提供媒体入口';
    }
    return '$host:$webrtcPort';
  }
}

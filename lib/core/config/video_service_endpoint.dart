import 'package:sickandflutter/core/constants/app_constants.dart';

/// 统一解析 Java 视频服务的基础地址和接口地址。
///
/// 当前设备状态服务部署在 `8082`，视频元数据服务部署在 `19081`。
/// 为了避免页面层自己拼接端口和路径，统一由该类负责解析。
final class VideoServiceEndpoint {
  /// 视频流列表接口路径。
  static const String streamsPath = '/api/video/streams';

  /// 根据当前设备服务地址解析对应的视频服务基础地址。
  ///
  /// 当传入地址不可用时，回退到项目默认视频服务地址。
  static String resolveBaseUrl(String serviceBaseUrl) {
    final fallbackUri = Uri.parse(AppConstants.defaultVideoBaseUrl);
    final currentUri = Uri.tryParse(serviceBaseUrl);
    if (currentUri == null ||
        currentUri.host.trim().isEmpty ||
        currentUri.scheme.trim().isEmpty) {
      return _normalizeBaseUrl(fallbackUri);
    }

    final resolvedUri = currentUri.replace(
      port: AppConstants.defaultVideoServicePort,
      path: '',
      query: null,
      fragment: null,
      userInfo: '',
    );
    return _normalizeBaseUrl(resolvedUri);
  }

  /// 返回视频流列表接口地址。
  static String resolveStreamsUrl(String serviceBaseUrl) {
    return '${resolveBaseUrl(serviceBaseUrl)}$streamsPath';
  }

  /// 返回单路视频流详情接口地址。
  static String resolveStreamUrl(String serviceBaseUrl, String streamId) {
    final normalizedStreamId = Uri.encodeComponent(streamId.trim());
    return '${resolveBaseUrl(serviceBaseUrl)}$streamsPath/$normalizedStreamId';
  }

  static String _normalizeBaseUrl(Uri uri) {
    final normalized = uri.toString();
    if (normalized.endsWith('/')) {
      return normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}

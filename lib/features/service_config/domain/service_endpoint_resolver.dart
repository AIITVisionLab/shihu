import 'package:sickandflutter/core/constants/app_constants.dart';

/// 统一解析服务基础地址和历史默认地址迁移规则。
final class ServiceEndpointResolver {
  static const Set<String> _legacyDefaultBaseUrls = <String>{
    'http://101.35.79.76:19081',
    'http://101.35.79.76:8082',
    'http://127.0.0.1:8082',
    AppConstants.localDevelopmentBaseUrl,
  };

  /// 解析当前生效的设备服务地址。
  static ResolvedServiceEndpoints resolve({
    required String configuredBaseUrl,
    required String fallbackBaseUrl,
  }) {
    final normalizedFallbackBaseUrl =
        normalizeBaseUrl(fallbackBaseUrl) ?? AppConstants.defaultBaseUrl;
    final deviceBaseUrl =
        normalizeBaseUrl(configuredBaseUrl) ?? normalizedFallbackBaseUrl;

    return ResolvedServiceEndpoints(deviceBaseUrl: deviceBaseUrl);
  }

  /// 迁移历史默认地址，避免旧版本继续命中已废弃入口。
  static String migrateLegacyBaseUrl({
    required String storedBaseUrl,
    required String envBaseUrl,
  }) {
    final normalizedStoredBaseUrl = normalizeBaseUrl(storedBaseUrl);
    if (normalizedStoredBaseUrl == null ||
        !_legacyDefaultBaseUrls.contains(normalizedStoredBaseUrl)) {
      return storedBaseUrl;
    }

    return normalizeBaseUrl(envBaseUrl) ?? AppConstants.defaultBaseUrl;
  }

  /// 规范化基础地址。
  ///
  /// 只接受 `scheme://host[:port]` 这类站点根地址，
  /// 不接受查询串、片段或额外路径段，避免后续请求拼接时出现歧义。
  static String? normalizeBaseUrl(String? rawValue) {
    final normalizedValue = rawValue?.trim();
    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(normalizedValue);
    if (uri == null ||
        uri.scheme.trim().isEmpty ||
        uri.host.trim().isEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      return null;
    }

    final normalizedPath = uri.path.trim();
    if (normalizedPath.isNotEmpty && normalizedPath != '/') {
      return null;
    }

    final normalizedUri = uri.replace(
      path: '',
      query: null,
      fragment: null,
      userInfo: '',
    );
    final normalizedUrl = normalizedUri.toString();
    if (normalizedUrl.endsWith('/')) {
      return normalizedUrl.substring(0, normalizedUrl.length - 1);
    }
    return normalizedUrl;
  }
}

/// 当前工作区实际使用的服务端点集合。
class ResolvedServiceEndpoints {
  /// 创建服务端点集合。
  const ResolvedServiceEndpoints({required this.deviceBaseUrl});

  /// 设备服务基础地址。
  final String deviceBaseUrl;
}

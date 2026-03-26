/// 统一描述网络层和业务层抛出的接口异常。
class ApiException implements Exception {
  /// 创建接口异常对象。
  const ApiException({
    required this.message,
    this.statusCode,
    this.businessCode,
    this.isTimeout = false,
    this.isConnectionError = false,
  });

  /// 面向用户和排查日志的异常描述。
  final String message;

  /// 对应的 HTTP 状态码。
  final int? statusCode;

  /// 对应的业务错误码。
  final int? businessCode;

  /// 是否由连接或收发超时触发。
  final bool isTimeout;

  /// 是否由底层网络连接失败触发。
  final bool isConnectionError;

  /// 是否属于适合自动重试的瞬时网络失败。
  bool get isTransientNetworkFailure => isTimeout || isConnectionError;

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, businessCode: $businessCode, isTimeout: $isTimeout, isConnectionError: $isConnectionError, message: $message)';
  }
}

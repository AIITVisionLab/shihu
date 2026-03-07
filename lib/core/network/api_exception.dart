/// 统一描述网络层和业务层抛出的接口异常。
class ApiException implements Exception {
  /// 创建接口异常对象。
  const ApiException({
    required this.message,
    this.statusCode,
    this.businessCode,
  });

  /// 面向用户和排查日志的异常描述。
  final String message;

  /// 对应的 HTTP 状态码。
  final int? statusCode;

  /// 对应的业务错误码。
  final int? businessCode;

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, businessCode: $businessCode, message: $message)';
  }
}

import 'package:sickandflutter/shared/models/model_utils.dart';

/// 统一描述后端业务接口的基础包裹结构。
class ApiResponse<T> {
  /// 创建接口包裹对象。
  const ApiResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  /// 从 JSON 构建接口包裹对象。
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    required T? Function(Object? data) dataParser,
  }) {
    return ApiResponse<T>(
      code: asInt(json['code'], fallback: 500),
      message: asString(json['message']),
      data: dataParser(json['data']),
    );
  }

  /// 业务状态码。
  final int code;

  /// 业务提示信息。
  final String message;

  /// 业务数据主体。
  final T? data;

  /// 当前响应是否表示业务成功。
  bool get isSuccess => code == 200;
}

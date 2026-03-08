import 'package:dio/dio.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/core/network/api_response.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

/// 统一的 HTTP 客户端封装。
///
/// 页面层只依赖上层 Repository，不直接依赖该类。
class ApiClient {
  /// 根据当前设置和环境配置创建 HTTP 客户端。
  ApiClient({
    required AppSettings settings,
    required EnvConfig envConfig,
    this.authorizationValue,
    this.onUnauthorized,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: settings.baseUrl.isEmpty
               ? envConfig.baseUrl
               : settings.baseUrl,
           connectTimeout: Duration(milliseconds: settings.connectTimeoutMs),
           receiveTimeout: Duration(milliseconds: settings.receiveTimeoutMs),
           headers: <String, Object>{
             'Accept': 'application/json',
             'X-Platform': currentPlatformType().value,
             if (_resolvedAuthorizationValue(authorizationValue) != null)
               'Authorization': _resolvedAuthorizationValue(
                 authorizationValue,
               )!,
           },
           responseType: ResponseType.json,
         ),
       );

  final Dio _dio;

  /// 当前客户端附带的认证头值。
  final String? authorizationValue;

  /// 检测到未授权状态时的统一回调。
  final void Function({String? message})? onUnauthorized;

  /// 当前客户端实际使用的基础地址。
  String get baseUrl => _dio.options.baseUrl;

  /// 发送 GET 请求并返回 JSON 对象。
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return _extractJson(response);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  /// 发送 GET 请求并按统一包裹结构解析响应。
  Future<ApiResponse<T>> getResponse<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T? Function(Object? data) dataParser,
  }) async {
    final json = await getJson(path, queryParameters: queryParameters);
    final response = ApiResponse<T>.fromJson(json, dataParser: dataParser);
    _notifyUnauthorizedForBusinessResponse(response);
    return response;
  }

  /// 发送 JSON POST 请求并返回 JSON 对象。
  Future<Map<String, dynamic>> postJson(String path, {Object? data}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return _extractJson(response);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  /// 发送 JSON POST 请求并按统一包裹结构解析响应。
  Future<ApiResponse<T>> postResponse<T>(
    String path, {
    Object? data,
    required T? Function(Object? data) dataParser,
  }) async {
    final json = await postJson(path, data: data);
    final response = ApiResponse<T>.fromJson(json, dataParser: dataParser);
    _notifyUnauthorizedForBusinessResponse(response);
    return response;
  }

  /// 发送 multipart 请求并返回 JSON 对象。
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required FormData data,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return _extractJson(response);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  /// 发送 multipart 请求并按统一包裹结构解析响应。
  Future<ApiResponse<T>> postMultipartResponse<T>(
    String path, {
    required FormData data,
    required T? Function(Object? data) dataParser,
  }) async {
    final json = await postMultipart(path, data: data);
    final response = ApiResponse<T>.fromJson(json, dataParser: dataParser);
    _notifyUnauthorizedForBusinessResponse(response);
    return response;
  }

  Map<String, dynamic> _extractJson(Response<Map<String, dynamic>> response) {
    final data = response.data;
    if (data == null) {
      throw const ApiException(statusCode: 500, message: '接口返回为空，无法解析响应。');
    }

    return data;
  }

  ApiException _mapDioException(DioException error) {
    final statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          statusCode: statusCode,
          message: '请求超时，请检查网络或服务地址。',
          isTimeout: true,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          statusCode: statusCode,
          message: '网络连接失败，请检查网络或服务地址。',
          isConnectionError: true,
        );
      case DioExceptionType.badResponse:
        final exception = ApiException(
          statusCode: statusCode,
          message: '服务返回异常状态码：${statusCode ?? 'unknown'}。',
        );
        if (statusCode == 401) {
          onUnauthorized?.call(message: exception.message);
        }
        return exception;
      case DioExceptionType.badCertificate:
        return ApiException(
          statusCode: statusCode,
          message: '服务证书校验失败，请检查服务配置。',
        );
      case DioExceptionType.cancel:
        return ApiException(statusCode: statusCode, message: '请求已取消。');
      case DioExceptionType.unknown:
        return ApiException(
          statusCode: statusCode,
          message: '网络请求失败：${error.message ?? 'unknown'}。',
        );
    }
  }

  void _notifyUnauthorizedForBusinessResponse<T>(ApiResponse<T> response) {
    if (response.code == 40101) {
      final rawMessage = response.message.trim();
      onUnauthorized?.call(
        message: rawMessage.isEmpty ? '登录状态已失效，请重新登录。' : rawMessage,
      );
    }
  }

  static String? _resolvedAuthorizationValue(String? rawValue) {
    final normalizedValue = rawValue?.trim();
    if (normalizedValue == null || normalizedValue.isEmpty) {
      return null;
    }

    return normalizedValue;
  }
}

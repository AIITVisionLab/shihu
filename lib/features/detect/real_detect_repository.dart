import 'dart:async';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/features/detect/detect_api_error_code.dart';
import 'package:sickandflutter/features/detect/detect_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';
import 'package:sickandflutter/shared/models/image_info.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 真实单图识别接口实现。
class RealDetectRepository implements DetectRepository {
  /// 创建真实单图识别仓储。
  RealDetectRepository({
    required ApiClient apiClient,
    Future<void> Function(Duration delay)? retryDelay,
    int maxAttempts = 3,
  }) : _apiClient = apiClient,
       _retryDelay = retryDelay ?? Future<void>.delayed,
       _maxAttempts = maxAttempts,
       assert(maxAttempts >= 1, 'maxAttempts 必须大于等于 1。');

  final ApiClient _apiClient;
  final Future<void> Function(Duration delay) _retryDelay;
  final int _maxAttempts;

  static const Set<int> _retryableHttpStatusCodes = <int>{
    408,
    429,
    500,
    502,
    503,
    504,
  };

  static const Set<DetectApiErrorCode> _retryableBusinessCodes =
      <DetectApiErrorCode>{
        DetectApiErrorCode.rateLimited,
        DetectApiErrorCode.inferenceFailed,
        DetectApiErrorCode.internalError,
        DetectApiErrorCode.serviceUnavailable,
      };

  @override
  Future<DetectResponse> detectImage({required XFile imageFile}) async {
    final fileName = _resolveFileName(imageFile);
    final imageBytes = await imageFile.readAsBytes();
    // 重试时复用同一 traceId，便于后端做幂等和排查。
    final clientTraceId = _buildClientTraceId(fileName);
    final capturedAt = DateTime.now().toIso8601String();

    ApiException? lastError;

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final response = await _apiClient
            .postMultipartResponse<Map<String, dynamic>>(
              '/api/v1/detect/image',
              data: _buildRequestData(
                imageBytes: imageBytes,
                fileName: fileName,
                clientTraceId: clientTraceId,
                capturedAt: capturedAt,
              ),
              dataParser: asStringMap,
            );

        if (!response.isSuccess) {
          lastError = ApiException(
            message: _resolveBusinessMessage(response.code, response.message),
            businessCode: response.code,
          );
        } else {
          final payload = response.data;
          if (payload == null) {
            throw ApiException(
              message: '识别接口返回成功，但缺少 data 数据体。',
              businessCode: response.code,
            );
          }

          return _normalizeImageUrls(DetectResponse.fromJson(payload));
        }
      } on ApiException catch (error) {
        lastError = _normalizeRequestError(error);
      }

      if (!_shouldRetry(error: lastError, attempt: attempt)) {
        throw lastError;
      }

      await _retryDelay(_resolveRetryDelay(attempt));
    }

    throw lastError ?? const ApiException(message: '识别请求失败，请稍后重试。');
  }

  FormData _buildRequestData({
    required List<int> imageBytes,
    required String fileName,
    required String clientTraceId,
    required String capturedAt,
  }) {
    return FormData.fromMap(<String, Object>{
      'file': MultipartFile.fromBytes(imageBytes, filename: fileName),
      'clientTraceId': clientTraceId,
      'capturedAt': capturedAt,
      'platform': currentPlatformType().value,
    });
  }

  DetectResponse _normalizeImageUrls(DetectResponse response) {
    final imageInfo = response.imageInfo;
    if (imageInfo == null) {
      return response;
    }

    return DetectResponse(
      detectId: response.detectId,
      sourceType: response.sourceType,
      capturedAt: response.capturedAt,
      summary: response.summary,
      detections: response.detections,
      advice: response.advice,
      modelInfo: response.modelInfo,
      imageInfo: ImageInfo(
        width: imageInfo.width,
        height: imageInfo.height,
        originalUrl: _resolveUrl(imageInfo.originalUrl),
        annotatedUrl: _resolveUrl(imageInfo.annotatedUrl),
      ),
    );
  }

  String _resolveFileName(XFile imageFile) {
    final normalizedName = imageFile.name.trim();
    if (normalizedName.isNotEmpty) {
      return normalizedName;
    }

    return 'selected_image.jpg';
  }

  String _buildClientTraceId(String fileName) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return 'flutter_${currentPlatformType().value}_${timestamp}_$fileName';
  }

  bool _shouldRetry({required ApiException error, required int attempt}) {
    if (attempt >= _maxAttempts) {
      return false;
    }

    if (error.isTransientNetworkFailure) {
      return true;
    }

    if (_retryableHttpStatusCodes.contains(error.statusCode)) {
      return true;
    }

    final mappedCode = tryDetectApiErrorCodeFromValue(error.businessCode);
    return mappedCode != null && _retryableBusinessCodes.contains(mappedCode);
  }

  Duration _resolveRetryDelay(int attempt) {
    return Duration(milliseconds: 300 * attempt);
  }

  String _resolveBusinessMessage(int code, String rawMessage) {
    final mappedCode = tryDetectApiErrorCodeFromValue(code);
    if (mappedCode != null) {
      return mappedCode.userMessage;
    }

    final normalizedMessage = rawMessage.trim();
    if (normalizedMessage.isNotEmpty) {
      return normalizedMessage;
    }

    return '识别请求失败，请稍后重试。';
  }

  ApiException _normalizeRequestError(ApiException error) {
    if (error.statusCode == 404) {
      return ApiException(
        statusCode: error.statusCode,
        message:
            '当前后端未提供 /api/v1/detect/image，请先并入独立识别服务，或在开发环境使用 USE_MOCK_DETECT=true。',
      );
    }

    return error;
  }

  String? _resolveUrl(String? rawUrl) {
    final normalizedUrl = rawUrl?.trim();
    if (normalizedUrl == null || normalizedUrl.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(normalizedUrl);
    if (uri != null && uri.hasScheme) {
      return normalizedUrl;
    }

    final baseUri = Uri.tryParse(_apiClient.baseUrl);
    if (baseUri == null) {
      return normalizedUrl;
    }

    return baseUri.resolve(normalizedUrl).toString();
  }
}

import 'package:dio/dio.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/features/detect/detect_api_error_code.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';
import 'package:sickandflutter/shared/models/image_info.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 真实实时识别接口实现。
class RealRealtimeDetectRepository implements RealtimeDetectRepository {
  /// 创建真实实时识别仓储。
  const RealRealtimeDetectRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  bool get supportsTestFeed => false;

  @override
  Future<DetectResponse> detectFrame({
    required RealtimeFrameRequest request,
  }) async {
    final frameFile = request.frameFile;
    if (frameFile == null) {
      throw const ApiException(message: '当前未提供实时帧文件，需接入摄像头取帧后才能调用真实实时识别接口。');
    }

    final fileName = _resolveFileName(frameFile.name);
    final response = await _apiClient
        .postMultipartResponse<Map<String, dynamic>>(
          '/api/v1/detect/realtime/frame',
          data: FormData.fromMap(<String, Object>{
            'file': MultipartFile.fromBytes(
              await frameFile.readAsBytes(),
              filename: fileName,
            ),
            'sessionId': request.sessionId,
            'frameIndex': request.frameIndex,
            'capturedAt': request.capturedAt.toIso8601String(),
            'platform': currentPlatformType().value,
          }),
          dataParser: asStringMap,
        );

    if (!response.isSuccess) {
      throw ApiException(
        message: _resolveBusinessMessage(response.code, response.message),
        businessCode: response.code,
      );
    }

    final payload = response.data;
    if (payload == null) {
      throw ApiException(
        message: '实时识别接口返回成功，但缺少 data 数据体。',
        businessCode: response.code,
      );
    }

    return _normalizeImageUrls(DetectResponse.fromJson(payload));
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

  String _resolveFileName(String rawFileName) {
    final normalizedName = rawFileName.trim();
    if (normalizedName.isNotEmpty) {
      return normalizedName;
    }

    return 'realtime_frame.jpg';
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

    return '实时识别请求失败，请稍后重试。';
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

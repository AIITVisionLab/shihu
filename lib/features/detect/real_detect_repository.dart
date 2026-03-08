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
  const RealDetectRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<DetectResponse> detectImage({required XFile imageFile}) async {
    final fileName = _resolveFileName(imageFile);
    final response = await _apiClient
        .postMultipartResponse<Map<String, dynamic>>(
          '/api/v1/detect/image',
          data: FormData.fromMap(<String, Object>{
            'file': MultipartFile.fromBytes(
              await imageFile.readAsBytes(),
              filename: fileName,
            ),
            'clientTraceId': _buildClientTraceId(fileName),
            'capturedAt': DateTime.now().toIso8601String(),
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
        message: '识别接口返回成功，但缺少 data 数据体。',
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

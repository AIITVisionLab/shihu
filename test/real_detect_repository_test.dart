import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/features/detect/real_detect_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  test(
    'RealDetectRepository posts multipart request and normalizes image URLs',
    () async {
      final apiClient = _FakeApiClient(
        baseUrl: 'http://127.0.0.1:8080',
        responseJson: <String, dynamic>{
          'code': 200,
          'message': 'success',
          'data': <String, dynamic>{
            'detectId': 'det_20260308_0001',
            'sourceType': 'image',
            'capturedAt': '2026-03-08T10:00:00+08:00',
            'summary': <String, dynamic>{
              'primaryLabelCode': 'disease_black_spot',
              'primaryLabelName': '黑斑病',
              'category': 'disease',
              'confidence': 0.9721,
              'severityLevel': 'medium',
              'severityScore': 0.66,
              'healthStatus': 'abnormal',
            },
            'imageInfo': <String, dynamic>{
              'width': 1920,
              'height': 1080,
              'originalUrl': '/static/original/det_20260308_0001.jpg',
              'annotatedUrl': '/static/annotated/det_20260308_0001.jpg',
            },
            'detections': const <Map<String, dynamic>>[],
          },
        },
      );
      final repository = RealDetectRepository(apiClient: apiClient);

      final response = await repository.detectImage(
        imageFile: XFile.fromData(
          Uint8List.fromList(<int>[1, 2, 3, 4]),
          name: 'leaf.jpg',
          mimeType: 'image/jpeg',
        ),
      );

      expect(apiClient.capturedPath, '/api/v1/detect/image');
      expect(apiClient.capturedData, isNotNull);
      expect(
        apiClient.capturedData!.fields.any(
          (field) =>
              field.key == 'platform' &&
              field.value == currentPlatformType().value,
        ),
        isTrue,
      );
      expect(apiClient.capturedData!.files.single.key, 'file');
      expect(
        apiClient.capturedData!.files.single.value.filename,
        'selected_image.jpg',
      );
      expect(
        response.imageInfo?.originalUrl,
        'http://127.0.0.1:8080/static/original/det_20260308_0001.jpg',
      );
      expect(
        response.imageInfo?.annotatedUrl,
        'http://127.0.0.1:8080/static/annotated/det_20260308_0001.jpg',
      );
    },
  );

  test(
    'RealDetectRepository throws ApiException for business error response',
    () async {
      final apiClient = _FakeApiClient(
        responseJson: <String, dynamic>{
          'code': 40002,
          'message': 'invalid image file',
          'data': null,
        },
      );
      final repository = RealDetectRepository(apiClient: apiClient);

      await expectLater(
        repository.detectImage(
          imageFile: XFile.fromData(
            Uint8List.fromList(<int>[9, 9, 9]),
            name: 'bad.jpg',
            mimeType: 'image/jpeg',
          ),
        ),
        throwsA(
          isA<ApiException>()
              .having((error) => error.businessCode, 'businessCode', 40002)
              .having(
                (error) => error.message,
                'message',
                '图片文件无效，请重新选择清晰的石斛图片。',
              ),
        ),
      );
    },
  );

  test(
    'RealDetectRepository falls back to backend message for unknown code',
    () async {
      final apiClient = _FakeApiClient(
        responseJson: <String, dynamic>{
          'code': 49999,
          'message': 'custom backend error',
          'data': null,
        },
      );
      final repository = RealDetectRepository(apiClient: apiClient);

      await expectLater(
        repository.detectImage(
          imageFile: XFile.fromData(
            Uint8List.fromList(<int>[3, 2, 1]),
            name: 'unknown.jpg',
            mimeType: 'image/jpeg',
          ),
        ),
        throwsA(
          isA<ApiException>()
              .having((error) => error.businessCode, 'businessCode', 49999)
              .having(
                (error) => error.message,
                'message',
                'custom backend error',
              ),
        ),
      );
    },
  );
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient({
    required this.responseJson,
    String baseUrl = 'http://127.0.0.1:8080',
  }) : super(
         settings: AppSettings.defaults(
           buildFlavor: BuildFlavor.development,
           baseUrl: baseUrl,
           enableLog: true,
         ),
         envConfig: EnvConfig(
           flavor: BuildFlavor.development,
           baseUrl: baseUrl,
           enableLog: true,
         ),
       );

  final Map<String, dynamic> responseJson;
  FormData? capturedData;
  String? capturedPath;

  @override
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required FormData data,
  }) async {
    capturedPath = path;
    capturedData = data;
    return responseJson;
  }
}

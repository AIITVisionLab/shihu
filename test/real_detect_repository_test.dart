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
        results: <Object>[_successResponseJson],
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
      expect(apiClient.capturedRequests, hasLength(1));
      expect(
        apiClient.capturedRequests.single.fields.any(
          (field) =>
              field.key == 'platform' &&
              field.value == currentPlatformType().value,
        ),
        isTrue,
      );
      expect(apiClient.capturedRequests.single.files.single.key, 'file');
      expect(
        apiClient.capturedRequests.single.files.single.value.filename,
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
        results: <Object>[
          <String, dynamic>{
            'code': 40002,
            'message': 'invalid image file',
            'data': null,
          },
        ],
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
      expect(apiClient.requestCount, 1);
    },
  );

  test(
    'RealDetectRepository falls back to backend message for unknown code',
    () async {
      final apiClient = _FakeApiClient(
        results: <Object>[
          <String, dynamic>{
            'code': 49999,
            'message': 'custom backend error',
            'data': null,
          },
        ],
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
      expect(apiClient.requestCount, 1);
    },
  );

  test(
    'RealDetectRepository retries retryable business response and reuses trace id',
    () async {
      final apiClient = _FakeApiClient(
        results: <Object>[
          <String, dynamic>{
            'code': 50301,
            'message': 'service unavailable',
            'data': null,
          },
          _successResponseJson,
        ],
      );
      final delays = <Duration>[];
      final repository = RealDetectRepository(
        apiClient: apiClient,
        retryDelay: (duration) async {
          delays.add(duration);
        },
      );

      final response = await repository.detectImage(
        imageFile: XFile.fromData(
          Uint8List.fromList(<int>[6, 6, 6]),
          name: 'retry.jpg',
          mimeType: 'image/jpeg',
        ),
      );

      expect(response.detectId, 'det_20260308_0001');
      expect(apiClient.requestCount, 2);
      expect(delays, <Duration>[const Duration(milliseconds: 300)]);

      final firstTraceId = _readField(
        apiClient.capturedRequests.first,
        'clientTraceId',
      );
      final secondTraceId = _readField(
        apiClient.capturedRequests.last,
        'clientTraceId',
      );
      final firstCapturedAt = _readField(
        apiClient.capturedRequests.first,
        'capturedAt',
      );
      final secondCapturedAt = _readField(
        apiClient.capturedRequests.last,
        'capturedAt',
      );

      expect(firstTraceId, isNotEmpty);
      expect(secondTraceId, firstTraceId);
      expect(secondCapturedAt, firstCapturedAt);
    },
  );

  test(
    'RealDetectRepository retries timeout exception and then succeeds',
    () async {
      final apiClient = _FakeApiClient(
        results: <Object>[
          const ApiException(message: '请求超时，请检查网络或服务地址。', isTimeout: true),
          _successResponseJson,
        ],
      );
      final delays = <Duration>[];
      final repository = RealDetectRepository(
        apiClient: apiClient,
        retryDelay: (duration) async {
          delays.add(duration);
        },
      );

      final response = await repository.detectImage(
        imageFile: XFile.fromData(
          Uint8List.fromList(<int>[7, 7, 7]),
          name: 'timeout.jpg',
          mimeType: 'image/jpeg',
        ),
      );

      expect(response.detectId, 'det_20260308_0001');
      expect(apiClient.requestCount, 2);
      expect(delays, <Duration>[const Duration(milliseconds: 300)]);
    },
  );
}

const Map<String, dynamic> _successResponseJson = <String, dynamic>{
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
    'detections': <Map<String, dynamic>>[],
  },
};

String _readField(FormData data, String key) {
  return data.fields.firstWhere((field) => field.key == key).value;
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient({
    required this.results,
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

  final List<Object> results;
  final List<FormData> capturedRequests = <FormData>[];
  String? capturedPath;
  int _requestCount = 0;

  int get requestCount => _requestCount;

  @override
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required FormData data,
  }) async {
    capturedPath = path;
    capturedRequests.add(data);
    final result = results[_requestCount];
    _requestCount += 1;

    if (result is ApiException) {
      throw result;
    }

    return result as Map<String, dynamic>;
  }
}

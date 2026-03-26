import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/ai/infrastructure/ai_detection_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  test('AiDetectionRepository parses latest AI detection payload', () async {
    final repository = AiDetectionRepository(
      apiClient: _FakeAiApiClient(
        responses: <String, Map<String, dynamic>>{
          '/api/edge/ai-detections/latest': <String, dynamic>{
            'code': 0,
            'msg': 'ok',
            'data': <String, dynamic>{
              'deviceId': 'k230',
              'stream': 'k230',
              'timestampMs': 1742200000000,
              'detectionCount': 1,
              'empty': false,
              'summary': '检测到 1 处高风险目标',
              'overallRiskLevel': '高',
              'items': <Map<String, dynamic>>[
                <String, dynamic>{
                  'displayName': '蚜虫',
                  'riskLevel': '高',
                  'confidence': 0.96,
                },
              ],
            },
          },
        },
      ),
    );

    final latest = await repository.fetchLatest();

    expect(latest, isNotNull);
    expect(latest?.deviceId, 'k230');
    expect(latest?.items.first.displayName, '蚜虫');
    expect(latest?.overallRiskLevel, '高');
  });

  test('AiDetectionRepository parses AI history list payload', () async {
    final repository = AiDetectionRepository(
      apiClient: _FakeAiApiClient(
        responses: <String, Map<String, dynamic>>{
          '/api/edge/ai-detections/history': <String, dynamic>{
            'code': 0,
            'msg': 'ok',
            'data': <Map<String, dynamic>>[
              <String, dynamic>{
                'deviceId': 'k230',
                'stream': 'k230',
                'timestampMs': 1742200000000,
                'detectionCount': 0,
                'empty': true,
                'summary': '当前未检测到病虫害目标',
                'overallRiskLevel': '健康',
              },
            ],
          },
        },
      ),
    );

    final history = await repository.fetchHistory(limit: 5);

    expect(history, hasLength(1));
    expect(history.first.summary, '当前未检测到病虫害目标');
    expect(history.first.empty, isTrue);
  });

  test(
    'AiDetectionRepository throws ApiException on business failure',
    () async {
      final repository = AiDetectionRepository(
        apiClient: _FakeAiApiClient(
          responses: <String, Map<String, dynamic>>{
            '/api/edge/ai-detections/latest': <String, dynamic>{
              'code': 500,
              'msg': 'AI 服务异常',
              'data': null,
            },
          },
        ),
      );

      await expectLater(
        repository.fetchLatest(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'AI 服务异常',
          ),
        ),
      );
    },
  );
}

class _FakeAiApiClient extends ApiClient {
  _FakeAiApiClient({required this.responses})
    : super(
        settings: AppSettings.defaults(
          buildFlavor: BuildFlavor.development,
          baseUrl: 'http://127.0.0.1:8085',
          enableLog: true,
        ),
        envConfig: const EnvConfig(
          flavor: BuildFlavor.development,
          baseUrl: 'http://127.0.0.1:8085',
          enableLog: true,
        ),
      );

  final Map<String, Map<String, dynamic>> responses;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return responses[path] ?? <String, dynamic>{'code': 0, 'msg': 'ok'};
  }
}

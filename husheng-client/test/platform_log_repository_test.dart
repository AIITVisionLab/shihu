import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/platform_logs/infrastructure/platform_log_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  test('PlatformLogRepository parses summary payload', () async {
    final repository = PlatformLogRepository(
      apiClient: _FakePlatformLogApiClient(
        responses: <String, Map<String, dynamic>>{
          '/api/logs/summary': <String, dynamic>{
            'code': 0,
            'msg': 'ok',
            'data': <String, dynamic>{
              'count': 16,
              'file': '/tmp/platform.log',
              'supportedTypes': <String>['ONENET_UPLINK', 'AI_DETECTION'],
            },
          },
        },
      ),
    );

    final summary = await repository.fetchSummary();

    expect(summary.count, 16);
    expect(summary.file, '/tmp/platform.log');
    expect(summary.supportedTypes, contains('AI_DETECTION'));
  });

  test('PlatformLogRepository parses recent entries payload', () async {
    final apiClient = _FakePlatformLogApiClient(
      responses: <String, Map<String, dynamic>>{
        '/api/logs': <String, dynamic>{
          'code': 0,
          'msg': 'ok',
          'data': <Map<String, dynamic>>[
            <String, dynamic>{
              'eventId': 'evt_1',
              'timestampMs': 1742200000000,
              'type': 'ONENET_COMMAND',
              'deviceId': 'dev_1',
              'summary': '补光开启指令已下发',
              'details': <String, Object>{'led': true},
            },
          ],
        },
      },
    );
    final repository = PlatformLogRepository(apiClient: apiClient);

    final recent = await repository.fetchRecent(
      type: 'ONENET_COMMAND',
      keyword: 'dev_1',
      limit: 5,
    );

    expect(recent, hasLength(1));
    expect(recent.first.type, 'ONENET_COMMAND');
    expect(recent.first.detailsPreview, contains('"led":true'));
    expect(apiClient.capturedQueryParameters['/api/logs'], <String, dynamic>{
      'type': 'ONENET_COMMAND',
      'keyword': 'dev_1',
      'limit': 5,
    });
  });

  test(
    'PlatformLogRepository throws ApiException on business failure',
    () async {
      final repository = PlatformLogRepository(
        apiClient: _FakePlatformLogApiClient(
          responses: <String, Map<String, dynamic>>{
            '/api/logs/summary': <String, dynamic>{
              'code': 403,
              'msg': 'forbidden',
              'data': null,
            },
          },
        ),
      );

      await expectLater(
        repository.fetchSummary(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'forbidden',
          ),
        ),
      );
    },
  );
}

class _FakePlatformLogApiClient extends ApiClient {
  _FakePlatformLogApiClient({required this.responses})
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
  final Map<String, Map<String, dynamic>?> capturedQueryParameters =
      <String, Map<String, dynamic>?>{};

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    capturedQueryParameters[path] = queryParameters;
    return responses[path] ?? <String, dynamic>{'code': 0, 'msg': 'ok'};
  }
}

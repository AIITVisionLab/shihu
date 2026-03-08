import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/settings/service_health_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  test('ServiceHealthRepository parses health payload', () async {
    final repository = ServiceHealthRepository(
      apiClient: _FakeApiClient(
        responseJson: <String, dynamic>{
          'code': 200,
          'message': 'success',
          'data': <String, dynamic>{
            'status': 'up',
            'serviceName': 'shihu-detect-service',
            'serviceVersion': '1.0.0',
            'modelStatus': 'ready',
            'serverTime': '2026-03-08T15:30:00+08:00',
          },
        },
      ),
    );

    final healthInfo = await repository.fetchHealth();

    expect(healthInfo.status, 'up');
    expect(healthInfo.serviceName, 'shihu-detect-service');
    expect(healthInfo.serviceVersion, '1.0.0');
    expect(healthInfo.modelStatus, 'ready');
  });

  test(
    'ServiceHealthRepository throws ApiException when business code is not success',
    () async {
      final repository = ServiceHealthRepository(
        apiClient: _FakeApiClient(
          responseJson: <String, dynamic>{
            'code': 50301,
            'message': 'service unavailable',
            'data': null,
          },
        ),
      );

      await expectLater(
        repository.fetchHealth(),
        throwsA(
          isA<ApiException>()
              .having((error) => error.businessCode, 'businessCode', 50301)
              .having(
                (error) => error.message,
                'message',
                'service unavailable',
              ),
        ),
      );
    },
  );

  test(
    'ServiceHealthRepository throws ApiException when success response misses data',
    () async {
      final repository = ServiceHealthRepository(
        apiClient: _FakeApiClient(
          responseJson: <String, dynamic>{
            'code': 200,
            'message': 'success',
            'data': null,
          },
        ),
      );

      await expectLater(
        repository.fetchHealth(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            '健康检查返回成功，但缺少 data 数据体。',
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

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return responseJson;
  }
}

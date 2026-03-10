import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/settings/service_health_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  test(
    'ServiceHealthRepository parses /api/health plain string payload',
    () async {
      final apiClient = _FakeApiClient(
        responseJson: <String, dynamic>{'status': 'up'},
        rawResponse: 'ok',
      );
      final repository = ServiceHealthRepository(apiClient: apiClient);

      final healthInfo = await repository.fetchHealth();

      expect(healthInfo.status, 'up');
      expect(healthInfo.serviceName, '设备运行服务');
      expect(healthInfo.serviceVersion, '标准部署');
      expect(healthInfo.modelStatus, 'ready');
      expect(apiClient.capturedPath, '/api/health');
    },
  );

  test(
    'ServiceHealthRepository throws ApiException when /api/health returns unexpected payload',
    () async {
      final repository = ServiceHealthRepository(
        apiClient: _FakeApiClient(
          responseJson: <String, dynamic>{'status': 'up'},
          rawResponse: 123,
        ),
      );

      await expectLater(
        repository.fetchHealth(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            '健康检查返回了无法识别的数据格式。',
          ),
        ),
      );
    },
  );
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient({
    required this.responseJson,
    this.rawResponse,
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
  final Object? rawResponse;
  String? capturedPath;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    capturedPath = path;
    return responseJson;
  }

  @override
  Future<Object?> getRaw(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    capturedPath = path;
    return rawResponse;
  }
}

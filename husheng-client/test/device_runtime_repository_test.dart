import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/device/infrastructure/device_remote_runtime_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  test(
    'DeviceRuntimeRepository treats pending led status as accepted receipt',
    () async {
      final apiClient = _FakeApiClient(
        responseJson: <String, dynamic>{
          'status': 'pending',
          'requestId': 'req_001',
          'message': 'OneNET API调用失败,已登记到待处理队列',
        },
      );
      final repository = DeviceRemoteRuntimeRepository(apiClient: apiClient);

      final receipt = await repository.setLed(
        deviceId: 'dev_001',
        deviceName: '石斛培育柜',
        ledOn: true,
      );

      expect(apiClient.capturedPath, '/api/ops/led');
      expect(receipt.status, 'pending');
      expect(receipt.requestId, 'req_001');
      expect(receipt.isAcceptedLike, isTrue);
      expect(
        receipt.buildUserMessage(ledOn: true),
        'OneNET API调用失败,已登记到待处理队列（请求号：req_001）',
      );
    },
  );

  test(
    'DeviceRuntimeRepository throws backend message for led error status',
    () async {
      final repository = DeviceRemoteRuntimeRepository(
        apiClient: _FakeApiClient(
          responseJson: <String, dynamic>{
            'status': 'error',
            'requestId': null,
            'message': 'deviceId不能为空',
          },
        ),
      );

      await expectLater(
        repository.setLed(deviceId: '', deviceName: '石斛培育柜', ledOn: true),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'deviceId不能为空',
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
  String? capturedPath;

  @override
  Future<Map<String, dynamic>> postJson(String path, {Object? data}) async {
    capturedPath = path;
    return responseJson;
  }
}

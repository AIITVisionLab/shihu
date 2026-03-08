import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/auth/real_auth_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  test(
    'RealAuthRepository login posts credentials and maps session payload',
    () async {
      final apiClient = _FakeApiClient(
        responseJson: <String, dynamic>{
          'code': 200,
          'message': 'success',
          'data': <String, dynamic>{
            'accessToken': 'token_1',
            'refreshToken': 'refresh_1',
            'tokenType': 'Bearer',
            'expiresAt': '2026-03-09T12:00:00+08:00',
            'user': <String, dynamic>{
              'userId': 'user_demo',
              'account': 'demo',
              'displayName': '演示账号',
              'roles': const <String>['app_user'],
            },
          },
        },
      );
      final repository = RealAuthRepository(apiClient: apiClient);

      final session = await repository.login(
        account: ' demo ',
        password: 'demo123456',
      );

      expect(apiClient.capturedPath, '/api/v1/auth/login');
      expect(apiClient.capturedData?['account'], 'demo');
      expect(apiClient.capturedData?['password'], 'demo123456');
      expect(apiClient.capturedData?['platform'], currentPlatformType().value);
      expect(session.accessToken, 'token_1');
      expect(session.refreshToken, 'refresh_1');
      expect(session.loginMode, AuthLoginMode.real);
      expect(session.user.account, 'demo');
    },
  );

  test('RealAuthRepository refreshSession requires refresh token', () async {
    final repository = RealAuthRepository(
      apiClient: _FakeApiClient(
        responseJson: <String, dynamic>{
          'code': 200,
          'message': 'success',
          'data': null,
        },
      ),
    );

    await expectLater(
      repository.refreshSession(
        session: const AuthSession(
          accessToken: 'token_1',
          user: AuthUser(
            userId: 'user_demo',
            account: 'demo',
            displayName: '演示账号',
          ),
        ),
      ),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          '当前会话缺少 refreshToken，无法自动续期。',
        ),
      ),
    );
  });

  test(
    'RealAuthRepository refreshSession posts refresh token and maps response',
    () async {
      final apiClient = _FakeApiClient(
        responseJson: <String, dynamic>{
          'code': 200,
          'message': 'success',
          'data': <String, dynamic>{
            'accessToken': 'token_2',
            'refreshToken': 'refresh_2',
            'tokenType': 'Bearer',
            'expiresAt': '2026-03-10T12:00:00+08:00',
            'user': <String, dynamic>{
              'userId': 'user_demo',
              'account': 'demo',
              'displayName': '演示账号',
              'roles': const <String>['app_user'],
            },
          },
        },
      );
      final repository = RealAuthRepository(apiClient: apiClient);

      final session = await repository.refreshSession(
        session: const AuthSession(
          accessToken: 'token_1',
          refreshToken: 'refresh_1',
          user: AuthUser(
            userId: 'user_demo',
            account: 'demo',
            displayName: '演示账号',
          ),
        ),
      );

      expect(apiClient.capturedPath, '/api/v1/auth/refresh');
      expect(apiClient.capturedData?['refreshToken'], 'refresh_1');
      expect(apiClient.capturedData?['platform'], currentPlatformType().value);
      expect(session.accessToken, 'token_2');
      expect(session.refreshToken, 'refresh_2');
    },
  );

  test(
    'RealAuthRepository logout posts refresh token to logout endpoint',
    () async {
      final apiClient = _FakeApiClient(
        responseJson: <String, dynamic>{
          'code': 200,
          'message': 'success',
          'data': null,
        },
      );
      final repository = RealAuthRepository(apiClient: apiClient);

      await repository.logout(
        session: const AuthSession(
          accessToken: 'token_1',
          refreshToken: 'refresh_1',
          user: AuthUser(
            userId: 'user_demo',
            account: 'demo',
            displayName: '演示账号',
          ),
        ),
      );

      expect(apiClient.capturedPath, '/api/v1/auth/logout');
      expect(apiClient.capturedData?['refreshToken'], 'refresh_1');
      expect(apiClient.capturedData?['platform'], currentPlatformType().value);
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
  Map<String, dynamic>? capturedData;

  @override
  Future<Map<String, dynamic>> postJson(String path, {Object? data}) async {
    capturedPath = path;
    capturedData = data as Map<String, dynamic>?;
    return responseJson;
  }
}

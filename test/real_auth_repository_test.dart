import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/auth/real_auth_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  test('RealAuthRepository login posts credentials to /api/login', () async {
    final apiClient = _FakeApiClient(
      responseJson: <String, dynamic>{'success': true, 'message': '登录成功'},
    );
    final repository = RealAuthRepository(apiClient: apiClient);

    final session = await repository.login(
      username: ' demo ',
      password: 'demo123456',
    );

    expect(apiClient.capturedPath, '/api/login');
    expect(apiClient.capturedData?['username'], 'demo');
    expect(apiClient.capturedData?['password'], 'demo123456');
    expect(session.accessToken, isNotEmpty);
    expect(session.refreshToken, isNull);
    expect(session.sessionCookie, 'JSESSIONID=test-session');
    expect(session.loginMode, AuthLoginMode.real);
    expect(session.user.account, 'demo');
  });

  test(
    'RealAuthRepository refreshSession throws when backend session is lost',
    () async {
      final repository = RealAuthRepository(
        apiClient: _FakeApiClient(
          responseJson: <String, dynamic>{'loggedIn': false},
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
            '本地登录态已过期，请重新登录。',
          ),
        ),
      );
    },
  );

  test('RealAuthRepository refreshSession checks /api/check-login', () async {
    final apiClient = _FakeApiClient(
      responseJson: <String, dynamic>{'loggedIn': true, 'username': 'demo'},
    );
    final repository = RealAuthRepository(apiClient: apiClient);

    final session = await repository.refreshSession(
      session: const AuthSession(
        accessToken: 'token_1',
        sessionCookie: 'JSESSIONID=test-session',
        user: AuthUser(
          userId: 'user_demo',
          account: 'demo',
          displayName: '演示账号',
        ),
      ),
    );

    expect(apiClient.capturedPath, '/api/check-login');
    expect(session.accessToken, 'token_1');
    expect(session.user.account, 'demo');
  });

  test(
    'RealAuthRepository register posts credentials to /api/register',
    () async {
      final apiClient = _FakeApiClient(
        responseJson: <String, dynamic>{
          'success': true,
          'message': '注册成功，请使用新账号登录',
        },
      );
      final repository = RealAuthRepository(apiClient: apiClient);

      final message = await repository.register(
        username: ' demo_user ',
        password: 'demo123456',
        confirmPassword: 'demo123456',
      );

      expect(apiClient.capturedPath, '/api/register');
      expect(apiClient.capturedData?['username'], 'demo_user');
      expect(apiClient.capturedData?['password'], 'demo123456');
      expect(apiClient.capturedData?['confirmPassword'], 'demo123456');
      expect(message, '注册成功，请使用新账号登录');
    },
  );

  test('RealAuthRepository logout posts to /api/logout', () async {
    final apiClient = _FakeApiClient(
      responseJson: <String, dynamic>{'success': true, 'message': '已登出'},
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

    expect(apiClient.capturedPath, '/api/logout');
  });
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
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    capturedPath = path;
    return responseJson;
  }

  @override
  Future<Map<String, dynamic>> postJson(String path, {Object? data}) async {
    capturedPath = path;
    capturedData = data as Map<String, dynamic>?;
    return responseJson;
  }

  @override
  Future<Response<Map<String, dynamic>>> postJsonDetailed(
    String path, {
    Object? data,
  }) async {
    capturedPath = path;
    capturedData = data as Map<String, dynamic>?;
    return Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: path),
      data: responseJson,
      headers: Headers.fromMap(<String, List<String>>{
        'set-cookie': const <String>[
          'JSESSIONID=test-session; Path=/; HttpOnly',
        ],
      }),
    );
  }
}

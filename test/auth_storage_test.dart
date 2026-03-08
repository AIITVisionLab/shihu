import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/storage/auth_storage.dart';
import 'package:sickandflutter/core/storage/sensitive_storage.dart';

void main() {
  test('AuthStorage reads persisted session', () async {
    final storage = AuthStorage(
      VolatileSensitiveStorage(
        values: <String, String>{
          AppConstants.authSessionStorageKey:
              '{"accessToken":"token_1","refreshToken":"refresh_1","tokenType":"Bearer","expiresAt":"2026-03-09T12:00:00+08:00","loginModeLabel":"受控演示登录","user":{"userId":"user_demo","account":"demo","displayName":"演示账号","roles":["app_user"]}}',
        },
      ),
    );

    final session = await storage.readSession();

    expect(session, isNotNull);
    expect(session?.accessToken, 'token_1');
    expect(session?.user.account, 'demo');
    expect(session?.user.roles, contains('app_user'));
  });

  test('AuthStorage returns null for malformed payload', () async {
    final storage = AuthStorage(
      VolatileSensitiveStorage(
        values: <String, String>{
          AppConstants.authSessionStorageKey: '{broken-json',
        },
      ),
    );

    expect(await storage.readSession(), isNull);
  });
}

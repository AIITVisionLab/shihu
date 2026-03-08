import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/storage/auth_storage.dart';
import 'package:sickandflutter/core/storage/local_storage.dart';

void main() {
  test('AuthStorage reads persisted session', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppConstants.authSessionStorageKey:
          '{"accessToken":"token_1","refreshToken":"refresh_1","tokenType":"Bearer","expiresAt":"2026-03-09T12:00:00+08:00","loginModeLabel":"受控演示登录","user":{"userId":"user_demo","account":"demo","displayName":"演示账号","roles":["app_user"]}}',
    });

    final preferences = await SharedPreferences.getInstance();
    final storage = AuthStorage(LocalStorage(preferences));

    final session = storage.readSession();

    expect(session, isNotNull);
    expect(session?.accessToken, 'token_1');
    expect(session?.user.account, 'demo');
    expect(session?.user.roles, contains('app_user'));
  });

  test('AuthStorage returns null for malformed payload', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppConstants.authSessionStorageKey: '{broken-json',
    });

    final preferences = await SharedPreferences.getInstance();
    final storage = AuthStorage(LocalStorage(preferences));

    expect(storage.readSession(), isNull);
  });
}

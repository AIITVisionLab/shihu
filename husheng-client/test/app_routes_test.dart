import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';

void main() {
  test('redirectForAuth sends anonymous users to login page', () {
    const authState = AuthState(isBootstrapping: false);

    final redirect = redirectForAuth(
      authState: authState,
      matchedLocation: AppRoutes.homePath,
    );

    expect(redirect, AppRoutes.loginPath);
  });

  test('redirectForAuth keeps public about page accessible', () {
    const authState = AuthState(isBootstrapping: false);

    final redirect = redirectForAuth(
      authState: authState,
      matchedLocation: AppRoutes.aboutPath,
    );

    expect(redirect, isNull);
  });

  test('redirectForAuth keeps splash page under splash bootstrap control', () {
    const authState = AuthState(isBootstrapping: false);

    final redirect = redirectForAuth(
      authState: authState,
      matchedLocation: AppRoutes.splashPath,
    );

    expect(redirect, isNull);
  });

  test('redirectForAuth sends authenticated users away from login page', () {
    const authState = AuthState(
      isBootstrapping: false,
      session: AuthSession(
        accessToken: 'token_1',
        user: AuthUser(
          userId: 'user_demo',
          account: 'demo',
          displayName: '演示账号',
        ),
      ),
    );

    final redirect = redirectForAuth(
      authState: authState,
      matchedLocation: AppRoutes.loginPath,
    );

    expect(redirect, AppRoutes.realtimeDetectPath);
  });

  test('redirectForAuth keeps authenticated protected page accessible', () {
    const authState = AuthState(
      isBootstrapping: false,
      session: AuthSession(
        accessToken: 'token_1',
        user: AuthUser(
          userId: 'user_demo',
          account: 'demo',
          displayName: '演示账号',
        ),
      ),
    );

    final redirect = redirectForAuth(
      authState: authState,
      matchedLocation: AppRoutes.settingsPath,
    );

    expect(redirect, isNull);
  });
}

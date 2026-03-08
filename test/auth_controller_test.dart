import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/storage/auth_storage.dart';
import 'package:sickandflutter/core/storage/local_storage.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_repository.dart';
import 'package:sickandflutter/features/auth/mock_auth_repository.dart';

void main() {
  test('AuthController restores persisted session on bootstrap', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppConstants.authSessionStorageKey:
          '{"accessToken":"token_1","refreshToken":"refresh_1","tokenType":"Bearer","expiresAt":"2099-03-09T12:00:00+08:00","loginModeLabel":"受控演示登录","user":{"userId":"user_demo","account":"demo","displayName":"演示账号","roles":["app_user"]}}',
    });
    final preferences = await SharedPreferences.getInstance();
    final authStorage = AuthStorage(LocalStorage(preferences));

    final container = ProviderContainer(
      overrides: [
        authStorageProvider.overrideWith((ref) async => authStorage),
        authRepositoryProvider.overrideWith(
          (ref) => const MockAuthRepository(responseDelay: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.notifier).ensureInitialized();
    final authState = container.read(authControllerProvider);

    expect(authState.isBootstrapping, isFalse);
    expect(authState.isAuthenticated, isTrue);
    expect(authState.session?.user.account, 'demo');
  });

  test('AuthController logs in and logs out successfully', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final authStorage = AuthStorage(LocalStorage(preferences));

    final container = ProviderContainer(
      overrides: [
        authStorageProvider.overrideWith((ref) async => authStorage),
        authRepositoryProvider.overrideWith(
          (ref) => const MockAuthRepository(responseDelay: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authControllerProvider.notifier);
    await notifier.ensureInitialized();

    final loginSuccess = await notifier.login(
      account: MockAuthRepository.demoAccount,
      password: MockAuthRepository.demoPassword,
    );

    expect(loginSuccess, isTrue);
    expect(container.read(authControllerProvider).isAuthenticated, isTrue);
    expect(authStorage.readSession(), isNotNull);

    await notifier.logout();

    expect(container.read(authControllerProvider).isAuthenticated, isFalse);
    expect(authStorage.readSession(), isNull);
  });

  test('AuthController clears session when unauthorized is reported', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final authStorage = AuthStorage(LocalStorage(preferences));

    final container = ProviderContainer(
      overrides: [
        authStorageProvider.overrideWith((ref) async => authStorage),
        authRepositoryProvider.overrideWith(
          (ref) => const MockAuthRepository(responseDelay: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authControllerProvider.notifier);
    await notifier.ensureInitialized();
    await notifier.login(
      account: MockAuthRepository.demoAccount,
      password: MockAuthRepository.demoPassword,
    );

    notifier.handleUnauthorized(message: '登录状态已失效，请重新登录。');
    await Future<void>.delayed(Duration.zero);

    final authState = container.read(authControllerProvider);
    expect(authState.isAuthenticated, isFalse);
    expect(authState.unauthorizedMessage, '登录状态已失效，请重新登录。');
  });
}

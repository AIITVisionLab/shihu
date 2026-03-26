import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/storage/auth_storage.dart';
import 'package:sickandflutter/core/storage/sensitive_storage.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_repository.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/auth/mock_auth_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  test('AuthController restores persisted session on bootstrap', () async {
    final authStorage = AuthStorage(
      VolatileSensitiveStorage(
        values: <String, String>{
          AppConstants.authSessionStorageKey:
              '{"accessToken":"token_1","refreshToken":"refresh_1","tokenType":"Bearer","expiresAt":"2099-03-09T12:00:00+08:00","loginModeLabel":"受控演示登录","user":{"userId":"user_demo","account":"demo","displayName":"演示账号","roles":["app_user"]}}',
        },
      ),
    );

    final container = ProviderContainer(
      overrides: [
        authStorageProvider.overrideWith((ref) => authStorage),
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
    final authStorage = AuthStorage(
      VolatileSensitiveStorage(values: <String, String>{}),
    );

    final container = ProviderContainer(
      overrides: [
        authStorageProvider.overrideWith((ref) => authStorage),
        authRepositoryProvider.overrideWith(
          (ref) => const MockAuthRepository(responseDelay: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authControllerProvider.notifier);
    await notifier.ensureInitialized();

    final loginSuccess = await notifier.login(
      username: MockAuthRepository.demoAccount,
      password: MockAuthRepository.demoPassword,
    );

    expect(loginSuccess, isTrue);
    expect(container.read(authControllerProvider).isAuthenticated, isTrue);
    expect(await authStorage.readSession(), isNotNull);

    await notifier.logout();

    expect(container.read(authControllerProvider).isAuthenticated, isFalse);
    expect(await authStorage.readSession(), isNull);
  });

  test(
    'AuthController registers without creating authenticated session',
    () async {
      final authStorage = AuthStorage(
        VolatileSensitiveStorage(values: <String, String>{}),
      );
      final authRepository = _RegisteringAuthRepository();

      final container = ProviderContainer(
        overrides: [
          authStorageProvider.overrideWith((ref) => authStorage),
          authRepositoryProvider.overrideWith((ref) => authRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authControllerProvider.notifier);
      await notifier.ensureInitialized();

      final message = await notifier.register(
        username: 'new_user',
        password: 'demo123456',
        confirmPassword: 'demo123456',
      );

      expect(message, '注册成功，请使用新账号登录。');
      expect(container.read(authControllerProvider).isAuthenticated, isFalse);
      expect(await authStorage.readSession(), isNull);
    },
  );

  test('AuthController clears session when unauthorized is reported', () async {
    final authStorage = AuthStorage(
      VolatileSensitiveStorage(values: <String, String>{}),
    );

    final container = ProviderContainer(
      overrides: [
        authStorageProvider.overrideWith((ref) => authStorage),
        authRepositoryProvider.overrideWith(
          (ref) => const MockAuthRepository(responseDelay: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authControllerProvider.notifier);
    await notifier.ensureInitialized();
    await notifier.login(
      username: MockAuthRepository.demoAccount,
      password: MockAuthRepository.demoPassword,
    );

    notifier.handleUnauthorized(message: '登录状态已失效，请重新登录。');
    await Future<void>.delayed(Duration.zero);

    final authState = container.read(authControllerProvider);
    expect(authState.isAuthenticated, isFalse);
    expect(authState.unauthorizedMessage, '登录状态已失效，请重新登录。');
  });

  test('AuthController validates persisted real session on bootstrap', () async {
    final authStorage = AuthStorage(
      VolatileSensitiveStorage(
        values: <String, String>{
          AppConstants.authSessionStorageKey:
              '{"accessToken":"session:1","sessionCookie":"JSESSIONID=test-session","tokenType":"Session","loginMode":"real","user":{"userId":"demo","account":"demo","displayName":"demo","roles":[]}}',
        },
      ),
    );
    final authRepository = _RefreshingAuthRepository();

    final container = ProviderContainer(
      overrides: [
        authStorageProvider.overrideWith((ref) => authStorage),
        authRepositoryProvider.overrideWith((ref) => authRepository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.notifier).ensureInitialized();

    final authState = container.read(authControllerProvider);
    expect(authRepository.refreshCount, 1);
    expect(authState.isAuthenticated, isTrue);
    expect(authState.session?.user.displayName, 'demo');
  });

  test(
    'AuthController can enter preview workspace without real backend',
    () async {
      final authStorage = AuthStorage(
        VolatileSensitiveStorage(values: <String, String>{}),
      );

      final container = ProviderContainer(
        overrides: [
          authStorageProvider.overrideWith((ref) => authStorage),
          authRepositoryProvider.overrideWith(
            (ref) => const MockAuthRepository(responseDelay: Duration.zero),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authControllerProvider.notifier);
      await notifier.enterPreviewWorkspace();

      final authState = container.read(authControllerProvider);
      expect(authState.isAuthenticated, isTrue);
      expect(authState.session?.user.displayName, '界面预览');
      expect(authState.session?.loginMode, AuthLoginMode.mock);
      expect(await authStorage.readSession(), isNotNull);
    },
  );
}

class _RefreshingAuthRepository implements AuthRepository {
  int refreshCount = 0;

  @override
  bool get isMockMode => false;

  @override
  AuthLoginMode get loginMode => AuthLoginMode.real;

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String> register({
    required String username,
    required String password,
    required String confirmPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout({required AuthSession session}) async {}

  @override
  Future<AuthSession> refreshSession({required AuthSession session}) async {
    refreshCount += 1;
    return session.copyWith(
      user: const AuthUser(
        userId: 'demo',
        account: 'demo',
        displayName: 'demo',
      ),
    );
  }
}

class _RegisteringAuthRepository implements AuthRepository {
  @override
  bool get isMockMode => false;

  @override
  AuthLoginMode get loginMode => AuthLoginMode.real;

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout({required AuthSession session}) async {}

  @override
  Future<String> register({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    return '注册成功，请使用新账号登录。';
  }

  @override
  Future<AuthSession> refreshSession({required AuthSession session}) {
    throw UnimplementedError();
  }
}

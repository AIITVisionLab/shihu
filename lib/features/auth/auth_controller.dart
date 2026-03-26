import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/core/storage/auth_storage.dart';
import 'package:sickandflutter/features/auth/auth_repository.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

/// 认证状态入口。
final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// 管理登录态恢复、登录、退出和未授权清理。
class AuthController extends Notifier<AuthState> {
  Future<void>? _bootstrapFuture;
  Future<void>? _refreshFuture;

  @override
  AuthState build() {
    unawaited(ensureInitialized());
    return const AuthState(isBootstrapping: true);
  }

  /// 确保登录态已完成初始化恢复。
  Future<void> ensureInitialized() {
    return _bootstrapFuture ??= _restoreSession();
  }

  /// 使用用户名密码执行登录。
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    await ensureInitialized();

    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: AppCopy.authInputRequired);
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      unauthorizedMessage: null,
    );

    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(username: normalizedUsername, password: password);
      await _persistSession(session);
      state = state.copyWith(
        isBootstrapping: false,
        isSubmitting: false,
        session: session,
        errorMessage: null,
        unauthorizedMessage: null,
      );
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        isBootstrapping: false,
        isSubmitting: false,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isBootstrapping: false,
        isSubmitting: false,
        errorMessage: AppCopy.authLoginFailedRetry,
      );
      return false;
    }
  }

  /// 使用用户名密码执行注册，不自动写入登录态。
  Future<String?> register({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    await ensureInitialized();

    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      state = state.copyWith(errorMessage: AppCopy.authRegisterInputRequired);
      return null;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]{3,32}$').hasMatch(normalizedUsername)) {
      state = state.copyWith(errorMessage: AppCopy.authRegisterAccountInvalid);
      return null;
    }
    if (password.length < 6 || password.length > 32) {
      state = state.copyWith(
        errorMessage: AppCopy.authRegisterPasswordLengthInvalid,
      );
      return null;
    }

    if (password != confirmPassword) {
      state = state.copyWith(
        errorMessage: AppCopy.authRegisterPasswordMismatch,
      );
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      unauthorizedMessage: null,
    );

    try {
      final message = await ref
          .read(authRepositoryProvider)
          .register(
            username: normalizedUsername,
            password: password,
            confirmPassword: confirmPassword,
          );
      state = state.copyWith(
        isBootstrapping: false,
        isSubmitting: false,
        errorMessage: null,
        unauthorizedMessage: null,
      );
      return message;
    } on ApiException catch (error) {
      state = state.copyWith(
        isBootstrapping: false,
        isSubmitting: false,
        errorMessage: error.message,
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        isBootstrapping: false,
        isSubmitting: false,
        errorMessage: AppCopy.authRegisterFailedRetry,
      );
      return null;
    }
  }

  /// 执行本地退出，并尽量通知后端。
  Future<void> logout({bool notifyServer = true}) async {
    await ensureInitialized();

    final currentSession = state.session;
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    if (notifyServer && currentSession != null) {
      try {
        await ref.read(authRepositoryProvider).logout(session: currentSession);
      } on ApiException {
        // 本地退出不能被远端失败阻塞。
      } catch (_) {
        // 本地退出不能被远端失败阻塞。
      }
    }

    await _clearSession();
    state = state.copyWith(
      isBootstrapping: false,
      isSubmitting: false,
      session: null,
      errorMessage: null,
    );
  }

  /// 直接写入一份本地预览会话，用于在非正式环境查看完整界面。
  Future<void> enterPreviewWorkspace() async {
    await ensureInitialized();

    final now = DateTime.now();
    final session = AuthSession(
      accessToken: 'preview_${now.microsecondsSinceEpoch}',
      refreshToken: 'preview_refresh_${now.microsecondsSinceEpoch}',
      tokenType: 'Bearer',
      expiresAt: now.add(const Duration(hours: 8)).toIso8601String(),
      loginMode: AuthLoginMode.mock,
      user: const AuthUser(
        userId: 'preview_user',
        account: 'preview',
        displayName: '界面预览',
        roles: <String>['app_user'],
      ),
    );

    await _persistSession(session);
    state = state.copyWith(
      isBootstrapping: false,
      isSubmitting: false,
      session: session,
      errorMessage: null,
      unauthorizedMessage: null,
    );
  }

  /// 处理网络层或仓储层回传的未授权状态。
  void handleUnauthorized({String? message}) {
    final effectiveMessage = (message == null || message.trim().isEmpty)
        ? AppCopy.authUnauthorized
        : message.trim();

    if (!state.isAuthenticated &&
        state.unauthorizedMessage == effectiveMessage) {
      return;
    }

    unawaited(_handleUnauthorizedInternal(effectiveMessage));
  }

  /// 刷新当前登录会话。
  Future<bool> refreshSession() async {
    await ensureInitialized();

    if (_refreshFuture != null) {
      await _refreshFuture;
      return state.isAuthenticated;
    }

    final currentSession = state.session;
    if (currentSession == null) {
      return false;
    }

    _refreshFuture = _refreshSessionInternal(currentSession);
    await _refreshFuture;
    _refreshFuture = null;
    return state.isAuthenticated;
  }

  /// 清空当前错误提示。
  void clearErrorMessage() {
    if (state.errorMessage == null) {
      return;
    }

    state = state.copyWith(errorMessage: null);
  }

  /// 清空当前错误和未授权提示。
  void clearMessages() {
    if (state.errorMessage == null && state.unauthorizedMessage == null) {
      return;
    }

    state = state.copyWith(errorMessage: null, unauthorizedMessage: null);
  }

  Future<void> _restoreSession() async {
    try {
      final storage = ref.read(authStorageProvider);
      final restoredSession = await storage.readSession();

      if (restoredSession == null) {
        state = state.copyWith(isBootstrapping: false, session: null);
        return;
      }

      if (restoredSession.loginMode == AuthLoginMode.real) {
        state = state.copyWith(session: restoredSession);
        await _refreshSessionInternal(restoredSession);
        if (state.isAuthenticated) {
          state = state.copyWith(isBootstrapping: false);
          return;
        }

        state = state.copyWith(isBootstrapping: false);
        return;
      }

      if (restoredSession.isExpired && restoredSession.hasRefreshToken) {
        state = state.copyWith(session: restoredSession);
        await _refreshSessionInternal(restoredSession);
        if (state.isAuthenticated) {
          state = state.copyWith(isBootstrapping: false);
          return;
        }
      }

      if (restoredSession.isExpired) {
        await _clearSession();
        state = state.copyWith(
          isBootstrapping: false,
          session: null,
          unauthorizedMessage: AppCopy.authSessionExpired,
        );
        return;
      }

      state = state.copyWith(
        isBootstrapping: false,
        session: restoredSession,
        unauthorizedMessage: null,
      );
    } catch (_) {
      state = state.copyWith(
        isBootstrapping: false,
        session: null,
        errorMessage: AppCopy.authRestoreFailed(),
      );
    }
  }

  Future<void> _persistSession(AuthSession session) async {
    final storage = ref.read(authStorageProvider);
    await storage.writeSession(session);
  }

  Future<void> _clearSession() async {
    final storage = ref.read(authStorageProvider);
    await storage.clearSession();
  }

  Future<void> _handleUnauthorizedInternal(String message) async {
    await _clearSession();
    state = state.copyWith(
      isBootstrapping: false,
      isSubmitting: false,
      session: null,
      errorMessage: null,
      unauthorizedMessage: message,
    );
  }

  Future<void> _refreshSessionInternal(AuthSession currentSession) async {
    try {
      final refreshedSession = await ref
          .read(authRepositoryProvider)
          .refreshSession(session: currentSession);
      await _persistSession(refreshedSession);
      state = state.copyWith(
        isBootstrapping: false,
        session: refreshedSession,
        errorMessage: null,
        unauthorizedMessage: null,
      );
    } on ApiException catch (error) {
      await _handleUnauthorizedInternal(error.message);
    } catch (_) {
      await _handleUnauthorizedInternal(AppCopy.authRefreshFailed());
    }
  }
}

const Object _authStateUnset = Object();

/// 应用级认证状态。
class AuthState {
  /// 创建认证状态对象。
  const AuthState({
    this.isBootstrapping = false,
    this.isSubmitting = false,
    this.session,
    this.errorMessage,
    this.unauthorizedMessage,
  });

  /// 是否仍在恢复本地登录态。
  final bool isBootstrapping;

  /// 当前是否正在提交登录或退出操作。
  final bool isSubmitting;

  /// 当前会话。
  final AuthSession? session;

  /// 最近一次普通错误信息。
  final String? errorMessage;

  /// 最近一次未授权提示。
  final String? unauthorizedMessage;

  /// 当前是否已登录。
  bool get isAuthenticated => session != null;

  /// 返回带增量修改的新状态对象。
  AuthState copyWith({
    bool? isBootstrapping,
    bool? isSubmitting,
    Object? session = _authStateUnset,
    Object? errorMessage = _authStateUnset,
    Object? unauthorizedMessage = _authStateUnset,
  }) {
    return AuthState(
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      session: identical(session, _authStateUnset)
          ? this.session
          : session as AuthSession?,
      errorMessage: identical(errorMessage, _authStateUnset)
          ? this.errorMessage
          : errorMessage as String?,
      unauthorizedMessage: identical(unauthorizedMessage, _authStateUnset)
          ? this.unauthorizedMessage
          : unauthorizedMessage as String?,
    );
  }
}

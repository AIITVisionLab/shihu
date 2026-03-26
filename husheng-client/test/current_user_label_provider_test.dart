import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/auth/application/current_user_label_provider.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  test('currentUserLabelProvider prefers display name', () {
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(
          () => _TestAuthController(
            initialState: const AuthState(
              session: AuthSession(
                accessToken: 'token_demo',
                loginMode: AuthLoginMode.real,
                user: AuthUser(
                  userId: 'user_1',
                  account: 'ops_admin',
                  displayName: '值守人员',
                  roles: <String>['admin'],
                ),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(currentUserLabelProvider), '值守人员');
  });

  test('currentUserLabelProvider falls back to account and placeholder', () {
    final accountFallbackContainer = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(
          () => _TestAuthController(
            initialState: const AuthState(
              session: AuthSession(
                accessToken: 'token_demo',
                loginMode: AuthLoginMode.real,
                user: AuthUser(
                  userId: 'user_1',
                  account: 'ops_admin',
                  displayName: '   ',
                  roles: <String>['admin'],
                ),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(accountFallbackContainer.dispose);

    expect(
      accountFallbackContainer.read(currentUserLabelProvider),
      'ops_admin',
    );

    final placeholderContainer = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(
          () => _TestAuthController(initialState: const AuthState()),
        ),
      ],
    );
    addTearDown(placeholderContainer.dispose);

    expect(placeholderContainer.read(currentUserLabelProvider), '--');
  });
}

class _TestAuthController extends AuthController {
  _TestAuthController({required this.initialState});

  final AuthState initialState;

  @override
  AuthState build() => initialState;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/about/about_page.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  testWidgets('AboutPage renders workflow and collaboration guidance', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => _TestAuthController(
              initialState: const AuthState(
                session: AuthSession(
                  accessToken: 'session_demo',
                  loginMode: AuthLoginMode.real,
                  user: AuthUser(
                    userId: 'user_1',
                    account: 'tester',
                    displayName: '联调用户',
                    roles: <String>['admin'],
                  ),
                ),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: AboutPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('工作说明'), findsWidgets);
    expect(find.text('返回总览'), findsOneWidget);
    expect(find.text('进入值守'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('主路径怎么走'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('主路径怎么走'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('视频与 AI 协作边界'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('视频与 AI 协作边界'), findsOneWidget);
    expect(find.text('Java 后端只负责告诉前端去哪里播放'), findsOneWidget);
    expect(find.text('Java 后端先接结果，再决定怎么给前端展示'), findsOneWidget);
  });

  testWidgets('AboutPage shows login entry for anonymous users', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => _TestAuthController(
              initialState: const AuthState(isBootstrapping: false),
            ),
          ),
        ],
        child: const MaterialApp(home: AboutPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('立即登录'), findsOneWidget);
    expect(find.text('返回总览'), findsNothing);
  });
}

class _TestAuthController extends AuthController {
  _TestAuthController({required this.initialState});

  final AuthState initialState;

  @override
  AuthState build() => initialState;
}

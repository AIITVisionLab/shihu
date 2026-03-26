import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/settings/domain/settings_profile_snapshot.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  group('SettingsProfileSnapshot', () {
    test('builds online session snapshot with remembered account', () {
      const authState = AuthState(
        session: AuthSession(
          accessToken: 'token_demo',
          loginMode: AuthLoginMode.real,
          user: AuthUser(
            userId: 'user_1',
            account: 'ops_admin',
            displayName: '运维账号',
          ),
        ),
      );

      final snapshot = SettingsProfileSnapshot.fromState(
        authState: authState,
        supportsPersistentSession: true,
        rememberedAccount: 'ops_admin',
      );

      expect(snapshot.headerTag, '常用操作');
      expect(snapshot.accountLabel, 'ops_admin');
      expect(snapshot.sessionLabel, '在线会话');
      expect(snapshot.rememberedLabel, 'ops_admin');
      expect(snapshot.rememberedBadgeLabel, '下次登录自动回填');
      expect(snapshot.persistenceLabel, '支持长期保持');
      expect(snapshot.showPreviewNotice, isFalse);
      expect(snapshot.showPersistenceWarning, isFalse);
    });

    test('builds preview snapshot without remembered account', () {
      const authState = AuthState(
        session: AuthSession(
          accessToken: 'token_demo',
          loginMode: AuthLoginMode.mock,
          user: AuthUser(
            userId: 'user_2',
            account: 'demo',
            displayName: '预览账号',
          ),
        ),
      );

      final snapshot = SettingsProfileSnapshot.fromState(
        authState: authState,
        supportsPersistentSession: false,
        rememberedAccount: '  ',
      );

      expect(snapshot.sessionLabel, '界面预览');
      expect(snapshot.rememberedLabel, '当前未保存');
      expect(snapshot.rememberedBadgeLabel, '未保存账号');
      expect(snapshot.persistenceLabel, '关闭应用后需重登');
      expect(snapshot.showPreviewNotice, isTrue);
      expect(snapshot.showPersistenceWarning, isTrue);
    });
  });
}

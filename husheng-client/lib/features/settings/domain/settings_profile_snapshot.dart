import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

/// 设置页“账号与本机”主卡使用的展示快照。
///
/// 页面和组件不再各自拼接账号、会话和本机提示文案，统一由这里派生。
class SettingsProfileSnapshot {
  /// 创建展示快照。
  const SettingsProfileSnapshot({
    required this.headerTag,
    required this.accountLabel,
    required this.accountHint,
    required this.sessionLabel,
    required this.statusMessage,
    required this.rememberedLabel,
    required this.rememberedHint,
    required this.persistenceLabel,
    required this.persistenceHint,
    required this.rememberedBadgeLabel,
    required this.showPreviewNotice,
    required this.showPersistenceWarning,
  });

  /// 由当前认证状态和本机信息生成展示快照。
  factory SettingsProfileSnapshot.fromState({
    required AuthState authState,
    required bool supportsPersistentSession,
    required String? rememberedAccount,
  }) {
    final session = authState.session;
    final normalizedAccount = session?.user.account.trim();
    final normalizedRememberedAccount = rememberedAccount?.trim();
    final hasSession = session != null;
    final hasRememberedAccount =
        normalizedRememberedAccount != null &&
        normalizedRememberedAccount.isNotEmpty;

    return SettingsProfileSnapshot(
      headerTag: hasSession ? '常用操作' : '未登录',
      accountLabel: normalizedAccount == null || normalizedAccount.isEmpty
          ? '未登录'
          : normalizedAccount,
      accountHint: hasSession
          ? AppCopy.settingsProfileAccountHint
          : AppCopy.settingsUnauthenticated,
      sessionLabel: !hasSession
          ? '待登录'
          : session.loginMode == AuthLoginMode.mock
          ? '界面预览'
          : '在线会话',
      statusMessage: authState.isSubmitting
          ? AppCopy.settingsProfileStatusSubmitting
          : hasSession
          ? AppCopy.settingsProfileStatusReady
          : AppCopy.settingsUnauthenticated,
      rememberedLabel: hasRememberedAccount
          ? normalizedRememberedAccount
          : AppCopy.settingsRememberedAccountMissing,
      rememberedHint: hasRememberedAccount
          ? AppCopy.settingsRememberedAccountSavedHint
          : AppCopy.settingsRememberedAccountEmptyHint,
      persistenceLabel: supportsPersistentSession ? '支持长期保持' : '关闭应用后需重登',
      persistenceHint: supportsPersistentSession
          ? AppCopy.settingsProfilePersistenceSupportedHint
          : AppCopy.settingsProfilePersistenceLimitedHint,
      rememberedBadgeLabel: hasRememberedAccount ? '下次登录自动回填' : '未保存账号',
      showPreviewNotice: session?.loginMode == AuthLoginMode.mock,
      showPersistenceWarning: !supportsPersistentSession,
    );
  }

  /// 标题标签。
  final String headerTag;

  /// 当前账号标签。
  final String accountLabel;

  /// 当前账号说明。
  final String accountHint;

  /// 当前会话状态。
  final String sessionLabel;

  /// 当前状态提示。
  final String statusMessage;

  /// 已记住账号显示值。
  final String rememberedLabel;

  /// 记住账号说明。
  final String rememberedHint;

  /// 本机登录态保留状态。
  final String persistenceLabel;

  /// 本机登录态说明。
  final String persistenceHint;

  /// 记住账号状态标签。
  final String rememberedBadgeLabel;

  /// 是否展示界面预览提示。
  final bool showPreviewNotice;

  /// 是否展示登录态持久化警告。
  final bool showPersistenceWarning;
}

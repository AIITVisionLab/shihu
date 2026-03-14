import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 设置页登录会话卡片。
class SettingsAuthSessionCard extends StatelessWidget {
  /// 创建登录会话卡片。
  const SettingsAuthSessionCard({
    required this.authState,
    required this.supportsPersistentSession,
    required this.onLogout,
    super.key,
  });

  /// 当前认证状态。
  final AuthState authState;

  /// 当前平台是否支持持久化登录态。
  final bool supportsPersistentSession;

  /// 退出登录回调。
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final session = authState.session;

    return CommonCard(
      title: AppCopy.settingsSessionTitle,
      subtitle: session == null
          ? AppCopy.settingsNoSession
          : AppCopy.settingsSessionSubtitle,
      child: session == null
          ? const Text(AppCopy.settingsUnauthenticated)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FeatureInsetPanel(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 24,
                  accentColor: AppPalette.softPine,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '当前账号',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        session.user.account,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '当前保持登录状态，需要更换账号时再从这里退出。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FeatureInsetPanel(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 20,
                  accentColor: AppPalette.mistMint,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppPalette.mistMint.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          authState.isSubmitting
                              ? '正在处理账号操作。'
                              : '当前已登录，可以直接继续使用。',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                height: 1.54,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!supportsPersistentSession) ...<Widget>[
                  const SizedBox(height: 16),
                  FeatureInsetPanel(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 20,
                    accentColor: AppPalette.linenOlive,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppPalette.linenOlive.withValues(
                              alpha: 0.32,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                AppCopy.settingsSessionPersistenceWarningTitle,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppCopy
                                    .settingsSessionPersistenceWarningMessage,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      height: 1.54,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CommonButton(
                    label: authState.isSubmitting
                        ? AppCopy.settingsLoggingOut
                        : AppCopy.settingsLogout,
                    tone: CommonButtonTone.secondary,
                    icon: const Icon(Icons.logout_rounded),
                    isLoading: authState.isSubmitting,
                    onPressed: authState.isSubmitting
                        ? null
                        : () async {
                            await onLogout();
                          },
                  ),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 设置页登录会话卡片。
class SettingsAuthSessionCard extends StatelessWidget {
  /// 创建登录会话卡片。
  const SettingsAuthSessionCard({
    required this.authState,
    required this.onLogout,
    super.key,
  });

  /// 当前认证状态。
  final AuthState authState;

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
                        '会话到期前保持登录，退出后会回到登录页。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 720 ? 2 : 1;
                    final itemWidth =
                        (constraints.maxWidth - ((columns - 1) * 12)) / columns;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        SizedBox(
                          width: itemWidth,
                          child: _SessionFact(
                            title: AppCopy.settingsCurrentAccount,
                            value: session.user.account,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _SessionFact(
                            title: AppCopy.settingsLoginMode,
                            value: session.loginMode.label,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _SessionFact(
                            title: AppCopy.settingsExpiry,
                            value: _formatExpiry(session.expiresAt),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _SessionFact(
                            title: '当前状态',
                            value: authState.isSubmitting ? '处理中' : '已登录',
                          ),
                        ),
                      ],
                    );
                  },
                ),
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

  String _formatExpiry(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return AppCopy.settingsExpiryMissing;
    }

    final dateTime = DateTime.tryParse(rawValue);
    if (dateTime == null) {
      return rawValue;
    }

    final localDateTime = dateTime.toLocal();
    final month = localDateTime.month.toString().padLeft(2, '0');
    final day = localDateTime.day.toString().padLeft(2, '0');
    final hour = localDateTime.hour.toString().padLeft(2, '0');
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    return '${localDateTime.year}-$month-$day $hour:$minute';
  }
}

class _SessionFact extends StatelessWidget {
  const _SessionFact({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return FeatureInsetPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      accentColor: AppPalette.softLavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

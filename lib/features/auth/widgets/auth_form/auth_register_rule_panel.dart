import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';

/// 注册规则提示面板。
class AuthRegisterRulePanel extends StatelessWidget {
  /// 创建注册规则提示面板。
  const AuthRegisterRulePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.rule_rounded, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppCopy.authRegisterRules,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

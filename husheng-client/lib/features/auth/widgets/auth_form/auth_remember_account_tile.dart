import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';

/// 记住账号开关项。
class AuthRememberAccountTile extends StatelessWidget {
  /// 创建记住账号开关项。
  const AuthRememberAccountTile({
    required this.rememberAccount,
    required this.isSubmitting,
    required this.onChanged,
    super.key,
  });

  /// 当前是否记住账号。
  final bool rememberAccount;

  /// 当前是否正在提交。
  final bool isSubmitting;

  /// 切换回调。
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.mistMint,
          opacity: 0.08,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.mistMint.withValues(alpha: 0.18)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isSubmitting ? null : () => onChanged(!rememberAccount),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: <Widget>[
              Checkbox(
                value: rememberAccount,
                onChanged: isSubmitting
                    ? null
                    : (value) => onChanged(value ?? false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '记住账号',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '下次自动回填账号。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

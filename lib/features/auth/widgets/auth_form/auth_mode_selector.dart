import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_form_mode.dart';

/// 认证表单模式切换器。
class AuthModeSelector extends StatelessWidget {
  /// 创建认证表单模式切换器。
  const AuthModeSelector({
    required this.currentMode,
    required this.isEnabled,
    required this.onSelectMode,
    super.key,
  });

  /// 当前模式。
  final AuthFormMode currentMode;

  /// 是否可切换。
  final bool isEnabled;

  /// 模式切换回调。
  final ValueChanged<AuthFormMode> onSelectMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SegmentedButton<AuthFormMode>(
        showSelectedIcon: false,
        segments: const <ButtonSegment<AuthFormMode>>[
          ButtonSegment<AuthFormMode>(
            value: AuthFormMode.login,
            label: Text(AppCopy.authLoginTab),
            icon: Icon(Icons.login_rounded),
          ),
          ButtonSegment<AuthFormMode>(
            value: AuthFormMode.register,
            label: Text(AppCopy.authRegisterTab),
            icon: Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
        selected: <AuthFormMode>{currentMode},
        onSelectionChanged: isEnabled
            ? (selection) => onSelectMode(selection.first)
            : null,
      ),
    );
  }
}

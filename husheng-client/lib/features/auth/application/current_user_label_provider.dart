import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';

/// 当前登录用户在工作台中的显示名称。
final currentUserLabelProvider = Provider<String>((ref) {
  final authState = ref.watch(authControllerProvider);
  final displayName = authState.session?.user.displayName.trim() ?? '';
  if (displayName.isNotEmpty) {
    return displayName;
  }

  final account = authState.session?.user.account.trim() ?? '';
  if (account.isNotEmpty) {
    return account;
  }

  return '--';
});

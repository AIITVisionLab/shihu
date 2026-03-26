import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/storage/local_storage.dart';
import 'package:sickandflutter/features/auth/remembered_account_repository.dart';

void main() {
  test(
    'RememberedAccountRepository reads, writes and clears account',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AppConstants.rememberedAccountStorageKey: 'demo_user',
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = RememberedAccountRepository(LocalStorage(preferences));

      expect(repository.readRememberedAccount(), 'demo_user');

      await repository.saveRememberedAccount(' tester ');
      expect(
        preferences.getString(AppConstants.rememberedAccountStorageKey),
        'tester',
      );

      await repository.clearRememberedAccount();
      expect(
        preferences.getString(AppConstants.rememberedAccountStorageKey),
        isNull,
      );
    },
  );
}

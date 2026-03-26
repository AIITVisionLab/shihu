import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/app/app_localizations.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/theme.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';

/// 应用级根组件，集中接入主题、路由和全局 Provider 容器。
class HuShengApp extends ConsumerWidget {
  /// 创建应用根组件。
  const HuShengApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      locale: AppLocalizations.fallbackLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.delegates,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}

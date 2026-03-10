import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/features/about/about_page.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/login_page.dart';
import 'package:sickandflutter/features/home/home_page.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_page.dart';
import 'package:sickandflutter/features/settings/settings_page.dart';
import 'package:sickandflutter/features/splash/splash_page.dart';
import 'package:sickandflutter/features/video/video_hub_page.dart';
import 'package:sickandflutter/features/video/video_stream_detail_page.dart';

/// 全局路由配置入口。
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    redirect: (context, state) => redirectForAuth(
      authState: authState,
      matchedLocation: state.matchedLocation,
    ),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.realtimeDetectPath,
        name: AppRoutes.realtimeDetect,
        builder: (context, state) => const RealtimeDetectPage(),
      ),
      GoRoute(
        path: AppRoutes.videoPath,
        name: AppRoutes.video,
        builder: (context, state) => const VideoHubPage(),
      ),
      GoRoute(
        path: AppRoutes.videoStreamDetailPath,
        name: AppRoutes.videoStreamDetail,
        builder: (context, state) => VideoStreamDetailPage(
          streamId: state.pathParameters['streamId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.aboutPath,
        name: AppRoutes.about,
        builder: (context, state) => const AboutPage(),
      ),
    ],
  );
});

/// 应用路由名和路径常量。
final class AppRoutes {
  /// 启动页路由名。
  static const String splash = 'splash';

  /// 登录页路由名。
  static const String login = 'login';

  /// 首页路由名。
  static const String home = 'home';

  /// 单图识别页路由名。
  static const String detect = 'detect';

  /// 实时识别页路由名。
  static const String realtimeDetect = 'realtimeDetect';

  /// 视频中心页路由名。
  static const String video = 'video';

  /// 单路视频流详情页路由名。
  static const String videoStreamDetail = 'videoStreamDetail';

  /// 结果页路由名。
  static const String result = 'result';

  /// 历史记录页路由名。
  static const String history = 'history';

  /// 设置页路由名。
  static const String settings = 'settings';

  /// 关于页路由名。
  static const String about = 'about';

  /// 启动页路由路径。
  static const String splashPath = '/';

  /// 登录页路由路径。
  static const String loginPath = '/login';

  /// 首页路由路径。
  static const String homePath = '/home';

  /// 单图识别页路由路径。
  static const String detectPath = '/detect';

  /// 实时识别页路由路径。
  static const String realtimeDetectPath = '/realtime-detect';

  /// 视频中心页路由路径。
  static const String videoPath = '/video';

  /// 单路视频流详情页路由路径。
  static const String videoStreamDetailPath = '/video/:streamId';

  /// 结果页路由路径。
  static const String resultPath = '/result';

  /// 历史记录页路由路径。
  static const String historyPath = '/history';

  /// 设置页路由路径。
  static const String settingsPath = '/settings';

  /// 关于页路由路径。
  static const String aboutPath = '/about';
}

/// 根据当前登录态决定路由跳转结果。
String? redirectForAuth({
  required AuthState authState,
  required String matchedLocation,
}) {
  const publicLocations = <String>{
    AppRoutes.splashPath,
    AppRoutes.loginPath,
    AppRoutes.aboutPath,
  };
  const unsupportedRuntimeLocations = <String>{
    AppRoutes.detectPath,
    AppRoutes.resultPath,
    AppRoutes.historyPath,
  };

  if (matchedLocation == AppRoutes.splashPath) {
    return null;
  }

  if (authState.isBootstrapping) {
    return null;
  }

  final isLogin = matchedLocation == AppRoutes.loginPath;
  final isPublic = publicLocations.contains(matchedLocation);
  final isUnsupportedRuntimeLocation = unsupportedRuntimeLocations.contains(
    matchedLocation,
  );

  if (authState.isAuthenticated) {
    if (isLogin) {
      return AppRoutes.realtimeDetectPath;
    }
    if (isUnsupportedRuntimeLocation) {
      return AppRoutes.homePath;
    }
    return null;
  }

  if (isUnsupportedRuntimeLocation) {
    return AppRoutes.loginPath;
  }

  if (!isPublic) {
    return AppRoutes.loginPath;
  }

  return null;
}

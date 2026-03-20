import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/app/app.dart';
import 'package:sickandflutter/core/bootstrap/desktop_video_backend.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDesktopVideoBackend();
  runApp(const ProviderScope(child: HuShengApp()));
}

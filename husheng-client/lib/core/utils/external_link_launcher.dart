import 'package:sickandflutter/core/utils/external_link_launcher_stub.dart'
    if (dart.library.html) 'package:sickandflutter/core/utils/external_link_launcher_web.dart'
    if (dart.library.io) 'package:sickandflutter/core/utils/external_link_launcher_io.dart'
    as launcher;

/// 调用系统能力打开外部链接。
///
/// 在不支持直接拉起浏览器的平台上返回 `false`，
/// 页面层可继续走复制链接的回退策略。
Future<bool> openExternalUrl(String url) => launcher.openExternalUrl(url);

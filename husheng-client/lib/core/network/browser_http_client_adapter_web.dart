import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// Web 平台按需启用 `withCredentials`，让浏览器决定是否携带会话 Cookie。
void configureBrowserHttpClientAdapter(
  Dio dio, {
  required bool withCredentials,
}) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(
    withCredentials: withCredentials,
  );
}

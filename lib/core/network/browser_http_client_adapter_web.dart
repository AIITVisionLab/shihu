import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// Web 平台启用 `withCredentials`，让浏览器自动携带会话 Cookie。
void configureBrowserHttpClientAdapter(Dio dio) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}

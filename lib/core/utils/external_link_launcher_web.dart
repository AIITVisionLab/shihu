import 'dart:js_interop';

@JS('window.open')
external JSAny? _windowOpen(JSString url, JSString target);

/// 在 Web 端通过浏览器打开新窗口。
Future<bool> openExternalUrl(String url) async {
  final normalizedUrl = url.trim();
  if (normalizedUrl.isEmpty) {
    return false;
  }

  _windowOpen(normalizedUrl.toJS, '_blank'.toJS);
  return true;
}

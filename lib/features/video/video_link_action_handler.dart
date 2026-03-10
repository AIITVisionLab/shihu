import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/core/utils/external_link_launcher.dart';

/// 统一处理视频模块中的外链打开与复制反馈。
final class VideoLinkActionHandler {
  /// 优先尝试打开外部链接，失败时自动回退为复制链接。
  static Future<void> openOrCopy(
    BuildContext context, {
    required String url,
    required String copiedLabel,
  }) async {
    final opened = await openExternalUrl(url);
    if (!context.mounted) {
      return;
    }

    if (opened) {
      _showMessage(context, AppCopy.videoOpenedExternal);
      return;
    }

    await copy(context, url: url, copiedLabel: copiedLabel);
  }

  /// 复制链接并提示用户。
  static Future<void> copy(
    BuildContext context, {
    required String url,
    required String copiedLabel,
  }) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) {
      return;
    }
    _showMessage(context, AppCopy.videoCopied(copiedLabel));
  }

  /// 复制视频服务接口地址。
  static Future<void> copyServiceUrl(
    BuildContext context, {
    required String serviceUrl,
  }) async {
    await Clipboard.setData(ClipboardData(text: serviceUrl));
    if (!context.mounted) {
      return;
    }
    _showMessage(context, AppCopy.videoServiceUrlCopied);
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

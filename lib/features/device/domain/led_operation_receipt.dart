/// LED 操作回执。
class LedOperationReceipt {
  /// 创建 LED 操作回执。
  const LedOperationReceipt({
    required this.status,
    required this.requestId,
    required this.message,
  });

  /// 后端返回的状态值。
  final String status;

  /// 后端分配的请求 ID。
  final String? requestId;

  /// 后端返回的说明信息。
  final String message;

  /// 是否属于后端接受或登记成功的状态。
  bool get isAcceptedLike {
    return status == 'accepted' ||
        status == 'success' ||
        status == 'ok' ||
        status == 'pending';
  }

  /// 是否已进入后端待处理队列。
  bool get isPending => status == 'pending';

  /// 构建面向用户的操作反馈文案。
  String buildUserMessage({required bool ledOn}) {
    final normalizedMessage = message.trim();
    final fallbackMessage = isPending
        ? '补光操作已提交，正在等待设备处理。'
        : ledOn
        ? '补光已开启，正在等待页面刷新。'
        : '补光已关闭，正在等待页面刷新。';
    final baseMessage = normalizedMessage.isEmpty
        ? fallbackMessage
        : normalizedMessage;
    final normalizedRequestId = requestId?.trim();
    if (normalizedRequestId == null || normalizedRequestId.isEmpty) {
      return baseMessage;
    }

    return '$baseMessage（请求号：$normalizedRequestId）';
  }
}

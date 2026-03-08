/// 单图识别接口业务错误码定义。
enum DetectApiErrorCode {
  /// 参数缺失或格式错误。
  invalidParams,

  /// 图片文件无效。
  invalidImageFile,

  /// 图片大小超限。
  imageTooLarge,

  /// 图片格式不支持。
  unsupportedImageFormat,

  /// 请求频率过高。
  rateLimited,

  /// 登录状态失效。
  unauthorized,

  /// 无访问权限。
  forbidden,

  /// 记录不存在。
  notFound,

  /// 请求冲突。
  conflict,

  /// 模型推理失败。
  inferenceFailed,

  /// 数据存储失败。
  storageFailed,

  /// 服务内部异常。
  internalError,

  /// 识别服务暂不可用。
  serviceUnavailable,
}

/// 根据业务错误码解析识别接口错误枚举。
DetectApiErrorCode? tryDetectApiErrorCodeFromValue(int? value) {
  switch (value) {
    case 40001:
      return DetectApiErrorCode.invalidParams;
    case 40002:
      return DetectApiErrorCode.invalidImageFile;
    case 40003:
      return DetectApiErrorCode.imageTooLarge;
    case 40004:
      return DetectApiErrorCode.unsupportedImageFormat;
    case 40005:
      return DetectApiErrorCode.rateLimited;
    case 40101:
      return DetectApiErrorCode.unauthorized;
    case 40301:
      return DetectApiErrorCode.forbidden;
    case 40401:
      return DetectApiErrorCode.notFound;
    case 40901:
      return DetectApiErrorCode.conflict;
    case 50001:
      return DetectApiErrorCode.inferenceFailed;
    case 50002:
      return DetectApiErrorCode.storageFailed;
    case 50003:
      return DetectApiErrorCode.internalError;
    case 50301:
      return DetectApiErrorCode.serviceUnavailable;
    default:
      return null;
  }
}

/// 提供识别接口错误码的默认用户提示。
extension DetectApiErrorCodeX on DetectApiErrorCode {
  /// 面向用户展示的统一错误提示。
  String get userMessage {
    switch (this) {
      case DetectApiErrorCode.invalidParams:
        return '识别参数无效，请重新选择图片后再试。';
      case DetectApiErrorCode.invalidImageFile:
        return '图片文件无效，请重新选择清晰的石斛图片。';
      case DetectApiErrorCode.imageTooLarge:
        return '图片体积过大，请压缩后再试。';
      case DetectApiErrorCode.unsupportedImageFormat:
        return '当前图片格式不受支持，请改用常见图片格式。';
      case DetectApiErrorCode.rateLimited:
        return '请求过于频繁，请稍后再试。';
      case DetectApiErrorCode.unauthorized:
        return '当前识别服务未授权，请联系管理员处理。';
      case DetectApiErrorCode.forbidden:
        return '当前环境无权访问识别服务。';
      case DetectApiErrorCode.notFound:
        return '识别资源不存在，请稍后重试。';
      case DetectApiErrorCode.conflict:
        return '当前请求发生冲突，请稍后重试。';
      case DetectApiErrorCode.inferenceFailed:
        return '模型推理失败，请稍后重试。';
      case DetectApiErrorCode.storageFailed:
        return '服务端保存识别结果失败，请稍后重试。';
      case DetectApiErrorCode.internalError:
        return '识别服务内部异常，请稍后重试。';
      case DetectApiErrorCode.serviceUnavailable:
        return '识别服务暂不可用，请稍后重试。';
    }
  }
}

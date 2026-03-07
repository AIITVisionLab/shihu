import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 本地应用设置模型。
class AppSettings {
  /// 创建应用设置对象。
  const AppSettings({
    required this.baseUrl,
    required this.connectTimeoutMs,
    required this.receiveTimeoutMs,
    required this.enableLog,
    required this.buildFlavor,
  });

  /// 创建当前环境下的默认设置。
  factory AppSettings.defaults({
    required BuildFlavor buildFlavor,
    String baseUrl = AppConstants.defaultBaseUrl,
    bool enableLog = true,
  }) {
    return AppSettings(
      baseUrl: baseUrl,
      connectTimeoutMs: AppConstants.defaultConnectTimeoutMs,
      receiveTimeoutMs: AppConstants.defaultReceiveTimeoutMs,
      enableLog: enableLog,
      buildFlavor: buildFlavor,
    );
  }

  /// 从 JSON 构建应用设置对象。
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      baseUrl: asString(json['baseUrl'], fallback: AppConstants.defaultBaseUrl),
      connectTimeoutMs: asInt(
        json['connectTimeoutMs'],
        fallback: AppConstants.defaultConnectTimeoutMs,
      ),
      receiveTimeoutMs: asInt(
        json['receiveTimeoutMs'],
        fallback: AppConstants.defaultReceiveTimeoutMs,
      ),
      enableLog: asBool(json['enableLog'], fallback: true),
      buildFlavor: buildFlavorFromValue(asString(json['buildFlavor'])),
    );
  }

  /// 服务基础地址。
  final String baseUrl;

  /// 连接超时时间，单位毫秒。
  final int connectTimeoutMs;

  /// 接收超时时间，单位毫秒。
  final int receiveTimeoutMs;

  /// 是否开启日志。
  final bool enableLog;

  /// 当前设置所属构建环境。
  final BuildFlavor buildFlavor;

  /// 返回带增量修改的新设置对象。
  AppSettings copyWith({
    String? baseUrl,
    int? connectTimeoutMs,
    int? receiveTimeoutMs,
    bool? enableLog,
    BuildFlavor? buildFlavor,
  }) {
    return AppSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeoutMs: connectTimeoutMs ?? this.connectTimeoutMs,
      receiveTimeoutMs: receiveTimeoutMs ?? this.receiveTimeoutMs,
      enableLog: enableLog ?? this.enableLog,
      buildFlavor: buildFlavor ?? this.buildFlavor,
    );
  }

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'baseUrl': baseUrl,
      'connectTimeoutMs': connectTimeoutMs,
      'receiveTimeoutMs': receiveTimeoutMs,
      'enableLog': enableLog,
      'buildFlavor': buildFlavor.value,
    };
  }
}

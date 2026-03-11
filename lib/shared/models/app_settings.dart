import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/core/config/service_endpoint_resolver.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

part 'app_settings.g.dart';

/// 本地应用设置模型。
@JsonSerializable()
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
  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  /// 服务基础地址。
  @JsonKey(fromJson: _baseUrlFromJson)
  final String baseUrl;

  /// 连接超时时间，单位毫秒。
  @JsonKey(fromJson: _connectTimeoutFromJson)
  final int connectTimeoutMs;

  /// 接收超时时间，单位毫秒。
  @JsonKey(fromJson: _receiveTimeoutFromJson)
  final int receiveTimeoutMs;

  /// 是否开启日志。
  @JsonKey(fromJson: _enableLogFromJson)
  final bool enableLog;

  /// 当前设置所属构建环境。
  @JsonKey(fromJson: _buildFlavorFromJson, toJson: _buildFlavorToJson)
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
  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);
}

String _baseUrlFromJson(Object? value) {
  return ServiceEndpointResolver.normalizeBaseUrl(asString(value)) ??
      AppConstants.defaultBaseUrl;
}

int _connectTimeoutFromJson(Object? value) {
  return asInt(value, fallback: AppConstants.defaultConnectTimeoutMs);
}

int _receiveTimeoutFromJson(Object? value) {
  return asInt(value, fallback: AppConstants.defaultReceiveTimeoutMs);
}

bool _enableLogFromJson(Object? value) => asBool(value, fallback: true);

BuildFlavor _buildFlavorFromJson(Object? value) {
  return buildFlavorFromValue(parseNullableStringValue(value));
}

String _buildFlavorToJson(BuildFlavor value) => value.value;

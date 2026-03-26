// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
  baseUrl: _baseUrlFromJson(json['baseUrl']),
  connectTimeoutMs: _connectTimeoutFromJson(json['connectTimeoutMs']),
  receiveTimeoutMs: _receiveTimeoutFromJson(json['receiveTimeoutMs']),
  enableLog: _enableLogFromJson(json['enableLog']),
  buildFlavor: _buildFlavorFromJson(json['buildFlavor']),
);

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'baseUrl': instance.baseUrl,
      'connectTimeoutMs': instance.connectTimeoutMs,
      'receiveTimeoutMs': instance.receiveTimeoutMs,
      'enableLog': instance.enableLog,
      'buildFlavor': _buildFlavorToJson(instance.buildFlavor),
    };

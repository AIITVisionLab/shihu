// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_health_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceHealthInfo _$ServiceHealthInfoFromJson(Map<String, dynamic> json) =>
    ServiceHealthInfo(
      status: parseStringValue(json['status']),
      responseText: parseStringValue(json['responseText']),
      checkedAt: parseStringValue(json['checkedAt']),
    );

Map<String, dynamic> _$ServiceHealthInfoToJson(ServiceHealthInfo instance) =>
    <String, dynamic>{
      'status': instance.status,
      'responseText': instance.responseText,
      'checkedAt': instance.checkedAt,
    };

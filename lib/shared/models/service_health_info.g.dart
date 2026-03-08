// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_health_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceHealthInfo _$ServiceHealthInfoFromJson(Map<String, dynamic> json) =>
    ServiceHealthInfo(
      status: parseStringValue(json['status']),
      serviceName: parseStringValue(json['serviceName']),
      serviceVersion: parseStringValue(json['serviceVersion']),
      modelStatus: parseStringValue(json['modelStatus']),
      serverTime: parseStringValue(json['serverTime']),
    );

Map<String, dynamic> _$ServiceHealthInfoToJson(ServiceHealthInfo instance) =>
    <String, dynamic>{
      'status': instance.status,
      'serviceName': instance.serviceName,
      'serviceVersion': instance.serviceVersion,
      'modelStatus': instance.modelStatus,
      'serverTime': instance.serverTime,
    };

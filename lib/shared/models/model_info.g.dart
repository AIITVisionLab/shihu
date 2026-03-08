// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelInfo _$ModelInfoFromJson(Map<String, dynamic> json) => ModelInfo(
  modelName: parseStringValue(json['modelName']),
  modelVersion: parseStringValue(json['modelVersion']),
  inferenceMs: parseIntValue(json['inferenceMs']),
);

Map<String, dynamic> _$ModelInfoToJson(ModelInfo instance) => <String, dynamic>{
  'modelName': instance.modelName,
  'modelVersion': instance.modelVersion,
  'inferenceMs': instance.inferenceMs,
};

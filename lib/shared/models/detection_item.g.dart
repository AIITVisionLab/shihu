// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetectionItem _$DetectionItemFromJson(Map<String, dynamic> json) =>
    DetectionItem(
      detectionId: parseStringValue(json['detectionId']),
      labelCode: parseStringValue(json['labelCode']),
      labelName: parseStringValue(json['labelName']),
      category: _detectionCategoryFromJson(json['category']),
      confidence: parseDoubleValue(json['confidence']),
      severityLevel: _severityLevelFromJson(json['severityLevel']),
      bbox: _boundingBoxFromJson(json['bbox']),
    );

Map<String, dynamic> _$DetectionItemToJson(DetectionItem instance) =>
    <String, dynamic>{
      'detectionId': instance.detectionId,
      'labelCode': instance.labelCode,
      'labelName': instance.labelName,
      'category': _detectionCategoryToJson(instance.category),
      'confidence': instance.confidence,
      'severityLevel': _severityLevelToJson(instance.severityLevel),
      'bbox': _boundingBoxToJson(instance.bbox),
    };

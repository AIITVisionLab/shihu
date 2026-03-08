// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detect_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetectResponse _$DetectResponseFromJson(Map<String, dynamic> json) =>
    DetectResponse(
      detectId: parseStringValue(json['detectId']),
      sourceType: _sourceTypeFromJson(json['sourceType']),
      capturedAt: parseStringValue(json['capturedAt']),
      summary: _detectSummaryFromJson(json['summary']),
      detections: _detectionItemListFromJson(json['detections']),
      imageInfo: _imageInfoFromJson(json['imageInfo']),
      advice: _adviceInfoFromJson(json['advice']),
      modelInfo: _modelInfoFromJson(json['modelInfo']),
    );

Map<String, dynamic> _$DetectResponseToJson(DetectResponse instance) =>
    <String, dynamic>{
      'detectId': instance.detectId,
      'sourceType': _sourceTypeToJson(instance.sourceType),
      'capturedAt': instance.capturedAt,
      'summary': _detectSummaryToJson(instance.summary),
      'imageInfo': _imageInfoToJson(instance.imageInfo),
      'detections': _detectionItemListToJson(instance.detections),
      'advice': _adviceInfoToJson(instance.advice),
      'modelInfo': _modelInfoToJson(instance.modelInfo),
    };

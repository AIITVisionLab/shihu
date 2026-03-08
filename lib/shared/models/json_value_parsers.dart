import 'package:sickandflutter/shared/models/model_utils.dart';

/// 将动态值解析为非空字符串。
String parseStringValue(Object? value) => asString(value);

/// 将动态值解析为可空字符串。
String? parseNullableStringValue(Object? value) => asNullableString(value);

/// 将动态值解析为整数。
int parseIntValue(Object? value) => asInt(value);

/// 将动态值解析为浮点数。
double parseDoubleValue(Object? value) => asDouble(value);

/// 将动态值解析为布尔值。
bool parseBoolValue(Object? value) => asBool(value);

/// 将动态值解析为字符串列表。
List<String> parseStringListValue(Object? value) => asStringList(value);

/// 将动态值解析为字符串键 JSON 对象。
Map<String, dynamic> parseStringMapValue(Object? value) {
  return asStringMap(value) ?? const <String, dynamic>{};
}

/// 将动态值解析为字符串键 JSON 对象列表。
List<Map<String, dynamic>> parseStringMapListValue(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }

  return value
      .map(asStringMap)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
}

/// 序列化字符串列表。
List<String> stringListToJson(List<String> value) => value;

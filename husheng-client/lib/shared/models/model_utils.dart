/// 将动态值安全转换为 `double`。
double asDouble(Object? value, {double fallback = 0}) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }

  return fallback;
}

/// 将动态值安全转换为 `int`。
int asInt(Object? value, {int fallback = 0}) {
  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }

  return fallback;
}

/// 将动态值安全转换为 `String`。
String asString(Object? value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }

  return value.toString();
}

/// 将动态值安全转换为可空字符串。
String? asNullableString(Object? value) {
  if (value == null) {
    return null;
  }

  return value.toString();
}

/// 将动态值安全转换为 `bool`。
bool asBool(Object? value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
  }

  return fallback;
}

/// 将动态值安全转换为字符串键的 JSON 对象。
Map<String, dynamic>? asStringMap(Object? value) {
  if (value is! Map) {
    return null;
  }

  return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
}

/// 将动态值安全转换为字符串列表。
List<String> asStringList(Object? value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList(growable: false);
  }

  return const <String>[];
}

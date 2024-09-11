import 'dart:convert';

T deepCopy<T>(T object, T Function(Map<String, dynamic>) fromJson) {
  var json = jsonEncode(object);
  return fromJson(jsonDecode(json) as Map<String, dynamic>);
}

List<T> deepCopyList<T>(List<T> list, T Function(Map<String, dynamic>) fromJson) {
  return list.map((item) => jsonEncode(item)).map((itemJson) => fromJson(jsonDecode(itemJson) as Map<String, dynamic>)).toList();
}

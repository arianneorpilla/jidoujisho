import 'dart:convert';

/// A type converter for a general purpose key-value map for conversion to a
/// primitive compatible with Isar.
class EnhancementsConverter {
  /// Deserializes the object.
  static Map<String, Map<int, String>> fromIsar(String object) {
    Map<String, dynamic> map = jsonDecode(object);

    return map.map(
      (k, e) => MapEntry(
        k,
        (e as Map<String, dynamic>).map(
          (k, e) => MapEntry(int.parse(k), e as String),
        ),
      ),
    );
  }

  /// Serializes the object.
  static String toIsar(Map<String, Map<int, String>> object) {
    Map<String, dynamic> map = object
        .map((k, e) => MapEntry(k, e.map((k, e) => MapEntry(k.toString(), e))));
    return jsonEncode(map);
  }
}

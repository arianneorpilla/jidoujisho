import 'dart:convert';

/// A type converter for a general purpose key-value map for conversion to a
/// primitive compatible with Isar.
class QuickActionsConverter {
  /// Deserializes the object.
  static Map<int, String> fromIsar(String object) {
    Map<dynamic, dynamic> json = jsonDecode(object);

    return json.map(
      (k, e) => MapEntry(int.parse(k), e as String),
    );
  }

  /// Serializes the object.
  static String toIsar(Map<int, String> object) {
    return jsonEncode(object.map((k, e) => MapEntry(k.toString(), e)));
  }
}

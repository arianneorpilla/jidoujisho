import 'dart:convert';

/// A type converter for a general purpose key-value map for conversion to a
/// primitive compatible with Isar.
class ImmutableStringMapConverter {
  /// Deserializes the object.
  static Map<String, dynamic> fromIsar(String object) {
    return Map<String, dynamic>.from(jsonDecode(object));
  }

  /// Serializes the object.
  static String toIsar(Map<String, dynamic> object) {
    return jsonEncode(object);
  }
}

import 'dart:convert';

import 'package:isar/isar.dart';

/// A type converter for a general purpose key-value map for conversion to a
/// primitive compatible with Isar.
class ImmutableStringMapConverter
    extends TypeConverter<Map<String, dynamic>, String> {
  /// Initialise this converter.
  const ImmutableStringMapConverter();

  @override
  Map<String, dynamic> fromIsar(String object) {
    return Map<String, dynamic>.unmodifiable(jsonDecode(object));
  }

  @override
  String toIsar(Map<String, dynamic> object) {
    return jsonEncode(object);
  }
}

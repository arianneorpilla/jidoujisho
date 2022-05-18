import 'dart:convert';

import 'package:isar/isar.dart';

/// A type converter for a general purpose key-value map for conversion to a
/// primitive compatible with Isar.
class QuickActionsConverter extends TypeConverter<Map<int, String>, String> {
  /// Initialise this converter.
  const QuickActionsConverter();

  @override
  Map<int, String> fromIsar(String object) {
    Map<dynamic, dynamic> json = jsonDecode(object);

    return json.map(
      (k, e) => MapEntry(int.parse(k), e as String),
    );
  }

  @override
  String toIsar(Map<int, String> object) {
    return jsonEncode(object.map((k, e) => MapEntry(k.toString(), e)));
  }
}

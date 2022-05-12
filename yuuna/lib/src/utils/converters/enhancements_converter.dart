import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:yuuna/creator.dart';

/// A type converter for a general purpose key-value map for conversion to a
/// primitive compatible with Isar.
class EnhancementsConverter
    extends TypeConverter<Map<Field, Map<int, String>>, String> {
  /// Initialise this converter.
  const EnhancementsConverter();

  @override
  Map<Field, Map<int, String>> fromIsar(String object) {
    Map<String, dynamic> map = jsonDecode(object);

    return map.map(
      (k, e) => MapEntry(
        Field.values.byName(k),
        (e as Map<String, dynamic>).map(
          (k, e) => MapEntry(int.parse(k), e as String),
        ),
      ),
    );
  }

  @override
  String toIsar(Map<Field, Map<int, String>> object) {
    Map<String, dynamic> map = object.map(
        (k, e) => MapEntry(k.name, e.map((k, e) => MapEntry(k.toString(), e))));
    return jsonEncode(map);
  }
}

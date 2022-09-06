import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';

/// A type converter for a list of [DictionaryEntry].
class DictionaryEntriesConverter
    extends TypeConverter<List<DictionaryEntry>, String> {
  /// Initialise this converter.
  const DictionaryEntriesConverter();

  @override
  List<DictionaryEntry> fromIsar(String object) {
    List<dynamic> jsons = jsonDecode(object);

    List<DictionaryEntry> mapping = jsons
        .map((e) => DictionaryEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return List<DictionaryEntry>.unmodifiable(mapping);
  }

  @override
  String toIsar(List<DictionaryEntry> object) {
    return jsonEncode(object);
  }
}

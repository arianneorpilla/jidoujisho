import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';

/// A type converter for a general purpose key-value map for conversion to a
/// primitive compatible with Isar.
class DictionaryEntriesConverter
    extends TypeConverter<List<List<DictionaryEntry>>, String> {
  /// Initialise this converter.
  const DictionaryEntriesConverter();

  @override
  List<List<DictionaryEntry>> fromIsar(String object) {
    List<dynamic> json = jsonDecode(object);

    List<List<DictionaryEntry>> mapping = json
        .map((e) => (e as List<dynamic>)
            .map((e) => DictionaryEntry.fromJson(e as Map<String, dynamic>))
            .toList())
        .toList();

    return List<List<DictionaryEntry>>.unmodifiable(mapping);
  }

  @override
  String toIsar(List<List<DictionaryEntry>> object) {
    return jsonEncode(object);
  }
}

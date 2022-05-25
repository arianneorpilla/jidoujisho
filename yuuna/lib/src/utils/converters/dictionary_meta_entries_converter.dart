import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';

/// A type converter for a list of [DictionaryMetaEntry].
class DictionaryMetaEntriesConverter
    extends TypeConverter<List<DictionaryMetaEntry>, String> {
  /// Initialise this converter.
  const DictionaryMetaEntriesConverter();

  @override
  List<DictionaryMetaEntry> fromIsar(String object) {
    List<dynamic> jsons = jsonDecode(object);

    List<DictionaryMetaEntry> mapping = jsons
        .map((e) => DictionaryMetaEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return List<DictionaryMetaEntry>.unmodifiable(mapping);
  }

  @override
  String toIsar(List<DictionaryMetaEntry> object) {
    return jsonEncode(object);
  }
}

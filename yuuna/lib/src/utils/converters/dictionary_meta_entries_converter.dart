import 'dart:convert';

import 'package:yuuna/dictionary.dart';

/// A type converter for a list of [DictionaryMetaEntry].
class DictionaryMetaEntriesConverter {
  /// Deserializes the object.
  static List<DictionaryMetaEntry> fromIsar(String object) {
    List<dynamic> jsons = jsonDecode(object);

    List<DictionaryMetaEntry> mapping = jsons
        .map((e) => DictionaryMetaEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return mapping;
  }

  /// Serializes the object.
  static String toIsar(List<DictionaryMetaEntry> object) {
    return jsonEncode(object);
  }
}

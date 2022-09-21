import 'dart:convert';

import 'package:yuuna/dictionary.dart';

/// A type converter for a list of [DictionaryEntry].
class DictionaryEntriesConverter {
  /// Deserializes the object.
  static List<DictionaryEntry> fromIsar(String object) {
    List<dynamic> jsons = jsonDecode(object);

    List<DictionaryEntry> mapping = jsons
        .map((e) => DictionaryEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return mapping;
  }

  /// Serializes the object.
  static String toIsar(List<DictionaryEntry> object) {
    return jsonEncode(object);
  }
}

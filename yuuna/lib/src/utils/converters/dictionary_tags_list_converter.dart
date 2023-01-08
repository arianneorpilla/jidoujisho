import 'dart:convert';

import 'package:yuuna/dictionary.dart';

/// A type converter for a list of list of [DictionaryTag].
class DictionaryTagsListConverter {
  /// Deserializes the object.
  static List<List<DictionaryTag>> fromIsar(String object) {
    List<dynamic> jsons = jsonDecode(object);

    List<List<DictionaryTag>> mapping = jsons
        .map((e) => (e as List<dynamic>)
            .map((e) => DictionaryTag.fromJson(e as Map<String, dynamic>))
            .toList())
        .toList();

    return mapping;
  }

  /// Serializes the object.
  static String toIsar(List<List<DictionaryTag>> object) {
    return jsonEncode(object);
  }
}

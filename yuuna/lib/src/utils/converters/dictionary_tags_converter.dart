import 'dart:convert';

import 'package:yuuna/dictionary.dart';

/// A type converter for a list of [DictionaryTag].
class DictionaryTagsConverter {
  /// Deserializes the object.
  static List<DictionaryTag> fromIsar(String object) {
    List<dynamic> jsons = jsonDecode(object);

    List<DictionaryTag> mapping = jsons
        .map((e) => DictionaryTag.fromJson(e as Map<String, dynamic>))
        .toList();

    return mapping;
  }

  /// Serializes the object.
  static String toIsar(List<DictionaryTag> object) {
    return jsonEncode(object);
  }
}

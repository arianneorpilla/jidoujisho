import 'dart:convert';

import 'package:yuuna/dictionary.dart';

/// A type converter for a list of [DictionaryTerm].
class DictionaryTermsConverter {
  /// Deserializes the object.
  static List<DictionaryTerm> fromIsar(String object) {
    List<dynamic> jsons = jsonDecode(object);

    List<DictionaryTerm> mapping = jsons
        .map((e) => DictionaryTerm.fromJson(e as Map<String, dynamic>))
        .toList();

    return mapping;
  }

  /// Serializes the object.
  static String toIsar(List<DictionaryTerm> object) {
    return jsonEncode(object);
  }
}

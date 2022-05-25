import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';

/// A type converter for a list of [DictionaryTerm].
class DictionaryTermsConverter
    extends TypeConverter<List<DictionaryTerm>, String> {
  /// Initialise this converter.
  const DictionaryTermsConverter();

  @override
  List<DictionaryTerm> fromIsar(String object) {
    List<dynamic> jsons = jsonDecode(object);

    List<DictionaryTerm> mapping = jsons
        .map((e) => DictionaryTerm.fromJson(e as Map<String, dynamic>))
        .toList();

    return List<DictionaryTerm>.unmodifiable(mapping);
  }

  @override
  String toIsar(List<DictionaryTerm> object) {
    return jsonEncode(object);
  }
}

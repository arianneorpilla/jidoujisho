import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';

/// A type converter for [PitchData].
class PitchDataConverter extends TypeConverter<List<PitchData>?, String?> {
  /// Initialise this converter.
  const PitchDataConverter();

  @override
  List<PitchData>? fromIsar(String? object) {
    if (object == null) {
      return null;
    }

    List<dynamic> jsons = jsonDecode(object);

    List<PitchData> mapping = jsons
        .map((e) => PitchData.fromJson(e as Map<String, dynamic>))
        .toList();

    return List<PitchData>.unmodifiable(mapping);
  }

  @override
  String? toIsar(List<PitchData>? object) {
    if (object == null) {
      return null;
    }

    return jsonEncode(object);
  }
}

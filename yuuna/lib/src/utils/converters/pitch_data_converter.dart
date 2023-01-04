import 'dart:convert';

import 'package:yuuna/dictionary.dart';

/// A type converter for [PitchData].
class PitchDataConverter {
  /// Deserializes the object.
  static List<PitchData>? fromIsar(String? object) {
    if (object == null) {
      return null;
    }

    List<dynamic> jsons = jsonDecode(object);

    List<PitchData> mapping = jsons
        .map((e) => PitchData.fromJson(e as Map<String, dynamic>))
        .toList();

    return List<PitchData>.unmodifiable(mapping);
  }

  /// Serializes the object.
  static String? toIsar(List<PitchData>? object) {
    if (object == null) {
      return null;
    }

    return jsonEncode(object);
  }
}

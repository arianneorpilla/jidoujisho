import 'dart:convert';

import 'package:yuuna/dictionary.dart';

/// A type converter for [FrequencyData].
class FrequencyDataConverter {
  /// Deserializes the object.
  static FrequencyData? fromIsar(String? object) {
    if (object == null) {
      return null;
    }

    return FrequencyData.fromJson(jsonDecode(object));
  }

  /// Serializes the object.
  static String? toIsar(FrequencyData? object) {
    if (object == null) {
      return null;
    }

    return jsonEncode(object.toJson());
  }
}

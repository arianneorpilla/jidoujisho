import 'dart:convert';

import 'package:yuuna/media.dart';

/// A type converter for [MediaItem].
class MediaItemConverter {
  /// Deserializes the object.
  static MediaItem? fromIsar(String? object) {
    if (object == null) {
      return null;
    }

    return MediaItem.fromJson(jsonDecode(object));
  }

  /// Serializes the object.
  static String? toIsar(MediaItem? object) {
    if (object == null) {
      return null;
    }

    return jsonEncode(object.toJson());
  }
}

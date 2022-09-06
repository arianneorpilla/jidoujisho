import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:yuuna/media.dart';

/// A type converter for [MediaItem].
class MediaItemConverter extends TypeConverter<MediaItem?, String?> {
  /// Initialise this converter.
  const MediaItemConverter();

  @override
  MediaItem? fromIsar(String? object) {
    if (object == null) {
      return null;
    }

    return MediaItem.fromJson(jsonDecode(object));
  }

  @override
  String? toIsar(MediaItem? object) {
    if (object == null) {
      return null;
    }

    return jsonEncode(object.toJson());
  }
}

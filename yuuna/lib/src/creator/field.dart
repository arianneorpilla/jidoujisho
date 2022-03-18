import 'package:flutter/material.dart';
import 'package:yuuna/models.dart';

/// An entity that represents a broad characteristic of an item being
/// exported that is distinguishable enough to deserve its own core
/// functionality and family of user extensions. For example, a field
/// could handle exclusively images, or dictionary definitions.
enum Field {
  /// Written context depicting usage of a word.
  sentence,

  /// The subject term of a card.
  word,

  /// The pronunciation of the word.
  reading,

  /// The definition of the word.
  meaning,

  /// Extra details for future-proofing.
  extra,

  /// Visual supplements.
  image,

  /// Auditory supplements.
  audio,
}

/// Extra methods for [Field].
extension AnkiExportFieldLocalisation on Field {
  /// Get the localised name of the field.
  String label(AppModel appModel) {
    return appModel.translate('field_label_$name');
  }

  /// Get the localised description hint of the field.
  String hint(AppModel appModel) {
    return appModel.translate('field_hint_$name');
  }

  /// Get the icon characteristic of this field.
  IconData icon(AppModel appModel) {
    switch (this) {
      case Field.sentence:
        return Icons.format_align_center;
      case Field.word:
        return Icons.speaker_notes_outlined;
      case Field.reading:
        return Icons.surround_sound_outlined;
      case Field.meaning:
        return Icons.translate_rounded;
      case Field.extra:
        return Icons.more_horiz;
      case Field.image:
        return Icons.image;
      case Field.audio:
        return Icons.audiotrack;
    }
  }
}

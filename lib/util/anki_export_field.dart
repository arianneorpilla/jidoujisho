import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';

enum AnkiExportField {
  sentence,
  word,
  reading,
  meaning,
  extra,
  image,
  audio,
}

extension AnkiExportFieldLocalisation on AnkiExportField {
  String label(AppModel appModel) {
    switch (this) {
      case AnkiExportField.sentence:
        return appModel.translate("field_label_sentence");
      case AnkiExportField.word:
        return appModel.translate("field_label_word");
      case AnkiExportField.reading:
        return appModel.translate("field_label_reading");
      case AnkiExportField.meaning:
        return appModel.translate("field_label_meaning");
      case AnkiExportField.extra:
        return appModel.translate("field_label_extra");
      case AnkiExportField.image:
        return appModel.translate("field_label_image");
      case AnkiExportField.audio:
        return appModel.translate("field_label_audio");
    }
  }

  String hint(AppModel appModel) {
    switch (this) {
      case AnkiExportField.sentence:
        return appModel.translate("field_hint_context");
      case AnkiExportField.word:
        return appModel.translate("field_hint_word");
      case AnkiExportField.reading:
        return appModel.translate("field_hint_reading");
      case AnkiExportField.meaning:
        return appModel.translate("field_hint_meaning");
      case AnkiExportField.extra:
        return appModel.translate("field_hint_extra");
      case AnkiExportField.image:
        return appModel.translate("field_hint_image");
      case AnkiExportField.audio:
        return appModel.translate("field_hint_audio");
    }
  }

  IconData icon(AppModel appModel) {
    switch (this) {
      case AnkiExportField.sentence:
        return Icons.format_align_center;
      case AnkiExportField.word:
        return Icons.speaker_notes_outlined;

      case AnkiExportField.reading:
        return Icons.surround_sound_outlined;

      case AnkiExportField.meaning:
        return Icons.translate_rounded;
      case AnkiExportField.extra:
        return Icons.more_horiz;
      case AnkiExportField.image:
        return Icons.image;
      case AnkiExportField.audio:
        return Icons.audiotrack;
    }
  }
}

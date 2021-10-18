import 'dart:async';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:flutter/material.dart';

class ClearButtonEnhancement extends AnkiExportEnhancement {
  ClearButtonEnhancement({
    required AppModel appModel,
    required AnkiExportField enhancementField,
  }) : super(
            appModel: appModel,
            enhancementName: "Clear Button",
            enhancementDescription: "Quickly empty a field's parameters.",
            enhancementIcon: Icons.clear,
            enhancementField: enhancementField);

  @override
  FutureOr<AnkiExportParams> enhanceParams(AnkiExportParams params) {
    switch (enhancementField) {
      case AnkiExportField.sentence:
        params.sentence = "";
        break;
      case AnkiExportField.word:
        params.word = "";
        break;
      case AnkiExportField.reading:
        params.reading = "";
        break;
      case AnkiExportField.meaning:
        params.meaning = "";
        break;
      case AnkiExportField.extra:
        params.extra = "";
        break;
      case AnkiExportField.image:
        params.imageFile = null;
        break;
      case AnkiExportField.audio:
        params.audioFile = null;
        break;
    }
    return params;
  }
}

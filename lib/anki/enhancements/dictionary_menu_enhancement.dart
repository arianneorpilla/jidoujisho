import 'dart:async';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:flutter/material.dart';

class DictionaryMenuEnhancement extends AnkiExportEnhancement {
  DictionaryMenuEnhancement({
    required AppModel appModel,
  }) : super(
          appModel: appModel,
          enhancementName: "Dictionary Menu",
          enhancementDescription:
              "Open the dictionary menu to change the current dictionary.",
          enhancementIcon: Icons.auto_stories,
          enhancementField: AnkiExportField.word,
        );

  @override
  Future<AnkiExportParams> enhanceParams({
    required BuildContext context,
    required AppModel appModel,
    required AnkiExportParams params,
    required bool autoMode,
    required CreatorPageState state,
  }) async {
    await appModel.showDictionaryMenu(context, themeData: Theme.of(context));
    return params;
  }
}

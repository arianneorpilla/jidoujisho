import 'dart:async';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/anki/enhancements/bing_search_enhancement.dart';
import 'package:chisa/anki/enhancements/forvo_audio_enhancement.dart';
import 'package:chisa/anki/enhancements/pitch_accent_export_enhancement.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/media/media_history_items/dictionary_media_history_item.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:chisa/util/dictionary_dialog_widget.dart';
import 'package:flutter/material.dart';

class SearchDictionaryEnhancement extends AnkiExportEnhancement {
  SearchDictionaryEnhancement({
    required AppModel appModel,
  }) : super(
          appModel: appModel,
          enhancementName: "Search Dictionary",
          enhancementDescription:
              "Search the current dictionary and show a picker dialog.",
          enhancementIcon: Icons.search,
          enhancementField: AnkiExportField.word,
        );

  @override
  Future<AnkiExportParams> enhanceParams({
    required BuildContext context,
    required AppModel appModel,
    required AnkiExportParams params,
    required bool autoMode,
    required CreatorPageState state,
    String? searchTerm,
  }) async {
    if (searchTerm == null && params.word.isEmpty) {
      return params;
    }

    DictionarySearchResult result =
        await appModel.searchDictionary(searchTerm ?? params.word);

    if (result.entries.isEmpty) {
      return params;
    }

    bool searched = false;

    ValueNotifier<int> indexNotifier = ValueNotifier<int>(0);
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => DictionaryDialogWidget(
        mediaHistoryItem:
            DictionaryMediaHistoryItem.fromDictionarySearchResult(result),
        dictionary: appModel.getDictionaryFromName(result.dictionaryName),
        dictionaryFormat:
            appModel.getDictionaryFormatFromName(result.formatName),
        result: result,
        callback: () {},
        indexNotifier: indexNotifier,
        actions: [
          TextButton(
            child: Text(
              appModel.translate("dialog_set"),
            ),
            onPressed: () async {
              DictionaryEntry entry = result.entries[indexNotifier.value];
              params.word = entry.word;
              params.meaning = entry.meaning;
              params.reading = entry.reading;

              searched = true;

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );

    if (searched) {
      Future.delayed(const Duration(milliseconds: 50), () {
        FocusScope.of(context).unfocus();
        runPiggybackEnhancements(context, appModel, params, state);
      });
    }

    return params;
  }

  List<Type> piggybackEnhancements = [
    BingSearchEnhancement,
    PitchAccentExportEnhancement,
    ForvoAudioEnhancement,
  ];

  /// This function takes every function listed above and executes them (if
  /// activated as auto) after the search.
  ///
  /// This way, after you searched a word, registered enhancements above will
  /// piggyback and also execute their enhancements afterwards. This is
  /// useful if you want, for example, to have your word search cascade with
  /// other search enhancements.
  ///
  /// Be very careful with base cases/recursion in regards to using this kind
  /// of automation chaining enhancements together.
  Future<void> runPiggybackEnhancements(BuildContext context, AppModel appModel,
      AnkiExportParams params, CreatorPageState state) async {
    state.setCurrentParams(params);

    for (AnkiExportField field in AnkiExportField.values) {
      AnkiExportEnhancement? enhancement =
          appModel.getAutoFieldEnhancement(field);
      if (enhancement != null) {
        if (piggybackEnhancements.contains(enhancement.runtimeType)) {
          AnkiExportParams piggybackParams = await enhancement.enhanceParams(
            context: context,
            params: state.getCurrentParams(),
            state: state,
            autoMode: true,
            appModel: appModel,
          );

          state.setCurrentParams(piggybackParams, field: field);
          state.refresh();
        }
      }
    }
  }
}

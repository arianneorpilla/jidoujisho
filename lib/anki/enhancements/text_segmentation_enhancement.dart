import 'dart:async';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/anki/enhancements/search_dictionary_enhancement.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class TextSegmentationEnhancement extends AnkiExportEnhancement {
  TextSegmentationEnhancement({
    required AppModel appModel,
  }) : super(
          appModel: appModel,
          enhancementName: "Text Segmentation",
          enhancementDescription:
              "Split text into words and open a picker dialog.",
          enhancementIcon: Icons.account_tree,
          enhancementField: AnkiExportField.image,
        );

  @override
  Future<AnkiExportParams> enhanceParams({
    required BuildContext context,
    required AppModel appModel,
    required AnkiExportParams params,
    required bool autoMode,
    required CreatorPageState state,
  }) async {
    if (params.sentence.isEmpty) {
      return params;
    }

    ValueNotifier<List<bool>> indexesSelected;
    List<Widget> textWidgets;
    List<String> words =
        await appModel.getCurrentLanguage().textToWords(params.sentence);

    words.removeWhere((word) => word.trim().isEmpty);

    indexesSelected = ValueNotifier<List<bool>>(
      List.generate(
        words.length,
        (index) => false,
      ),
    );
    textWidgets = getTextWidgetsFromWords(words, indexesSelected);

    ScrollController scrollController = ScrollController();

    bool isSpaceDelimited = appModel.getCurrentLanguage().isSpaceDelimited;
    bool isSearch = false;
    String searchTerm = "";

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: SizedBox(
            child: ValueListenableBuilder(
              valueListenable: indexesSelected,
              builder: (BuildContext context, List<bool> _, Widget? widget) {
                return RawScrollbar(
                  thumbColor: (appModel.getIsDarkMode())
                      ? Colors.grey[700]
                      : Colors.grey[400],
                  controller: scrollController,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Wrap(children: textWidgets),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                appModel.translate('dialog_set'),
              ),
              onPressed: () {
                if (indexesSelected.value
                    .every((selected) => selected == false)) {
                  params.sentence = params.sentence;
                } else {
                  String wordsJoined = "";

                  for (int i = 0; i < words.length; i++) {
                    if (indexesSelected.value[i]) {
                      wordsJoined += words[i];
                    }
                    if (isSpaceDelimited) {
                      wordsJoined += " ";
                    }
                  }

                  params.word = wordsJoined.trim();
                }

                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(appModel.translate('dialog_search')),
              onPressed: () async {
                isSearch = true;

                if (indexesSelected.value
                    .every((selected) => selected == false)) {
                  searchTerm = params.sentence;
                } else {
                  String wordsJoined = "";

                  for (int i = 0; i < words.length; i++) {
                    if (indexesSelected.value[i]) {
                      wordsJoined += words[i];
                    }
                    if (isSpaceDelimited) {
                      wordsJoined += " ";
                    }
                  }

                  searchTerm = wordsJoined.trim();
                }

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );

    if (isSearch) {
      AnkiExportEnhancement enhancement =
          SearchDictionaryEnhancement(appModel: appModel);
      params.word = searchTerm;
      return enhancement.enhanceParams(
        context: context,
        appModel: appModel,
        params: params,
        autoMode: autoMode,
        state: state,
      );
    } else {
      return params;
    }
  }

  List<Widget> getTextWidgetsFromWords(
      List<String> words, ValueNotifier<List<bool>> notifier) {
    words.forEachIndexed((i, word) {
      words[i] = word.trim();
    });

    List<Widget> widgets = [];
    for (int i = 0; i < words.length; i++) {
      widgets.add(
        GestureDetector(
          onTap: () {
            List<bool> values = notifier.value;
            values[i] = !values[i];
            notifier.value = [...values];
          },
          child: ValueListenableBuilder(
              valueListenable: notifier,
              builder:
                  (BuildContext context, List<bool> values, Widget? child) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 10, right: 10),
                  color: (notifier.value[i])
                      ? Colors.red.withOpacity(0.3)
                      : (Theme.of(context).backgroundColor == Colors.black)
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                  child: Text(
                    words[i],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                );
              }),
        ),
      );
    }

    return widgets;
  }
}

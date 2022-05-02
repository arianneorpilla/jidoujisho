import 'dart:async';
import 'dart:convert';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/language/language.dart';
import 'package:chisa/language/languages/chinese_simplified_language.dart';
import 'package:chisa/language/languages/chinese_traditional_language.dart';
import 'package:chisa/language/languages/japanese_language.dart';
import 'package:chisa/language/languages/korean_language.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TatoebaExampleSentencesEnhancement extends AnkiExportEnhancement {
  TatoebaExampleSentencesEnhancement({
    required AppModel appModel,
  }) : super(
          appModel: appModel,
          enhancementName: "Tatoeba Example Sentences",
          enhancementDescription: "Get example sentences via Tatoeba.",
          enhancementIcon: Icons.article_outlined,
          enhancementField: AnkiExportField.word,
        );

  Map<String, List<String>> tatoebaCache = {};

  @override
  Future<AnkiExportParams> enhanceParams({
    required BuildContext context,
    required AppModel appModel,
    required AnkiExportParams params,
    required bool autoMode,
    required CreatorPageState state,
  }) async {
    String text = "";
    if (params.word.isEmpty) {
      return params;
    }

    text = params.word;

    ValueNotifier<List<bool>> indexesSelected;
    List<Widget> textWidgets;

    String lang = "";
    Language currentLanguage = appModel.getCurrentLanguage();
    if (currentLanguage is JapaneseLanguage) {
      lang = "jpn";
    } else if (currentLanguage is ChineseSimplifiedLanguage) {
      lang = "cmn";
    } else if (currentLanguage is ChineseTraditionalLanguage) {
      lang = "yue";
    } else if (currentLanguage is KoreanLanguage) {
      lang = "kor";
    } else {
      throw UnimplementedError("This language is not implemented for Tatoeba");
    }

    List<String> sentences = [];

    String cacheKey = "${appModel.getCurrentLanguage()}/$text";
    if (tatoebaCache[cacheKey] != null) {
      sentences = tatoebaCache[cacheKey]!;
    } else {
      var client = http.Client();
      http.Response response = await client.get(Uri.parse(
          'https://tatoeba.org/en/api_v0/search?from=$lang&has_audio=&native=&orphans=no&query=$text&sort=relevance&sort_reverse=&tags=&to=none&trans_filter=limit&trans_has_audio=&trans_link=&trans_orphan=&trans_to=&trans_unapproved=&trans_user=&unapproved=no&user='));

      Map<String, dynamic> json = jsonDecode(response.body);
      List<dynamic> results = json["results"];

      sentences = results.map((result) => result["text"].toString()).toList();
      tatoebaCache[cacheKey] = sentences;
    }

    indexesSelected = ValueNotifier<List<bool>>(
      List.generate(
        sentences.length,
        (index) => false,
      ),
    );
    textWidgets = getTextWidgetsFromSentences(sentences, indexesSelected);

    ScrollController scrollController = ScrollController();

    bool isSpaceDelimited = appModel.getCurrentLanguage().isSpaceDelimited;

    if (sentences.isEmpty) {
      return params;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          shape: const RoundedRectangleBorder(),
          content: RawScrollbar(
            thumbColor: (appModel.getIsDarkMode())
                ? Colors.grey[700]
                : Colors.grey[400],
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              child: ValueListenableBuilder<List<bool>>(
                valueListenable: indexesSelected,
                builder: (context, _, widget) {
                  return Wrap(children: textWidgets);
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                appModel.translate('dialog_set'),
              ),
              onPressed: () {
                String sentencesJoined = "";

                for (int i = 0; i < sentences.length; i++) {
                  if (indexesSelected.value[i]) {
                    sentencesJoined += sentences[i];
                    sentencesJoined += "\n";
                  }
                  if (isSpaceDelimited) {
                    sentencesJoined += " ";
                    sentencesJoined += "\n";
                  }
                }

                params.sentence = sentencesJoined.trim();

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );

    return params;
  }

  List<Widget> getTextWidgetsFromSentences(
      List<String> sentences, ValueNotifier<List<bool>> notifier) {
    sentences.forEachIndexed((i, word) {
      sentences[i] = word.trim();
    });

    List<Widget> widgets = [];
    for (int i = 0; i < sentences.length; i++) {
      widgets.add(
        GestureDetector(
          onTap: () {
            List<bool> values = notifier.value;
            values[i] = !values[i];
            notifier.value = [...values];
          },
          child: ValueListenableBuilder<List<bool>>(
              valueListenable: notifier,
              builder: (context, values, child) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 10, right: 10),
                  color: (notifier.value[i])
                      ? Colors.red.withOpacity(0.3)
                      : (Theme.of(context).backgroundColor == Colors.black)
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                  child: Text(
                    sentences[i],
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

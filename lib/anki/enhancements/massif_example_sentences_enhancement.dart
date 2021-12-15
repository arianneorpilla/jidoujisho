import 'dart:async';
import 'dart:convert';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:chisa/util/reg_exp.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

class MassifResult {
  MassifResult({
    required this.spans,
    required this.text,
    required this.context,
  });

  List<InlineSpan> spans;
  String text;
  String context;
}

class MassifExampleSentencesEnhancement extends AnkiExportEnhancement {
  MassifExampleSentencesEnhancement({
    required AppModel appModel,
  }) : super(
          appModel: appModel,
          enhancementName: "Massif Example Sentences",
          enhancementDescription: "Get curated example sentences via Massif.",
          enhancementIcon: Icons.article,
          enhancementField: AnkiExportField.word,
        );

  Map<String, List<MassifResult>> massifCache = {};

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

    List<MassifResult> results = [];

    String cacheKey = "${appModel.getCurrentLanguage()}/$text";
    if (massifCache[cacheKey] != null) {
      results = massifCache[cacheKey]!;
    } else {
      var client = http.Client();
      http.Response response = await client
          .get(Uri.parse('https://massif.la/ja/search?q=$text&fmt=json'));
      Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));

      List<dynamic> resultsJson = json['results'];
      for (Map<String, dynamic> resultJson in resultsJson) {
        String context = resultJson['sample_source']['title'];
        String text = resultJson['text'];

        List<InlineSpan> spans = [];

        String highlightedText = resultJson['highlighted_html'];
        List<String> splitWithDelims =
            highlightedText.splitWithDelim(RegExp(r"<em>(.*?)<\/em>"));

        for (String splitWithDelim in splitWithDelims) {
          if (splitWithDelim.startsWith("<em>") &&
              splitWithDelim.endsWith("</em>")) {
            spans.add(
              TextSpan(
                text: splitWithDelim
                    .replaceAll("<em>", "")
                    .replaceAll("</em>", ""),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
            );
          } else {
            spans.add(
              TextSpan(
                text: splitWithDelim,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }
        }

        MassifResult result = MassifResult(
          spans: spans,
          text: text,
          context: context,
        );

        results.add(result);
      }

      massifCache[cacheKey] = results;
    }

    indexesSelected = ValueNotifier<List<bool>>(
      List.generate(
        results.length,
        (index) => false,
      ),
    );
    textWidgets = getTextWidgetsFromSentences(results, indexesSelected);

    ScrollController scrollController = ScrollController();

    if (results.isEmpty) {
      return params;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          content: RawScrollbar(
            thumbColor: (appModel.getIsDarkMode())
                ? Colors.grey[700]
                : Colors.grey[400],
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              child: ValueListenableBuilder(
                valueListenable: indexesSelected,
                builder: (BuildContext context, List<bool> _, Widget? widget) {
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

                for (int i = 0; i < results.length; i++) {
                  if (indexesSelected.value[i]) {
                    sentencesJoined += results[i].text;
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
      List<MassifResult> results, ValueNotifier<List<bool>> notifier) {
    List<Widget> widgets = [];
    for (int i = 0; i < results.length; i++) {
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(children: results[i].spans),
                        ),
                        Text(
                          results[i].context,
                          style: TextStyle(
                            fontSize: 8,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                        )
                      ],
                    ));
              }),
        ),
      );
    }

    return widgets;
  }
}

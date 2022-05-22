import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/models.dart';
import 'package:http/http.dart' as http;

/// An entity used to neatly return and organise results fetched from Massif.
class MassifResult {
  /// Define a result with the given parameters.
  MassifResult({
    required this.widget,
    required this.text,
    required this.source,
  });

  /// A formatted widget which may contain highlighted text.
  Widget widget;

  /// The sentence in plain unformatted form.
  String text;

  /// The context from which the text was obtained.
  String source;
}

/// An enhancement used to fetch example sentences via Massif.
class MassifExampleSentencesEnhancement extends Enhancement {
  /// Initialise this enhancement with the hardset parameters.
  MassifExampleSentencesEnhancement()
      : super(
          uniqueKey: key,
          label: 'Massif Example Sentences',
          description: 'Get curated example sentences via Massif.',
          icon: Icons.article,
          field: Field.word,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'massif_example_sentences';

  /// Used to store results that have already been found at runtime.
  final Map<String, List<MassifResult>> massifCache = {};

  /// Client used to communicate with the Massif API.
  final http.Client client = http.Client();

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    String searchTerm = creatorModel.getFieldController(field).text;

    List<MassifResult> exampleSentences = await searchForSentences(
      context: context,
      appModel: appModel,
      searchTerm: searchTerm,
    );

    appModel.openMassifSentenceDialog(
      exampleSentences: exampleSentences,
      onSelect: (selection) {
        creatorModel.getFieldController(Field.sentence).text = selection;
      },
    );
  }

  /// Search the Massif API for example sentences and return a list of results.
  Future<List<MassifResult>> searchForSentences({
    required BuildContext context,
    required AppModel appModel,
    required String searchTerm,
  }) async {
    if (searchTerm.trim().isEmpty) {
      return [];
    }

    if (massifCache[searchTerm] != null) {
      return massifCache[searchTerm]!;
    }

    List<MassifResult> results = [];

    late http.Response response;

    try {
      /// Query the Massif API for results.
      response = await client.get(
          Uri.parse('https://massif.la/ja/search?&fmt=json&q=$searchTerm'));

      Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));

      /// For each response, create a [MassifResult] that can be used to display
      /// the widget as well as hold the sentence and source data.
      List<Map<String, dynamic>> queryResponses =
          List<Map<String, dynamic>>.from(json['results']);

      for (Map<String, dynamic> queryResponse in queryResponses) {
        Map<String, String> sampleSource =
            Map<String, String>.from(queryResponse['sample_source']);
        String source = sampleSource['title']!;
        String text = queryResponse['text'];

        List<InlineSpan> spans = [];

        String highlightedText = queryResponse['highlighted_html'];
        List<String> splitWithDelims =
            highlightedText.splitWithDelim(RegExp(r'<em>(.*?)<\/em>'));

        for (String splitWithDelim in splitWithDelims) {
          if (splitWithDelim.startsWith('<em>') &&
              splitWithDelim.endsWith('</em>')) {
            spans.add(
              TextSpan(
                text: splitWithDelim
                    .replaceAll('<em>', '')
                    .replaceAll('</em>', ''),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                ),
              ),
            );
          } else {
            spans.add(
              TextSpan(
                text: splitWithDelim,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                ),
              ),
            );
          }
        }

        Widget widget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(children: spans),
            ),
            Text(
              source,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.labelSmall?.fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            )
          ],
        );

        MassifResult result = MassifResult(
          widget: widget,
          text: text,
          source: source,
        );

        results.add(result);
      }

      /// Save this into cache.
      massifCache[searchTerm] = results;

      return results;
    } catch (e) {
      /// Used to log if this third-party service is down or changes domains.
      appModel.showFailedToCommunicateMessage();
      throw Exception(
        'Failed to communicate with Massif: ${response.reasonPhrase}',
      );
    }
  }
}

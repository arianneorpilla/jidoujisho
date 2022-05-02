import 'dart:async';

import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_import.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:collection/collection.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';

class NaverDictionaryFormat extends DictionaryFormat {
  NaverDictionaryFormat()
      : super(
          formatName: 'Naver Dictionary',
          isOnline: true,
          prepareWorkingDirectory: prepareWorkingDirectoryNaverDictionaryFormat,
          getDictionaryName: getDictionaryNameNaverDictionaryFormat,
          getDictionaryEntries: getDictionaryEntriesNaverDictionaryFormat,
          getDictionaryMetadata: getDictionaryMetadataNaverDictionaryFormat,
          searchResultsEnhancement:
              searchResultsEnhancementNaverDictionaryFormat,
        );
}

/// Online dictionary. These are left blank.
///
/// To get a list of [DictionaryEntry], these are injected during
@override
FutureOr<void> prepareWorkingDirectoryNaverDictionaryFormat(
    ImportPreparationParams params) async {}

@override
FutureOr<String> getDictionaryNameNaverDictionaryFormat(
    ImportDirectoryParams params) {
  return 'Naver Dictionary';
}

@override
FutureOr<List<DictionaryEntry>> getDictionaryEntriesNaverDictionaryFormat(
    ImportDirectoryParams params) async {
  return [];
}

@override
FutureOr<Map<String, String>> getDictionaryMetadataNaverDictionaryFormat(
    ImportDirectoryParams params) {
  return {};
}

@override
FutureOr<DictionarySearchResult> searchResultsEnhancementNaverDictionaryFormat(
  ResultsProcessingParams params,
) async {
  List<DictionaryEntry> entries = [];
  bool webViewBusy = true;

  DictionarySearchResult result = params.result;
  HeadlessInAppWebView webView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: Uri.parse(
            'https://korean.dict.naver.com/koendict/#/search?range=word&query=${params.result.originalSearchTerm}&shouldSearchOpen=false'),
      ),
      onLoadStop: (controller, uri) async {
        await Future.delayed(const Duration(milliseconds: 500), () {});

        dom.Document document = parser.parse(await controller.getHtml());

        List<dom.Element> rowElements = document.getElementsByClassName('row');

        rowElements.forEachIndexed((i, rowElement) {
          dom.Element wordElement = rowElement
              .getElementsByClassName('origin')
              .first
              .getElementsByTagName('a')
              .first;

          for (dom.Element element in wordElement.children) {
            if (element.className == 'num') {
              element.remove();
            }
          }

          String word = Bidi.stripHtmlIfNeeded(wordElement.innerHtml)
              .split('\n')
              .map((line) => line.trim())
              .join(' ')
              .trim();

          dom.Element meaningElement =
              rowElement.getElementsByClassName('mean_list').first;

          meaningElement
              .querySelectorAll('div.user_info')
              .forEach((element) => element.remove());

          for (dom.Element element in wordElement.children) {
            if (element.className == 'num') {
              element.remove();
            }
          }

          List<String> meanings = [];

          for (dom.Element element in rowElement
              .getElementsByClassName('mean_list')
              .first
              .children) {
            meanings.add(Bidi.stripHtmlIfNeeded(element.innerHtml)
                .split('\n')
                .map((line) => line.trim())
                .join(' ')
                .trim());
          }

          String meaning = meanings.join('\n');

          List<String> readings = [];

          if (rowElement.getElementsByClassName('listen_list').isNotEmpty) {
            for (dom.Element element in rowElement
                .getElementsByClassName('listen_list')
                .first
                .children) {
              readings.add(Bidi.stripHtmlIfNeeded(element.innerHtml)
                  .split('\n')
                  .map((line) => line.trim())
                  .join(' ')
                  .trim());
            }
          }

          readings.removeWhere((reading) => reading == 'Listen');
          String reading = readings
              .map((reading) =>
                  reading.replaceAll('[', '').replaceAll(']', '').trim())
              .join(' / ');

          DictionaryEntry entry = DictionaryEntry(
            word: word,
            reading: reading,
            meaning: meaning,
          );

          entries.add(entry);
        });

        webViewBusy = false;
      });

  await webView.run();

  while (webViewBusy) {
    await Future.delayed(const Duration(milliseconds: 100), () {});
  }

  result.entries.addAll(entries);

  return result;
}

import 'dart:convert';

import 'package:daijidoujisho/dictionary/dictionary_format.dart';
import 'package:daijidoujisho/dictionary/dictionary_result.dart';

class DictionarySearchResult {
  DictionarySearchResult({
    required this.dictionaryName,
    required this.dictionaryFormat,
    required this.originalSearchTerm,
    required this.fallbackSearchTerm,
    required this.results,
  });

  /// The dictionary where the results were sourced from.
  final String dictionaryName;

  /// The format of the dictionary where the results were sourced from.
  final DictionaryFormat dictionaryFormat;

  /// An original search term used from the actual media or search made.
  final String originalSearchTerm;

  /// A lemmatised or fallback search term from the original search term.
  final String fallbackSearchTerm;

  /// The list of processed search results.
  final List<DictionaryResultItem> results;

  String toJson() {
    List<String> serialisedItems = [];
    for (DictionaryResultItem result in results) {
      serialisedItems.add(
        jsonEncode(
          result.toJson(),
        ),
      );
    }

    Map<String, String> map = {
      "dictionaryName": dictionaryName,
      "dictionaryFormat": dictionaryFormat.formatName,
      "originalSearchTerm": originalSearchTerm,
      "fallbackSearchTerm": fallbackSearchTerm,
      "results": jsonEncode(serialisedItems),
    };

    return jsonEncode(map);
  }
}

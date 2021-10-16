import 'dart:convert';

import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_result.dart';

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

  /// Get a serialised representation of the dictionary search result
  /// for history and persistence purposes.
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
      "formatName": dictionaryFormat.formatName,
      "originalSearchTerm": originalSearchTerm,
      "fallbackSearchTerm": fallbackSearchTerm,
      "results": jsonEncode(serialisedItems),
    };

    return jsonEncode(map);
  }

  factory DictionarySearchResult.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);

    List<String> resultsJson = jsonDecode(map["results"]);

    List<DictionaryResultItem> results = [];
    for (String resultJson in resultsJson) {
      results.add(
        DictionaryResultItem.fromJson(resultJson),
      );
    }

    return DictionarySearchResult(
      dictionaryName: map["dictionaryName"],
      dictionaryFormat: map["formatName"],
      originalSearchTerm: map["originalSearchTerm"],
      fallbackSearchTerm: map["fallbackSearchTerm"],
      results: results,
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:chisa/dictionary/dictionary_entry.dart';

class DictionarySearchResult {
  DictionarySearchResult({
    required this.dictionaryName,
    required this.formatName,
    required this.originalSearchTerm,
    required this.fallbackSearchTerm,
    required this.entries,
    this.contextSource = "",
    this.contextPosition = -1,
    this.contextMediaTypeName = "",
    this.storeReference,
  });

  /// The dictionary where the results were sourced from.
  final String dictionaryName;

  /// The format of the dictionary where the results were sourced from.
  final String formatName;

  /// An original search term used from the actual media or search made.
  final String originalSearchTerm;

  /// A lemmatised or fallback search term from the original search term.
  final String fallbackSearchTerm;

  /// A [Uri] in [String] form that represents media that could be in use
  /// when the search was made. Used to return from context from history.
  final String contextSource;

  /// A number that represents the position of progress of media upon search.
  /// Used to return to a specific point in context from history.
  final int contextPosition;

  /// Name of the media type where a media was playing. Used to return from
  /// context from history back to a certain media type body.
  final String contextMediaTypeName;

  /// The list of processed search results.
  final List<DictionaryEntry> entries;

  /// An ObjectBox [Store] reference that is used to make the dictionary
  /// search from another isolate. As an empty [DictionarySearchResult] is
  /// passed as a parameter to make the search, the object itself to be filled
  /// is passed as the parameter to the [compute] function.
  ByteData? storeReference;

  /// Get a serialised representation of the dictionary search result
  /// for history and persistence purposes.
  String toJson() {
    List<String> serialisedItems = [];
    for (DictionaryEntry entry in entries) {
      serialisedItems.add(
        entry.toJson(),
      );
    }

    Map<String, dynamic> map = {
      "dictionaryName": dictionaryName,
      "formatName": formatName,
      "originalSearchTerm": originalSearchTerm,
      "fallbackSearchTerm": fallbackSearchTerm,
      "entries": jsonEncode(serialisedItems),
      "contextSource": contextSource,
      "contextPosition": contextPosition,
      "contextMediaTypeName": contextMediaTypeName,
    };

    return jsonEncode(map);
  }

  factory DictionarySearchResult.fromJson(String json) {
    Map<String, dynamic> map = Map.castFrom(jsonDecode(json));

    List<String> entriesJson = List.castFrom(jsonDecode(map["entries"]));

    List<DictionaryEntry> entries = [];
    for (String entryJson in entriesJson) {
      entries.add(
        DictionaryEntry.fromJson(entryJson),
      );
    }

    return DictionarySearchResult(
      dictionaryName: map["dictionaryName"],
      formatName: map["formatName"],
      originalSearchTerm: map["originalSearchTerm"],
      fallbackSearchTerm: map["fallbackSearchTerm"],
      entries: entries,
      contextSource: map["contextSource"],
      contextPosition: map["contextPosition"] as int,
      contextMediaTypeName: map["contextMediaTypeName"],
    );
  }
}

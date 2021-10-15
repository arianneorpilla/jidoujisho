import 'package:flutter/material.dart';

import 'package:daijidoujisho/dictionary/dictionary_entry.dart';
import 'package:daijidoujisho/dictionary/dictionary_extract_params.dart';
import 'package:daijidoujisho/dictionary/dictionary_result.dart';
import 'package:daijidoujisho/dictionary/dictionary_search_results.dart';
import 'package:daijidoujisho/models/dictionary_progress_model.dart';

abstract class DictionaryFormat {
  DictionaryFormat({
    required this.formatName,
    this.formatIcon = Icons.archive,
  });

  /// The name of this dictionary format. For example, this could be a
  /// "Yomichan Term Bank Dictionary" or "ABBYY Lingvo".
  late String formatName;

  /// An appropriate icon for this dictionary format.
  late IconData formatIcon;

  /// Given a [Uri], return whether or not the source is of this dictionary
  /// format.
  bool isUriSupported(Uri uri);

  /// Given a [Uri], return the appropriate name of a dictionary. For example,
  /// "JMdict" or "Merriam-Webster Dictionary".
  String getDictionaryName(Uri uri);

  /// Return a list of [DictionaryEntry] from a given [Uri]. This function
  /// will perform file extraction and will parse the contents of the
  /// dictionary file to get the entries.
  ///
  /// This is a resource intensive operation and operations inside this should
  /// be handled in a separate isolate and call [compute].
  List<DictionaryExtractParams> getDictionaryEntries(
      Uri uri, DictionaryProgressModel dictionaryProgress);

  /// Process clean results from the searched entries.
  DictionarySearchResult processResultsFromEntries(
      List<DictionaryEntry> entries);

  /// Recreate a dictionary result item from serialised JSON. Used for history.
  DictionaryResultItem fromJson(String json);
}

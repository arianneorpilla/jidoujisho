import 'dart:async';
import 'dart:io';

import 'package:chisa/dictionary/dictionary_entry_widget.dart';
import 'package:chisa/dictionary/dictionary_utils.dart';
import 'package:flutter/material.dart';

import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_search_results.dart';

abstract class DictionaryFormat {
  DictionaryFormat({
    required this.formatName,
    required this.prepareWorkingDirectory,
    required this.getDictionaryName,
    required this.getDictionaryEntries,
    required this.getDictionaryMetadata,
    this.databaseSearchEnhancement,
    this.searchResultsEnhancement,
    this.widgetDisplayEnhancement,
  });

  /// The name of this dictionary format. For example, this could be a
  /// "Yomichan Term Bank Dictionary" or "ABBYY Lingvo".
  late String formatName;

  /// An appropriate icon for this dictionary format.
  late IconData formatIcon;

  /// Given a [Uri], return whether or not the source is of this dictionary
  /// format. Some formats may not depend on file extensions for compatibility.
  ///
  /// Hence, the default behaviour of this function is to always allow files
  /// regardless of [Uri] to be attempted for import.
  bool isUriSupported(Uri uri) {
    return true;
  }

  /// [IMPORTANT]: The following parameters below point to functions defined in
  /// the top-level, not within the inheriting class. They are meant to be
  /// defined in the constructor -- the actual functions to be executed are
  /// outside of the class, placed preferably at the bottom of the inheriting
  /// format class. This is because these functions should not block the UI
  /// isolate and must be top-level in order to do so.

  /// Given a [File], prepare files to be accessible in a working [Directory]
  /// such that it will be possible to make relative commands (in the
  /// directory) to be able to get a dictionary's name, its entries and
  /// other related metadata that will be useful for preservation.
  ///
  /// For many formats, this will likely be a ZIP extraction operation. A
  /// given parameter [targetDirectory] is where the final working directory
  /// should be, and where the rest of the operations will be performed.
  ///
  /// See [ImportPreparationParams] for how to work with the individual input
  /// parameters.
  late FutureOr<void> Function(ImportPreparationParams params)
      prepareWorkingDirectory;

  /// Given a [Directory] of files pertaining to this dictionary format,
  /// return a [String] that will refer to a dictionary's name in this format.
  ///
  /// If this format does not offer a way for a dictionary's name to be
  /// represented in its schema, return a unique [String] instead such that
  /// collisions with other dictionaries will not be likely.
  ///
  /// See [ImportProcessingParams] for how to work with the individual input
  /// parameters.
  late FutureOr<String> Function(ImportProcessingParams) getDictionaryName;

  /// Given a [Directory] of files pertaining to this dictionary format,
  /// return a list of [DictionaryEntry] that will be added to the database.
  ///
  /// See [ImportProcessingParams] for how to work with the individual input
  /// parameters.
  late FutureOr<List<DictionaryEntry>> Function(ImportProcessingParams)
      getDictionaryEntries;

  /// Given a [Directory] of files pertaining to this dictionary format,
  /// prepare a [Map] of metadata that will be used for cleaning up and
  /// enhancing raw database results.
  ///
  /// For example, a dictionary format may make use of tags separate from the
  /// entry. This will be preserved by the dictionary. This field may also
  /// be used to store trivial metadata pertaining to the dictionary itself.
  ///
  /// See [ImportProcessingParams] for how to work with the individual input
  /// parameters.
  late FutureOr<Map<String, String>> Function(ImportProcessingParams)
      getDictionaryMetadata;

  /// Some formats may want to perform their own queries and override the
  /// standard database query. If not, leave this null, which is the default.
  late FutureOr<DictionarySearchResult> Function(DictionarySearchResult result)?
      databaseSearchEnhancement;

  /// Some formats may want to override existing search results over the
  /// standard results. If not, leave this null, which is the default.
  late FutureOr<DictionarySearchResult> Function(DictionarySearchResult result)?
      searchResultsEnhancement;

  /// Some formats may want to override the widget representation of their
  /// results. If not, leave this null, which is the default.
  late DictionaryEntryWidget Function(DictionaryEntry result)?
      widgetDisplayEnhancement;
}

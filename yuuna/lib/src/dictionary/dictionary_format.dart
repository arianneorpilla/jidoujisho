import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:yuuna/dictionary.dart';

/// Information making up a supported dictionary format, as well as the methods
/// that the format will use in a separate isolate for importing or enabling
/// a dictionary of the matching format. Methods are top-level and should be
/// defined in the global scope below the class declaration of a dictionary
/// format.
abstract class DictionaryFormat {
  /// Define a format with the given metadata that has its behaviour for
  /// import, search and display defined with a set of top-level helper methods.
  DictionaryFormat({
    required this.formatName,
    required this.formatIcon,
    required this.compatibleFileExtensions,
    required this.prepareDirectory,
    required this.prepareName,
    required this.prepareEntries,
    required this.prepareMetaEntries,
    required this.prepareTags,
    required this.prepareMetadata,
  });

  /// The name of this dictionary format. For example, this could be a
  /// 'Yomichan Term Bank Dictionary' or 'ABBYY Lingvo'.
  late String formatName;

  /// An appropriate icon for this dictionary format.
  late IconData formatIcon;

  /// This will be used to notify the user about the required extension if they
  /// select a file with the wrong extension.
  late List<String> compatibleFileExtensions;

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
  /// given parameter is where the final working directory should be, and where
  /// zthe rest of the operations will be performed.
  ///
  /// See [PrepareDirectoryParams] for how to work with the individual input
  /// parameters.
  Future<void> Function(PrepareDirectoryParams params) prepareDirectory;

  /// Given a [Directory] of files pertaining to this dictionary format,
  /// return a [String] that will refer to a dictionary's name in this format.
  ///
  /// If this format does not offer a way for a dictionary's name to be
  /// represented in its schema, return a unique [String] instead such that
  /// collisions with other dictionaries will not be likely.
  ///
  /// See [PrepareDictionaryParams] for how to work with the individual input
  /// parameters.
  Future<String> Function(PrepareDirectoryParams params) prepareName;

  /// Given a [Directory] of files pertaining to this dictionary format,
  /// return a list of [DictionaryEntry] that will be added to the database.
  ///
  /// See [PrepareDictionaryParams] for how to work with the individual input
  /// parameters.
  Future<List<DictionaryEntry>> Function(PrepareDictionaryParams params)
      prepareEntries;

  /// Given a [Directory] of files pertaining to this dictionary format,
  /// prepare a list of [DictionaryTag] that will be added to the database.
  ///
  /// For example, a dictionary format may make use of tags separate from the
  /// entry. This will be preserved.
  ///
  /// See [PrepareDictionaryParams] for how to work with the individual input
  /// parameters.
  Future<List<DictionaryTag>> Function(PrepareDictionaryParams params)
      prepareTags;

  /// Given a [Directory] of files pertaining to this dictionary format,
  /// prepare a list of [DictionaryMetaEntry] that will be added to the database.
  ///
  /// For example, a dictionary format may make use of data that may match a
  /// certain word-reading combination. This will be preserved.
  ///
  /// See [PrepareDictionaryParams] for how to work with the individual input
  /// parameters.
  Future<List<DictionaryMetaEntry>> Function(PrepareDictionaryParams params)
      prepareMetaEntries;

  /// Given a [Directory] of files pertaining to this dictionary format,
  /// prepare a [Map] of metadata that will be used for cleaning up and
  /// enhancing raw database results.
  ///
  /// For example, a dictionary format may make use of tags separate from the
  /// entry. This will be preserved by the dictionary. This field may also
  /// be used to store trivial metadata pertaining to the dictionary itself.
  ///
  /// See [PrepareDictionaryParams] for how to work with the individual input
  /// parameters.
  Future<Map<String, String>> Function(PrepareDictionaryParams params)
      prepareMetadata;
}

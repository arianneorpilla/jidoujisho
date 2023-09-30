import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';
import 'package:flutter/widgets.dart';

/// Information making up a supported dictionary format, as well as the methods
/// that the format will use in a separate isolate for importing or enabling
/// a dictionary of the matching format. Methods are top-level and should be
/// defined in the global scope below the class declaration of a dictionary
/// format.
abstract class DictionaryFormat {
  /// Define a format with the given metadata that has its behaviour for
  /// import, search and display defined with a set of top-level helper methods.
  DictionaryFormat({
    required this.uniqueKey,
    required this.name,
    required this.icon,
    required this.allowedExtensions,
    required this.isTextFormat,
    required this.fileType,
    required this.prepareDirectory,
    required this.prepareName,
    required this.prepareEntries,
    required this.prepareTags,
    required this.preparePitches,
    required this.prepareFrequencies,
  });

  /// This is used to distinguish dictionary formats from one another, and to
  /// allow editing of the display name easily without having to worry about
  /// backwards compatibility.
  late String uniqueKey;

  /// The display name of this dictionary format. For example, this could be a
  /// 'Yomichan Dictionary' or 'ABBYY Lingvo'.
  late String name;

  /// An appropriate icon for this dictionary format.
  late IconData icon;

  /// This will be used to notify the user about the required extension if they
  /// select a file with the wrong extension. Elements should not include
  /// leading dots.
  late List<String> allowedExtensions;

  /// If this is true, the charset of this format will be taken.
  late bool isTextFormat;

  /// Whether or not the file picker supports the file extensions of this
  /// format.
  final FileType fileType;

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

  /// Prepares a list of tags that will be added to the database.
  /// See [PrepareDictionaryParams] for how to work with the individual input
  /// parameters.
  void Function({
    required PrepareDictionaryParams params,
    required Isar isar,
  }) prepareTags;

  /// Prepares entries that will be added to the database.
  /// See [PrepareDictionaryParams] for how to work with the individual input
  /// parameters.
  void Function({
    required PrepareDictionaryParams params,
    required Isar isar,
  }) prepareEntries;

  /// Prepares pitch entries that will be added to the database.
  /// See [PrepareDictionaryParams] for how to work with the individual input
  /// parameters.
  void Function({
    required PrepareDictionaryParams params,
    required Isar isar,
  }) preparePitches;

  /// Prepares frequency entries that will be added to the database.
  /// See [PrepareDictionaryParams] for how to work with the individual input
  /// parameters.
  void Function({
    required PrepareDictionaryParams params,
    required Isar isar,
  }) prepareFrequencies;

  /// Used to allow a format to render its dictionary entries with a custom
  /// widget.
  Widget customDefinitionWidget({
    required BuildContext context,
    required WidgetRef ref,
    required String definition,
  }) {
    return const SizedBox.shrink();
  }

  /// Get the text representation of the custom definition.
  String getCustomDefinitionText(String meaning) {
    return meaning;
  }

  /// If true, uses the [customDefinitionWidget] instead.
  bool shouldUseCustomDefinitionWidget(String definition) {
    return false;
  }
}

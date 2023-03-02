import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:yuuna/dictionary.dart';

/// Base entity which allows messaging updates from other isolates.
class IsolateParams {
  /// Base entity which allows messaging updates from other isolates.
  IsolateParams({
    required this.sendPort,
  });

  /// For communication with a [ReceivePort] for isolate updates.
  final SendPort sendPort;

  /// Send a message through the [sendPort].
  void send(Object? message) {
    sendPort.send(message);
  }
}

/// For isolate communication purposes. See a dictionary format's directory
/// preparation method.
class PrepareDirectoryParams extends IsolateParams {
  /// Prepare parameters for a dictionary format's directory preparation method.
  PrepareDirectoryParams({
    required this.file,
    required this.workingDirectory,
    required this.dictionaryFormat,
    required super.sendPort,
  });

  /// A file from which the contents must be put in working directory. This
  /// should be non-null for dictionary formats that do not require a file for
  /// import.
  final File file;

  /// A working directory to be used in isolation and where data is to be
  /// handled in later steps.
  final Directory workingDirectory;

  /// The dictionary format to be used for entry processing.
  final DictionaryFormat dictionaryFormat;
}

/// For isolate communication purposes. See a dictionary fformat's name, entries
/// and metadata preparation methods. Some parameters may be null at certain
/// stages of the import.
class PrepareDictionaryParams extends IsolateParams {
  /// Prepare parameters for a dictionary format's name, entries and metadata
  /// preparation methods.
  PrepareDictionaryParams({
    required this.dictionary,
    required this.dictionaryFormat,
    required this.workingDirectory,
    required super.sendPort,
  });

  /// The new dictionary to be added after the import is complete.
  final Dictionary dictionary;

  /// The dictionary format to be used for entry processing.
  final DictionaryFormat dictionaryFormat;

  /// A working directory from which to extract dictionary data from.
  final Directory workingDirectory;
}

/// For isolate communication purposes. Used for dictionary deletion.
class DeleteDictionaryParams extends IsolateParams {
  /// Prepare parameters needed for deleting a dictionary from a separate
  /// isolate.
  DeleteDictionaryParams({
    required super.sendPort,
    this.dictionaryId,
  });

  /// If null, this will delete all dictionaries.
  final int? dictionaryId;
}

/// For isolate communication purposes. Used for dictionary deletion.
class UpdateDictionaryHistoryParams extends IsolateParams {
  /// Prepare parameters needed to update dictionary history.
  UpdateDictionaryHistoryParams({
    required this.resultId,
    required this.newPosition,
    required this.maximumDictionaryHistoryItems,
    required super.sendPort,
  });

  /// The result of a dictionary search to be added to history.
  final int resultId;

  /// New position to record.
  final int newPosition;

  /// Maximum number of history items.
  final int maximumDictionaryHistoryItems;
}

/// For isolate communication purposes. Used for dictionary search.
class DictionarySearchParams extends IsolateParams {
  /// Prepare parameters needed for searching the dictionary database from a
  /// separate isolate.
  DictionarySearchParams({
    required this.searchTerm,
    required this.maximumDictionaryHistoryItems,
    required this.maximumDictionaryTermsInResult,
    required this.enabledDictionaryIds,
    required this.searchWithWildcards,
    required super.sendPort,
  });

  /// Primary search term, likely taken from context.
  final String searchTerm;

  /// Maximum number of items that can be in dictionary history.
  final int maximumDictionaryHistoryItems;

  /// Maximum number of headwords in a returned dictionary result for
  /// performance purposes.
  final int maximumDictionaryTermsInResult;

  /// Whether or not this search performs a wildcard search.
  final bool searchWithWildcards;

  /// IDs of dictionaries that are not disabled.
  final List<int> enabledDictionaryIds;

  @override
  bool operator ==(Object other) =>
      other is DictionarySearchParams &&
      searchTerm == other.searchTerm &&
      other.maximumDictionaryTermsInResult ==
          other.maximumDictionaryTermsInResult &&
      searchWithWildcards == other.searchWithWildcards &&
      listEquals(enabledDictionaryIds, other.enabledDictionaryIds);

  @override
  int get hashCode => searchTerm.hashCode;
}

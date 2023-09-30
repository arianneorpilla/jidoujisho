import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// FNV-1a 64bit hash algorithm optimized for Dart Strings.
/// This is used to generate integer IDs that can be hard assigned to entities
/// with string IDs with microscopically low collision. This allows for example,
/// a [DictionaryHeading]'s ID to always be determinable by its composite
/// parameters.
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}

/// Performed in another isolate with compute. This is a top-level utility
/// function that makes use of Isar allowing instances to be opened through
/// multiple isolates. The function for preparing entries and tags according to
/// the [DictionaryFormat] is also done in the same isolate, to remove having
/// to communicate potentially hundreds of thousands of entries to another
/// newly opened isolate.
Future<void> depositDictionaryDataHelper(PrepareDictionaryParams params) async {
  try {
    /// Create a new instance of Isar as this is a different isolate.
    final Isar isar = await Isar.open(
      globalSchemas,
      directory: params.directoryPath,
      maxSizeMiB: 8192,
    );

    /// Write as one transaction. If anything fails, no changes should occur.
    await isar.writeTxnSync(() async {
      /// Write the [Dictionary] entity.
      isar.dictionarys.putSync(params.dictionary);

      /// Write entities.
      params.dictionaryFormat.prepareTags(params: params, isar: isar);
      params.dictionaryFormat.prepareEntries(params: params, isar: isar);
      params.dictionaryFormat.preparePitches(params: params, isar: isar);
      params.dictionaryFormat.prepareFrequencies(params: params, isar: isar);
    });
  } catch (e, stack) {
    debugPrint('$e');
    debugPrint('$stack');

    params.send('$stack');

    rethrow;
  }
}

/// Preloads the entities linked to a search result.
void preloadResultSync(int id) {
  /// Create a new instance of Isar as this is a different isolate.
  final Isar database = Isar.getInstance()!;
  DictionarySearchResult result = database.dictionarySearchResults.getSync(id)!;

  result.headings.loadSync();

  for (DictionaryHeading heading in result.headings) {
    heading.entries.loadSync();
    for (DictionaryEntry entry in heading.entries) {
      entry.dictionary.loadSync();
      entry.tags.loadSync();
    }
    heading.pitches.loadSync();
    heading.frequencies.loadSync();
    for (DictionaryFrequency frequency in heading.frequencies) {
      frequency.dictionary.loadSync();
    }
    heading.tags.loadSync();
  }
}

/// Add a [DictionarySearchResult] to the dictionary history. If the maximum value
/// is exceed, the dictionary history is cut down to the newest values.
Future<void> updateDictionaryHistoryHelper(
  UpdateDictionaryHistoryParams params,
) async {
  final Isar database = await Isar.open(
    globalSchemas,
    directory: params.directoryPath,
    maxSizeMiB: 8192,
  );

  DictionarySearchResult result =
      database.dictionarySearchResults.getSync(params.resultId)!;

  database.writeTxnSync(() {
    result.scrollPosition = params.newPosition;
    database.dictionarySearchResults.putSync(result);
  });
}

/// Clears all data from the dictionary database.
Future<void> deleteDictionariesHelper(DeleteDictionaryParams params) async {
  final Isar database = await Isar.open(
    globalSchemas,
    directory: params.directoryPath,
    maxSizeMiB: 8192,
  );

  database.writeTxnSync(() {
    database.dictionarySearchResults.clearSync();
    database.dictionaryTags.clearSync();
    database.dictionaryEntrys.clearSync();
    database.dictionaryHeadings.clearSync();
    database.dictionaryPitchs.clearSync();
    database.dictionaryFrequencys.clearSync();
    database.dictionarys.clearSync();
  });
}

/// Clears single dictionary data from the dictionary database.
Future<void> deleteDictionaryHelper(DeleteDictionaryParams params) async {
  final Isar database = await Isar.open(
    globalSchemas,
    directory: params.directoryPath,
    maxSizeMiB: 8192,
  );

  int id = params.dictionaryId!;
  Dictionary dictionary = database.dictionarys.getSync(id)!;

  database.writeTxnSync(() {
    database.dictionarySearchResults.clearSync();
    database.dictionaryEntrys
        .filter()
        .dictionary((q) => q.idEqualTo(id))
        .deleteAllSync();
    database.dictionaryTags
        .filter()
        .dictionary((q) => q.idEqualTo(id))
        .deleteAllSync();
    database.dictionaryPitchs
        .filter()
        .dictionary((q) => q.idEqualTo(id))
        .deleteAllSync();
    database.dictionaryFrequencys
        .filter()
        .dictionary((q) => q.idEqualTo(id))
        .deleteAllSync();
    database.dictionaryHeadings
        .filter()
        .entriesIsEmpty()
        .and()
        .tagsIsEmpty()
        .and()
        .pitchesIsEmpty()
        .and()
        .frequenciesIsEmpty()
        .deleteAllSync();
    database.dictionarys.deleteSync(dictionary.id);
  });
}

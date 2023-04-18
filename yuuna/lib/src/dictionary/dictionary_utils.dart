import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/i18n/strings.g.dart';
import 'package:yuuna/models.dart';
import 'package:quiver/iterables.dart';

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
    final Isar database = await Isar.open(
      globalSchemas,
      directory: params.directoryPath,
      maxSizeMiB: 8192,
    );

    /// Perform format-specific entity generation.
    List<DictionaryTag> tags =
        await params.dictionaryFormat.prepareTags(params);
    Map<DictionaryHeading, List<DictionaryPitch>> pitchesByHeading =
        await params.dictionaryFormat.preparePitches(params);
    Map<DictionaryHeading, List<DictionaryFrequency>> frequenciesByHeading =
        await params.dictionaryFormat.prepareFrequencies(params);
    Map<DictionaryHeading, List<DictionaryEntry>> entriesByHeading =
        await params.dictionaryFormat.prepareEntries(params);

    /// For each entity type, assign heading and dictionary so that there are
    /// links and backlinks.
    for (DictionaryTag tag in tags) {
      tag.dictionary.value = params.dictionary;
    }
    Map<int, DictionaryTag> tagsByHash =
        Map.fromEntries(tags.map((tag) => MapEntry(tag.isarId, tag)));

    /// This section is for linking heading and entry tags into their actual
    /// entities, via the tag names they have. The tag names themselves will
    /// not be imported to the database to save space, but will be accessible
    /// via links.
    for (MapEntry<DictionaryHeading, List<DictionaryEntry>> entriesForHeading
        in entriesByHeading.entries) {
      for (DictionaryEntry entryForHeading in entriesForHeading.value) {
        entryForHeading.heading.value = entriesForHeading.key;
        entryForHeading.dictionary.value = params.dictionary;

        List<DictionaryTag> entryTags = entryForHeading.entryTagNames
            .map((name) {
              int dictionaryId = entryForHeading.dictionary.value!.id;
              int hash =
                  DictionaryTag.hash(dictionaryId: dictionaryId, name: name);
              return tagsByHash[hash];
            })
            .whereNotNull()
            .toList();
        List<DictionaryTag> headingTags = entryForHeading.headingTagNames
            .map((name) {
              int dictionaryId = entryForHeading.dictionary.value!.id;
              int hash =
                  DictionaryTag.hash(dictionaryId: dictionaryId, name: name);
              return tagsByHash[hash];
            })
            .whereNotNull()
            .toList();

        entryForHeading.tags.addAll(entryTags);
        entryForHeading.heading.value!.tags.addAll(headingTags);
      }
    }

    for (MapEntry<DictionaryHeading, List<DictionaryPitch>> pitchesForHeading
        in pitchesByHeading.entries) {
      for (DictionaryPitch pitchForHeading in pitchesForHeading.value) {
        pitchForHeading.heading.value = pitchesForHeading.key;
        pitchForHeading.dictionary.value = params.dictionary;
      }
    }
    for (MapEntry<DictionaryHeading,
            List<DictionaryFrequency>> frequenciesByHeading
        in frequenciesByHeading.entries) {
      for (DictionaryFrequency frequencyForHeading
          in frequenciesByHeading.value) {
        frequencyForHeading.heading.value = frequenciesByHeading.key;
        frequencyForHeading.dictionary.value = params.dictionary;
      }
    }

    if (params.useSlowImport) {
      /// Write the [Dictionary] entity.
      database.writeTxnSync(() {
        database.dictionarys.putSync(params.dictionary);
      });

      /// Write [DictionaryTag] entities.
      int tagCount = 0;
      int tagTotal = tags.length;
      partition<DictionaryTag>(tags, 10000).forEach((batch) {
        database.writeTxnSync(() {
          database.dictionaryTags.putAllSync(batch);
        });
        tagCount += batch.length;
        params.send(t.import_write_tag(count: tagCount, total: tagTotal));
      });

      /// Write [DictionaryPitch] entities.
      int pitchCount = 0;
      int pitchTotal = pitchesByHeading.values.map((e) => e.length).sum;
      partition<MapEntry<DictionaryHeading, List<DictionaryPitch>>>(
              pitchesByHeading.entries, 10000)
          .forEach((batch) {
        database.writeTxnSync(() {
          for (MapEntry<DictionaryHeading,
              List<DictionaryPitch>> pitchesForHeading in batch) {
            DictionaryHeading heading = pitchesForHeading.key;
            List<DictionaryPitch> pitches = pitchesForHeading.value;

            database.dictionaryHeadings.putSync(heading);
            database.dictionaryPitchs.putAllSync(pitches);

            pitchCount += pitches.length;
          }
        });

        params.send(t.import_write_pitch(count: pitchCount, total: pitchTotal));
      });

      /// Write [DictionaryFrequency] entities.
      int frequencyCount = 0;
      int frequencyTotal = frequenciesByHeading.values.map((e) => e.length).sum;
      partition<MapEntry<DictionaryHeading, List<DictionaryFrequency>>>(
              frequenciesByHeading.entries, 10000)
          .forEach((batch) {
        database.writeTxnSync(() {
          for (MapEntry<DictionaryHeading,
              List<DictionaryFrequency>> frequenciesForHeading in batch) {
            DictionaryHeading heading = frequenciesForHeading.key;
            List<DictionaryFrequency> frequencies = frequenciesForHeading.value;

            database.dictionaryHeadings.putSync(heading);
            database.dictionaryFrequencys.putAllSync(frequencies);

            frequencyCount += frequencies.length;
          }
        });

        params.send(t.import_write_frequency(
            count: frequencyCount, total: frequencyTotal));
      });

      /// Used to test the collision resistance of the FNV-1a algorithm used
      /// for hashing dictionary headings to each have unique integer IDs.
      /// This doesn't seem that heavy but we shouldn't instantiate millions
      /// of elements at any given time, so this should be commented out for
      /// a production release or when not debugging for collisions.
      ///
      /// For testing, a mix of Japanese bilingual and monolingual dictionaries
      /// can be imported in sequence. The collision count should always be
      /// zero. Interestingly, the Dart implementation of FNV-1a recommended by
      /// Isar seems to produce less collisions than a MurmurHash V3
      /// implementation. In any case, the code below can be uncommented for
      /// and hash algorithm comparison testing and research.
      ///
      /// The idea is to get the delta number of headings, but also take into
      /// account the number of headings already in the database.

      // int headingsInDatabase = database.dictionaryHeadings.countSync();
      // int headingsToImportAlreadyInDatabase = database.dictionaryHeadings
      //     .getAllSync(entriesByHeading.keys.map((e) => e.id).toList())
      //     .whereNotNull()
      //     .length;
      // int headingsToImportNotInDatabase =
      //     entriesByHeading.keys.length - headingsToImportAlreadyInDatabase;

      // debugPrint('Headings In Database: $headingsInDatabase');
      // debugPrint(
      //     'Headings To Import Already In Database: $headingsToImportAlreadyInDatabase');
      // debugPrint(
      //     'Headings To Import Not In Database: $headingsToImportNotInDatabase');

      /// Write [DictionaryEntry] entities.
      int entryCount = 0;
      int entryTotal = entriesByHeading.values.map((e) => e.length).sum;
      partition<MapEntry<DictionaryHeading, List<DictionaryEntry>>>(
              entriesByHeading.entries, 10000)
          .forEach((batch) {
        database.writeTxnSync(() {
          for (MapEntry<DictionaryHeading,
              List<DictionaryEntry>> entriesForHeading in batch) {
            DictionaryHeading heading = entriesForHeading.key;
            List<DictionaryEntry> entries = entriesForHeading.value;

            database.dictionaryHeadings.putSync(heading);
            database.dictionaryEntrys.putAllSync(entries);

            entryCount += entries.length;
          }
        });

        params.send(t.import_write_entry(count: entryCount, total: entryTotal));
      });

      /// Collision count should always be zero.

      // int newHeadingsInDatabase = database.dictionaryHeadings.countSync();
      // int collisionsFound = newHeadingsInDatabase -
      //     headingsInDatabase -
      //     headingsToImportNotInDatabase;
      // debugPrint('New Headings In Database: $newHeadingsInDatabase');
      // debugPrint('Collisions Found: $collisionsFound');
    } else {
      /// Write as one transaction. If anything fails, no changes should occur.
      database.writeTxnSync(() {
        /// Write the [Dictionary] entity.
        database.dictionarys.putSync(params.dictionary);

        /// Write [DictionaryTag] entities.
        int tagCount = 0;
        int tagTotal = tags.length;
        database.dictionaryTags.putAllSync(tags);
        partition<DictionaryTag>(tags, 10000).forEach((batch) {
          database.dictionaryTags.putAllSync(batch);
          tagCount += batch.length;
          params.send(t.import_write_tag(count: tagCount, total: tagTotal));
        });

        /// Write [DictionaryPitch] entities.
        int pitchCount = 0;
        int pitchTotal = pitchesByHeading.values.map((e) => e.length).sum;
        partition<MapEntry<DictionaryHeading, List<DictionaryPitch>>>(
                pitchesByHeading.entries, 10000)
            .forEach((batch) {
          for (MapEntry<DictionaryHeading,
              List<DictionaryPitch>> pitchesForHeading in batch) {
            DictionaryHeading heading = pitchesForHeading.key;
            List<DictionaryPitch> pitches = pitchesForHeading.value;

            database.dictionaryHeadings.putSync(heading);
            database.dictionaryPitchs.putAllSync(pitches);
            pitchCount += pitches.length;
          }

          params
              .send(t.import_write_pitch(count: pitchCount, total: pitchTotal));
        });

        /// Write [DictionaryFrequency] entities.
        int frequencyCount = 0;
        int frequencyTotal =
            frequenciesByHeading.values.map((e) => e.length).sum;
        partition<MapEntry<DictionaryHeading, List<DictionaryFrequency>>>(
                frequenciesByHeading.entries, 10000)
            .forEach((batch) {
          for (MapEntry<DictionaryHeading,
              List<DictionaryFrequency>> frequenciesForHeading in batch) {
            DictionaryHeading heading = frequenciesForHeading.key;
            List<DictionaryFrequency> frequencies = frequenciesForHeading.value;

            database.dictionaryHeadings.putSync(heading);
            database.dictionaryFrequencys.putAllSync(frequencies);
            frequencyCount += frequencies.length;
          }

          params.send(t.import_write_frequency(
              count: frequencyCount, total: frequencyTotal));
        });

        /// Used to test the collision resistance of the FNV-1a algorithm used
        /// for hashing dictionary headings to each have unique integer IDs.
        /// This doesn't seem that heavy but we shouldn't instantiate millions
        /// of elements at any given time, so this should be commented out for
        /// a production release or when not debugging for collisions.
        ///
        /// For testing, a mix of Japanese bilingual and monolingual dictionaries
        /// can be imported in sequence. The collision count should always be
        /// zero. Interestingly, the Dart implementation of FNV-1a recommended by
        /// Isar seems to produce less collisions than a MurmurHash V3
        /// implementation. In any case, the code below can be uncommented for
        /// and hash algorithm comparison testing and research.
        ///
        /// The idea is to get the delta number of headings, but also take into
        /// account the number of headings already in the database.
        // int headingsInDatabase = database.dictionaryHeadings.countSync();
        // int headingsToImportAlreadyInDatabase = database.dictionaryHeadings
        //     .getAllSync(entriesByHeading.keys.map((e) => e.id).toList())
        //     .whereNotNull()
        //     .length;
        // int headingsToImportNotInDatabase =
        //     entriesByHeading.keys.length - headingsToImportAlreadyInDatabase;

        // debugPrint('Headings In Database: $headingsInDatabase');
        // debugPrint(
        //     'Headings To Import Already In Database: $headingsToImportAlreadyInDatabase');
        // debugPrint(
        //     'Headings To Import Not In Database: $headingsToImportNotInDatabase');

        /// Write [DictionaryEntry] entities.
        int entryCount = 0;
        int entryTotal = entriesByHeading.values.map((e) => e.length).sum;
        partition<MapEntry<DictionaryHeading, List<DictionaryEntry>>>(
                entriesByHeading.entries, 10000)
            .forEach((batch) {
          for (MapEntry<DictionaryHeading,
              List<DictionaryEntry>> entriesForHeading in batch) {
            DictionaryHeading heading = entriesForHeading.key;
            List<DictionaryEntry> entries = entriesForHeading.value;

            database.dictionaryHeadings.putSync(heading);
            database.dictionaryEntrys.putAllSync(entries);
            entryCount += entries.length;
          }

          params
              .send(t.import_write_entry(count: entryCount, total: entryTotal));
        });

        /// Collision count should always be zero.
        // int newHeadingsInDatabase = database.dictionaryHeadings.countSync();
        // int collisionsFound = newHeadingsInDatabase -
        //     headingsInDatabase -
        //     headingsToImportNotInDatabase;
        // debugPrint('New Headings In Database: $newHeadingsInDatabase');
        // debugPrint('Collisions Found: $collisionsFound');
      });
    }
  } catch (e, stack) {
    debugPrint('$e');
    debugPrint('$stack');

    params.send('$e');

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

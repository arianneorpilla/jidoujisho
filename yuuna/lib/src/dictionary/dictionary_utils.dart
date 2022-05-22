import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Performed in another isolate with compute. This is a top-level utility
/// function that makes use of Isar allowing instances to be opened through
/// multiple isolates. The function for preparing entries and tags according to
/// the [DictionaryFormat] is also done in the same isolate, to remove having
/// to communicate potentially hundreds of thousands of entries to another
/// newly opened isolate.
Future<void> depositDictionaryEntriesAndTags(
    PrepareDictionaryParams params) async {
  List<DictionaryTag> dictionaryTags =
      await params.dictionaryFormat.prepareTags(params);
  List<DictionaryEntry> dictionaryEntries =
      await params.dictionaryFormat.prepareEntries(params);

  final Isar database = await Isar.open(
    directory: params.isarDirectoryPath,
    schemas: globalSchemas,
  );

  database.writeTxnSync((database) {
    database.dictionaryTags
        .filter()
        .dictionaryNameEqualTo(params.dictionaryName)
        .deleteAllSync();
    database.dictionaryEntrys
        .filter()
        .dictionaryNameEqualTo(params.dictionaryName)
        .deleteAllSync();

    database.dictionaryTags.putAllSync(dictionaryTags);
    database.dictionaryEntrys.putAllSync(dictionaryEntries);
  });
}

/// Delete a selected dictionary from the dictionary database.
Future<void> deleteDictionaryData(DeleteDictionaryParams params) async {
  final Isar database = await Isar.open(
    directory: params.isarDirectoryPath,
    schemas: globalSchemas,
  );

  database.writeTxnSync((database) {
    database.dictionarys.deleteByDictionaryNameSync(params.dictionaryName);
    database.dictionaryTags
        .filter()
        .dictionaryNameEqualTo(params.dictionaryName)
        .deleteAllSync();
    database.dictionaryEntrys
        .filter()
        .dictionaryNameEqualTo(params.dictionaryName)
        .deleteAllSync();
    database.dictionaryResults.clearSync();
  });
}

/// For isolate communication purposes. See a dictionary format's directory
/// preparation method.
class PrepareDirectoryParams {
  /// Prepare parameters for a dictionary format's directory preparation method.
  PrepareDirectoryParams({
    required this.file,
    required this.workingDirectory,
    required this.sendPort,
    required this.localisation,
  });

  /// A file from which the contents must be put in working directory. This
  /// should be non-null for dictionary formats that do not require a file for
  /// import.
  final File? file;

  /// A working directory to be used in isolation and where data is to be
  /// handled in later steps.
  final Directory workingDirectory;

  /// For communication with a [ReceivePort] for isolate updates.
  final SendPort sendPort;

  /// Used to send localised message count updates from a separate isolate.
  final DictionaryImportLocalisation localisation;
}

/// For isolate communication purposes. See a dictionary format's name, entries
/// and metadata preparation methods. Some parameters may be null at certain
/// stages of the import.
class PrepareDictionaryParams {
  /// Prepare parameters for a dictionary format's name, entries and metadata
  /// preparation methods.
  PrepareDictionaryParams({
    required this.dictionaryName,
    required this.dictionaryFormat,
    required this.workingDirectory,
    required this.sendPort,
    required this.isarDirectoryPath,
    required this.localisation,
  });

  /// The dictionary name obtained in the previous stage, used to indicate
  /// that entries are from a certain dictionary.
  final String dictionaryName;

  /// The dictionary format to be used for entry processing.
  final DictionaryFormat dictionaryFormat;

  /// A working directory from which to extract dictionary data from.
  final Directory workingDirectory;

  /// For communication with the [ReceivePort] for isolate updates.
  final SendPort sendPort;

  /// Used to pass the path to the database to open from the other isolate.
  final String isarDirectoryPath;

  /// Used to send localised message count updates from a separate isolate.
  final DictionaryImportLocalisation localisation;
}

/// For isolate communication purposes. Used for dictionary deletion.
class DeleteDictionaryParams {
  /// Prepare parameters needed for deleting a dictionary from a separate
  /// isolate.
  DeleteDictionaryParams({
    required this.dictionaryName,
    required this.isarDirectoryPath,
  });

  /// The dictionary name obtained in the previous stage, used to indicate
  /// that entries are from a certain dictionary.
  final String dictionaryName;

  /// Used to pass the path to the database to open from the other isolate.
  final String isarDirectoryPath;
}

/// For isolate communication purposes. Used for dictionary search.
class DictionarySearchParams {
  /// Prepare parameters needed for searching the dictioanry database from a
  /// separate isolate.
  DictionarySearchParams({
    required this.searchTerm,
    required this.fallbackTerm,
    required this.isarDirectoryPath,
  });

  /// Primary search term, likely taken from context.
  final String searchTerm;

  /// Fallback search term, likely sanitised with deinflection.
  final String fallbackTerm;

  /// Used to pass the path to the database to open from the other isolate.
  final String isarDirectoryPath;
}

/// Bundles relevant localisation information for use in dictionary imports.
class DictionaryImportLocalisation {
  /// Manually define messages for localisation.
  const DictionaryImportLocalisation({
    required this.importMessageStart,
    required this.importMessageClean,
    required this.importMessageExtraction,
    required this.importMessageName,
    required this.importMessageEntries,
    required this.importMessageEntryCount,
    required this.importMessageTagCount,
    required this.importMessageMetadata,
    required this.importMessageDatabase,
    required this.importMessageError,
    required this.importMessageFailed,
    required this.importMessageComplete,
  });

  /// Return an entry count update message with a proper variable.
  String importMessageEntryCountWithVar(int count) {
    return importMessageEntryCount.replaceAll('%count%', '$count');
  }

  /// Return an entry count update message with a proper variable.
  String importMessageTagCountWithVar(int count) {
    return importMessageTagCount.replaceAll('%count%', '$count');
  }

  /// Return a message informing the dictionary name with a proper variable.
  String importMessageNameWithVar(String name) {
    return importMessageName.replaceAll('%name%', name);
  }

  /// Return an error message with a proper variable.
  String importMessageErrorWithVar(String error) {
    return importMessageError.replaceAll('%error%', error);
  }

  /// For message to show when initialising dictionary import.
  final String importMessageStart;

  /// For message to show when cleaning up the working directory.
  final String importMessageClean;

  /// For message to show when preparing the working directory.
  final String importMessageExtraction;

  /// For message to show when the dictionary name has been obtained.
  final String importMessageName;

  /// For message to show when current progress is processing entries.
  final String importMessageEntries;

  /// For message to show when updating entry count while processing entries.
  final String importMessageEntryCount;

  /// For message to show when updating tag count while processing tags.
  final String importMessageTagCount;

  /// For message to show when current progress is processing metadata.
  final String importMessageMetadata;

  /// For message to show when current progress is entry import to database.
  final String importMessageDatabase;

  /// For error reporting of dictionary import.
  final String importMessageError;

  /// For marking failure of dictionary import.
  final String importMessageFailed;

  /// For marking completion of dictionary import.
  final String importMessageComplete;
}

/// A general purpose class for dictionary operations that do not require to be
/// at the top-level.
class DictionaryUtils {
  /// Get a single combined text for all meanings in a list of entries.
  static String flattenMeanings(List<DictionaryEntry> entries) {
    StringBuffer meaningBuffer = StringBuffer();

    Map<String, List<DictionaryEntry>> entriesByDictionaryName =
        groupBy<DictionaryEntry, String>(
      entries,
      (entry) => entry.dictionaryName,
    );

    entriesByDictionaryName.forEach((dictionaryName, singleDictionaryEntries) {
      int meaningsCount = 0;
      for (DictionaryEntry entry in singleDictionaryEntries) {
        meaningsCount += entry.meanings.length;
      }

      for (DictionaryEntry entry in singleDictionaryEntries) {
        if (singleDictionaryEntries.length == 1) {
          entry.meanings.forEachIndexed((index, meaning) {
            if (meaningsCount != 1) {
              meaningBuffer.write('• $meaning');
            } else {
              meaningBuffer.write(meaning);
            }

            if (index != entry.meanings.length - 1) {
              meaningBuffer.write('\n');
            }
          });
        } else {
          entry.meanings.forEachIndexed((index, meaning) {
            if (meaningsCount == 1) {
              meaningBuffer.write('$meaning\n');
            } else {
              if (index == 0) {
                meaningBuffer.write('• ');
              }
              meaningBuffer.write(meaning);
              if (index != entry.meanings.length - 1) {
                meaningBuffer.write('; ');
              }
            }
          });
        }

        meaningBuffer.write('\n');
      }

      meaningBuffer.write('\n');
    });

    return meaningBuffer.toString().trim();
  }
}

import 'dart:io';
import 'dart:isolate';

import 'package:isar/isar.dart';
import 'package:quiver/iterables.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Performed in another isolate with compute. This is a top-level utility
/// function that makes use of Isar allowing instances to be opened through
/// multiple isolates. The function for preparing entries and tags according to
/// the [DictionaryFormat] is also done in the same isolate, to remove having
/// to communicate potentially hundreds of thousands of entries to another
/// newly opened isolate.
Future<void> depositDictionaryDataHelper(PrepareDictionaryParams params) async {
  List<DictionaryTag> dictionaryTags =
      await params.dictionaryFormat.prepareTags(params);
  List<DictionaryMetaEntry> dictionaryMetaEntries =
      await params.dictionaryFormat.prepareMetaEntries(params);
  List<DictionaryEntry> dictionaryEntries =
      await params.dictionaryFormat.prepareEntries(params);

  final Isar database = await Isar.open(
    globalSchemas,
    maxSizeMiB: 4096,
  );

  database.writeTxnSync(() {
    database.dictionaryTags
        .where()
        .dictionaryNameEqualTo(params.dictionaryName)
        .deleteAllSync();
    database.dictionaryMetaEntrys
        .where()
        .dictionaryNameEqualTo(params.dictionaryName)
        .deleteAllSync();
    database.dictionaryEntrys
        .where()
        .dictionaryNameEqualTo(params.dictionaryName)
        .deleteAllSync();
  });

  if (params.useSlowImport) {
    int tagCount = 0;
    partition(dictionaryTags, 1000).forEach((e) {
      database.writeTxnSync(() {
        database.dictionaryTags.putAllSync(e);
      });

      tagCount += e.length;
      String message = params.localisation
          .importMessageTagImportCountWithVar(tagCount, dictionaryTags.length);
      params.sendPort.send(message);
    });

    int metaEntriesCount = 0;
    partition(dictionaryMetaEntries, 1000).forEach((e) {
      database.writeTxnSync(() {
        database.dictionaryMetaEntrys.putAllSync(e);
      });

      metaEntriesCount += e.length;
      String message = params.localisation
          .importMessageMetaEntryImportCountWithVar(
              metaEntriesCount, dictionaryMetaEntries.length);
      params.sendPort.send(message);
    });

    int entriesCount = 0;
    partition(dictionaryEntries, 1000).forEach((e) {
      database.writeTxnSync(() {
        database.dictionaryEntrys.putAllSync(e);
      });

      entriesCount += e.length;
      String message = params.localisation.importMessageEntryImportCountWithVar(
          entriesCount, dictionaryEntries.length);
      params.sendPort.send(message);
    });
  } else {
    database.writeTxnSync(() {
      int tagCount = 0;
      partition(dictionaryTags, 1000).forEach((e) {
        database.dictionaryTags.putAllSync(e);

        tagCount += e.length;
        String message = params.localisation.importMessageTagImportCountWithVar(
            tagCount, dictionaryTags.length);
        params.sendPort.send(message);
      });

      int metaEntriesCount = 0;
      partition(dictionaryMetaEntries, 1000).forEach((e) {
        database.dictionaryMetaEntrys.putAllSync(e);

        metaEntriesCount += e.length;
        String message = params.localisation
            .importMessageMetaEntryImportCountWithVar(
                metaEntriesCount, dictionaryMetaEntries.length);
        params.sendPort.send(message);
      });

      int entriesCount = 0;
      partition(dictionaryEntries, 1000).forEach((e) {
        database.dictionaryEntrys.putAllSync(e);

        entriesCount += e.length;
        String message = params.localisation
            .importMessageEntryImportCountWithVar(
                entriesCount, dictionaryEntries.length);
        params.sendPort.send(message);
      });
    });
  }
}

/// Delete a selected dictionary from the dictionary database.
Future<void> deleteDictionaryDataHelper(DeleteDictionaryParams params) async {
  final Isar database = await Isar.open(
    globalSchemas,
    maxSizeMiB: 4096,
  );

  database.writeTxnSync(() {
    database.dictionarys.deleteByDictionaryNameSync(params.dictionaryName);
    database.dictionaryTags
        .where()
        .dictionaryNameEqualTo(params.dictionaryName)
        .deleteAllSync();
    database.dictionaryMetaEntrys
        .where()
        .dictionaryNameEqualTo(params.dictionaryName)
        .deleteAllSync();
    database.dictionaryEntrys
        .where()
        .dictionaryNameEqualTo(params.dictionaryName)
        .deleteAllSync();

    database.dictionaryResults.clearSync();
  });
}

/// Add a [DictionaryResult] to the dictionary history. If the maximum value
/// is exceed, the dictionary history is cut down to the newest values.

Future<void> addToDictionaryHistoryHelper(
  UpdateDictionaryHistoryParams params,
) async {
  final Isar database = await Isar.open(
    globalSchemas,
    maxSizeMiB: 4096,
  );

  database.writeTxnSync(() {
    database.dictionaryResults.deleteBySearchTermSync(params.result.searchTerm);
    database.dictionaryResults.putSync(params.result);

    int countInSameHistory = database.dictionaryResults.countSync();

    if (params.maximumDictionaryHistoryItems < countInSameHistory) {
      int surplus = countInSameHistory - params.maximumDictionaryHistoryItems;
      database.dictionaryResults.where().limit(surplus).build().deleteAllSync();
    }
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
    required this.useSlowImport,
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

  /// Whether or not to use slow import to prevent crashing.
  final bool useSlowImport;
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

/// For isolate communication purposes. Used for dictionary deletion.
class UpdateDictionaryHistoryParams {
  /// Prepare parameters needed to update dictionary history.
  UpdateDictionaryHistoryParams({
    required this.result,
    required this.maximumDictionaryHistoryItems,
    required this.isarDirectoryPath,
  });

  /// The result of a dictionary search to be added to history.
  final DictionaryResult result;

  /// Maximum number of history items.
  final int maximumDictionaryHistoryItems;

  /// Used to pass the path to the database to open from the other isolate.
  final String isarDirectoryPath;
}

/// For isolate communication purposes. Used for dictionary search.
class DictionarySearchParams {
  /// Prepare parameters needed for searching the dictioanry database from a
  /// separate isolate.
  DictionarySearchParams({
    required this.searchTerm,
    required this.maximumDictionaryEntrySearchMatch,
    required this.maximumDictionaryTermsInResult,
    required this.fallbackTerm,
    required this.isarDirectoryPath,
  });

  /// Primary search term, likely taken from context.
  final String searchTerm;

  /// Fallback search term, likely sanitised with deinflection.
  final String fallbackTerm;

  /// Used to pass the path to the database to open from the other isolate.
  final String isarDirectoryPath;

  /// Maximum number of dictionary entries that can be returned from a database
  /// dictionary search.
  final int maximumDictionaryEntrySearchMatch;

  /// Maximum number of headwords in a returned dictionary result for
  /// performance purposes.
  final int maximumDictionaryTermsInResult;
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
    required this.importMessageMetaEntryCount,
    required this.importMessageTagCount,
    required this.importMessageEntryImportCount,
    required this.importMessageMetaEntryImportCount,
    required this.importMessageTagImportCount,
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

  /// Return an entry count update message with a proper variable.
  String importMessageMetaEntryCountWithVar(int count) {
    return importMessageMetaEntryCount.replaceAll('%count%', '$count');
  }

  /// Return an entry count update message with a proper variable.
  String importMessageEntryImportCountWithVar(int count, int total) {
    return importMessageEntryImportCount
        .replaceAll('%count%', '$count')
        .replaceAll('%total%', '$total');
  }

  /// Return an entry count update message with a proper variable.
  String importMessageTagImportCountWithVar(int count, int total) {
    return importMessageTagImportCount
        .replaceAll('%count%', '$count')
        .replaceAll('%total%', '$total');
  }

  /// Return an entry count update message with a proper variable.
  String importMessageMetaEntryImportCountWithVar(int count, int total) {
    return importMessageMetaEntryImportCount
        .replaceAll('%count%', '$count')
        .replaceAll('%total%', '$total');
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

  /// For message to show when updating entry count while processing meta
  /// entries.
  final String importMessageMetaEntryCount;

  /// For message to show when updating tag count while processing tags.
  final String importMessageTagCount;

  /// For message to show when updating entry count while importing entries.
  final String importMessageEntryImportCount;

  /// For message to show when updating entry count while importing meta
  /// entries.
  final String importMessageMetaEntryImportCount;

  /// For message to show when updating tag count while importing tags.
  final String importMessageTagImportCount;

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

import 'dart:io';
import 'dart:isolate';

import 'package:isar/isar.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/media.dart';

/// Performed in another isolate with compute. This is a top-level utility
/// function that makes use of Isar allowing instances to be opened through
/// multiple isolates. The function for preparing entries according to the
/// [DictionaryFormat] is also done in the same isolate, to remove having to
/// communicate potentially hundreds of thousands of entries to another newly
/// opened isolate.
Future<void> depositDictionaryEntries(PrepareDictionaryParams params) async {
  List<DictionaryEntry> dictionaryEntries =
      await params.dictionaryFormat.prepareEntries(params);

  final Isar database = await Isar.open(
    directory: params.isarDirectoryPath,
    schemas: [
      DictionarySchema,
      DictionaryEntrySchema,
      MediaItemSchema,
      CreatorContextSchema,
    ],
  );

  database.writeTxnSync((database) {
    database.dictionaryEntrys
        .filter()
        .dictionaryNameEqualTo(params.dictionaryName)
        .deleteAllSync();
    database.dictionaryEntrys.putAllSync(dictionaryEntries);
  });
}

/// Delete a selected dictionary from the dictionary database.
Future<void> deleteDictionaryData(DeleteDictionaryParams params) async {
  final Isar database = await Isar.open(
    directory: params.isarDirectoryPath,
    schemas: [
      DictionarySchema,
      DictionaryEntrySchema,
      MediaItemSchema,
      CreatorContextSchema,
    ],
  );

  database.writeTxnSync((database) {
    database.dictionarys.deleteByDictionaryNameSync(params.dictionaryName);
    database.dictionaryEntrys
        .filter()
        .dictionaryNameEqualTo(params.dictionaryName)
        .deleteAllSync();
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

/// Bundles relevant localisation information for use in dictionary imports.
class DictionaryImportLocalisation {
  /// Manually define messages for localisation.
  const DictionaryImportLocalisation({
    required this.importMessageStart,
    required this.importMessageClean,
    required this.importMessageExtraction,
    required this.importMessageName,
    required this.importMessageEntries,
    required this.importMessageCount,
    required this.importMessageMetadata,
    required this.importMessageDatabase,
    required this.importMessageError,
    required this.importMessageFailed,
    required this.importMessageComplete,
  });

  /// Return an entry count update message with a proper variable.
  String importMessageCountWithVar(int count) {
    return importMessageCount.replaceAll('%count%', '$count');
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
  final String importMessageCount;

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

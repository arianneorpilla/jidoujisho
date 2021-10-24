import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/dictionary_media_type.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/objectbox.g.dart';

Future<void> dictionaryFileImport(
  BuildContext context,
  AppModel appModel,
  DictionaryFormat dictionaryFormat,
) async {
  /// A [ValueNotifier] that will update a message based on the progress of the
  /// on-going dictionary file import.
  ValueNotifier<String> progressNotifier = ValueNotifier<String>("");

  /// Importing makes heavy use of isolates as it is very performance intensive
  /// to work with files. In order to ensure the UI isolate isn't blocked, a
  /// [ReceivePort] is necessary to receive UI updates.
  ReceivePort receivePort = ReceivePort();
  receivePort.listen((data) {
    if (data is String) {
      progressNotifier.value = data;
    }
  });

  MediaType mediaType = DictionaryMediaType();

  Iterable<String>? filePaths = await FilesystemPicker.open(
    title: appModel.translate("player_pick_video"),
    pickText: appModel.translate("dialog_select"),
    cancelText: appModel.translate("dialog_return"),
    context: context,
    rootDirectories: await appModel.getMediaTypeDirectories(mediaType),
    fsType: FilesystemType.file,
    folderIconColor: Colors.red,
  );

  if (filePaths == null || filePaths.isEmpty) {
    return;
  }

  String filePath = filePaths.first;

  appModel.setLastPickedDirectory(mediaType, Directory(p.dirname(filePath)));

  /// This file will be passed to a [DictionaryFormat]'s
  /// [prepareWorkingDirectory] method. Direct interaction with the file is
  /// discouraged and functions pertaining to getting the actual dictionary
  /// data is distanced from this file.
  File file = File(filePath);

  /// If any [Exception] occurs, the process is aborted with a message as
  /// shown below. A dialog is shown to show the progress of the dictionary
  /// file import, with messages pertaining to the above [ValueNotifier].
  try {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return showProgressDialog(context, progressNotifier);
      },
    );

    /// Foremostly, the process should not begin if a file does not match the
    /// correct [Uri] to start with.
    if (!dictionaryFormat.isUriSupported(file.uri)) {
      throw Exception("Dictionary file does not match format Uri.");
    }

    /// Import process starts here.
    importMessageStart(progressNotifier);
    await Future.delayed(const Duration(milliseconds: 500), () {});

    /// Firstly, the import working area must be prepared.
    String appDirDocPath = (await getApplicationSupportDirectory()).path;
    Directory workingDirectory =
        Directory(p.join(appDirDocPath, 'workingDirectory'));

    /// If the working area exists, clean it up.
    if (workingDirectory.existsSync()) {
      importMessageClean(progressNotifier);
      await Future.delayed(const Duration(milliseconds: 500), () {});
      workingDirectory.deleteSync(recursive: true);
    }

    /// Many formats require ZIP extraction, while others have their own
    /// particular cases.
    ///
    /// The purpose of this function is to make it such that it can be
    /// assumed that the remaining operations after this can be performed
    /// from the working directory, and allow different formats to gracefully
    /// follow the remaining generic steps.
    importMessageExtraction(progressNotifier);
    ImportPreparationParams importPreparationParams = ImportPreparationParams(
      file: file,
      workingDirectory: workingDirectory,
      sendPort: receivePort.sendPort,
    );

    await dictionaryFormat.prepareWorkingDirectory(importPreparationParams);

    /// It is now assumed that the rest of the operations can be performed
    /// from the working area. A dictionary name is required for import, and
    /// all dictionaries in the database must have a unique name. Hence,
    /// through the [workingDirectory], a [String] name must be obtainable,
    /// and generically handled by all formats.
    ///
    /// If a format does not keep the name of a dictionary as metadata, it
    /// should provide a sufficiently unique and considerate name with no
    /// collision with other existing dictionaries and other dictionary
    /// formats.
    ImportDirectoryParams importDirectoryParams = ImportDirectoryParams(
      workingDirectory: workingDirectory,
      sendPort: receivePort.sendPort,
    );
    String dictionaryName = await compute(
      dictionaryFormat.getDictionaryName,
      importDirectoryParams,
    );
    importMessageName(progressNotifier, dictionaryName);

    /// If the dictionary name collides with an existing dictionary, the
    /// process is halted.
    if (appModel.getImportedDictionaryNames().contains(dictionaryName)) {
      throw Exception("Name collision with existing dictionary");
    }

    /// Initialise an ObjectBox [Store], where the new database will be
    /// used from. Stores of existing dictionaries are initialised on startup.
    Store store = await appModel.initialiseDictionaryStore(dictionaryName);

    /// From the working directory, the format is mainly responsible for
    /// parsing its entries. [extractAndDepositEntries] handles two main
    /// performance-intensive operations. Firstly, the format-defined entry
    /// extraction function [getDictionaryEntries]. Then, it adds these to an
    /// ObjectBox database -- ensuring other developers don't have to learn
    /// ObjectBox to implement their own formats is vital.
    ///
    /// It is necessary to perform the database deposit in another isolate itself
    /// as receiving the entries and then pushing these arguments to another
    /// isolate will cause a lot of jank. Therefore, one isolate is necessary
    /// for these two operations.
    importMessageEntries(progressNotifier);
    ImportEntriesParams importEntriesParams = ImportEntriesParams(
      dictionaryFormat: dictionaryFormat,
      importDirectoryParams: importDirectoryParams,
      sendPort: receivePort.sendPort,
      dictionaryName: dictionaryName,
      storeReference: store.reference,
    );
    await compute(extractAndDepositEntries, importEntriesParams);

    /// Finally, any necessary metadata that is pertaining to the dictionary
    /// format that will come in handy when in actual use (i.e. interacting
    /// with the database or during searches) should be provided in this step.
    importMessageMetadata(progressNotifier);
    Map<String, String> dictionaryMetadata = await compute(
      dictionaryFormat.getDictionaryMetadata,
      importDirectoryParams,
    );

    Dictionary dictionary = Dictionary(
      dictionaryName: dictionaryName,
      formatName: dictionaryFormat.formatName,
      metadata: dictionaryMetadata,
    );
    appModel.availableDictionaries[dictionaryName] = dictionary;

    /// If the working area exists, clean it up.
    if (workingDirectory.existsSync()) {
      importMessageClean(progressNotifier);
      await Future.delayed(const Duration(milliseconds: 500), () {});
      workingDirectory.deleteSync(recursive: true);
    }

    importMessageComplete(progressNotifier);
    await Future.delayed(const Duration(seconds: 1), () {});

    await appModel.addDictionaryRecord(
      Dictionary(
        dictionaryName: dictionaryName,
        formatName: dictionaryFormat.formatName,
        metadata: dictionaryMetadata,
      ),
    );
    await appModel.setCurrentDictionaryName(dictionaryName);
  } catch (e) {
    importMessageError(progressNotifier, e.toString());
    await Future.delayed(const Duration(seconds: 3), () {});
    importMessageFailed(progressNotifier);
    await Future.delayed(const Duration(seconds: 1), () {});

    throw Exception(e);
  } finally {
    Navigator.pop(context);
  }
}

/// Performed in another isolate with [compute]. Adds given [DictionaryEntry]
/// items to an [ObjectBox] database pertaining to a given dictionary name.
/// See [ImportEntriesParams] for information on how to work with the given
/// parameters.
Future<void> extractAndDepositEntries(ImportEntriesParams params) async {
  List<DictionaryEntry> dictionaryEntries = await params.dictionaryFormat
      .getDictionaryEntries(params.importDirectoryParams);

  params.sendPort.send("Adding entries to database...");
  Store entryStore = Store.fromReference(
    getObjectBoxModel(),
    params.storeReference,
  );

  Box entryBox = entryStore.box<DictionaryEntry>();
  entryBox.putMany(dictionaryEntries);
}

Widget showProgressDialog(
    BuildContext context, ValueNotifier<String> progressNotifier) {
  AppModel appModel = Provider.of<AppModel>(context);

  return AlertDialog(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),
    contentPadding:
        const EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
    content: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0.7),
                child: Text(
                  appModel.translate("import_in_progress"),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ValueListenableBuilder(
                valueListenable: progressNotifier,
                builder: (context, progressNotification, _) {
                  return Text(
                    progressNotifier.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// For working area step isolate. See [prepareWorkingDirectory].
class ImportPreparationParams {
  ImportPreparationParams({
    /// A file from which the contents must be put in working directory.
    required this.file,

    /// A working directory to be used in isolation and where data is to be
    /// handled in later steps.
    required this.workingDirectory,

    /// For communication with the [ReceivePort] for isolate updates.
    required this.sendPort,
  });

  final File file;
  final Directory workingDirectory;
  final SendPort sendPort;
}

/// For working area step isolate. See [getDictionaryName] and
/// [extractDictionaryEntries].
class ImportDirectoryParams {
  ImportDirectoryParams({
    /// A working directory from which to extract dictionary data from.
    /// Prepared in [prepareWorkingDirectory].
    required this.workingDirectory,

    /// For communication with the [ReceivePort] for isolate updates.
    required this.sendPort,
  });

  final Directory workingDirectory;
  final SendPort sendPort;
}

/// For working area step isolate. See [getDictionaryName] and
/// [extractDictionaryEntries].
class ImportEntriesParams {
  ImportEntriesParams({
    /// The [ImportDirectoryParams] that the format uses for
    /// [getDictionaryEntries].
    required this.importDirectoryParams,

    /// The dictionary format in order to determine which top-level
    /// [getDictionaryEntries] to run.
    required this.dictionaryFormat,

    /// Dictionary name is necessary for identifying which database to use.
    required this.dictionaryName,

    /// For communication with the [ReceivePort] for isolate updates.
    required this.sendPort,

    /// Used to transfer an ObjectBox [StoreReference] across isolates.
    required this.storeReference,
  });

  final ImportDirectoryParams importDirectoryParams;
  final DictionaryFormat dictionaryFormat;
  final String dictionaryName;
  final SendPort sendPort;
  final ByteData storeReference;
}

/// For database interaction. See [depositEntriesToDatabase].
class ResultsProcessingParams {
  ResultsProcessingParams({
    /// Dictionary search results.
    required this.result,

    /// Dictionary metadata obtained from import.
    required this.metadata,

    /// For communication with the [ReceivePort] for isolate updates.
    required this.sendPort,

    /// For widget creation.
    this.context,
  });

  final DictionarySearchResult result;
  final Map<String, String> metadata;
  final SendPort sendPort;
  BuildContext? context;
}

/// These duplicate functions are necessary for later localisation.
void importMessageStart(ValueNotifier<String> progressNotifier) {
  progressNotifier.value = "Importing dictionary...";
}

void importMessageClean(ValueNotifier<String> progressNotifier) {
  progressNotifier.value = "Clearing working space...";
}

void importMessageExtraction(ValueNotifier<String> progressNotifier) {
  progressNotifier.value = "Extracting files...";
}

void importMessageName(ValueNotifier<String> progressNotifier, String name) {
  progressNotifier.value = "Importing as 『$name』...";
}

void importMessageEntries(ValueNotifier<String> progressNotifier) {
  progressNotifier.value = "Processing entries...";
}

void importMessageMetadata(ValueNotifier<String> progressNotifier) {
  progressNotifier.value = "Processing metadata...";
}

void importMessageDatabase(ValueNotifier<String> progressNotifier) {
  progressNotifier.value = "Adding entries to database...";
}

void importMessageComplete(ValueNotifier<String> progressNotifier) {
  progressNotifier.value = "Dictionary import complete.";
}

void importMessageError(ValueNotifier<String> progressNotifier, String error) {
  progressNotifier.value = "Import error: $error";
}

void importMessageFailed(ValueNotifier<String> progressNotifier) {
  progressNotifier.value = "Dictionary import failed.";
}

Future<DictionarySearchResult> searchDatabase(
    ResultsProcessingParams params) async {
  DictionarySearchResult unprocessedResult = params.result;
  int searchLimit = 20;

  ByteData storeReference = unprocessedResult.storeReference!;
  Store store = Store.fromReference(getObjectBoxModel(), storeReference);
  Box box = store.box<DictionaryEntry>();

  List<String> terms = [];
  terms.add(params.result.originalSearchTerm);
  terms.addAll(params.result.fallbackSearchTerms);

  for (String term in terms) {
    QueryBuilder exactWordMatch = box.query(DictionaryEntry_.word.equals(term));
    Query exactWordQuery = exactWordMatch.build();

    Query limitedWordQuery = exactWordQuery..limit = searchLimit;
    unprocessedResult.entries
        .addAll(limitedWordQuery.find() as List<DictionaryEntry>);

    QueryBuilder exactReadingMatch =
        box.query(DictionaryEntry_.reading.equals(term));
    Query exactReadingQuery = exactReadingMatch.build();

    Query limitedReadingQuery = exactReadingQuery..limit = searchLimit;
    List<DictionaryEntry> readingMatchQueries =
        limitedReadingQuery.find() as List<DictionaryEntry>;
    unprocessedResult.entries.addAll(readingMatchQueries);

    if (unprocessedResult.entries.length >= searchLimit) {
      break;
    }
  }

  if (unprocessedResult.entries.length < searchLimit) {
    for (String term in terms) {
      QueryBuilder fallbackMixMatch = box.query(
          DictionaryEntry_.word.startsWith(term) |
              DictionaryEntry_.reading.startsWith(term))
        ..order(DictionaryEntry_.popularity, flags: Order.descending);
      Query fallbackMixQuery = fallbackMixMatch.build();

      Query fallbackLimitedQuery = fallbackMixQuery..limit = searchLimit;
      List<DictionaryEntry> likeMatches =
          fallbackLimitedQuery.find() as List<DictionaryEntry>;
      unprocessedResult.entries.addAll(likeMatches);

      if (unprocessedResult.entries.length >= searchLimit) {
        break;
      }
    }
  }

  List<DictionaryEntry> exactFirstEntries = [];
  for (DictionaryEntry entry in unprocessedResult.entries) {
    if (entry.word == unprocessedResult.originalSearchTerm) {
      if (!exactFirstEntries.contains(entry)) {
        exactFirstEntries.add(entry);
      }
    }
  }
  for (DictionaryEntry entry in unprocessedResult.entries) {
    if (entry.reading == unprocessedResult.originalSearchTerm) {
      if (!exactFirstEntries.contains(entry)) {
        exactFirstEntries.add(entry);
      }
    }
  }
  for (DictionaryEntry entry in unprocessedResult.entries) {
    if (unprocessedResult.fallbackSearchTerms.contains(entry.word) ||
        unprocessedResult.fallbackSearchTerms.contains(entry.reading)) {
      if (!exactFirstEntries.contains(entry)) {
        exactFirstEntries.add(entry);
      }
    }
  }
  for (DictionaryEntry entry in unprocessedResult.entries) {
    if (!exactFirstEntries.contains(entry)) {
      exactFirstEntries.add(entry);
    }
  }

  unprocessedResult.entries = exactFirstEntries;

  return unprocessedResult;
}

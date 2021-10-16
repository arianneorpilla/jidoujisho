import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:daijidoujisho/dictionary/dictionary.dart';
import 'package:daijidoujisho/dictionary/dictionary_entry.dart';
import 'package:daijidoujisho/dictionary/dictionary_format.dart';
import 'package:daijidoujisho/models/app_model.dart';
import 'package:daijidoujisho/objectbox.g.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<void> dictionaryFileImport(
  BuildContext context,
  AppModel appModel,
  DictionaryFormat dictionaryFormat,
) async {
  // A [ValueNotifier] that will update a message based on the progress of the
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

  /// This function is specifically for handling single [File] imports, which
  /// should suffice for most generic cases.
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.any);

  /// This file will be passed to a [DictionaryFormat]'s
  /// [prepareWorkingDirectory] method. Direct interaction with the file is
  /// discouraged and functions pertaining to getting the actual dictionary
  /// data is distanced from this file.
  File file = File(result!.files.single.path!);

  /// If any [Exception] occurs, the process is aborted with a message as
  /// shown below. A dialog is shown to show the progress of the dictionary
  /// file import, with messages pertaining to the above [ValueNotifier].
  // try {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return showProgressDialog(progressNotifier);
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
  ImportProcessingParams importProcessingParams = ImportProcessingParams(
    workingDirectory: workingDirectory,
    sendPort: receivePort.sendPort,
  );
  String dictionaryName = await compute(
    dictionaryFormat.getDictionaryName,
    importProcessingParams,
  );
  importMessageName(progressNotifier, dictionaryName);

  /// If the dictionary name collides with an existing dictionary, the
  /// process is halted.
  if (appModel.getImportedDictionaryNames().contains(dictionaryName)) {
    throw Exception("Name collision with existing dictionary");
  }

  /// From the working directory, the format is mainly responsible for
  /// parsing its entries.
  importMessageEntries(progressNotifier);
  List<DictionaryEntry> dictionaryEntries = await compute(
    dictionaryFormat.getDictionaryEntries,
    importProcessingParams,
  );

  /// Finally, any necessary metadata that is pertaining to the dictionary
  /// format that will come in handy when in actual use (i.e. interacting
  /// with the database or during searches) should be provided in this step.
  importMessageMetadata(progressNotifier);
  Map<String, String> dictionaryMetadata = await compute(
    dictionaryFormat.getDictionaryMetadata,
    importProcessingParams,
  );

  /// Initialise an ObjectBox [Store], where the new database will be
  /// used from. Stores of existing dictionaries are initialised on startup.
  Store store = await appModel.initialiseImportedDictionary(dictionaryName);

  /// Now that a name, entries and metadata are obtained, the entries can
  /// now be placed in a database.
  ///
  /// Entries are handled by [ObjectBox] with querying for search and
  /// indexing. See the schema in [DictionaryEntry]. Metadata is handled
  /// separately by [SharedPreferences] as JSON.
  importMessageDatabase(progressNotifier);
  ImportDatabaseParams importDatabaseParams = ImportDatabaseParams(
    dictionaryName: dictionaryName,
    dictionaryEntries: dictionaryEntries,
    sendPort: receivePort.sendPort,
    storeReference: store.reference,
  );
  await compute(
    depositEntriesToDatabase,
    importDatabaseParams,
  );

  /// If the working area exists, clean it up.
  if (workingDirectory.existsSync()) {
    importMessageClean(progressNotifier);
    await Future.delayed(const Duration(milliseconds: 500), () {});
    workingDirectory.deleteSync(recursive: true);
  }

  await Future.delayed(const Duration(seconds: 1), () {});
  importMessageComplete(progressNotifier);

  await appModel.addDictionaryRecord(
    Dictionary(
      dictionaryName: dictionaryName,
      formatName: dictionaryFormat.formatName,
      metadata: dictionaryMetadata,
    ),
  );
  await appModel.setCurrentDictionaryName(dictionaryName);
  // } catch (e) {
  //   importMessageError(progressNotifier, e.toString());
  //   await Future.delayed(const Duration(seconds: 3), () {});
  //   importMessageFailed(progressNotifier);
  //   await Future.delayed(const Duration(seconds: 1), () {});

  //   throw Exception(e);
  // } finally {
  Navigator.pop(context);
}

/// Performed in another isolate with [compute]. Adds given [DictionaryEntry]
/// items to an [ObjectBox] database pertaining to a given dictionary name.
/// See [ImportDatabaseParams] for information on how to work with the given
/// parameters.
Future<void> depositEntriesToDatabase(ImportDatabaseParams params) async {
  Store entryStore = Store.fromReference(
    getObjectBoxModel(),
    params.storeReference,
  );
  Box entryBox = entryStore.box<DictionaryEntry>();
  entryBox.putMany(params.dictionaryEntries);
}

Widget showProgressDialog(ValueNotifier<String> progressNotifier) {
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
            child: ValueListenableBuilder(
          valueListenable: progressNotifier,
          builder: (context, progressNotification, _) {
            return Text(
              progressNotifier.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        )),
      ],
    ),
  );
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
class ImportProcessingParams {
  ImportProcessingParams({
    /// A working directory from which to extract dictionary data from.
    /// Prepared in [prepareWorkingDirectory].
    required this.workingDirectory,

    /// For communication with the [ReceivePort] for isolate updates.
    required this.sendPort,
  });

  final Directory workingDirectory;
  final SendPort sendPort;
}

/// For database interaction. See [depositEntriesToDatabase].
class ImportDatabaseParams {
  ImportDatabaseParams({
    /// Dictionary name is necessary for identifying which database to use.
    required this.dictionaryName,

    /// Entries to be added to the database with the given dictionary name.
    required this.dictionaryEntries,

    /// For communication with the [ReceivePort] for isolate updates.
    required this.sendPort,

    /// Used to transfer an ObjectBox [StoreReference] across isolates.
    required this.storeReference,
  });

  final String dictionaryName;
  final List<DictionaryEntry> dictionaryEntries;
  final SendPort sendPort;
  final ByteData storeReference;
}

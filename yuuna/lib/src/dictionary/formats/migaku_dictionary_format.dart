import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart' as path;

import 'package:yuuna/dictionary.dart';

/// A dictionary format for the Migaku's proprietary archived JSON dictionary
/// format.
///
/// Details on the format can be found here:
/// https://www.migaku.io/tools-guides/migaku-dictionary/manual/
class MigakuDictionaryFormat extends DictionaryFormat {
  /// Define a format with the given metadata that has its behaviour for
  /// import, search and display defined with af set of top-level helper
  /// methods.
  MigakuDictionaryFormat._privateConstructor()
      : super(
          formatName: 'Migaku Dictionary',
          formatIcon: Icons.auto_stories_rounded,
          compatibleFileExtensions: const ['.zip'],
          prepareDirectory: prepareDirectoryMigakuDictionaryFormat,
          prepareName: prepareNameMigakuDictionaryFormat,
          prepareEntries: prepareEntriesMigakuDictionaryFormat,
          prepareMetaEntries: prepareMetaEntriesMigakuDictionaryFormat,
          prepareTags: prepareTagsMigakuDictionaryFormat,
          prepareMetadata: prepareMetadataMigakuDictionaryFormat,
          useAnyPicker: false,
        );

  /// Get the singleton instance of this dictionary format.
  static MigakuDictionaryFormat get instance => _instance;

  static final MigakuDictionaryFormat _instance =
      MigakuDictionaryFormat._privateConstructor();
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<void> prepareDirectoryMigakuDictionaryFormat(
    PrepareDirectoryParams params) async {
  try {
    /// Extract the user selected archive to the working directory.
    await ZipFile.extractToDirectory(
      zipFile: params.file!,
      destinationDir: params.workingDirectory,
    );
  } catch (e) {
    String message = params.localisation.importMessageErrorWithVar('$e');
    params.sendPort.send(message);
  }
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<String> prepareNameMigakuDictionaryFormat(
    PrepareDirectoryParams params) async {
  try {
    /// Get the index, which contains the name of the dictionary contained by
    /// the archive.
    File originalFile = params.file!;
    return path.basenameWithoutExtension(originalFile.path);
  } catch (e) {
    String message = params.localisation.importMessageErrorWithVar('$e');
    params.sendPort.send(message);
  }

  throw Exception('Unable to get name');
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<List<DictionaryEntry>> prepareEntriesMigakuDictionaryFormat(
    PrepareDictionaryParams params) async {
  try {
    List<DictionaryEntry> entries = [];

    final List<FileSystemEntity> entities = params.workingDirectory.listSync();
    final Iterable<File> files = entities.whereType<File>();

    for (File file in files) {
      List<dynamic> items = List.from(jsonDecode(file.readAsStringSync()));

      for (dynamic item in items) {
        Map<String, dynamic> map = Map<String, dynamic>.from(item);

        String term = map['term'] as String;
        String reading = map['pronunciation'] as String;
        String definition = map['definition'] as String;

        definition = definition
            .replaceAll('<br>', '\n')
            .replaceAll(RegExp('<[^<]+?>'), '');

        entries.add(
          DictionaryEntry(
            dictionaryName: params.dictionaryName,
            term: term,
            reading: reading,
            meanings: [definition],
          ),
        );
        if (entries.length % 1000 == 0) {
          String message = params.localisation
              .importMessageEntryCountWithVar(entries.length);
          params.sendPort.send(message);
        }
      }
    }

    return entries;
  } catch (e) {
    String message = params.localisation.importMessageErrorWithVar('$e');
    params.sendPort.send(message);
  }

  throw Exception('Unable to get entries');
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<List<DictionaryMetaEntry>> prepareMetaEntriesMigakuDictionaryFormat(
    PrepareDictionaryParams params) async {
  return [];
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<List<DictionaryTag>> prepareTagsMigakuDictionaryFormat(
    PrepareDictionaryParams params) async {
  return [];
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<Map<String, String>> prepareMetadataMigakuDictionaryFormat(
    PrepareDictionaryParams params) async {
  return {};
}

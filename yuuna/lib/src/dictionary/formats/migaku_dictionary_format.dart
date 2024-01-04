import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;

import 'package:yuuna/dictionary.dart';
import 'package:yuuna/i18n/strings.g.dart';

/// A dictionary format for archives following the ABBYY Lingvo or DSL format
/// compatible with GoldenDict.
///
/// Details on the format can be found here:
/// http://lingvo.helpmax.net/en/troubleshooting/dsl-compiler/dsl-dictionary-structure/
class MigakuFormat extends DictionaryFormat {
  /// Define a format with the given metadata that has its behaviour for
  /// import, search and display defined with af set of top-level helper methods.
  MigakuFormat._privateConstructor()
      : super(
          uniqueKey: 'migaku',
          name: 'Migaku Dictionary',
          icon: Icons.auto_stories_rounded,
          allowedExtensions: const ['zip'],
          isTextFormat: false,
          fileType: FileType.any,
          prepareDirectory: prepareDirectoryMigakuFormat,
          prepareName: prepareNameMigakuFormat,
          prepareEntries: prepareEntriesMigakuFormat,
          prepareTags: prepareTagsMigakuFormat,
          preparePitches: preparePitchesMigakuFormat,
          prepareFrequencies: prepareFrequenciesMigakuFormat,
        );

  /// Get the singleton instance of this dictionary format.
  static MigakuFormat get instance => _instance;

  static final MigakuFormat _instance = MigakuFormat._privateConstructor();
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<void> prepareDirectoryMigakuFormat(PrepareDirectoryParams params) async {
  await ZipFile.extractToDirectory(
    zipFile: params.file,
    destinationDir: params.resourceDirectory,
  );
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<String> prepareNameMigakuFormat(PrepareDirectoryParams params) async {
  File originalFile = params.file;
  return path.basenameWithoutExtension(originalFile.path);
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
void prepareEntriesMigakuFormat({
  required PrepareDictionaryParams params,
  required Isar isar,
}) async {
  final List<FileSystemEntity> entities = params.resourceDirectory.listSync();
  final Iterable<File> files = entities.whereType<File>();

  int count = 0;

  for (File file in files) {
    List<dynamic> items = List.from(jsonDecode(file.readAsStringSync()));

    for (dynamic item in items) {
      Map<String, dynamic> map = Map<String, dynamic>.from(item);

      String term = (map['term'] as String).trim();
      String definition = map['definition'] as String;
      String reading = map['pronunciation'] ?? '';

      definition = definition
          .replaceAll('<br>', '\n')
          .replaceAll(RegExp('<[^<]+?>'), '');

      int headingId = DictionaryHeading.hash(term: term, reading: reading);
      DictionaryHeading heading = isar.dictionaryHeadings.getSync(headingId) ??
          DictionaryHeading(term: term, reading: reading);

      DictionaryEntry entry = DictionaryEntry(
        definitions: [definition],
        popularity: 0,
      );

      entry.heading.value = heading;
      entry.dictionary.value = params.dictionary;
      isar.dictionaryEntrys.putSync(entry);

      heading.entries.add(entry);

      isar.dictionaryHeadings.putSync(heading);

      count++;
      params.send(t.import_found_entry(
        count: count,
      ));
    }
  }

  params.send(t.import_found_entry(count: count));
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
void prepareTagsMigakuFormat({
  required PrepareDictionaryParams params,
  required Isar isar,
}) async {}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
void preparePitchesMigakuFormat({
  required PrepareDictionaryParams params,
  required Isar isar,
}) async {}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
void prepareFrequenciesMigakuFormat({
  required PrepareDictionaryParams params,
  required Isar isar,
}) async {}

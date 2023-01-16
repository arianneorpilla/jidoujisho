import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:yuuna/dictionary.dart';

/// A dictionary format for archives following the ABBYY Lingvo or DSL format
/// compatible with GoldenDict.
///
/// Details on the format can be found here:
/// http://lingvo.helpmax.net/en/troubleshooting/dsl-compiler/dsl-dictionary-structure/
class AbbyyLingvoFormat extends DictionaryFormat {
  /// Define a format with the given metadata that has its behaviour for
  /// import, search and display defined with af set of top-level helper methods.
  AbbyyLingvoFormat._privateConstructor()
      : super(
          formatName: 'ABBYY Lingvo (DSL)',
          formatIcon: Icons.auto_stories_rounded,
          compatibleFileExtensions: const ['.dsl'],
          prepareDirectory: prepareDictionaryAbbyyLingvoFormat,
          prepareName: prepareNameAbbyyLingvoFormat,
          prepareEntries: prepareEntriesAbbyyLingvoFormat,
          prepareMetaEntries: prepareMetaEntriesAbbyyLingvoFormat,
          prepareTags: prepareTagsAbbyyLingvoFormat,
          prepareMetadata: prepareMetadataAbbyyLingvoFormat,
        );

  /// Get the singleton instance of this dictionary format.
  static AbbyyLingvoFormat get instance => _instance;

  static final AbbyyLingvoFormat _instance =
      AbbyyLingvoFormat._privateConstructor();
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<void> prepareDictionaryAbbyyLingvoFormat(
    PrepareDirectoryParams params) async {
  try {
    String dictionaryFilePath =
        path.join(params.workingDirectory.path, 'dictionary.dsl');
    File originalFile = params.file!;
    File newFile = File(dictionaryFilePath);

    if (params.charset.startsWith('UTF-16')) {
      final utf16CodeUnits =
          originalFile.readAsBytesSync().buffer.asUint16List();
      var converted = String.fromCharCodes(utf16CodeUnits);
      newFile.createSync();
      newFile.writeAsStringSync(converted);
    } else {
      originalFile.copySync(newFile.path);
    }
  } catch (e) {
    String message = params.localisation.importMessageErrorWithVar('$e');
    params.sendPort.send(message);
  }
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<String> prepareNameAbbyyLingvoFormat(
    PrepareDirectoryParams params) async {
  try {
    String dictionaryFilePath =
        path.join(params.workingDirectory.path, 'dictionary.dsl');
    File dictionaryFile = File(dictionaryFilePath);

    String nameLine =
        dictionaryFile.readAsLinesSync().first.replaceFirst('#NAME', '').trim();

    String name = nameLine.substring(1, nameLine.length - 1);
    return name;
  } catch (e) {
    params.sendPort.send(e);
    String message = params.localisation.importMessageErrorWithVar('$e');
    params.sendPort.send(message);
    throw Exception(e);
  }
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<List<DictionaryEntry>> prepareEntriesAbbyyLingvoFormat(
    PrepareDictionaryParams params) async {
  try {
    List<DictionaryEntry> entries = [];

    String dictionaryFilePath =
        path.join(params.workingDirectory.path, 'dictionary.dsl');
    File dictionaryFile = File(dictionaryFilePath);

    String text = dictionaryFile
        .readAsStringSync()
        .replaceAll('[', '<')
        .replaceAll(']', '>')
        .replaceAll('{{', '<')
        .replaceAll('}}', '>')
        .replaceAll('<m0>', '')
        .replaceAll('<m1>', ' ')
        .replaceAll('<m2>', '  ')
        .replaceAll('<m3>', '   ')
        .replaceAll('\\<', '<')
        .replaceAll('\\>', '>')
        .replaceAll('<<', '')
        .replaceAll('>>', '')
        .replaceAll(RegExp('<[^<]+?>'), '');

    List<String> lines = text.split('\n');

    String term = '';

    final buffer = StringBuffer();

    for (String line in lines) {
      if (line.startsWith('#')) {
        continue;
      }

      if (line.characters.isNotEmpty &&
          line.characters.first.codeUnits.first == 9) {
        buffer.writeln(line);
      } else {
        String meaning = buffer.toString();
        buffer.clear();

        if (term.isNotEmpty && meaning.isNotEmpty) {
          DictionaryEntry entry = DictionaryEntry(
            term: term,
            meanings: [meaning],
            dictionaryName: params.dictionaryName,
          );
          entries.add(entry);

          if (entries.length % 1000 == 0) {
            String message = params.localisation
                .importMessageEntryCountWithVar(entries.length);
            params.sendPort.send(message);
          }
        }

        term = line;
      }
    }

    String message =
        params.localisation.importMessageEntryCountWithVar(entries.length);
    params.sendPort.send(message);

    return entries;
  } catch (e) {
    String message = params.localisation.importMessageErrorWithVar('$e');
    params.sendPort.send(message);
  }

  throw Exception('Unable to get entries');
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<List<DictionaryMetaEntry>> prepareMetaEntriesAbbyyLingvoFormat(
    PrepareDictionaryParams params) async {
  return [];
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<List<DictionaryTag>> prepareTagsAbbyyLingvoFormat(
    PrepareDictionaryParams params) async {
  return [];
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<Map<String, String>> prepareMetadataAbbyyLingvoFormat(
    PrepareDictionaryParams params) async {
  return {};
}

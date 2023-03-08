import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:yuuna/dictionary.dart';
import 'package:yuuna/i18n/strings.g.dart';

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
          uniqueKey: 'abbyy_lingvo',
          name: 'ABBYY Lingvo (DSL)',
          icon: Icons.auto_stories_rounded,
          allowedExtensions: const ['dsl'],
          isTextFormat: true,
          fileType: FileType.any,
          prepareDirectory: prepareDirectoryAbbyyLingvoFormat,
          prepareName: prepareNameAbbyyLingvoFormat,
          prepareEntries: prepareEntriesAbbyyLingvoFormat,
          prepareTags: prepareTagsAbbyyLingvoFormat,
          preparePitches: preparePitchesAbbyyLingvoFormat,
          prepareFrequencies: prepareFrequenciesAbbyyLingvoFormat,
        );

  /// Get the singleton instance of this dictionary format.
  static AbbyyLingvoFormat get instance => _instance;

  static final AbbyyLingvoFormat _instance =
      AbbyyLingvoFormat._privateConstructor();
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<void> prepareDirectoryAbbyyLingvoFormat(
    PrepareDirectoryParams params) async {
  String dictionaryFilePath =
      path.join(params.workingDirectory.path, 'dictionary.dsl');
  File originalFile = params.file;
  File newFile = File(dictionaryFilePath);

  if (params.charset.startsWith('UTF-16')) {
    final utf16CodeUnits = originalFile.readAsBytesSync().buffer.asUint16List();
    var converted = String.fromCharCodes(utf16CodeUnits);
    newFile.createSync();
    newFile.writeAsStringSync(converted);
  } else {
    originalFile.copySync(newFile.path);
  }
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<String> prepareNameAbbyyLingvoFormat(
    PrepareDirectoryParams params) async {
  String dictionaryFilePath =
      path.join(params.workingDirectory.path, 'dictionary.dsl');
  File dictionaryFile = File(dictionaryFilePath);

  String nameLine =
      dictionaryFile.readAsLinesSync().first.replaceFirst('#NAME', '').trim();

  String name = nameLine.substring(1, nameLine.length - 1);
  return name;
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<Map<DictionaryHeading, List<DictionaryEntry>>>
    prepareEntriesAbbyyLingvoFormat(PrepareDictionaryParams params) async {
  Map<DictionaryHeading, List<DictionaryEntry>> entriesByHeading = {};

  String dictionaryFilePath =
      path.join(params.workingDirectory.path, 'dictionary.dsl');
  File dictionaryFile = File(dictionaryFilePath);

  String text = dictionaryFile
      .readAsStringSync()
      .replaceAll('<br>', '\n')
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
      String definition = buffer.toString();
      buffer.clear();

      if (term.isNotEmpty && definition.isNotEmpty) {
        DictionaryHeading heading = DictionaryHeading(
          term: term,
        );
        DictionaryEntry entry = DictionaryEntry(
          definitions: [definition],
          entryTagNames: [],
          headingTagNames: [],
          popularity: 0,
        );

        entriesByHeading.putIfAbsent(heading, () => []);
        entriesByHeading[heading]!.add(entry);

        if (entriesByHeading.length % 1000 == 0) {
          params.send(t.import_found_entry(count: entriesByHeading.length));
        }
      }

      term = line;
    }
  }

  params.send(t.import_found_entry(count: entriesByHeading.length));

  return entriesByHeading;
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<List<DictionaryTag>> prepareTagsAbbyyLingvoFormat(
    PrepareDictionaryParams params) async {
  return [];
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<Map<DictionaryHeading, List<DictionaryPitch>>>
    preparePitchesAbbyyLingvoFormat(PrepareDictionaryParams params) async {
  return {};
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<Map<DictionaryHeading, List<DictionaryFrequency>>>
    prepareFrequenciesAbbyyLingvoFormat(PrepareDictionaryParams params) async {
  return {};
}

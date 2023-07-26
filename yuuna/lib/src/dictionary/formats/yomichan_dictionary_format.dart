import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart' as path;
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/utils.dart';

/// A dictionary format for archives following the latest Yomichan bank schema.
/// Example dictionaries for this format may be downloaded from the Yomichan
/// website.
///
/// Details on the format can be found here:
/// https://github.com/FooSoft/yomichan/blob/master/ext/data/schemas/dictionary-term-bank-v3-schema.json
class YomichanFormat extends DictionaryFormat {
  /// Define a format with the given metadata that has its behaviour for
  /// import, search and display defined with af set of top-level helper methods.
  YomichanFormat._privateConstructor()
      : super(
          uniqueKey: 'yomichan',
          name: 'Yomichan Dictionary',
          icon: Icons.auto_stories_rounded,
          allowedExtensions: const ['zip'],
          isTextFormat: false,
          fileType: FileType.custom,
          prepareDirectory: prepareDirectoryYomichanFormat,
          prepareName: prepareNameYomichanFormat,
          prepareEntries: prepareEntriesYomichanFormat,
          prepareTags: prepareTagsYomichanFormat,
          preparePitches: preparePitchesYomichanFormat,
          prepareFrequencies: prepareFrequenciesYomichanFormat,
        );

  /// Get the singleton instance of this dictionary format.
  static YomichanFormat get instance => _instance;

  static final YomichanFormat _instance = YomichanFormat._privateConstructor();
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<void> prepareDirectoryYomichanFormat(
    PrepareDirectoryParams params) async {
  /// Extract the user selected archive to the working directory.
  await ZipFile.extractToDirectory(
    zipFile: params.file,
    destinationDir: params.workingDirectory,
  );
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<String> prepareNameYomichanFormat(PrepareDirectoryParams params) async {
  /// Get the index, which contains the name of the dictionary contained by
  /// the archive.
  String indexFilePath = path.join(params.workingDirectory.path, 'index.json');
  File indexFile = File(indexFilePath);
  String indexJson = indexFile.readAsStringSync();
  Map<String, dynamic> index = jsonDecode(indexJson);

  String dictionaryName = (index['title'] as String).trim();
  return dictionaryName;
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<Map<DictionaryHeading, List<DictionaryEntry>>>
    prepareEntriesYomichanFormat(PrepareDictionaryParams params) async {
  int structuredContentCount = 0;
  Map<DictionaryHeading, List<DictionaryEntry>> entriesByHeading = {};

  final List<FileSystemEntity> entities = params.workingDirectory.listSync();
  final Iterable<File> files = entities.whereType<File>();

  for (File file in files) {
    String filename = path.basename(file.path);
    if (filename.startsWith('term_bank')) {
      List<dynamic> items = jsonDecode(file.readAsStringSync());

      for (List<dynamic> item in items) {
        String term = item[0] as String;
        String reading = item[1] as String;

        double popularity = (item[4] as num).toDouble();

        // Third entry in array can be null
        List<String> entryTagNames = [];
        if (item[2] != null) {
          entryTagNames = (item[2] as String).split(' ');
        }

        List<String> headingTagNames = (item[7] as String).split(' ');

        List<String> definitions = [];

        if (item[5] is List) {
          List<dynamic> meaningsList = List.from(item[5]);
          definitions = meaningsList.map((e) {
            if (e is Map) {
              Map<String, dynamic> data = Map<String, dynamic>.from(e);
              if (data['type'] == 'image') {
                return '';
              } else if (data['type'] == 'structured-content') {
                structuredContentCount++;
                return '';
              } else {
                return e.toString().trim();
              }
            } else {
              return e.toString().trim();
            }
          }).toList();
        } else if (item[5] is Map) {
          Map<String, dynamic> data = Map<String, dynamic>.from(item[5]);
          if (data['type'] != 'image' && data['type'] != 'structured-content') {
            definitions.add(item[5].toString().trim());
          }
        } else {
          definitions.add(item[5].toString().trim());
        }

        definitions = definitions.where((e) => e.isNotEmpty).toList();

        if (definitions.isNotEmpty) {
          DictionaryHeading heading = DictionaryHeading(
            reading: reading,
            term: term,
          );
          DictionaryEntry entry = DictionaryEntry(
            definitions: definitions,
            entryTagNames: entryTagNames,
            headingTagNames: headingTagNames,
            popularity: popularity,
          );

          entriesByHeading.putIfAbsent(heading, () => []);
          entriesByHeading[heading]!.add(entry);
        }
      }
    } else if (filename.startsWith('kanji_bank')) {
      List<dynamic> items = jsonDecode(file.readAsStringSync());

      for (List<dynamic> item in items) {
        String term = item[0] as String;
        List<String> onyomis = (item[1] as String).split(' ');
        List<String> kunyomis = (item[2] as String).split(' ');
        List<String> headingTagNames = (item[3] as String).split(' ');
        List<String> meanings = List<String>.from(item[4]);

        StringBuffer buffer = StringBuffer();
        if (onyomis.join().trim().isNotEmpty) {
          buffer.write('音読み\n');
          for (String onyomi in onyomis) {
            buffer.write('  • $onyomi\n');
          }
          buffer.write('\n');
        }
        if (kunyomis.join().trim().isNotEmpty) {
          buffer.write('訓読み\n');
          for (String kun in kunyomis) {
            buffer.write('  • $kun\n');
          }
          buffer.write('\n');
        }
        if (meanings.isNotEmpty) {
          buffer.write('意味\n');
          for (String meaning in meanings) {
            buffer.write('  • $meaning\n');
          }
          buffer.write('\n');
        }

        String definition = buffer.toString().trim();

        if (definition.isNotEmpty) {
          DictionaryHeading heading = DictionaryHeading(
            term: term,
          );
          DictionaryEntry entry = DictionaryEntry(
            definitions: [definition],
            entryTagNames: [],
            headingTagNames: headingTagNames,
            popularity: 0,
          );

          entriesByHeading.putIfAbsent(heading, () => []);
          entriesByHeading[heading]!.add(entry);
        }
      }
    }

    if (entriesByHeading.isNotEmpty) {
      params.send(t.import_found_entry(count: entriesByHeading.length));
    }
  }

  if (structuredContentCount != 0) {
    params.sendAlert(
        message: t.structured_content_first(i: structuredContentCount));
    params.sendAlert(message: t.structured_content_second);
  }

  return entriesByHeading;
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<List<DictionaryTag>> prepareTagsYomichanFormat(
    PrepareDictionaryParams params) async {
  List<DictionaryTag> tags = [];

  final List<FileSystemEntity> entities = params.workingDirectory.listSync();
  final Iterable<File> files = entities.whereType<File>();

  for (File file in files) {
    String filename = path.basename(file.path);
    if (!filename.startsWith('tag_bank')) {
      continue;
    }

    String json = file.readAsStringSync();
    List<dynamic> items = jsonDecode(json);

    for (List<dynamic> item in items) {
      String name = item[0] as String;
      String category = item[1] as String;
      int sortingOrder = item[2] as int;
      String notes = item[3] as String;
      double popularity = (item[4] as num).toDouble();

      DictionaryTag tag = DictionaryTag(
        dictionaryId: params.dictionary.id,
        name: name,
        category: category,
        sortingOrder: sortingOrder,
        notes: notes,
        popularity: popularity,
      );

      tags.add(tag);
    }

    if (tags.isNotEmpty) {
      params.send(t.import_found_tag(count: tags.length));
    }
  }

  return tags;
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<Map<DictionaryHeading, List<DictionaryPitch>>>
    preparePitchesYomichanFormat(PrepareDictionaryParams params) async {
  Map<DictionaryHeading, List<DictionaryPitch>> pitchesByHeading = {};
  final List<FileSystemEntity> entities = params.workingDirectory.listSync();
  final Iterable<File> files = entities.whereType<File>();

  for (File file in files) {
    String filename = path.basename(file.path);
    if (!filename.startsWith('term_meta_bank')) {
      continue;
    }

    String json = file.readAsStringSync();
    List<dynamic> items = jsonDecode(json);

    for (List<dynamic> item in items) {
      String term = item[0] as String;
      String type = item[1] as String;

      if (type == 'pitch') {
        Map<String, dynamic> data = Map<String, dynamic>.from(item[2]);
        String reading = data['reading'] ?? '';
        DictionaryHeading heading = DictionaryHeading(
          term: term,
          reading: reading,
        );
        pitchesByHeading.putIfAbsent(heading, () => []);

        List<Map<String, dynamic>> distinctPitchJsons =
            List<Map<String, dynamic>>.from(data['pitches']);
        for (Map<String, dynamic> distinctPitch in distinctPitchJsons) {
          int downstep = distinctPitch['position'];
          DictionaryPitch pitch = DictionaryPitch(downstep: downstep);

          pitchesByHeading[heading]!.add(pitch);
        }
      } else {
        continue;
      }
    }

    if (pitchesByHeading.isNotEmpty) {
      params.send(t.import_found_pitch(count: pitchesByHeading.length));
    }
  }

  return pitchesByHeading;
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<Map<DictionaryHeading, List<DictionaryFrequency>>>
    prepareFrequenciesYomichanFormat(PrepareDictionaryParams params) async {
  Map<DictionaryHeading, List<DictionaryFrequency>> frequenciesByHeading = {};
  final List<FileSystemEntity> entities = params.workingDirectory.listSync();
  final Iterable<File> files = entities.whereType<File>();

  for (File file in files) {
    String filename = path.basename(file.path);
    if (!filename.startsWith('term_meta_bank')) {
      continue;
    }

    String json = file.readAsStringSync();
    List<dynamic> items = jsonDecode(json);

    for (List<dynamic> item in items) {
      String term = item[0] as String;
      String type = item[1] as String;

      late DictionaryHeading heading;
      late DictionaryFrequency frequency;

      if (type == 'freq') {
        if (item[2] is double) {
          double number = item[2] as double;
          if (number % 1 == 0) {
            heading = DictionaryHeading(term: term);
            frequency = DictionaryFrequency(
              value: number,
              displayValue: '${number.toInt()}',
            );
          } else {
            heading = DictionaryHeading(term: term);
            frequency = DictionaryFrequency(
              value: number,
              displayValue: '$number',
            );
          }
        } else if (item[2] is int) {
          int number = item[2] as int;
          heading = DictionaryHeading(term: term);
          DictionaryFrequency(
            value: number.toDouble(),
            displayValue: '$number',
          );
          frequency = DictionaryFrequency(
            value: number.toDouble(),
            displayValue: '$number',
          );
        } else if (item[2] is Map) {
          Map<String, dynamic> data = Map<String, dynamic>.from(item[2]);

          if (data['reading'] != null && data['frequency'] is Map) {
            Map<String, dynamic> frequencyData =
                Map<String, dynamic>.from(data['frequency']);

            String reading = data['reading'] ?? '';
            heading = DictionaryHeading(
              term: term,
              reading: reading,
            );

            num number = frequencyData['value'] ?? 0;

            frequency = DictionaryFrequency(
              value: number.toDouble(),
              displayValue: frequencyData['displayValue'],
            );
          } else if (data['displayValue'] != null) {
            String reading = data['reading'] ?? '';
            heading = DictionaryHeading(
              term: term,
              reading: reading,
            );
            num number = data['value'] ?? 0;

            frequency = DictionaryFrequency(
              value: number.toDouble(),
              displayValue: data['displayValue'],
            );
          } else if (data['value'] != null) {
            String reading = data['reading'] ?? '';
            heading = DictionaryHeading(
              term: term,
              reading: reading,
            );
            num number = data['value'] ?? 0;

            frequency = DictionaryFrequency(
              value: number.toDouble(),
              displayValue: number.toInt().toString(),
            );
          } else if (data['frequency'] is num) {
            num frequencyValue = data['frequency'];
            String reading = data['reading'] ?? '';
            heading = DictionaryHeading(
              term: term,
              reading: reading,
            );

            if (frequencyValue % 1 == 0) {
              frequency = DictionaryFrequency(
                value: frequencyValue.toDouble(),
                displayValue: frequencyValue.toInt().toString(),
              );
            } else {
              frequency = DictionaryFrequency(
                value: frequencyValue.toDouble(),
                displayValue: frequencyValue.toDouble().toString(),
              );
            }
          }
        } else {
          heading = DictionaryHeading(term: term);
          frequency = DictionaryFrequency(
            value: 0,
            displayValue: item[2].toString(),
          );
        }

        frequenciesByHeading.putIfAbsent(heading, () => []);
        frequenciesByHeading[heading]!.add(frequency);
      } else {
        continue;
      }
    }

    if (frequenciesByHeading.isNotEmpty) {
      params.send(t.import_found_frequency(count: frequenciesByHeading.length));
    }
  }

  return frequenciesByHeading;
}

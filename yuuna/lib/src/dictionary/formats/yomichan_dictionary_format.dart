import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart' as path;

import 'package:yuuna/dictionary.dart';

/// A dictionary format for archives following the latest Yomichan bank schema.
/// Example dictionaries for this format may be downloaded from the Yomichan
/// website.
///
/// Details on the term bank schema particularly can be found here:
/// https://github.com/FooSoft/yomichan/blob/master/ext/data/schemas/dictionary-term-bank-v3-schema.json
class YomichanDictionaryFormat extends DictionaryFormat {
  /// Define a format with the given metadata that has its behaviour for
  /// import, search and display defined with af set of top-level helper methods.
  YomichanDictionaryFormat._privateConstructor()
      : super(
          formatName: 'Yomichan Dictionary',
          formatIcon: Icons.auto_stories,
          compatibleFileExtensions: const ['.zip'],
          prepareDirectory: prepareDirectoryYomichanTermBankFormat,
          prepareName: prepareNameYomichanTermBankFormat,
          prepareEntries: prepareEntriesYomichanTermBankFormat,
          prepareMetaEntries: prepareMetaEntriesYomichanTermBankFormat,
          prepareTags: prepareTagsYomichanTermBankFormat,
          prepareMetadata: prepareMetadataYomichanTermBankFormat,
        );

  /// Get the singleton instance of this dictionary format.
  static YomichanDictionaryFormat get instance => _instance;

  static final YomichanDictionaryFormat _instance =
      YomichanDictionaryFormat._privateConstructor();
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<void> prepareDirectoryYomichanTermBankFormat(
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
Future<String> prepareNameYomichanTermBankFormat(
    PrepareDirectoryParams params) async {
  try {
    /// Get the index, which contains the name of the dictionary contained by
    /// the archive.
    String indexFilePath =
        path.join(params.workingDirectory.path, 'index.json');
    File indexFile = File(indexFilePath);
    String indexJson = indexFile.readAsStringSync();
    Map<String, dynamic> index = jsonDecode(indexJson);

    String dictionaryName = (index['title'] as String).trim();
    return dictionaryName;
  } catch (e) {
    String message = params.localisation.importMessageErrorWithVar('$e');
    params.sendPort.send(message);
  }

  throw Exception('Unable to get name');
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<List<DictionaryEntry>> prepareEntriesYomichanTermBankFormat(
    PrepareDictionaryParams params) async {
  try {
    List<DictionaryEntry> entries = [];

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
          List<String> meaningTags = (item[2] as String).split(' ');
          List<String> termTags = (item[7] as String).split(' ');

          List<String> meanings = [];

          if (item[5] is List) {
            List<dynamic> meaningsList = List.from(item[5]);
            meanings = meaningsList.map((e) {
              if (e is Map) {
                Map<String, dynamic> data = Map<String, dynamic>.from(e);
                if (data['type'] == 'image' ||
                    data['type'] == 'structured-content') {
                  return '';
                } else {
                  return e.toString();
                }
              } else {
                return e.toString();
              }
            }).toList();
          } else if (item[5] is Map) {
            Map<String, dynamic> data = Map<String, dynamic>.from(item[5]);
            if (data['type'] != 'image' &&
                data['type'] != 'structured-content') {
              meanings.add(item[5].toString());
            }
          } else {
            meanings.add(item[5].toString());
          }

          meanings = meanings.where((e) => e.isNotEmpty).toList();

          if (meanings.isNotEmpty) {
            entries.add(
              DictionaryEntry(
                dictionaryName: params.dictionaryName,
                term: term,
                reading: reading,
                meanings: meanings,
                popularity: popularity,
                meaningTags: meaningTags,
                termTags: termTags,
              ),
            );
          }
        }
      } else if (filename.startsWith('kanji_bank')) {
        List<dynamic> items = jsonDecode(file.readAsStringSync());

        for (List<dynamic> item in items) {
          String term = item[0] as String;
          List<String> onyomis = (item[1] as String).split(' ');
          List<String> kunyomis = (item[2] as String).split(' ');
          List<String> termTags = (item[3] as String).split(' ');
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

          String meaning = buffer.toString().trim();

          List<String> normalisedMeaning = [meaning];

          meanings = meanings.where((e) => e.isNotEmpty).toList();

          if (meaning.isNotEmpty) {
            entries.add(
              DictionaryEntry(
                dictionaryName: params.dictionaryName,
                term: term,
                meanings: normalisedMeaning,
                termTags: termTags,
              ),
            );
          }
        }
      }

      String message =
          params.localisation.importMessageEntryCountWithVar(entries.length);
      params.sendPort.send(message);
    }

    return entries;
  } catch (e) {
    String message = params.localisation.importMessageErrorWithVar('$e');
    params.sendPort.send(message);
  }

  throw Exception('Unable to get entries');
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<List<DictionaryMetaEntry>> prepareMetaEntriesYomichanTermBankFormat(
    PrepareDictionaryParams params) async {
  try {
    List<DictionaryMetaEntry> metaEntries = [];

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

        FrequencyData? frequency;
        List<PitchData>? pitches;

        if (type == 'pitch') {
          pitches = [];

          Map<String, dynamic> data = Map<String, dynamic>.from(item[2]);
          String reading = data['reading'];

          List<Map<String, dynamic>> distinctPitchJsons =
              List<Map<String, dynamic>>.from(data['pitches']);
          for (Map<String, dynamic> distinctPitch in distinctPitchJsons) {
            int downstep = distinctPitch['position'];
            PitchData pitch = PitchData(
              reading: reading,
              downstep: downstep,
            );
            pitches.add(pitch);
          }
        } else if (type == 'freq') {
          if (item[2] is double) {
            double number = item[2] as double;
            if (number % 1 == 0) {
              frequency = FrequencyData(
                value: number,
                displayValue: '${number.toInt()}',
              );
            } else {
              frequency = FrequencyData(
                value: number,
                displayValue: '$number',
              );
            }
          } else if (item[2] is int) {
            int number = item[2] as int;
            frequency = FrequencyData(
              value: number.toDouble(),
              displayValue: '$number',
            );
          } else if (item[2] is Map) {
            Map<String, dynamic> data = Map<String, dynamic>.from(item[2]);

            if (data['reading'] != null && data['frequency'] is Map) {
              Map<String, dynamic> frequencyData =
                  Map<String, dynamic>.from(data['frequency']);

              num number = frequencyData['value'] ?? 0;

              frequency = FrequencyData(
                value: number.toDouble(),
                displayValue: frequencyData['displayValue'],
                reading: data['reading'],
              );
            } else if (data['displayValue'] != null) {
              num number = data['value'] ?? 0;

              frequency = FrequencyData(
                value: number.toDouble(),
                displayValue: data['displayValue'],
                reading: data['reading'],
              );
            } else if (data['value'] != null) {
              num number = data['value'] ?? 0;

              frequency = FrequencyData(
                value: number.toDouble(),
                displayValue: number.toInt().toString(),
                reading: data['reading'],
              );
            } else {}
          } else {
            frequency = FrequencyData(
              value: 0,
              displayValue: item[2].toString(),
            );
          }
        } else {
          continue;
        }

        DictionaryMetaEntry metaEntry = DictionaryMetaEntry(
          dictionaryName: params.dictionaryName,
          term: term,
          frequency: frequency,
          pitches: pitches,
        );

        metaEntries.add(metaEntry);
      }

      String message = params.localisation
          .importMessageMetaEntryCountWithVar(metaEntries.length);
      params.sendPort.send(message);
    }

    return metaEntries;
  } catch (e) {
    String message = params.localisation.importMessageErrorWithVar('$e');
    params.sendPort.send(message);
  }

  throw Exception('Unable to get meta entries');
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<List<DictionaryTag>> prepareTagsYomichanTermBankFormat(
    PrepareDictionaryParams params) async {
  try {
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
          dictionaryName: params.dictionaryName,
          name: name,
          category: category,
          sortingOrder: sortingOrder,
          notes: notes,
          popularity: popularity,
        );

        tags.add(tag);
      }

      String message =
          params.localisation.importMessageTagCountWithVar(tags.length);
      params.sendPort.send(message);
    }

    return tags;
  } catch (e) {
    String message = params.localisation.importMessageErrorWithVar('$e');
    params.sendPort.send(message);
  }

  throw Exception('Unable to get tags');
}

/// Top-level function for use in compute. See [DictionaryFormat] for details.
Future<Map<String, String>> prepareMetadataYomichanTermBankFormat(
    PrepareDictionaryParams params) async {
  return {};
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as path;

import 'package:yuuna/dictionary.dart';

part 'yomichan_term_bank_format.g.dart';

/// A dictionary format for archives in the Yomichan Term Bank V3 schema.
/// Example dictionaries for this format may be downloaded from the Yomichan
/// website.
///
/// Details on the schema can be found here:
/// https://github.com/FooSoft/yomichan/blob/master/ext/data/schemas/dictionary-term-bank-v3-schema.json
class YomichanTermBankFormat extends DictionaryFormat {
  /// Define a format with the given metadata that has its behaviour for
  /// import, search and display defined with a set of top-level helper methods.
  YomichanTermBankFormat._privateConstructor()
      : super(
          formatName: 'Yomichan Term Bank',
          formatIcon: Icons.auto_stories,
          requiresFile: true,
          prepareDirectory: prepareDirectoryYomichanTermBankFormat,
          prepareName: prepareNameYomichanTermBankFormat,
          prepareEntries: prepareEntriesYomichanTermBankFormat,
          prepareMetadata: prepareMetadataYomichanTermBankFormat,
        );

  /// Get the singleton instance of this dictionary format.
  static YomichanTermBankFormat get instance => _instance;

  static final YomichanTermBankFormat _instance =
      YomichanTermBankFormat._privateConstructor();
}

/// A helper class for tags that are present in Yomichan imported dictionary
/// entries.
@JsonSerializable()
class YomichanTag {
  /// Define a tag with given parameters.
  YomichanTag({
    required this.name,
    required this.category,
    required this.sortingOrder,
    required this.notes,
    required this.popularity,
  });

  /// Create an instance of this class from a serialized format.
  factory YomichanTag.fromJson(Map<String, dynamic> json) =>
      _$YomichanTagFromJson(json);

  /// Convert this into a serialized format.
  Map<String, dynamic> toJson() => _$YomichanTagToJson(this);

  /// Tag name.
  String name;

  /// Category for the tag.
  String category;

  /// Sorting order for the tag.
  int sortingOrder;

  /// Notes for this tag.
  String notes;

  /// Score used to determine popularity.
  /// Negative values are more rare and positive values are more frequent.
  /// This score is also used to sort search results.
  double? popularity;
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
      if (!filename.startsWith('term_bank')) {
        continue;
      }

      List<dynamic> items = jsonDecode(file.readAsStringSync());

      for (List<dynamic> item in items) {
        String word = item[0] as String;
        String reading = item[1] as String;

        double popularity = (item[4] as num).toDouble();
        List<String> meaningTags = (item[2] as String).split(' ');
        List<String> wordTags = (item[7] as String).split(' ');

        List<String> meanings = [];
        int? sequence = item[6] as int?;

        if (item[5] is List) {
          List<dynamic> meaningsList = List.from(item[5]);
          meanings = meaningsList.map((e) => e.toString()).toList();
        } else {
          meanings.add(item[5].toString());
        }

        entries.add(
          DictionaryEntry(
            dictionaryName: params.dictionaryName,
            word: word,
            reading: reading,
            meanings: meanings,
            popularity: popularity,
            meaningTags: meaningTags,
            wordTags: wordTags,
            sequence: sequence,
          ),
        );
      }

      String message =
          params.localisation.importMessageCountWithVar(entries.length);
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
Future<Map<String, String>> prepareMetadataYomichanTermBankFormat(
    PrepareDictionaryParams params) async {
  try {
    Map<String, String> metadata = {};

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

        YomichanTag tag = YomichanTag(
          name: name,
          category: category,
          sortingOrder: sortingOrder,
          notes: notes,
          popularity: popularity,
        );

        String key = name;
        String value = jsonEncode(tag.toJson());

        metadata[key] = value;
      }

      params.sendPort.send('Found ${metadata.length} tags...');
    }

    return metadata;
  } catch (e) {
    String message = params.localisation.importMessageErrorWithVar('$e');
    params.sendPort.send(message);
  }

  throw Exception('Unable to get entries');
}

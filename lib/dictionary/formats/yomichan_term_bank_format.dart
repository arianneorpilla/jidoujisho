import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:daijidoujisho/dictionary/dictionary_entry.dart';
import 'package:daijidoujisho/dictionary/dictionary_format.dart';
import 'package:daijidoujisho/dictionary/dictionary_utils.dart';
import 'package:daijidoujisho/dictionary/dictionary_search_results.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class YomichanTermBankFormat extends DictionaryFormat {
  YomichanTermBankFormat()
      : super(
          formatName: "Yomichan Term Bank",
          prepareWorkingDirectory:
              prepareWorkingDirectoryYomichanTermBankFormat,
          getDictionaryName: getDictionaryNameYomichanTermBankFormat,
          getDictionaryEntries: getDictionaryEntriesYomichanTermBankFormat,
          getDictionaryMetadata: getDictionaryMetadataYomichanTermBankFormat,
        );

  @override
  bool isUriSupported(Uri uri) {
    return (lookupMimeType(uri.path) ?? "") == 'application/zip';
  }

  @override
  DictionarySearchResult processResultsFromEntries(
      List<DictionaryEntry> entries) {
    // TODO: implement processResultsFromEntries
    throw UnimplementedError();
  }
}

@override
FutureOr<void> prepareWorkingDirectoryYomichanTermBankFormat(
    ImportPreparationParams params) async {
  await ZipFile.extractToDirectory(
      zipFile: params.file, destinationDir: params.workingDirectory);
}

@override
FutureOr<String> getDictionaryNameYomichanTermBankFormat(
    ImportProcessingParams params) {
  String indexJsonPath = p.join(params.workingDirectory.path, "index.json");
  File indexJson = File(indexJsonPath);
  Map<String, dynamic> index = jsonDecode(indexJson.readAsStringSync());

  String dictionaryName = (index["title"] as String).trim();
  return dictionaryName;
}

@override
FutureOr<List<DictionaryEntry>> getDictionaryEntriesYomichanTermBankFormat(
    ImportProcessingParams params) {
  /// Used to parse more structured meanings, i.e. where a [Map] is used
  /// for the meaning. These need to be reduced to a simple [String]
  String parseMeaning(entry) {
    try {
      List<dynamic> list = List.from(entry);
      if (list.length == 1) {
        return list.first as String;
      }
      String reduced = list.reduce((value, element) {
        return "$value; $element";
      });
      return reduced;
    } catch (e) {
      return entry.toString();
    }
  }

  /// Used to ensure whatever is in this field value is a valid double.
  double parsePopularity(dynamic value) {
    if (value == null) {
      return 0;
    }
    return value.toDouble();
  }

  List<DictionaryEntry> entries = [];

  for (int i = 0; i < 999; i++) {
    String termBankPath =
        p.join(params.workingDirectory.path, "term_bank_$i.json");
    File termBank = File(termBankPath);

    if (termBank.existsSync()) {
      List<dynamic> termJsons = jsonDecode(termBank.readAsStringSync());

      /// See https://github.com/FooSoft/yomichan/blob/master/ext/data/schemas/dictionary-term-bank-v3-schema.json
      for (var termJson in termJsons) {
        List<String> definitionTags = [];
        String definitionTagsUnsplit = termJson[2].toString();
        definitionTags = definitionTagsUnsplit.split(" ");

        List<String> termTags = [];
        String termTagsUnsplit = termJson[7].toString();
        termTags = termTagsUnsplit.split(" ");

        String headword = termJson[0].toString();
        String reading = termJson[1].toString();
        String meaning = parseMeaning(termJson[5]);
        double popularity = parsePopularity(termJson[4]);

        Map<String, String> extraMap = {
          "definitionTags": jsonEncode(definitionTags),
          "termTags": jsonEncode(termTags),
        };
        String extra = jsonEncode(extraMap);

        entries.add(DictionaryEntry(
          headword: headword,
          reading: reading,
          meaning: meaning,
          extra: extra,
          popularity: popularity,
        ));
      }
    }

    params.sendPort.send("Found ${entries.length} entries...");
  }

  return entries;
}

@override
FutureOr<Map<String, String>> getDictionaryMetadataYomichanTermBankFormat(
    ImportProcessingParams params) {
  Map<String, String> metadata = {};

  /// Used to ensure whatever is in this field value is a valid double.
  double parsePopularity(dynamic value) {
    if (value == null) {
      return 0;
    }
    return value.toDouble();
  }

  for (int i = 0; i < 999; i++) {
    String tagBankPath =
        p.join(params.workingDirectory.path, "tag_bank_$i.json");
    File tagBank = File(tagBankPath);

    if (tagBank.existsSync()) {
      List<dynamic> tagJsons = jsonDecode(tagBank.readAsStringSync());

      for (var tagJson in tagJsons) {
        String tagName = tagJson[0];
        String frequencyName = tagJson[1];
        int sortingOrder = tagJson[2];
        String tagNotes = tagJson[3];
        double popularity = parsePopularity(tagJson[4]);

        String key = tagName;
        String value = jsonEncode({
          "frequencyName": frequencyName,
          "sortingOrder": sortingOrder,
          "tagNotes": tagNotes,
          "popularity": popularity,
        });

        metadata[key] = value;
      }
    }

    params.sendPort.send("Found ${metadata.length} tags...");
  }

  return metadata;
}

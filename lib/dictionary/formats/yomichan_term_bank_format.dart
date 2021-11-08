import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/dictionary/dictionary_import.dart';
import 'package:chisa/dictionary/formats/yomichan_term_bank_format_widget.dart';
import 'package:chisa/util/dictionary_entry_widget.dart';
import 'package:chisa/util/number_tag.dart';

class YomichanTermBankFormat extends DictionaryFormat {
  YomichanTermBankFormat()
      : super(
          formatName: "Yomichan Term Bank",
          prepareWorkingDirectory:
              prepareWorkingDirectoryYomichanTermBankFormat,
          getDictionaryName: getDictionaryNameYomichanTermBankFormat,
          getDictionaryEntries: getDictionaryEntriesYomichanTermBankFormat,
          getDictionaryMetadata: getDictionaryMetadataYomichanTermBankFormat,
          searchResultsEnhancement:
              searchResultsEnhancementYomichanTermBankFormat,
          widgetDisplayEnhancement: widgetDisplayEnhancementYomichanTermBank,
        );

  @override
  bool isUriSupported(Uri uri) {
    return (lookupMimeType(uri.path) ?? "") == 'application/zip';
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
    ImportDirectoryParams params) {
  String indexJsonPath = p.join(params.workingDirectory.path, "index.json");
  File indexJson = File(indexJsonPath);
  Map<String, dynamic> index = jsonDecode(indexJson.readAsStringSync());

  String dictionaryName = (index["title"] as String).trim();
  return dictionaryName;
}

@override
FutureOr<List<DictionaryEntry>> getDictionaryEntriesYomichanTermBankFormat(
    ImportDirectoryParams params) {
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
        List<String> meaningTags = [];
        String meaningTagsUnsplit = termJson[2].toString();
        meaningTags = meaningTagsUnsplit.split(" ");

        List<String> termTags = [];
        String termTagsUnsplit = termJson[7].toString();
        termTags = termTagsUnsplit.split(" ");

        String word = termJson[0].toString();
        String reading = termJson[1].toString();
        String meaning = parseMeaning(termJson[5]);
        double popularity = parsePopularity(termJson[4]);

        Map<String, String> extraMap = {
          "meaningTags": jsonEncode(meaningTags),
          "termTags": jsonEncode(termTags),
        };
        String extra = jsonEncode(extraMap);

        entries.add(
          DictionaryEntry(
            word: word,
            reading: reading,
            meaning: meaning,
            extra: extra,
            popularity: popularity,
          ),
        );
      }
    }

    params.sendPort.send("Found ${entries.length} entries...");
  }

  return entries;
}

@override
FutureOr<Map<String, String>> getDictionaryMetadataYomichanTermBankFormat(
    ImportDirectoryParams params) {
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

@override
FutureOr<DictionarySearchResult> searchResultsEnhancementYomichanTermBankFormat(
  ResultsProcessingParams params,
) {
  DictionarySearchResult result = params.result;
  Map<String, String> dictionaryMetadata = params.metadata;

  List<YomichanTag> tagStore =
      YomichanTag.getTagsFromMetadata(dictionaryMetadata);

  Map<String, Map<String, DictionaryEntry>> readingMap = {};
  List<DictionaryEntry> mergedEntries = [];

  for (DictionaryEntry entry in result.entries) {
    if (readingMap[entry.reading] == null) {
      readingMap[entry.reading] = {};
    }
    if (readingMap[entry.reading]![entry.word] == null) {
      readingMap[entry.reading]![entry.word] = DictionaryEntry(
        word: entry.word,
        reading: entry.reading,
        meaning: "",
        extra: entry.extra,
        popularity: 0,
      );
    }

    DictionaryEntry monoEntry = readingMap[entry.reading]![entry.word]!;
    if (monoEntry.workingArea["yomichanDefinitionTags"] == null) {
      final List<List<String>> yomichanDefinitionTags = [];
      monoEntry.workingArea["yomichanDefinitionTags"] = yomichanDefinitionTags;
    }
    if (monoEntry.workingArea["meanings"] == null) {
      final List<String> meanings = [];
      monoEntry.workingArea["meanings"] = meanings;
    }
    if (monoEntry.workingArea["duplicateCount"] == null) {
      monoEntry.workingArea["duplicateCount"] = 0;
    }
    monoEntry.workingArea["duplicateCount"] += 1;
    monoEntry.meaning += getBetterNumberTag("• ${entry.meaning}\n");
    monoEntry.workingArea["duplicateWorkingMeaning"] = entry.meaning;
    monoEntry.popularity += entry.popularity;

    monoEntry.workingArea["meanings"].add(entry.meaning);
    (monoEntry.workingArea["yomichanDefinitionTags"] as List<List<String>>)
        .add(YomichanTag.getMeaningTagNames(entry));
  }

  for (Map<String, DictionaryEntry> headwordMap in readingMap.values) {
    for (DictionaryEntry dictionaryEntry in headwordMap.values) {
      mergedEntries.add(dictionaryEntry);
    }
  }

  String removeLastNewline(String n) => n = n.substring(0, n.length - 1);
  for (DictionaryEntry entry in mergedEntries) {
    if (entry.workingArea["duplicateCount"] == 1) {
      entry.meaning = entry.workingArea["duplicateWorkingMeaning"];
    } else {
      entry.meaning = removeLastNewline(entry.meaning);
    }

    entry.popularity = entry.popularity / entry.workingArea["duplicateCount"];

    List<YomichanTag> termTags =
        YomichanTag.getTermTagsFromEntry(entry, tagStore);
    entry.workingArea["yomichanTermTags"] = termTags;

    List<String> termTagNames = termTags.map((tag) => tag.tagName).toList();

    entry.extra = jsonEncode({
      "termTags": termTagNames,
      "definitionTags": entry.workingArea["yomichanDefinitionTags"],
      "meanings": entry.workingArea["meanings"],
    });
  }

  mergedEntries.sort((a, b) => b.workingArea["yomichanDefinitionTags"].length
      .compareTo(a.workingArea["yomichanDefinitionTags"].length));
  mergedEntries.sort((a, b) =>
      YomichanTag.getPopularitySum(b.workingArea["yomichanTermTags"]).compareTo(
          YomichanTag.getPopularitySum(a.workingArea["yomichanTermTags"])));
  mergedEntries.sort((a, b) =>
      (YomichanTag.getTagCount(b.workingArea["yomichanTermTags"]) +
              b.workingArea["duplicateCount"] * 0.3)
          .compareTo(
              YomichanTag.getTagCount(a.workingArea["yomichanTermTags"]) +
                  a.workingArea["duplicateCount"] * 0.3));

  KanaKit kanaKit = const KanaKit();
  List<DictionaryEntry> exactFirstEntries = [];
  for (DictionaryEntry entry in mergedEntries) {
    if (entry.word == result.originalSearchTerm) {
      if (!exactFirstEntries.contains(entry)) {
        exactFirstEntries.add(entry);
      }
    }
  }
  for (DictionaryEntry entry in mergedEntries) {
    if (entry.reading == result.originalSearchTerm) {
      if (!exactFirstEntries.contains(entry)) {
        exactFirstEntries.add(entry);
      }
    }
    if (kanaKit.isRomaji(result.originalSearchTerm)) {
      if (entry.reading == kanaKit.toHiragana(result.originalSearchTerm) ||
          entry.word == kanaKit.toHiragana(result.originalSearchTerm)) {
        if (!exactFirstEntries.contains(entry)) {
          exactFirstEntries.add(entry);
        }
      }
    }
  }
  for (DictionaryEntry entry in mergedEntries) {
    if (result.fallbackSearchTerms.contains(entry.word) ||
        result.fallbackSearchTerms.contains(entry.reading)) {
      if (!exactFirstEntries.contains(entry)) {
        exactFirstEntries.add(entry);
      }
    }
  }
  for (DictionaryEntry entry in mergedEntries) {
    if (!exactFirstEntries.contains(entry)) {
      exactFirstEntries.add(entry);
    }
  }

  result.entries = exactFirstEntries;

  return result;
}

class YomichanTag {
  late String tagName;
  late String frequencyName;
  late double sortingOrder;
  late String tagNotes;
  late double popularity;

  YomichanTag({
    this.tagName = "",
    this.frequencyName = "",
    this.sortingOrder = 0,
    this.tagNotes = "",
    this.popularity = 0,
  });

  YomichanTag.fromJson(String json) {
    Map<String, dynamic> metadata = jsonDecode(json);
    tagName = metadata.keys.first;
    Map<String, dynamic> map = jsonDecode(metadata["tagName"]);

    frequencyName = map["frequencyName"];
    sortingOrder = map["sortingOrder"];
    tagNotes = map["tagNotes"];
    popularity = map["popularity"];
  }

  Color getTagColor() {
    switch (frequencyName) {
      case "name":
        return const Color(0xffd46a6a);
      case "expression":
        return const Color(0xffff4d4d);
      case "popular":
        return const Color(0xff550000);
      case "partOfSpeech":
        return const Color(0xff565656);
      case "archaism":
        return Colors.grey.shade700;
      case "dictionary":
        return const Color(0xffa15151);
      case "frequency":
        return const Color(0xffd46a6a);
      case "frequent":
        return const Color(0xff801515);
    }

    return Colors.grey.shade700;
  }

  static List<YomichanTag> getTagsFromMetadata(Map<String, dynamic> map) {
    List<YomichanTag> tags = [];

    double checkDouble(dynamic value) {
      if (value is String) {
        return double.parse(value);
      } else if (value is int) {
        return value.toDouble();
      } else {
        return value;
      }
    }

    for (String key in map.keys) {
      Map<String, dynamic> tagMap = jsonDecode(map[key]);
      YomichanTag tag = YomichanTag(
        tagName: key,
        frequencyName: tagMap["frequencyName"],
        sortingOrder: checkDouble(tagMap["sortingOrder"]),
        tagNotes: tagMap["tagNotes"],
        popularity: checkDouble(tagMap["popularity"]),
      );
      tags.add(tag);
    }
    return tags;
  }

  static List<YomichanTag> getTagsFromNames(
      List<YomichanTag> tagStore, List<String> tagNames) {
    List<YomichanTag> tags = [];
    for (YomichanTag tag in tagStore) {
      if (tagNames.contains(tag.tagName)) {
        tags.add(tag);
      }
    }
    return tags;
  }

  static List<String> getMeaningTagNames(DictionaryEntry entry) {
    return List.castFrom(jsonDecode(jsonDecode(entry.extra)["meaningTags"]));
  }

  static List<YomichanTag> getTermTagsFromEntry(
      DictionaryEntry entry, List<YomichanTag> tagStore) {
    List<String> tagNames =
        List.castFrom(jsonDecode(jsonDecode(entry.extra)["termTags"]));

    return getTagsFromNames(tagStore, tagNames);
  }

  static List<YomichanTag> getMeaningTagsFromEntry(
      DictionaryEntry entry, List<YomichanTag> tagStore) {
    List<String> tagNames =
        List.castFrom(jsonDecode(jsonDecode(entry.extra)["meaningTags"]));

    return getTagsFromNames(tagStore, tagNames);
  }

  String tagsToJson(List<YomichanTag> tags) {
    Map<String, String> metadata = {};

    for (YomichanTag _ in tags) {
      String key = tagName;
      String value = jsonEncode({
        "frequencyName": frequencyName,
        "sortingOrder": sortingOrder,
        "tagNotes": tagNotes,
        "popularity": popularity,
      });

      metadata[key] = value;
    }

    return jsonEncode(metadata);
  }

  static double getPopularitySum(List<YomichanTag> tags) {
    double sum = 0;
    for (YomichanTag tag in tags) {
      sum += tag.popularity;
    }

    return sum;
  }

  static int getTagCount(List<YomichanTag> tags) {
    int sum = 0;
    for (YomichanTag _ in tags) {
      sum += 1;
    }

    return sum;
  }
}

DictionaryWidget widgetDisplayEnhancementYomichanTermBank({
  required BuildContext context,
  required DictionaryEntry dictionaryEntry,
  required DictionaryFormat dictionaryFormat,
  required Dictionary dictionary,
  required bool selectable,
}) {
  return YomichanTermBankFormatWidget(
    dictionaryEntry: dictionaryEntry,
    dictionary: dictionary,
    dictionaryFormat: dictionaryFormat,
    context: context,
    selectable: selectable,
  );
}

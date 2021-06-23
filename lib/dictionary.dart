import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:jidoujisho/pitch.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:path/path.dart' as path;
import 'package:unofficial_jisho_api/api.dart';

import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/util.dart';
import 'package:jidoujisho/pitch.dart';

class DictionaryEntry {
  String word;
  String reading;
  String meaning;
  String searchTerm;
  List<PitchAccentInformation> pitchAccentEntries;

  DictionaryEntry({
    this.word,
    this.reading,
    this.meaning,
    this.searchTerm,
    this.pitchAccentEntries = const [],
  });

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> entriesMaps = [];
    for (int i = 0; i < pitchAccentEntries.length; i++) {
      entriesMaps.add(pitchAccentEntries[i].toMap());
    }

    return {
      "word": this.word,
      "reading": this.reading,
      "meaning": this.meaning,
      "searchTerm": this.searchTerm,
      "pitchAccentEntries": jsonEncode(entriesMaps),
    };
  }

  DictionaryEntry.fromMap(Map<String, dynamic> map) {
    List<dynamic> entriesMaps =
        (jsonDecode(map['pitchAccentEntries']) as List<dynamic>);
    List<PitchAccentInformation> entriesFromMap = [];
    entriesMaps.forEach((map) {
      PitchAccentInformation entry = PitchAccentInformation.fromMap(map);
      entriesFromMap.add(entry);
    });

    this.word = map['word'];
    this.reading = map['reading'];
    this.meaning = map['meaning'];
    this.searchTerm = map['searchTerm'];
    this.pitchAccentEntries = entriesFromMap;
  }

  @override
  String toString() {
    return "DictionaryEntry ($word)";
  }

  @override
  bool operator ==(Object other) =>
      other is DictionaryEntry &&
      this.word == other.word &&
      this.reading == other.reading &&
      this.meaning == other.meaning;

  @override
  int get hashCode =>
      this.word.hashCode ^ this.reading.hashCode ^ this.meaning.hashCode;
}

class VideoContext {
  String dataSource;
  int position;
}

class DictionaryHistoryEntry {
  List<DictionaryEntry> entries;
  String searchTerm;
  int swipeIndex;
  String contextDataSource;
  int contextPosition;

  DictionaryHistoryEntry({
    this.entries,
    this.searchTerm,
    this.swipeIndex,
    this.contextDataSource,
    this.contextPosition,
  });

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> entriesMaps = [];
    for (int i = 0; i < entries.length; i++) {
      entriesMaps.add(entries[i].toMap());
    }

    return {
      "entries": jsonEncode(entriesMaps),
      "searchTerm": searchTerm,
      "swipeIndex": swipeIndex,
      "contextDataSource": contextDataSource,
      "contextPosition": contextPosition,
    };
  }

  DictionaryHistoryEntry.fromMap(Map<String, dynamic> map) {
    List<dynamic> entriesMaps = (jsonDecode(map['entries']) as List<dynamic>);
    List<DictionaryEntry> entriesFromMap = [];
    entriesMaps.forEach((map) {
      DictionaryEntry entry = DictionaryEntry.fromMap(map);
      entriesFromMap.add(entry);
    });

    this.entries = entriesFromMap;
    this.searchTerm = map['searchTerm'];
    this.swipeIndex = map['swipeIndex'] as int;
    this.contextDataSource = map['contextDataSource'] as String ?? "-1";
    this.contextPosition = map['contextPosition'] as int ?? -1;
  }

  @override
  bool operator ==(Object other) =>
      other is DictionaryHistoryEntry &&
      listEquals(this.entries, other.entries) &&
      this.searchTerm == other.searchTerm;

  @override
  int get hashCode => super.hashCode;
}

List<DictionaryEntry> importCustomDictionary() {
  List<DictionaryEntry> entries = [];

  if (!getTermBankDirectory().existsSync()) {
    getTermBankDirectory().createSync(recursive: true);
  }

  for (int i = 0; i < 999; i++) {
    String outputPath =
        path.join(getTermBankDirectory().path, "term_bank_$i.json");
    File dictionaryFile = File(outputPath);

    if (dictionaryFile.existsSync()) {
      List<dynamic> dictionary = jsonDecode(dictionaryFile.readAsStringSync());
      dictionary.forEach((entry) {
        entries.add(DictionaryEntry(
          word: entry[0].toString(),
          reading: entry[1].toString(),
          meaning: entry[5].toString(),
        ));
      });
    }
  }

  return entries;
}

DictionaryEntry getEntryFromJishoResult(JishoResult result, String searchTerm) {
  String removeLastNewline(String n) => n = n.substring(0, n.length - 2);
  bool hasDuplicateReading(String readings, String reading) =>
      readings.contains("$reading; ");

  List<JishoJapaneseWord> words = result.japanese;
  List<JishoWordSense> senses = result.senses;

  List<JishoJapaneseWord> duplicates = [];
  words.forEach((word) {
    String reading = word.reading;

    if (reading != null) {
      if (reading == result.slug) {
        duplicates.add(word);
      }
    }
  });

  for (JishoJapaneseWord word in duplicates) {
    words.remove(word);
  }

  String exportTerm = "";
  String exportReadings = "";
  String exportMeanings = "";

  words.forEach((word) {
    String term = word.word;
    String reading = word.reading;

    if (term == null) {
      exportTerm += "";
    } else {
      if (!hasDuplicateReading(exportTerm, term)) {
        exportTerm = "$exportTerm$term; ";
      }
    }
    if (!hasDuplicateReading(exportReadings, reading)) {
      exportReadings = "$exportReadings$reading; ";
    }
  });

  if (exportReadings.isNotEmpty) {
    exportReadings = removeLastNewline(exportReadings);
  }
  if (exportTerm.isNotEmpty) {
    exportTerm = removeLastNewline(exportTerm);
  } else {
    if (result.slug.isNotEmpty && result.slug.length != 24) {
      exportTerm = result.slug;
    } else {
      exportTerm = exportReadings;
    }
  }

  if (exportReadings == "null" ||
      exportReadings == searchTerm && result.slug == exportReadings ||
      exportTerm == exportReadings) {
    exportReadings = "";
  }

  int i = 0;

  senses.forEach(
    (sense) {
      i++;

      List<String> allParts = sense.parts_of_speech;
      List<String> allDefinitions = sense.english_definitions;

      String partsOfSpeech = "";
      String definitions = "";

      allParts.forEach(
        (part) => {partsOfSpeech = "$partsOfSpeech $part; "},
      );
      allDefinitions.forEach(
        (definition) => {definitions = "$definitions $definition; "},
      );

      if (partsOfSpeech.isNotEmpty) {
        partsOfSpeech = removeLastNewline(partsOfSpeech);
      }
      if (definitions.isNotEmpty) {
        definitions = removeLastNewline(definitions);
      }

      String numberTag = getBetterNumberTag("$i)");

      exportMeanings =
          "$exportMeanings$numberTag $definitions -$partsOfSpeech \n";
    },
  );
  exportMeanings = removeLastNewline(exportMeanings);

  return DictionaryEntry(
    word: exportTerm ?? searchTerm,
    reading: exportReadings,
    meaning: exportMeanings,
  );
}

bool searchTermIllegal(searchTerm) {
  if (searchTerm.trim().isEmpty) {
    return true;
  }
  switch (searchTerm) {
    case "「":
    case "」":
    case "。":
    case "、":
    case "『":
    case "』":
    case "！":
    case "…":
    case "‥":
    case "・":
    case "〽":
    case "〜":
    case "：":
    case "？":
    case "♪":
    case "，":
    case "（":
    case "）":
    case "｛":
    case "｝":
    case "［":
    case "］":
    case "【":
    case "】":
    case "｛":
    case "｝":
      return true;
  }
  return false;
}

Future<DictionaryHistoryEntry> getWordDetails({
  String searchTerm,
  String contextDataSource,
  int contextPosition,
  String searchTermOverride = "",
}) async {
  if (searchTermIllegal(searchTerm)) {
    return DictionaryHistoryEntry(
      entries: [],
      searchTerm: searchTermOverride.trim(),
      swipeIndex: 0,
      contextDataSource: contextDataSource,
      contextPosition: contextPosition,
    );
  }

  List<DictionaryEntry> entries = [];
  if (searchTermOverride.isEmpty) {
    searchTermOverride = searchTerm;
  }

  List<JishoResult> results = (await searchForPhrase(searchTerm)).data;
  if (results.isEmpty) {
    var client = http.Client();
    http.Response response =
        await client.get(Uri.parse('https://jisho.org/search/$searchTerm'));

    var document = parser.parse(response.body);

    var breakdown = document.getElementsByClassName("fact grammar-breakdown");
    if (breakdown.isEmpty) {
      return DictionaryHistoryEntry(
        entries: [],
        searchTerm: searchTermOverride.trim(),
        swipeIndex: 0,
        contextDataSource: contextDataSource,
        contextPosition: contextPosition,
      );
    } else {
      String inflection = breakdown.first.querySelector("a").text;
      return getWordDetails(
        searchTerm: inflection.trim(),
        searchTermOverride: searchTermOverride.trim(),
        contextDataSource: contextDataSource,
        contextPosition: contextPosition,
      );
    }
  }

  for (JishoResult result in results) {
    DictionaryEntry entry = getEntryFromJishoResult(result, searchTerm);
    entries.add(entry);
  }

  for (DictionaryEntry entry in entries) {
    entry.searchTerm = searchTerm;
  }

  // Fixes inflections
  if (entries.first.word.contains(searchTerm) &&
          entries.first.word != searchTerm ||
      entries.first.reading.contains(searchTerm) &&
          entries.first.reading != searchTerm) {
    var client = http.Client();
    http.Response response =
        await client.get(Uri.parse('https://jisho.org/search/$searchTerm'));

    var document = parser.parse(response.body);

    var breakdown = document.getElementsByClassName("fact grammar-breakdown");
    if (breakdown.isNotEmpty) {
      String inflection = breakdown.first.querySelector("a").text;

      if (searchTerm != inflection) {
        return getWordDetails(
          searchTerm: inflection.trim(),
          searchTermOverride: searchTermOverride.trim(),
          contextDataSource: contextDataSource,
          contextPosition: contextPosition,
        );
      }
    }
  }

  return DictionaryHistoryEntry(
    entries: entries,
    searchTerm: searchTermOverride.trim(),
    swipeIndex: 0,
    contextDataSource: contextDataSource,
    contextPosition: contextPosition,
  );
}

Future<DictionaryHistoryEntry> getMonolingualWordDetails({
  String searchTerm,
  bool recursive,
  String contextDataSource = "-1",
  int contextPosition = -1,
  String searchTermOverride = "",
}) async {
  List<DictionaryEntry> entries = [];
  if (searchTermIllegal(searchTerm)) {
    return DictionaryHistoryEntry(
      entries: [],
      searchTerm: searchTermOverride.trim(),
      swipeIndex: 0,
      contextDataSource: contextDataSource,
      contextPosition: contextPosition,
    );
  }

  if (searchTermOverride.isEmpty) {
    searchTermOverride = searchTerm;
  }

  var client = http.Client();
  http.Response response = await client.get(Uri.parse(
      'https://sakura-paris.org/dict/?api=1&q=$searchTerm&dict=大辞泉&type=2&romaji=1'));

  if (response.body != "[]") {
    entries =
        sakuraJsonToDictionaryEntries(jsonDecode(response.body), searchTerm);
  }

  if (entries == null || entries.isEmpty) {
    if (recursive) {
      return DictionaryHistoryEntry(
        entries: [],
        searchTerm: searchTermOverride.trim(),
        swipeIndex: 0,
        contextDataSource: contextDataSource,
        contextPosition: contextPosition,
      );
    } else {
      DictionaryHistoryEntry bilingualResults = await getWordDetails(
        searchTerm: searchTerm.trim(),
        contextDataSource: contextDataSource,
        contextPosition: contextPosition,
      );
      String newSearchTerm = bilingualResults.entries.first.word;
      if (newSearchTerm.contains(";")) {
        newSearchTerm = newSearchTerm.split(";").first;
      }

      return getMonolingualWordDetails(
        searchTerm: newSearchTerm.trim(),
        searchTermOverride: searchTermOverride.trim(),
        recursive: true,
        contextDataSource: contextDataSource,
        contextPosition: contextPosition,
      );
    }
  }

  return DictionaryHistoryEntry(
    entries: entries,
    searchTerm: searchTermOverride.trim(),
    swipeIndex: 0,
    contextDataSource: contextDataSource,
    contextPosition: contextPosition,
  );
}

List<DictionaryEntry> sakuraJsonToDictionaryEntries(
    Map<String, dynamic> json, String searchTerm) {
  List<DictionaryEntry> entries = [];

  List<dynamic> words = json['words'];
  words.forEach((word) {
    Map<String, dynamic> json = word as Map<String, dynamic>;
    if (!json['text'].contains('ＪＩＳ')) {
      DictionaryEntry entry = sakuraJsonToDictionaryEntry(json, searchTerm);
      if (entry.word.isNotEmpty && entry.reading.isNotEmpty) {
        entries.add(entry);
      }
    }
  });

  return entries;
}

DictionaryEntry sakuraJsonToDictionaryEntry(
    Map<String, dynamic> json, String searchTerm) {
  String word = "";
  String reading = "";
  String meaning = "";

  String wordAndReadingRaw = json['heading'];
  String meaningRaw = json['text'];

  List<String> wordSanitized = [];
  List<String> readingSanitized = [];

  if (wordAndReadingRaw.contains("【") && wordAndReadingRaw.contains("】")) {
    word = wordAndReadingRaw.substring(wordAndReadingRaw.indexOf("【"));
    word = word.substring(1, word.indexOf("】"));
    reading = wordAndReadingRaw.substring(0, wordAndReadingRaw.indexOf("【"));

    wordSanitized = sanitizeGooForPitchMatch(word.trim(), true);
    readingSanitized = sanitizeGooForPitchMatch(reading.trim(), false);
  } else {
    word = wordAndReadingRaw;
    wordSanitized = sanitizeGooForPitchMatch(word.trim(), false);
  }

  word = "";
  for (int i = 0; i < wordSanitized.length; i++) {
    word += wordSanitized[i];
    if (i != wordSanitized.length - 1) {
      word += "; ";
    }
  }
  reading = "";
  for (int i = 0; i < readingSanitized.length; i++) {
    reading += readingSanitized[i];
    if (i != readingSanitized.length - 1) {
      reading += "; ";
    }
  }

  word = word.replaceAll(RegExp(r'{{.*?}}'), "");
  reading = reading.replaceAll(RegExp(r'{{.*?}}'), "");

  if (word.isEmpty && reading.isNotEmpty) {
    word = reading;
    reading = "";
  }

  meaning = meaningRaw.substring(meaningRaw.indexOf("\n"));
  meaning = meaning.replaceAll(RegExp(r"\[subscript\].*?\[\/subscript\]"), "");
  meaning = meaning.replaceAll(RegExp(r'\[.*?\]'), "");
  meaning = meaning.replaceAll(RegExp(r'{{.*?}}'), "");
  meaning = getMonolingualNumberTag(meaning);
  meaning = meaning.trim();

  return DictionaryEntry(
    word: word,
    reading: reading,
    meaning: meaning,
    searchTerm: searchTerm,
  );
}

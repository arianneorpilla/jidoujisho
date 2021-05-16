import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:jidoujisho/preferences.dart';
import 'package:path/path.dart' as path;
import 'package:unofficial_jisho_api/api.dart';

import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/util.dart';

class DictionaryEntry {
  String word;
  String reading;
  String meaning;
  String searchTerm;

  DictionaryEntry({
    this.word,
    this.reading,
    this.meaning,
    this.searchTerm,
  });

  Map<String, dynamic> toMap() {
    return {
      "word": this.word,
      "reading": this.reading,
      "meaning": this.meaning,
      "searchTerm": this.searchTerm,
    };
  }

  DictionaryEntry.fromMap(Map<String, dynamic> map) {
    this.word = map['word'];
    this.reading = map['reading'];
    this.meaning = map['meaning'];
    this.searchTerm = map['searchTerm'];
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

List<String> getAllImportedWords() {
  List<String> allWords = [];
  for (DictionaryEntry entry in gCustomDictionary) {
    allWords.add(entry.word);
  }

  return allWords;
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

    if (!hasDuplicateReading(exportTerm, term)) {
      exportTerm = "$exportTerm$term; ";
    }
    if (!hasDuplicateReading(exportReadings, reading)) {
      exportReadings = "$exportReadings$reading; ";
    }

    if (term == null) {
      exportTerm = "";
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

  DictionaryEntry dictionaryEntry;

  // print("SEARCH TERM: $searchTerm");
  // print("EXPORT TERM: $exportTerm");

  if (gCustomDictionary.isEmpty) {
    dictionaryEntry = DictionaryEntry(
      word: exportTerm ?? searchTerm,
      reading: exportReadings,
      meaning: exportMeanings,
    );
  } else {
    int resultIndex;

    final searchResult = gCustomDictionaryFuzzy.search(searchTerm, 1);
    // print("SEARCH RESULT: $searchResult");

    if (searchResult.isNotEmpty && searchResult.first.score == 0) {
      resultIndex = searchResult.first.matches.first.arrayIndex;

      dictionaryEntry = DictionaryEntry(
        word: gCustomDictionary[resultIndex].word,
        reading: gCustomDictionary[resultIndex].reading,
        meaning: gCustomDictionary[resultIndex].meaning,
      );

      return dictionaryEntry;
    } else {
      words.forEach((word) {
        String term = word.word;

        if (term != null) {
          final termResult = gCustomDictionaryFuzzy.search(term, 1);

          if (termResult.isNotEmpty && termResult.first.score == 0.0) {
            resultIndex = termResult.first.matches.first.arrayIndex;
            print("TERM RESULT: $searchResult");
          }
        }
      });
    }

    if (resultIndex == null) {
      resultIndex = searchResult.first.matches.first.arrayIndex;
    }

    dictionaryEntry = DictionaryEntry(
      word: exportTerm ?? searchTerm,
      reading: exportReadings,
      meaning: exportMeanings,
    );
  }

  return dictionaryEntry;
}

Future<DictionaryHistoryEntry> getWordDetails({
  String searchTerm,
  String contextDataSource,
  int contextPosition,
}) async {
  List<DictionaryEntry> entries = [];

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
        searchTerm: searchTerm.trim(),
        swipeIndex: 0,
        contextDataSource: contextDataSource,
        contextPosition: contextPosition,
      );
    } else {
      String inflection = breakdown.first.querySelector("a").text;
      return getWordDetails(
        searchTerm: inflection.trim(),
        contextDataSource: contextDataSource,
        contextPosition: contextPosition,
      );
    }
  }

  if (gCustomDictionary.isNotEmpty) {
    List<JishoResult> onlyFirst = [];
    onlyFirst.add(results.first);
    results = onlyFirst;
  }

  for (JishoResult result in results) {
    DictionaryEntry entry = getEntryFromJishoResult(result, searchTerm);
    entries.add(entry);
  }

  for (DictionaryEntry entry in entries) {
    entry.searchTerm = searchTerm;
  }

  return DictionaryHistoryEntry(
    entries: entries,
    searchTerm: searchTerm.trim(),
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
  List<JishoResult> results = (await searchForPhrase(searchTerm)).data;
  List<DictionaryEntry> entries = [];

  if (searchTermOverride.isEmpty) {
    searchTermOverride = searchTerm;
  }

  var client = http.Client();
  http.Response response = await client
      .get(Uri.parse('https://dictionary.goo.ne.jp/srch/jn/$searchTerm/m1u/'));
  var document = parser.parse(response.body);
  bool multiDefinition = document.body.innerHtml.contains("で一致する言葉");
  bool empty = document.body.innerHtml.contains("一致する情報は見つかりませんでした");

  if (empty) {
    if (recursive) {
      return DictionaryHistoryEntry(
        entries: entries,
        searchTerm: searchTermOverride.trim(),
        swipeIndex: 0,
        contextDataSource: contextDataSource,
        contextPosition: contextPosition,
      );
    }

    searchTerm = getEntryFromJishoResult(results.first, searchTerm)
        .word
        .split(";")
        .first;
    return getMonolingualWordDetails(
      searchTerm: searchTerm.trim(),
      searchTermOverride: searchTermOverride.trim(),
      recursive: true,
      contextDataSource: contextDataSource,
      contextPosition: contextPosition,
    );
  }

  if (multiDefinition) {
    List<String> wordLinks = [];
    List<Future<http.Response>> futureResponses = [];
    List<http.Response> responses = [];

    document
        .getElementById("NR-main-in")
        .getElementsByTagName("a")
        .forEach((element) {
      String link = element.attributes["href"];
      if (link.contains("/word/")) {
        wordLinks.add(link);
      }
    });

    for (int i = 0; i < wordLinks.length; i++) {
      String wordLink = wordLinks[i];

      futureResponses
          .add(client.get(Uri.parse('https://dictionary.goo.ne.jp/$wordLink')));
    }

    responses = await Future.wait(futureResponses);

    for (int i = 0; i < responses.length; i++) {
      http.Response wordResponse = responses[i];
      var firstResultDocument = parser.parse(wordResponse.body);
      List<dom.Element> wordAndReadingElements =
          firstResultDocument.getElementsByClassName("nolink title paddding");
      List<dom.Element> meaningElements = firstResultDocument
          .getElementsByClassName("content-box contents_area meaning_area p10");

      if (wordAndReadingElements == null || meaningElements == null) {
        continue;
      }

      for (int i = 0; i < meaningElements.length; i++) {
        if (entries.length >= 20) {
          return DictionaryHistoryEntry(
            entries: entries,
            searchTerm: searchTermOverride.trim(),
            swipeIndex: 0,
            contextDataSource: contextDataSource,
            contextPosition: contextPosition,
          );
        }

        DictionaryEntry singleEntry = getEntryFromGooElement(
          meaningElements[i],
          wordAndReadingElements[i],
          searchTerm,
        );

        if (entries.isEmpty) {
          entries.add(singleEntry);
        } else {
          bool found = false;
          for (int i = 0; i < entries.length; i++) {
            DictionaryEntry entry = entries[i];

            if (singleEntry.meaning == entry.meaning &&
                singleEntry.reading == entry.reading &&
                singleEntry.word == entry.word) {
              found = true;
            }
          }

          if (!found) {
            entries.add(singleEntry);
          }
        }
      }
    }
  } else {
    List<dom.Element> wordAndReadingElements =
        document.getElementsByClassName("nolink title paddding");
    List<dom.Element> meaningElements = document
        .getElementsByClassName("content-box contents_area meaning_area p10");

    for (int i = 0; i < meaningElements.length; i++) {
      DictionaryEntry singleEntry = getEntryFromGooElement(
        meaningElements[i],
        wordAndReadingElements[i],
        searchTerm,
      );
      entries.add(singleEntry);
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

DictionaryEntry getEntryFromGooElement(
  dom.Element meaningElement,
  dom.Element wordAndReadingElement,
  String searchTerm,
) {
  String word = "";
  String reading = "";
  String meaning = "";

  String wordAndReadingRaw =
      wordAndReadingElement.innerHtml.replaceAll(RegExp(r"<[^>]*>"), "").trim();

  word = wordAndReadingRaw.replaceAll("の解説", "").trim();

  if (wordAndReadingRaw.contains("【") && wordAndReadingRaw.contains("】")) {
    word = wordAndReadingRaw.substring(wordAndReadingRaw.indexOf("【"));
    word = word.substring(1, word.indexOf("】"));
    reading = wordAndReadingRaw.substring(0, wordAndReadingRaw.indexOf("【"));
  }

  List<dom.Element> meaningChildren = meaningElement.children.first.children;
  List<String> meaningChildrenLines = [];
  for (int i = 0; i < meaningChildren.length; i++) {
    meaningChildrenLines.add(
        meaningChildren[i].innerHtml.replaceAll(RegExp(r"<[^>]*>"), "").trim());
  }
  meaningChildrenLines.removeWhere((line) => line.isEmpty);
  meaning = meaningChildrenLines.join("\n\n");

  word = word.trim();
  reading = reading.trim();
  meaning = meaning.trim();

  print(word);
  print(reading);
  print(meaning);

  DictionaryEntry singleEntry = DictionaryEntry(
    word: word,
    reading: reading,
    meaning: meaning,
    searchTerm: searchTerm,
  );

  return singleEntry;
}

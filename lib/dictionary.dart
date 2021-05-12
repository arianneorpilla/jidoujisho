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
  String contextDataSource = "-1",
  int contextPosition = -1,
}) async {
  List<DictionaryEntry> entries = [];

  var client = http.Client();
  http.Response response = await client.get(Uri.parse(
      'https://krdict.korean.go.kr/eng/dicSearch/search?wordMatchFlag=N&mainSearchWord=$searchTerm&currentPage=1&sort=C&searchType=W&proverbType=&exaType=&ParaWordNo=&nation=eng&nationCode=6&viewType=M&blockCount=10&viewTypes=on'));
  var document = parser.parse(response.body);

  if (document.body.innerHtml.contains("No result for ")) {
    return DictionaryHistoryEntry(
      entries: entries,
      searchTerm: searchTerm.trim(),
      swipeIndex: 0,
      contextDataSource: contextDataSource,
      contextPosition: contextPosition,
    );
  }

  List<dom.Element> searchResultBox =
      document.getElementsByClassName("search_result mt25 printArea ");

  List<dom.Element> searchResults = searchResultBox.first.children;

  for (int i = 0; i < searchResults.length; i++) {
    DictionaryEntry entry = getEntryFromKrDictElement(
      searchResults[i],
      searchTerm,
    );

    entries.add(entry);
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
  String contextDataSource = "-1",
  int contextPosition = -1,
}) async {
  List<DictionaryEntry> entries = [];

  var client = http.Client();
  http.Response response = await client.get(Uri.parse(
      'https://krdict.korean.go.kr/eng/dicSearch/search?wordMatchFlag=N&mainSearchWord=$searchTerm&currentPage=1&sort=W&searchType=W&proverbType=&exaType=&ParaWordNo=&nation=eng&nationCode=6&viewType=K&blockCount=10&viewTypes=on'));
  var document = parser.parse(response.body);

  if (document.body.innerHtml.contains("No result for ")) {
    return DictionaryHistoryEntry(
      entries: entries,
      searchTerm: searchTerm.trim(),
      swipeIndex: 0,
      contextDataSource: contextDataSource,
      contextPosition: contextPosition,
    );
  }

  List<dom.Element> searchResultBox =
      document.getElementsByClassName("search_result mt25 printArea ");

  List<dom.Element> searchResults = searchResultBox.first.children;

  for (int i = 0; i < searchResults.length; i++) {
    DictionaryEntry entry = getMonolingualEntryFromKrDictElement(
      searchResults[i],
      searchTerm,
    );

    entries.add(entry);
  }

  return DictionaryHistoryEntry(
    entries: entries,
    searchTerm: searchTerm.trim(),
    swipeIndex: 0,
    contextDataSource: contextDataSource,
    contextPosition: contextPosition,
  );
}

DictionaryEntry getEntryFromKrDictElement(
  dom.Element searchResult,
  String searchTerm,
) {
  String word = "";
  String reading = "";
  String meaning = "";

  List<dom.Element> wordElements =
      searchResult.getElementsByClassName("word_type1_17");

  if (wordElements.isNotEmpty) {
    dom.Element wordElement =
        searchResult.getElementsByClassName("word_type1_17").first;
    for (dom.Element child in wordElement.children) {
      wordElement.children.remove(child);
    }

    word = wordElement.innerHtml.replaceAll(RegExp(r"<[^>]*>"), "").trim();
  }

  List<dom.Element> readingElements =
      searchResult.getElementsByClassName("search_sub");

  if (readingElements.isNotEmpty) {
    dom.Element readingElement =
        searchResult.getElementsByClassName("search_sub").first;
    for (dom.Element child in readingElement.children) {
      readingElement.children.remove(child);
    }

    reading =
        readingElement.innerHtml.replaceAll(RegExp(r"<[^>]*>"), "").trim();
  }

  List<dom.Element> meaningElements = searchResult.getElementsByTagName("dd");

  meaningElements.removeWhere((element) => element.classes.contains("allview"));

  if (readingElements.isNotEmpty) {
    for (int i = 0; i < meaningElements.length; i++) {
      String addendum = meaningElements[i]
          .innerHtml
          .replaceAll("\"View All \"", "")
          .replaceAll(RegExp(r"<[^>]*>"), "")
          .replaceAll(
              "																					\n																				\n																				\n																					\n																						",
              "")
          .trim();

      List<String> addendumLines = [addendum];
      if (addendum.contains("\n")) {
        addendumLines = addendum.split("\n");
      }

      String couldBeNumber = addendumLines[0];

      if (addendum.contains("(no equivalent expression)")) {
        meaning += "(no equivalent expression)";
        meaning += "\n";
        continue;
      }
      if (addendumLines.length == 1) {
        print(addendumLines);
        meaning += addendum;
        meaning += "\n";
        continue;
      }

      if (couldBeNumber.length == 2 ||
          couldBeNumber.length == 3 &&
              couldBeNumber[couldBeNumber.length - 1] == "." &&
              int.tryParse(
                      couldBeNumber.substring(0, couldBeNumber.length - 1)) !=
                  null) {
        addendumLines[0] = addendumLines[0].replaceAll(".", ") ");
        String newAddendum = "";

        for (int i = 0; i < addendumLines.length; i++) {
          newAddendum += addendumLines[i];
          if (i == 0) {
            continue;
          }
          newAddendum += "\n";
        }

        addendum = newAddendum;
        meaning += addendum;
      } else {
        meaning += addendum;
        meaning += "\n";
      }
    }
  }

  if (word == reading) {
    reading = "";
  }

  DictionaryEntry singleEntry = DictionaryEntry(
    word: word,
    reading: reading,
    meaning: meaning,
    searchTerm: searchTerm,
  );

  return singleEntry;
}

DictionaryEntry getMonolingualEntryFromKrDictElement(
  dom.Element searchResult,
  String searchTerm,
) {
  String word = "";
  String reading = "";
  String meaning = "";
  String partOfSpeech = "";

  List<dom.Element> wordElements =
      searchResult.getElementsByClassName("word_type1_17");

  if (wordElements.isNotEmpty) {
    dom.Element wordElement =
        searchResult.getElementsByClassName("word_type1_17").first;
    for (dom.Element child in wordElement.children) {
      wordElement.children.remove(child);
    }

    word = wordElement.innerHtml.replaceAll(RegExp(r"<[^>]*>"), "").trim();
  }

  List<dom.Element> readingElements =
      searchResult.getElementsByClassName("search_sub");

  if (readingElements.isNotEmpty) {
    dom.Element readingElement =
        searchResult.getElementsByClassName("search_sub").first;
    for (dom.Element child in readingElement.children) {
      readingElement.children.remove(child);
    }

    reading =
        readingElement.innerHtml.replaceAll(RegExp(r"<[^>]*>"), "").trim();
  }

  List<dom.Element> partOfSpeechElements =
      searchResult.getElementsByClassName("word_att_type1");

  if (partOfSpeechElements.isNotEmpty) {
    partOfSpeech = searchResult
        .getElementsByClassName("word_att_type1")
        .first
        .text
        .replaceAll(RegExp(r"<[^>]*>"), "")
        .trim();

    partOfSpeech =
        partOfSpeech.substring(0, partOfSpeech.indexOf("」") + 1).trim() +
            "\n\n";
  }

  List<dom.Element> meaningElements = searchResult.getElementsByTagName("dd");

  if (readingElements.isNotEmpty) {
    for (int i = 0; i < meaningElements.length; i++) {
      String addendum = meaningElements[i]
          .innerHtml
          .replaceAll(RegExp(r"<[^>]*>"), "")
          .replaceAll(" \n																\n																", " ")
          .trim();

      List<String> addendumLines = [addendum];
      if (addendum.contains("\n")) {
        addendumLines = addendum.split("\n");
      }

      String couldBeNumber = addendumLines[0];

      if (couldBeNumber.length == 2 ||
          couldBeNumber.length == 3 &&
              couldBeNumber[couldBeNumber.length - 1] == "." &&
              int.tryParse(
                      couldBeNumber.substring(0, couldBeNumber.length - 1)) !=
                  null) {
        addendumLines[0] = addendumLines[0].replaceAll(".", ") ");
        String newAddendum = "";

        for (int i = 0; i < addendumLines.length; i++) {
          newAddendum += addendumLines[i];
          if (i == 0) {
            continue;
          }
          newAddendum += "\n";
        }

        addendum = newAddendum;
        meaning += addendum;
      } else {
        meaning += addendum;
        meaning += "\n";
      }
    }
  }

  if (word == reading) {
    reading = "";
  }

  DictionaryEntry singleEntry = DictionaryEntry(
    word: word,
    reading: reading,
    meaning: partOfSpeech + meaning,
    searchTerm: searchTerm,
  );

  return singleEntry;
}

Future<DictionaryHistoryEntry> getNaverWordDetails({
  String searchTerm,
  String contextDataSource = "-1",
  int contextPosition = -1,
}) async {
  List<DictionaryEntry> entries = [];

  http.Client client = http.Client();
  http.Response response = await client
      .get(Uri.parse(
          'https://dict.naver.com/enendict/english/#/search?query=test'))
      .timeout(Duration(seconds: 1));

  var document = parser.parse(response.body);
  print("RESPONSE" + document.body.outerHtml);
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
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
}

List<DictionaryEntry> importCustomDictionary() {
  List<DictionaryEntry> entries = [];

  for (int i = 0; i < 999; i++) {
    String outputPath =
        "storage/emulated/0/Android/data/com.lrorpilla.jidoujisho/files/term_bank_$i.json";
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
    if (exportReadings.isNotEmpty) {
      exportTerm = exportReadings;
    } else {
      exportTerm = result.slug;
    }
  }

  if (exportReadings == "null" ||
      exportReadings == searchTerm && result.slug == exportReadings) {
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

      exportMeanings = "$exportMeanings$i) $definitions -$partsOfSpeech \n";
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

Future<List<DictionaryEntry>> getWordDetails(String searchTerm) async {
  List<DictionaryEntry> entries = [];

  List<JishoResult> results = (await searchForPhrase(searchTerm)).data;
  if (results.isEmpty) {
    var client = http.Client();
    http.Response response =
        await client.get(Uri.parse('https://jisho.org/search/$searchTerm'));

    var document = parser.parse(response.body);

    var breakdown = document.getElementsByClassName("fact grammar-breakdown");
    if (breakdown.isEmpty) {
      return [];
    } else {
      String inflection = breakdown.first.querySelector("a").text;
      return getWordDetails(inflection);
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
    entry.meaning = getBetterNumberTag(entry.meaning);
  }

  return entries;
}

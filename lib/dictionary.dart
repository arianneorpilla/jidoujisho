import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gx_file_picker/gx_file_picker.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/objectbox.g.dart';
import 'package:jidoujisho/pitch.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as path;
import 'package:unofficial_jisho_api/api.dart';

import 'package:jidoujisho/util.dart';

@Entity()
class DictionaryEntry {
  int id;
  String dictionarySource;
  @Index()
  String word;
  @Index()
  String reading;
  String meaning;
  double popularity;
  @Index()
  String searchTerm;
  List<String> termTags;
  List<String> definitionTags;

  List<String> meanings;

  List<YomichanTag> yomichanTermTags;
  List<List<YomichanTag>> yomichanDefinitionTags;

  int duplicateCount;
  String duplicateWorkingMeaning;

  List<PitchAccentInformation> pitchAccentEntries;

  DictionaryEntry({
    this.id = 0,
    this.word,
    this.reading,
    this.meaning,
    this.popularity,
    this.duplicateCount = 0,
    this.searchTerm,
    this.dictionarySource,
    this.termTags = const [],
    this.definitionTags = const [],
    this.pitchAccentEntries = const [],
    this.meanings = const [],
    this.yomichanTermTags = const [],
    this.yomichanDefinitionTags = const [],
  });

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> entriesMaps = [];
    for (int i = 0; i < pitchAccentEntries.length; i++) {
      entriesMaps.add(pitchAccentEntries[i].toMap());
    }

    List<Map<String, dynamic>> yomichanTagMaps = [];
    for (int i = 0; i < yomichanTermTags.length; i++) {
      yomichanTagMaps.add(yomichanTermTags[i].toMap());
    }

    List<List<Map<String, dynamic>>> yomichanDefinitionMaps = [];
    for (int i = 0; i < yomichanDefinitionTags.length; i++) {
      List<Map<String, dynamic>> yomichanTagMapList = [];
      yomichanDefinitionTags[i].forEach((definition) {
        yomichanTagMapList.add(definition.toMap());
      });
      yomichanDefinitionMaps.add(yomichanTagMapList);
    }

    return {
      "word": this.word,
      "reading": this.reading,
      "meaning": this.meaning,
      "popularity": this.popularity,
      "searchTerm": this.searchTerm,
      "dictionarySource": this.dictionarySource,
      "termTags": jsonEncode(termTags),
      "definitionTags": jsonEncode(definitionTags),
      "yomichanTermTags": jsonEncode(yomichanTagMaps),
      "yomichanDefinitionTags": jsonEncode(yomichanDefinitionMaps),
      "pitchAccentEntries": jsonEncode(entriesMaps),
      "meanings": jsonEncode(meanings),
    };
  }

  DictionaryEntry.fromMap(Map<String, dynamic> map) {
    List<dynamic> entriesMaps =
        (jsonDecode(map['pitchAccentEntries']) as List<dynamic>) ?? [];
    List<PitchAccentInformation> entriesFromMap = [];
    entriesMaps.forEach((map) {
      PitchAccentInformation entry = PitchAccentInformation.fromMap(map);
      entriesFromMap.add(entry);
    });

    List<dynamic> yomichanDefinitionTagMaps =
        (jsonDecode(map['yomichanDefinitionTags']) as List<dynamic>) ?? [];
    List<List<YomichanTag>> yomichanDefinitionTags = [];
    yomichanDefinitionTagMaps.forEach((list) {
      List<YomichanTag> yomichanTagList = [];
      list.forEach((map) {
        YomichanTag tag = YomichanTag.fromMap(map);
        yomichanTagList.add(tag);
      });
      yomichanDefinitionTags.add(yomichanTagList);
    });

    List<dynamic> yomichanTermTagMaps =
        (jsonDecode(map['yomichanTermTags']) as List<dynamic>) ?? [];
    List<YomichanTag> yomichanTermTags = [];
    yomichanTermTagMaps.forEach((map) {
      YomichanTag tag = YomichanTag.fromMap(map);
      yomichanTermTags.add(tag);
    });

    var termTagsJson = jsonDecode(map['termTags']);
    List<String> termTags =
        termTagsJson != null ? List.from(termTagsJson) : null;

    var definitionTagsJson = jsonDecode(map['definitionTags']);
    List<String> definitionTags =
        definitionTagsJson != null ? List.from(definitionTagsJson) : null;

    var meaningsJson = jsonDecode(map['meanings']);
    List<String> meanings =
        meaningsJson != null ? List.from(meaningsJson) : null;

    this.dictionarySource = map['dictionarySource'] as String;
    this.word = map['word'] as String;
    this.reading = map['reading'] as String;
    this.meaning = map['meaning'] as String;
    this.popularity = parsePopularity(map["popularity"]);
    this.searchTerm = map['searchTerm'];
    this.termTags = termTags;
    this.definitionTags = definitionTags;
    this.yomichanTermTags = yomichanTermTags;
    this.yomichanDefinitionTags = yomichanDefinitionTags;
    this.pitchAccentEntries = entriesFromMap;
    this.meanings = meanings;
  }

  List<Widget> generateTagWidgets(BuildContext context) {
    List<Widget> tagWidgets = [];

    this.yomichanTermTags.forEach((tag) {
      tagWidgets.add(
        GestureDetector(
          onTap: () {
            Fluttertoast.showToast(
              msg: "${tag.tagName} - ${tag.tagNotes}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: tag.getTagColor(),
              textColor: Colors.white,
              fontSize: 16.0,
            );
          },
          child: Container(
            child: Text(
              tag.tagName,
              style: TextStyle(
                fontSize: 11,
              ),
            ),
            color: tag.getTagColor(),
            padding: EdgeInsets.all(3),
          ),
        ),
      );
      tagWidgets.add(SizedBox(width: 5));
    });

    tagWidgets.removeLast();
    return tagWidgets;
  }

  Widget generateMeaningWidgetsDialog(BuildContext context,
      {bool selectable = false}) {
    if (gReservedDictionaryNames.contains(this.dictionarySource)) {
      return Text(
        "\n${this.meaning}\n",
        style: TextStyle(
          fontSize: 15,
        ),
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
      );
    }

    List<List<Widget>> definitionWidgets = [];
    yomichanDefinitionTags.forEach((tagList) {
      List<Widget> tagWidgets = [];
      tagList.forEach((tag) {
        tagWidgets.add(
          GestureDetector(
            onTap: () {
              Fluttertoast.showToast(
                msg: "${tag.tagName} - ${tag.tagNotes}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: tag.getTagColor(),
                textColor: Colors.white,
                fontSize: 16.0,
              );
            },
            child: Container(
              child: Text(
                tag.tagName,
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
              color: tag.getTagColor(),
              padding: EdgeInsets.all(3),
            ),
          ),
        );
        tagWidgets.add(SizedBox(width: 5));
      });
      definitionWidgets.add(tagWidgets);
    });

    List<Widget> meaningWidgets = [];

    for (int i = 0; i < meanings.length; i++) {
      List<InlineSpan> inlineSpanWidgets = [];
      for (int j = 0; j < definitionWidgets[i].length; j++) {
        inlineSpanWidgets.add(
          WidgetSpan(
            child: definitionWidgets[i][j],
          ),
        );
      }

      inlineSpanWidgets.add(
        TextSpan(
          text: meanings[i],
        ),
      );

      meaningWidgets.add(
        SizedBox(height: (i == 0) ? 10 : 5),
      );
      if (selectable) {
        meaningWidgets.add(
          SelectableText.rich(
            TextSpan(
              text: '',
              style: TextStyle(
                fontSize: 15,
              ),
              children: inlineSpanWidgets,
            ),
          ),
        );
      } else {
        meaningWidgets.add(
          Text.rich(
            TextSpan(
              text: '',
              style: TextStyle(
                fontSize: 15,
              ),
              children: inlineSpanWidgets,
            ),
          ),
        );
      }
      if (i == meanings.length - 1) {
        meaningWidgets.add(
          SizedBox(height: 10),
        );
      }
    }

    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: meaningWidgets,
        ),
      ),
    );
  }

  Widget generateMeaningWidgetsMenu(BuildContext context) {
    if (gReservedDictionaryNames.contains(this.dictionarySource)) {
      return Text(
        "\n${this.meaning}\n",
        style: TextStyle(
          fontSize: 15,
        ),
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
      );
    }

    List<List<Widget>> definitionWidgets = [];
    yomichanDefinitionTags.forEach((tagList) {
      List<Widget> tagWidgets = [];
      tagList.forEach((tag) {
        tagWidgets.add(
          GestureDetector(
            onTap: () {
              Fluttertoast.showToast(
                msg: "${tag.tagName} - ${tag.tagNotes}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: tag.getTagColor(),
                textColor: Colors.white,
                fontSize: 16.0,
              );
            },
            child: Container(
              child: Text(
                tag.tagName,
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
              color: tag.getTagColor(),
              padding: EdgeInsets.all(3),
            ),
          ),
        );
        tagWidgets.add(SizedBox(width: 5));
      });
      definitionWidgets.add(tagWidgets);
    });

    List<Widget> meaningWidgets = [];

    for (int i = 0; i < meanings.length; i++) {
      List<InlineSpan> inlineSpanWidgets = [];
      for (int j = 0; j < definitionWidgets[i].length; j++) {
        inlineSpanWidgets.add(
          WidgetSpan(
            child: definitionWidgets[i][j],
          ),
        );
      }

      inlineSpanWidgets.add(
        TextSpan(
          text: meanings[i],
        ),
      );

      meaningWidgets.add(
        SizedBox(height: (i == 0) ? 10 : 5),
      );
      meaningWidgets.add(
        Text.rich(
          TextSpan(
            text: '',
            style: TextStyle(
              fontSize: 15,
            ),
            children: inlineSpanWidgets,
          ),
          maxLines: 10,
          overflow: TextOverflow.ellipsis,
        ),
      );
      if (i == meanings.length - 1) {
        meaningWidgets.add(
          SizedBox(height: 10),
        );
      }
    }

    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: meaningWidgets,
      ),
    );
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

@Entity()
class YomichanTag {
  int id;
  @Index()
  String tagName;
  String frequencyName;
  int sortingOrder;
  String tagNotes;
  int popularity;
  @Index()
  String dictionarySource;

  YomichanTag({
    this.id = 0,
    this.tagName,
    this.frequencyName,
    this.sortingOrder,
    this.tagNotes,
    this.popularity,
    this.dictionarySource,
  });

  Map<String, dynamic> toMap() {
    return {
      "tagName": this.tagName,
      "frequencyName": this.frequencyName,
      "sortingOrder": this.sortingOrder,
      "tagNotes": this.tagNotes,
      "popularity": this.popularity,
      "dictionarySource": this.dictionarySource,
    };
  }

  YomichanTag.fromMap(Map<String, dynamic> map) {
    this.tagName = map["tagName"];
    this.frequencyName = map["frequencyName"];
    this.sortingOrder = map["sortingOrder"];
    this.tagNotes = map["tagNotes"];
    this.popularity = map["popularity"];
    this.dictionarySource = map["dictionarySource"];
  }

  Color getTagColor() {
    switch (this.frequencyName) {
      case "name":
        return Color(0xffd46a6a);
      case "expression":
        return Color(0xffff4d4d);
      case "popular":
        return Color(0xff550000);
      case "partOfSpeech":
        return Color(0xff565656);
      case "archaism":
        return Colors.grey[700];
      case "dictionary":
        return Color(0xffa15151);
      case "frequency":
        return Color(0xffd46a6a);
      case "frequent":
        return Color(0xff801515);
    }

    return Colors.grey[700];
  }
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
  String dictionarySource;

  DictionaryHistoryEntry({
    this.entries,
    this.searchTerm,
    this.swipeIndex,
    this.contextDataSource,
    this.contextPosition,
    this.dictionarySource,
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
      "dictionarySource": dictionarySource,
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
    this.dictionarySource = map['dictionarySource'];
  }

  @override
  bool operator ==(Object other) =>
      other is DictionaryHistoryEntry &&
      listEquals(this.entries, other.entries) &&
      this.searchTerm == other.searchTerm;

  @override
  int get hashCode => super.hashCode;
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
    dictionarySource: getCurrentDictionary(),
    word: exportTerm ?? searchTerm,
    reading: exportReadings,
    meaning: exportMeanings,
    yomichanTermTags: [
      YomichanTag(
        tagName: getCurrentDictionary(),
        frequencyName: "dictionary",
        sortingOrder: 99999999999,
        tagNotes:
            "Dictionary entry imported and queried from ${getCurrentDictionary()}",
        popularity: 0,
        dictionarySource: getCurrentDictionary(),
      ),
    ],
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
      dictionarySource: getCurrentDictionary(),
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
        dictionarySource: getCurrentDictionary(),
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
    dictionarySource: getCurrentDictionary(),
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
        dictionarySource: getCurrentDictionary(),
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
    dictionarySource: getCurrentDictionary(),
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
    dictionarySource: getCurrentDictionary(),
    word: word,
    reading: reading,
    meaning: meaning,
    searchTerm: searchTerm,
    yomichanTermTags: [
      YomichanTag(
        tagName: getCurrentDictionary(),
        frequencyName: "dictionary",
        sortingOrder: 99999999999,
        tagNotes:
            "Dictionary entry imported and queried from ${getCurrentDictionary()}",
        popularity: 0,
        dictionarySource: getCurrentDictionary(),
      ),
    ],
  );
}

Future openDictionaryMenu(BuildContext context, bool importAllowed) {
  ScrollController scrollController = ScrollController();
  ValueNotifier<List<String>> _useCustomDictionaries =
      ValueNotifier<List<String>>(getDictionariesName());

  Widget buildDictionaryMenuContent() {
    return Container(
      width: double.maxFinite,
      child: ValueListenableBuilder(
        valueListenable: _useCustomDictionaries,
        builder:
            (BuildContext context, List<String> dictionaryNames, Widget child) {
          return ValueListenableBuilder(
            valueListenable: gActiveDictionary,
            builder:
                (BuildContext context, String activeDictionary, Widget child) {
              return RawScrollbar(
                thumbColor: Colors.grey[600],
                controller: scrollController,
                child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: dictionaryNames.length + 2,
                  itemBuilder: (context, index) {
                    if (index < dictionaryNames.length) {
                      String dictionaryName = dictionaryNames[index];

                      return ListTile(
                        dense: true,
                        selected: (activeDictionary == dictionaryName),
                        selectedTileColor: Colors.white.withOpacity(0.2),
                        title: Row(
                          children: [
                            Icon(
                              Icons.auto_stories,
                              size: 20.0,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              dictionaryName,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        onTap: () {
                          setCurrentDictionary(dictionaryName);
                          if (!importAllowed) {
                            Navigator.pop(context);
                          }
                        },
                        onLongPress: () async {
                          if (importAllowed) {
                            deleteDialog(context, dictionaryName,
                                _useCustomDictionaries);
                          }
                        },
                      );
                    } else if (index == dictionaryNames.length) {
                      String dictionaryName = "Jisho.org API";
                      return ListTile(
                        dense: true,
                        selected: (activeDictionary == dictionaryName),
                        selectedTileColor: Colors.white.withOpacity(0.2),
                        title: Row(
                          children: [
                            Icon(
                              Icons.cloud,
                              size: 20.0,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              dictionaryName,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        onTap: () {
                          useBilingual();
                          if (!importAllowed) {
                            Navigator.pop(context);
                          }
                        },
                      );
                    } else {
                      String dictionaryName = "Sora Dictionary API";
                      return ListTile(
                        dense: true,
                        selected: (activeDictionary == dictionaryName),
                        selectedTileColor: Colors.white.withOpacity(0.2),
                        title: Row(
                          children: [
                            Icon(
                              Icons.cloud,
                              size: 20.0,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              dictionaryName,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        onTap: () {
                          useMonolingual();
                          if (!importAllowed) {
                            Navigator.pop(context);
                          }
                        },
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding:
            EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        content: buildDictionaryMenuContent(),
        actions: <Widget>[
          if (gIsTapToSelectSupported && importAllowed)
            TextButton(
              child: Text('IMPORT', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await dictionaryImport(context);
                _useCustomDictionaries.value = getDictionariesName();
              },
            ),
          if (importAllowed)
            TextButton(
              child: Text('CLOSE', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
        ],
      );
    },
  );
}

void deleteDialog(BuildContext context, String dictionaryName,
    ValueNotifier<List<String>> customDictionaries) {
  Widget alertDialog = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),
    title: new Text('Delete 『$dictionaryName』?'),
    actions: <Widget>[
      new TextButton(
          child: Text(
            'NO',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            textStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context)),
      new TextButton(
        child: Text(
          'YES',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(
          textStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () async {
          await deleteCustomDictionary(dictionaryName);
          Navigator.pop(context);
          customDictionaries.value = getDictionariesName();
          await setCurrentDictionary("Jisho.org API");
        },
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (context) => alertDialog,
  );
}

class ArchiveImportResult {
  String dictionaryName;
  List<DictionaryEntry> entries;

  ArchiveImportResult({this.dictionaryName, this.entries});
}

Future dictionaryImport(BuildContext context) async {
  ValueNotifier<String> progressNotifier = ValueNotifier<String>("");
  File archiveFile = await FilePicker.getFile(type: FileType.any);

  if (archiveFile != null) {
    try {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            contentPadding:
                EdgeInsets.only(top: 20, bottom: 10, left: 30, right: 30),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
                SizedBox(width: 20),
                Flexible(
                  child: ValueListenableBuilder(
                    valueListenable: progressNotifier,
                    builder: (BuildContext context, String progressNotification,
                        Widget child) {
                      return Text(
                        progressNotification,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [],
          );
        },
      );

      await importCustomDictionary(archiveFile, progressNotifier);
      Navigator.pop(context);
    } catch (e) {
      progressNotifier.value = "An error has occurred.";
      await Future.delayed(Duration(seconds: 3), () {});
      progressNotifier.value = "Dictionary import failed.";
      await Future.delayed(Duration(seconds: 1), () {});
      Navigator.pop(context);
      print(e);
    }
  }
}

Future<void> importCustomDictionary(
    File archiveFile, ValueNotifier<String> progressNotifier) async {
  progressNotifier.value = "Initializing import...";

  await Future.delayed(Duration(milliseconds: 500), () {});

  Directory importDirectory = Directory(
    path.join(gAppDirPath, "importDirectory"),
  );
  if (importDirectory.existsSync()) {
    progressNotifier.value = "Clearing working space...";
    await Future.delayed(Duration(milliseconds: 500), () {});
    importDirectory.deleteSync(recursive: true);
  }

  progressNotifier.value = "Extracting archive...";
  await Future.delayed(Duration(milliseconds: 500), () {});
  importDirectory.createSync();
  await ZipFile.extractToDirectory(
      zipFile: archiveFile, destinationDir: importDirectory);

  if (!getTermBankDirectory().existsSync()) {
    getTermBankDirectory().createSync(recursive: true);
  }

  await Future.delayed(Duration(milliseconds: 500), () {});

  String indexPath = path.join(importDirectory.path, "index.json");
  File indexFile = File(indexPath);
  Map<String, dynamic> index = jsonDecode(indexFile.readAsStringSync());
  String dictionaryName = (index["title"] as String).trim();

  if (getDictionariesName().contains(dictionaryName) ||
      gReservedDictionaryNames.contains(dictionaryName)) {
    throw Exception("Dictionary with same title already found.");
  }

  progressNotifier.value = "Importing 『$dictionaryName』...";
  initializeCustomDictionary(dictionaryName);
  Store store = gCustomDictionaryStores[dictionaryName];

  await Future.delayed(Duration(milliseconds: 500), () {});

  ReceivePort receivePort = ReceivePort();
  receivePort.listen((data) {
    if (data is String) {
      progressNotifier.value = data;
    }
  });

  EntryExtractParams params = EntryExtractParams(
    dictionaryName: dictionaryName,
    importDirectoryPath: importDirectory.path,
    entryStoreReference: store.reference,
    tagStoreReference: gTagStore.reference,
    sendPort: receivePort.sendPort,
  );

  int entriesCount = await compute(importEntries, params);
  progressNotifier.value = "Imported $entriesCount entries...";

  await Future.delayed(Duration(seconds: 1), () {});

  progressNotifier.value = "Dictionary import complete.";

  await Future.delayed(Duration(seconds: 1), () {});

  await addDictionaryName(dictionaryName);
  await setCurrentDictionary(dictionaryName);
}

Future<int> importEntries(EntryExtractParams params) async {
  SendPort sendPort = params.sendPort;
  List<DictionaryEntry> entries = [];
  List<YomichanTag> tags = [];

  for (int i = 0; i < 999; i++) {
    String outputPath =
        path.join(params.importDirectoryPath, "tag_bank_$i.json");
    File tagBankFile = File(outputPath);

    if (tagBankFile.existsSync()) {
      List<dynamic> tagBank = jsonDecode(tagBankFile.readAsStringSync());

      tagBank.forEach((tag) {
        tags.add(YomichanTag(
          tagName: tag[0],
          frequencyName: tag[1],
          sortingOrder: tag[2],
          tagNotes: tag[3],
          popularity: tag[4],
          dictionarySource: params.dictionaryName,
        ));
      });
    }

    sendPort.send("Found ${tags.length} tags...");
  }

  await Future.delayed(Duration(seconds: 1), () {});

  for (int i = 0; i < 999; i++) {
    String outputPath =
        path.join(params.importDirectoryPath, "term_bank_$i.json");
    File termBankFile = File(outputPath);

    if (termBankFile.existsSync()) {
      List<dynamic> termBank = jsonDecode(termBankFile.readAsStringSync());
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

      termBank.forEach((term) {
        List<String> definitionTags = [];
        String definitionTagsUnsplit = term[2].toString();
        definitionTags = definitionTagsUnsplit.split(" ");

        List<String> termTags = [];
        try {
          String termTagsUnsplit = term[7].toString();
          termTags = termTagsUnsplit.split(" ");
        } catch (e) {}

        entries.add(DictionaryEntry(
          word: term[0].toString(),
          reading: term[1].toString(),
          definitionTags: definitionTags,
          popularity: parsePopularity(term[4]),
          meaning: parseMeaning(term[5]),
          termTags: termTags,
          dictionarySource: params.dictionaryName,
        ));
      });
    }

    sendPort.send("Found ${entries.length} entries...");
  }

  await Future.delayed(Duration(seconds: 1), () {});
  sendPort.send("Adding tags to database...");

  Store tagStore =
      Store.fromReference(getObjectBoxModel(), params.tagStoreReference);
  Box tagBox = tagStore.box<YomichanTag>();
  tagBox.putMany(tags);

  await Future.delayed(Duration(milliseconds: 500), () {});
  sendPort.send("Adding entries to database...");

  Store entryStore =
      Store.fromReference(getObjectBoxModel(), params.entryStoreReference);
  Box entryBox = entryStore.box<DictionaryEntry>();
  entryBox.putMany(entries);
  return entries.length;
}

class EntryExtractParams {
  String dictionaryName;
  String importDirectoryPath;
  ByteData entryStoreReference;
  ByteData tagStoreReference;
  SendPort sendPort;

  EntryExtractParams({
    this.dictionaryName,
    this.importDirectoryPath,
    this.entryStoreReference,
    this.tagStoreReference,
    this.sendPort,
  });
}

void initializeCustomDictionaries() async {
  Directory tagsDirectory = Directory(
    path.join(gAppDirPath, "tags"),
  );
  if (!tagsDirectory.existsSync()) {
    tagsDirectory.createSync(recursive: true);
  }

  gTagStore = Store(getObjectBoxModel(), directory: tagsDirectory.path);

  getDictionariesName().forEach((dictionaryName) {
    initializeCustomDictionary(dictionaryName);
  });
}

void initializeCustomDictionary(String dictionaryName) {
  Directory objectBoxDirDirectory = Directory(
    path.join(gAppDirPath, "customDictionaries", dictionaryName),
  );
  if (!objectBoxDirDirectory.existsSync()) {
    objectBoxDirDirectory.createSync(recursive: true);
  }

  gCustomDictionaryStores[dictionaryName] = Store(
    getObjectBoxModel(),
    directory: objectBoxDirDirectory.path,
  );
}

Future<void> deleteCustomDictionary(String dictionaryName) async {
  Store entryStore = gCustomDictionaryStores[dictionaryName];
  Box entryBox = entryStore.box<DictionaryEntry>();
  entryBox.removeAll();
  entryStore.close();

  Store tagStore = gTagStore;
  Box tagBox = tagStore.box<YomichanTag>();

  QueryBuilder tagMatchDictionary =
      tagBox.query(YomichanTag_.dictionarySource.equals(dictionaryName));
  Query tagMatchQuery = tagMatchDictionary.build();
  List<YomichanTag> tags = tagMatchQuery.find();
  tags.forEach((tag) {
    tagBox.remove(tag.id);
  });

  Directory objectBoxDirDirectory = Directory(
    path.join(gAppDirPath, "customDictionaries", dictionaryName),
  );
  objectBoxDirDirectory.deleteSync(recursive: true);

  await removeDictionaryName(dictionaryName);
}

class CustomWordDetailsParams {
  String searchTerm;
  String contextDataSource;
  int contextPosition;
  String originalSearchTerm;
  String fallbackTerm;
  ByteData entryStoreReference;
  ByteData tagStoreReference;
  List<ByteData> allStoreReferences;

  CustomWordDetailsParams({
    this.searchTerm,
    this.contextDataSource,
    this.contextPosition,
    this.originalSearchTerm,
    this.fallbackTerm,
    this.entryStoreReference,
    this.tagStoreReference,
    this.allStoreReferences,
  });
}

Future<DictionaryHistoryEntry> getCustomWordDetails(
  CustomWordDetailsParams params,
) async {
  String searchTerm = params.searchTerm;
  String contextDataSource = params.contextDataSource;
  int contextPosition = params.contextPosition;
  String originalSearchTerm = params.originalSearchTerm;
  String fallbackTerm = params.fallbackTerm;
  ByteData entryStoreReference = params.entryStoreReference;

  Store entryStore =
      Store.fromReference(getObjectBoxModel(), entryStoreReference);
  Box entryBox = entryStore.box<DictionaryEntry>();

  QueryBuilder exactWordMatch =
      entryBox.query(DictionaryEntry_.word.equals(searchTerm));
  Query exactWordQuery = exactWordMatch.build();

  Query limitedWordQuery = exactWordQuery..limit = 20;
  List<DictionaryEntry> entries = limitedWordQuery.find();

  QueryBuilder exactReadingMatch =
      entryBox.query(DictionaryEntry_.reading.equals(searchTerm));
  Query exactReadingQuery = exactReadingMatch.build();

  Query limitedReadingQuery = exactReadingQuery..limit = 20;
  List<DictionaryEntry> readingMatchQueries = limitedReadingQuery.find();
  entries.addAll(readingMatchQueries);

  if (entries.isEmpty) {
    QueryBuilder fallbackMixMatch = entryBox.query(
        DictionaryEntry_.word.equals(fallbackTerm) |
            DictionaryEntry_.reading.equals(fallbackTerm) |
            DictionaryEntry_.word.startsWith(searchTerm) |
            DictionaryEntry_.reading.startsWith(searchTerm))
      ..order(DictionaryEntry_.popularity, flags: Order.descending);
    Query fallbackMixQuery = fallbackMixMatch.build();

    Query fallbackLimitedQuery = fallbackMixQuery..limit = 30;
    entries = fallbackLimitedQuery.find();
  }

  if (entries.isNotEmpty) {
    return DictionaryHistoryEntry(
      entries: mergeSameEntries(
        entries: entries,
        params: params,
        entryBox: entryBox,
        dictionarySource: entries.first.dictionarySource,
      ),
      searchTerm: originalSearchTerm,
      swipeIndex: 0,
      contextDataSource: contextDataSource,
      contextPosition: contextPosition,
      dictionarySource: entries.first.dictionarySource,
    );
  }

  if (entries.isEmpty) {
    QueryBuilder startsWithWordMatch = entryBox
        .query(DictionaryEntry_.word.startsWith(fallbackTerm))
          ..order(DictionaryEntry_.popularity, flags: Order.descending);
    Query startsWithWordQuery = startsWithWordMatch.build();

    limitedWordQuery = startsWithWordQuery..limit = 20;
    entries = limitedWordQuery.find();

    QueryBuilder startsWithReadingMatch = entryBox
        .query(DictionaryEntry_.reading.startsWith(fallbackTerm))
          ..order(DictionaryEntry_.popularity, flags: Order.descending);
    Query startsWithReadingQuery = startsWithReadingMatch.build();

    limitedReadingQuery = startsWithReadingQuery..limit = 20;
    readingMatchQueries = limitedReadingQuery.find();
    entries.addAll(readingMatchQueries);
  }

  if (entries.isNotEmpty) {
    return DictionaryHistoryEntry(
      entries: mergeSameEntries(
        entries: entries,
        params: params,
        entryBox: entryBox,
        dictionarySource: entries.first.dictionarySource,
      ),
      searchTerm: originalSearchTerm,
      swipeIndex: 0,
      contextDataSource: contextDataSource,
      contextPosition: contextPosition,
      dictionarySource: entries.first.dictionarySource,
    );
  }

  return null;
}

List<DictionaryEntry> mergeSameEntries({
  List<DictionaryEntry> entries,
  CustomWordDetailsParams params,
  Box entryBox,
  String dictionarySource,
}) {
  Store tagStore =
      Store.fromReference(getObjectBoxModel(), params.tagStoreReference);
  List<Box> allBoxes = [];
  params.allStoreReferences.forEach((storeReference) {
    Store store = Store.fromReference(getObjectBoxModel(), storeReference);
    allBoxes.add(store.box<DictionaryEntry>());
  });
  allBoxes.add(entryBox);

  List<DictionaryEntry> mergedEntries = [];

  Map<String, Map<String, DictionaryEntry>> readingMap = {};

  entries.forEach((entry) {
    if (readingMap[entry.reading] == null) {
      readingMap[entry.reading] = {};
    }
    if (readingMap[entry.reading][entry.word] == null) {
      readingMap[entry.reading][entry.word] = DictionaryEntry(
        word: entry.word,
        reading: entry.reading,
        meaning: "",
        popularity: 0,
        duplicateCount: 0,
        searchTerm: entry.searchTerm,
        termTags: [],
        definitionTags: [],
        yomichanDefinitionTags: [],
        yomichanTermTags: [],
        meanings: [],
      );
    }

    DictionaryEntry monoEntry = readingMap[entry.reading][entry.word];

    monoEntry.duplicateCount += 1;
    monoEntry.meaning += getBetterNumberTag("• ${entry.meaning}\n");
    monoEntry.duplicateWorkingMeaning = entry.meaning;
    monoEntry.popularity += entry.popularity;

    monoEntry.meanings.add(entry.meaning);
    monoEntry.yomichanDefinitionTags.add(
      getYomichanTermTags(
        entry.definitionTags,
        tagStore,
        dictionaryName: dictionarySource,
      ),
    );
  });

  readingMap.values.forEach((headwordMap) {
    headwordMap.values.forEach((dictionaryEntry) {
      mergedEntries.add(dictionaryEntry);
    });
  });

  String removeLastNewline(String n) => n = n.substring(0, n.length - 1);
  mergedEntries.forEach((entry) {
    if (entry.duplicateCount == 1) {
      entry.meaning = entry.duplicateWorkingMeaning;
    } else {
      entry.meaning = removeLastNewline(entry.meaning);
    }

    entry.popularity = entry.popularity / entry.duplicateCount;
    entry.termTags = getRawTags(entry, allBoxes);
    entry.yomichanTermTags = getYomichanTermTags(entry.termTags, tagStore);
    entry.yomichanTermTags.add(YomichanTag(
      tagName: dictionarySource,
      frequencyName: "dictionary",
      sortingOrder: 99999999999,
      tagNotes: "Dictionary entry imported and queried from $dictionarySource",
      popularity: 0,
      dictionarySource: dictionarySource,
    ));
  });

  mergedEntries.sort((a, b) => b.yomichanDefinitionTags.length
      .compareTo(a.yomichanDefinitionTags.length));
  mergedEntries.sort((a, b) => getPopularitySum(b.yomichanTermTags)
      .compareTo(getPopularitySum(a.yomichanTermTags)));
  mergedEntries.sort((a, b) =>
      (getTagCount(b.yomichanTermTags) + b.duplicateCount * 0.3)
          .compareTo(getTagCount(a.yomichanTermTags) + a.duplicateCount * 0.3));

  List<DictionaryEntry> exactFirstEntries = [];
  mergedEntries.forEach((entry) {
    if (entry.word == params.searchTerm) {
      exactFirstEntries.add(entry);
    }
  });
  if (params.fallbackTerm != params.searchTerm) {
    mergedEntries.forEach((entry) {
      if (entry.word == params.fallbackTerm) {
        exactFirstEntries.add(entry);
      }
    });
  }
  mergedEntries.forEach((entry) {
    if (entry.word != params.searchTerm && entry.word != params.fallbackTerm) {
      exactFirstEntries.add(entry);
    }
  });

  return exactFirstEntries;
}

int getPopularitySum(List<YomichanTag> tags) {
  int sum = 0;
  tags.forEach((tag) {
    sum += tag.popularity;
  });

  return sum;
}

int getTagCount(List<YomichanTag> tags) {
  int sum = 0;
  tags.forEach((tag) {
    sum += 1;
  });

  return sum;
}

List<YomichanTag> getYomichanTermTags(List<String> tagNames, Store tagStore,
    {String dictionaryName}) {
  List<YomichanTag> tags = [];
  Box tagBox = tagStore.box<YomichanTag>();

  tagNames.forEach((tagName) {
    QueryBuilder tagMatch;
    if (dictionaryName != null) {
      tagMatch = tagBox.query(YomichanTag_.tagName.equals(tagName) &
          YomichanTag_.dictionarySource.equals(dictionaryName));
    } else {
      tagMatch = tagBox.query(YomichanTag_.tagName.equals(tagName));
    }
    List<YomichanTag> tagsToAdd = tagMatch.build().find();
    tags.addAll(tagsToAdd);
  });

  tags.sort((a, b) => a.sortingOrder.compareTo(b.sortingOrder));
  return tags;
}

List<String> collapseEntryTags(List<DictionaryEntry> entries) {
  List<String> rawTags = [];
  entries.forEach((entry) {
    rawTags.addAll(entry.termTags);
  });
  return rawTags;
}

List<String> getRawTags(DictionaryEntry entry, List<Box> boxes) {
  List<String> rawTags = [];

  boxes.forEach((box) {
    QueryBuilder exactMatchBuilder = box.query(
        DictionaryEntry_.word.equals(entry.word) &
            DictionaryEntry_.reading.equals(entry.reading));
    Query exactMatchQuery = exactMatchBuilder.build();
    List<DictionaryEntry> entries = exactMatchQuery.find();
    rawTags.addAll(collapseEntryTags(entries));
  });

  return rawTags.toSet().toList();
}

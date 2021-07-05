import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:gx_file_picker/gx_file_picker.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/objectbox.g.dart';
import 'package:jidoujisho/pitch.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:unofficial_jisho_api/api.dart';

import 'package:jidoujisho/util.dart';
import 'package:ve_dart/ve_dart.dart';

@Entity()
class DictionaryEntry {
  int id;
  String dictionarySource;
  String word;
  String reading;
  String meaning;
  String searchTerm;
  List<PitchAccentInformation> pitchAccentEntries;

  DictionaryEntry({
    this.id = 0,
    this.dictionarySource,
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
      "dictionarySource": this.dictionarySource,
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

    this.dictionarySource = map['dictionarySource'];
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

Future<ArchiveImportResult> getCustomDictionaryFromArchive(
    File archiveFile, ValueNotifier<String> progressNotifier) async {
  List<DictionaryEntry> entries = [];

  progressNotifier.value = "Initializing import...";

  await Future.delayed(Duration(milliseconds: 1), () {});

  Directory importDirectory = Directory(
    path.join(gAppDirPath, "importDirectory"),
  );
  if (importDirectory.existsSync()) {
    progressNotifier.value = "Clearing working space...";
    await Future.delayed(Duration(milliseconds: 1), () {});
    importDirectory.deleteSync(recursive: true);
  }

  progressNotifier.value = "Extracting archive...";
  importDirectory.createSync();
  await ZipFile.extractToDirectory(
      zipFile: archiveFile, destinationDir: importDirectory);

  if (!getTermBankDirectory().existsSync()) {
    getTermBankDirectory().createSync(recursive: true);
  }

  await Future.delayed(Duration(milliseconds: 1), () {});

  String indexPath = path.join(importDirectory.path, "index.json");
  File indexFile = File(indexPath);
  Map<String, dynamic> index = jsonDecode(indexFile.readAsStringSync());
  String dictionaryName = index["title"];

  if (getDictionariesName().contains(dictionaryName) ||
      gReservedDictionaryNames.contains(dictionaryName)) {
    throw Exception("Dictionary with same title already found.");
  }

  for (int i = 0; i < 999; i++) {
    String outputPath = path.join(importDirectory.path, "term_bank_$i.json");
    File dictionaryFile = File(outputPath);

    if (dictionaryFile.existsSync()) {
      List<dynamic> dictionary = jsonDecode(dictionaryFile.readAsStringSync());
      dictionary.forEach((entry) {
        entries.add(DictionaryEntry(
          dictionarySource: dictionaryName,
          word: entry[0].toString(),
          reading: entry[1].toString(),
          meaning: entry[5].toString(),
        ));
        progressNotifier.value = "Found ${entries.length} entries...";
      });
    }
  }

  await Future.delayed(Duration(milliseconds: 1), () {});

  return ArchiveImportResult(
    dictionaryName: dictionaryName,
    entries: entries,
  );
}

class ArchiveImportResult {
  String dictionaryName;
  List<DictionaryEntry> entries;

  ArchiveImportResult({this.dictionaryName, this.entries});
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
    dictionarySource: getCurrentDictionary(),
    word: word,
    reading: reading,
    meaning: meaning,
    searchTerm: searchTerm,
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
              return Scrollbar(
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

Widget deleteDialog(BuildContext context, String dictionaryName,
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
                ValueListenableBuilder(
                  valueListenable: progressNotifier,
                  builder: (BuildContext context, String progressNotification,
                      Widget child) {
                    return Text(
                      progressNotification,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    );
                  },
                ),
              ],
            ),
            actions: [],
          );
        },
      );

      ArchiveImportResult archiveImportResult =
          await getCustomDictionaryFromArchive(archiveFile, progressNotifier);
      await populateCustomDictionaryDatabase(
          archiveImportResult, progressNotifier);
      await addDictionaryName(archiveImportResult.dictionaryName);
      await setCurrentDictionary(archiveImportResult.dictionaryName);
      Navigator.pop(context);
    } catch (e) {
      progressNotifier.value = "An error has occurred.";
      await Future.delayed(Duration(seconds: 3), () {
        Navigator.pop(context);
      });
      print(e);
    }
  }
}

Future<void> populateCustomDictionaryDatabase(
  ArchiveImportResult archiveImportResult,
  ValueNotifier<String> progressNotifier,
) async {
  String dictionaryName = archiveImportResult.dictionaryName;
  List<DictionaryEntry> entries = archiveImportResult.entries;

  await Future.delayed(Duration(seconds: 1), () {});

  initializeCustomDictionary(dictionaryName);
  progressNotifier.value = "Initializing database store...";
  Store store = gCustomDictionaryStores[dictionaryName];
  Box box = store.box<DictionaryEntry>();

  await Future.delayed(Duration(seconds: 1), () {});

  box.putMany(entries);

  progressNotifier.value = "Added ${entries.length} entries to database.";

  await Future.delayed(Duration(seconds: 1), () {});

  progressNotifier.value = "Dictionary import complete.";

  await Future.delayed(Duration(seconds: 1), () {});
}

void initializeCustomDictionaries() async {
  getDictionariesName().forEach((dictionaryName) {
    initializeCustomDictionary(dictionaryName);
  });
}

void initializeCustomDictionary(String dictionaryName) {
  Directory objectBoxDirDirectory = Directory(
    path.join(gAppDirPath, "objectbox", dictionaryName),
  );
  if (!objectBoxDirDirectory.existsSync()) {
    objectBoxDirDirectory.createSync(recursive: true);
  }

  gCustomDictionaryStores[dictionaryName] = Store(
    getObjectBoxModel(),
    directory: path.join(gAppDirPath, "objectbox", objectBoxDirDirectory.path),
  );
}

Future<void> deleteCustomDictionary(String dictionaryName) async {
  Store store = gCustomDictionaryStores[dictionaryName];
  Box box = store.box<DictionaryEntry>();
  box.removeAll();
  store.close();

  Directory objectBoxDirDirectory = Directory(
    path.join(gAppDirPath, "objectbox", dictionaryName),
  );
  objectBoxDirDirectory.deleteSync(recursive: true);

  await removeDictionaryName(dictionaryName);
}

Future<DictionaryHistoryEntry> getCustomWordDetails({
  String searchTerm,
  String contextDataSource,
  int contextPosition,
}) async {
  String parsedTerm;
  List<Word> words = parseVe(gMecabTagger, searchTerm);
  if (words == null && words.isNotEmpty) {
    parsedTerm = searchTerm;
  } else {
    if (words.first.lemma != null && words.first.lemma != words.first.word) {
      parsedTerm = words.first.lemma;
    } else {
      if (words.first.word == searchTerm) {
        parsedTerm = words.first.word;
      } else {
        parsedTerm = searchTerm;
      }
    }
  }

  Store store = gCustomDictionaryStores[getCurrentDictionary()];
  Box box = store.box<DictionaryEntry>();

  final queryBuilder = box.query(DictionaryEntry_.word.equals(parsedTerm) |
      DictionaryEntry_.reading.equals(parsedTerm) |
      DictionaryEntry_.meaning.equals(parsedTerm) |
      DictionaryEntry_.word.startsWith(parsedTerm) |
      DictionaryEntry_.reading.startsWith(parsedTerm) |
      DictionaryEntry_.meaning.startsWith(parsedTerm))
    ..order(DictionaryEntry_.word);
  final query = queryBuilder.build();

  Query limitedQuery = query..limit = 40;
  List<DictionaryEntry> entries = limitedQuery.find();

  return DictionaryHistoryEntry(
    entries: entries,
    searchTerm: searchTerm,
    swipeIndex: 0,
    contextDataSource: contextDataSource,
    contextPosition: contextPosition,
  );
}

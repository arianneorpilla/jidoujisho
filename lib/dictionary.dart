import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

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
import 'package:unofficial_jisho_api/api.dart';

import 'package:jidoujisho/util.dart';

@Entity()
class DictionaryEntry {
  int id;
  String dictionarySource;
  String word;
  String reading;
  String meaning;
  int popularity;
  String searchTerm;
  List<PitchAccentInformation> pitchAccentEntries;

  int duplicateCount;
  String duplicateWorkingMeaning;

  DictionaryEntry({
    this.id = 0,
    this.dictionarySource,
    this.word,
    this.reading,
    this.meaning,
    this.popularity,
    this.duplicateCount = 0,
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
      "popularity": this.popularity,
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
    this.popularity = map['popularity'];
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
      await Future.delayed(Duration(seconds: 3), () {
        Navigator.pop(context);
      });
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
    storeReference: store.reference,
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
  for (int i = 0; i < 999; i++) {
    String outputPath =
        path.join(params.importDirectoryPath, "term_bank_$i.json");
    File dictionaryFile = File(outputPath);

    if (dictionaryFile.existsSync()) {
      List<dynamic> dictionary = jsonDecode(dictionaryFile.readAsStringSync());
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

      dictionary.forEach((entry) {
        entries.add(DictionaryEntry(
          dictionarySource: params.dictionaryName,
          word: entry[0].toString(),
          reading: entry[1].toString(),
          meaning: parseMeaning(entry[5]),
          popularity: entry[4],
        ));
      });
    }

    sendPort.send("Found ${entries.length} entries...");
  }

  await Future.delayed(Duration(seconds: 1), () {});
  sendPort.send("Adding entries to database...");

  Store store = Store.fromReference(getObjectBoxModel(), params.storeReference);
  Box box = store.box<DictionaryEntry>();
  box.putMany(entries);
  return entries.length;
}

class EntryExtractParams {
  String dictionaryName;
  String importDirectoryPath;
  ByteData storeReference;
  SendPort sendPort;

  EntryExtractParams({
    this.dictionaryName,
    this.importDirectoryPath,
    this.storeReference,
    this.sendPort,
  });
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
    directory: objectBoxDirDirectory.path,
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

class CustomWordDetailsParams {
  String searchTerm;
  String contextDataSource;
  int contextPosition;
  String originalSearchTerm;
  String fallbackTerm;
  ByteData storeReference;

  CustomWordDetailsParams({
    this.searchTerm,
    this.contextDataSource,
    this.contextPosition,
    this.originalSearchTerm,
    this.fallbackTerm,
    this.storeReference,
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
  ByteData storeReference = params.storeReference;

  Store store = Store.fromReference(getObjectBoxModel(), storeReference);
  Box box = store.box<DictionaryEntry>();

  QueryBuilder exactWordMatch = box
      .query(DictionaryEntry_.word.equals(searchTerm))
        ..order(DictionaryEntry_.popularity, flags: Order.descending);
  Query exactWordQuery = exactWordMatch.build();

  Query limitedWordQuery = exactWordQuery..limit = 20;
  List<DictionaryEntry> entries = limitedWordQuery.find();

  QueryBuilder exactReadingMatch = box
      .query(DictionaryEntry_.reading.equals(searchTerm))
        ..order(DictionaryEntry_.popularity, flags: Order.descending);
  Query exactReadingQuery = exactReadingMatch.build();

  Query limitedReadingQuery = exactReadingQuery..limit = 20;
  List<DictionaryEntry> readingMatchQueries = limitedReadingQuery.find();
  entries.addAll(readingMatchQueries);

  if (entries.isEmpty) {
    QueryBuilder fallbackMixMatch = box.query(
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
      entries: mergeSameEntries(entries),
      searchTerm: originalSearchTerm,
      swipeIndex: 0,
      contextDataSource: contextDataSource,
      contextPosition: contextPosition,
    );
  }

  if (entries.isEmpty) {
    QueryBuilder startsWithWordMatch = box
        .query(DictionaryEntry_.word.startsWith(fallbackTerm))
          ..order(DictionaryEntry_.popularity, flags: Order.descending);
    Query startsWithWordQuery = startsWithWordMatch.build();

    limitedWordQuery = startsWithWordQuery..limit = 20;
    entries = limitedWordQuery.find();

    QueryBuilder startsWithReadingMatch = box
        .query(DictionaryEntry_.reading.startsWith(fallbackTerm))
          ..order(DictionaryEntry_.popularity, flags: Order.descending);
    Query startsWithReadingQuery = startsWithReadingMatch.build();

    limitedReadingQuery = startsWithReadingQuery..limit = 20;
    readingMatchQueries = limitedReadingQuery.find();
    entries.addAll(readingMatchQueries);
  }

  if (entries.isNotEmpty) {
    return DictionaryHistoryEntry(
      entries: mergeSameEntries(entries),
      searchTerm: originalSearchTerm,
      swipeIndex: 0,
      contextDataSource: contextDataSource,
      contextPosition: contextPosition,
    );
  }

  return null;
}

List<DictionaryEntry> mergeSameEntries(List<DictionaryEntry> entries) {
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
      );
    }

    DictionaryEntry monoEntry = readingMap[entry.reading][entry.word];

    monoEntry.duplicateCount += 1;
    monoEntry.meaning += getBetterNumberTag("• ${entry.meaning}\n");
    monoEntry.duplicateWorkingMeaning = entry.meaning;
    monoEntry.popularity += entry.popularity;
  });

  readingMap.values.forEach((headwordMap) {
    headwordMap.values.forEach((dictionaryEntry) {
      print(dictionaryEntry);
    });
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

    entry.popularity = entry.popularity ~/ entry.duplicateCount;
  });

  mergedEntries.sort((a, b) => b.popularity.compareTo(a.popularity));
  mergedEntries.sort((a, b) => b.duplicateCount.compareTo(a.duplicateCount));
  return mergedEntries;
}

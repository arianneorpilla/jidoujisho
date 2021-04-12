import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:mecab_dart/mecab_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:unofficial_jisho_api/api.dart';
import 'package:ve_dart/ve_dart.dart';
import 'package:xml2json/xml2json.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:jidoujisho/main.dart';

String getDefaultSubtitles(File file, List<File> internalSubtitles) {
  String content = "";

  if (hasExternalSubtitles(file)) {
    content = getExternalSubtitles(file).readAsStringSync();
  } else if (internalSubtitles.isNotEmpty) {
    content = (internalSubtitles[0]).readAsStringSync();
  }

  print(content);

  return content;
}

bool hasExternalSubtitles(File file) {
  String subtitlePath = getExternalSubtitles(file).path;
  File subtitleFile = File(subtitlePath);

  return subtitleFile.existsSync();
}

File getExternalSubtitles(File file) {
  String videoDir = path.dirname(file.path);
  String videoBasename = path.basenameWithoutExtension(file.path);
  String subtitlePath;

  subtitlePath = "$videoDir/$videoBasename.srt";
  if (File(subtitlePath).existsSync()) {
    return File(subtitlePath);
  }

  subtitlePath = "$videoDir/$videoBasename.ass";
  if (File(subtitlePath).existsSync()) {
    return File(subtitlePath);
  }

  subtitlePath = "$videoDir/$videoBasename.ssa";
  if (File(subtitlePath).existsSync()) {
    return File(subtitlePath);
  }

  return File(subtitlePath);
}

String timedTextToSRT(String timedText) {
  final Xml2Json xml2Json = Xml2Json();

  xml2Json.parse(timedText);
  var jsonString = xml2Json.toBadgerfish();
  var data = jsonDecode(jsonString);

  List<dynamic> lines = (data["transcript"]["text"]);

  String convertedLines = "";
  int lineCount = 0;

  lines.forEach((line) {
    String convertedLine = timedLineToSRT(line, lineCount++);
    convertedLines = convertedLines + convertedLine;
  });

  return convertedLines;
}

String timedLineToSRT(Map<String, dynamic> line, int lineCount) {
  double start = double.parse(line["\@start"]);
  double duration = double.parse(line["\@dur"]);
  String text = line["\$"] ?? "";

  text = text.replaceAll("\\n", "\n");
  text = text.replaceAll("&quot;", "\"");

  text = text.replaceAll("​", "");

  String startTime = formatTimeString(start);
  String endTime = formatTimeString(start + duration);
  String lineNumber = lineCount.toString();

  String srtLine = "$lineNumber\n$startTime --> $endTime\n$text\n\n";

  return srtLine;
}

Future exportCurrentFrame(
    ChewieController chewie, VlcPlayerController controller) async {
  File imageFile = File(previewImageDir);
  if (imageFile.existsSync()) {
    imageFile.deleteSync();
  }

  Duration currentTime = controller.value.position;
  String formatted = getTimestampFromDuration(currentTime);

  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  String inputPath = chewie.currentVideoQuality.videoURL;
  String exportPath = "\"$appDirPath/exportImage.jpg\"";

  String command =
      "-loglevel quiet -ss $formatted -y -i \"$inputPath\" -frames:v 1 -q:v 2 $exportPath";

  await _flutterFFmpeg.execute(command);

  return;
}

List<File> extractWebSubtitle(String webSubtitle) {
  List<File> files = [];

  String subPath = "$appDirPath/extractWebSrt.srt";
  File subFile = File(subPath);
  if (subFile.existsSync()) {
    subFile.deleteSync();
  }

  subFile.createSync();
  subFile.writeAsStringSync(webSubtitle);
  files.add(subFile);

  return files;
}

Future exportCurrentAudio(ChewieController chewie,
    VlcPlayerController controller, Subtitle subtitle) async {
  File audioFile = File(previewAudioDir);
  if (audioFile.existsSync()) {
    audioFile.deleteSync();
  }

  String timeStart;
  String timeEnd;
  String audioIndex;

  timeStart = getTimestampFromDuration(subtitle.startTime);
  timeEnd = getTimestampFromDuration(subtitle.endTime);

  switch (controller.dataSourceType) {
    case DataSourceType.network:
      audioIndex = "0";
      break;
    default:
      audioIndex = (controller.value.activeAudioTrack - 1).toString();
      break;
  }

  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  String inputPath = chewie.audioSource;
  String outputPath = "\"$appDirPath/exportAudio.mp3\"";
  String command =
      "-loglevel quiet -ss $timeStart -to $timeEnd -y -i \"$inputPath\" -map 0:a:$audioIndex $outputPath";

  await _flutterFFmpeg.execute(command);

  return;
}

Future<List<File>> extractSubtitles(File file) async {
  String inputPath = file.path;
  List<File> files = [];

  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  for (int i = 0; i < 10; i++) {
    String outputPath = "\"$appDirPath/extractSrt$i.srt\"";
    String command =
        "-loglevel quiet -i \"$inputPath\" -map 0:s:$i $outputPath";

    String subPath = "$appDirPath/extractSrt$i.srt";
    File subFile = File(subPath);

    if (subFile.existsSync()) {
      subFile.deleteSync();
    }

    await _flutterFFmpeg.execute(command);

    if (await subFile.exists()) {
      if (subFile.readAsStringSync().isEmpty) {
        subFile.deleteSync();
      } else {
        files.add(subFile);
      }
    }
  }

  return files;
}

Future<String> extractNonSrtSubtitles(File file) async {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  String inputPath = file.path;
  String outputPath = "\"$appDirPath/extractNonSrt.srt\"";
  String command =
      "-loglevel quiet -f ass -c:s ass -i \"$inputPath\" -map 0:s:0 -c:s subrip $outputPath";

  String subPath = "$appDirPath/extractNonSrt.srt";
  File subFile = File(subPath);

  if (subFile.existsSync()) {
    subFile.deleteSync();
  }

  await _flutterFFmpeg.execute(command);
  return subFile.readAsStringSync();
}

Future exportToAnki(
  BuildContext context,
  ChewieController chewie,
  VlcPlayerController controller,
  ValueNotifier<String> clipboard,
  Subtitle subtitle,
  DictionaryEntry dictionaryEntry,
  bool wasPlaying,
) async {
  final prefs = await SharedPreferences.getInstance();
  String lastDeck = prefs.getString("lastDeck") ?? "Default";

  await exportCurrentFrame(chewie, controller);
  await exportCurrentAudio(chewie, controller, subtitle);
  List<String> decks = await getDecks();

  Clipboard.setData(
    ClipboardData(text: ""),
  );
  clipboard.value = "";

  showAnkiDialog(
    context,
    subtitle.text,
    dictionaryEntry,
    decks,
    lastDeck,
    controller,
    clipboard,
    wasPlaying,
  );
}

void showAnkiDialog(
  BuildContext context,
  String sentence,
  DictionaryEntry dictionaryEntry,
  List<String> decks,
  String lastDeck,
  VlcPlayerController controller,
  ValueNotifier<String> clipboard,
  bool wasPlaying,
) {
  TextEditingController _sentenceController =
      TextEditingController(text: sentence);
  TextEditingController _wordController =
      TextEditingController(text: dictionaryEntry.word);
  TextEditingController _readingController =
      TextEditingController(text: dictionaryEntry.reading);
  TextEditingController _meaningController =
      TextEditingController(text: dictionaryEntry.meaning);

  Widget displayField(
    String labelText,
    String hintText,
    IconData icon,
    TextEditingController controller,
  ) {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          iconSize: 12,
          onPressed: () => controller.clear(),
          icon: Icon(Icons.clear),
        ),
        labelText: labelText,
        hintText: hintText,
      ),
    );
  }

  Widget sentenceField = displayField(
    "Sentence",
    "Enter front of card or sentence here",
    Icons.format_align_center_rounded,
    _sentenceController,
  );
  Widget wordField = displayField(
    "Word",
    "Enter the word in the back here",
    Icons.speaker_notes_outlined,
    _wordController,
  );
  Widget readingField = displayField(
    "Reading",
    "Enter the reading of the word here",
    Icons.surround_sound_outlined,
    _readingController,
  );
  Widget meaningField = displayField(
    "Meaning",
    "Enter the meaning in the back here",
    Icons.translate_rounded,
    _meaningController,
  );

  AudioPlayer audioPlayer = AudioPlayer();
  imageCache.clear();

  showDialog(
    context: context,
    builder: (context) {
      ValueNotifier<String> _selectedDeck = new ValueNotifier<String>(lastDeck);

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        contentPadding: EdgeInsets.all(8),
        content: Row(
          children: <Widget>[
            Expanded(
              flex: 30,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.file(File(previewImageDir), fit: BoxFit.contain),
                    DeckDropDown(
                      decks: decks,
                      selectedDeck: _selectedDeck,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(flex: 1, child: Container()),
            Expanded(
              flex: 30,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    sentenceField,
                    wordField,
                    readingField,
                    meaningField,
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'PREVIEW AUDIO',
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
              await audioPlayer.stop();
              await audioPlayer.play(previewAudioDir, isLocal: true);
            },
          ),
          TextButton(
            child: Text(
              'CANCEL',
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(
              'EXPORT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              exportAnkiCard(
                _selectedDeck.value,
                _sentenceController.text,
                _wordController.text,
                _readingController.text,
                _meaningController.text,
              );

              Navigator.pop(context);

              if (wasPlaying) {
                controller.play();
              }

              clipboard.value = "&<&>exported${_selectedDeck.value}&<&>";
              Future.delayed(Duration(seconds: 2), () {
                clipboard.value = "";
              });
            },
          ),
        ],
      );
    },
  );
}

void exportAnkiCard(String deck, String sentence, String answer, String reading,
    String meaning) {
  DateTime now = DateTime.now();
  String newFileName =
      "jidoujisho-" + intl.DateFormat('yyyyMMddTkkmmss').format(now);

  File imageFile = File(previewImageDir);
  File audioFile = File(previewAudioDir);

  String newImagePath =
      "storage/emulated/0/AnkiDroid/collection.media/$newFileName.jpg";
  String newAudioPath =
      "storage/emulated/0/AnkiDroid/collection.media/$newFileName.mp3";

  String addImage = "";
  String addAudio = "";

  if (imageFile.existsSync()) {
    imageFile.copySync(newImagePath);
    addImage = "<img src=\"$newFileName.jpg\">";
  }
  if (audioFile.existsSync()) {
    audioFile.copySync(newAudioPath);
    addAudio = "[sound:$newFileName.mp3]";
  }

  requestPermissions();
  addNote(deck, addImage, addAudio, sentence, answer, meaning, reading);
}

class DictionaryEntry {
  String word;
  String reading;
  String meaning;
  String searchTerm;

  DictionaryEntry({this.word, this.reading, this.meaning, this.searchTerm});
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
  for (DictionaryEntry entry in customDictionary) {
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

  if (customDictionary.isEmpty) {
    dictionaryEntry = DictionaryEntry(
      word: exportTerm ?? searchTerm,
      reading: exportReadings,
      meaning: exportMeanings,
    );
  } else {
    int resultIndex;

    final searchResult = customDictionaryFuzzy.search(searchTerm, 1);
    // print("SEARCH RESULT: $searchResult");

    if (searchResult.isNotEmpty && searchResult.first.score == 0) {
      resultIndex = searchResult.first.matches.first.arrayIndex;

      dictionaryEntry = DictionaryEntry(
        word: customDictionary[resultIndex].word,
        reading: customDictionary[resultIndex].reading,
        meaning: customDictionary[resultIndex].meaning,
      );

      return dictionaryEntry;
    } else {
      words.forEach((word) {
        String term = word.word;

        if (term != null) {
          final termResult = customDictionaryFuzzy.search(term, 1);

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
        await client.get('https://jisho.org/search/$searchTerm');

    var document = parser.parse(response.body);

    var breakdown = document.getElementsByClassName("fact grammar-breakdown");
    if (breakdown.isEmpty) {
      return [];
    } else {
      String inflection = breakdown.first.querySelector("a").text;
      return getWordDetails(inflection);
    }
  }

  if (customDictionary.isNotEmpty) {
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

class YouTubeQualityOption {
  final String videoURL;
  final String resolution;

  YouTubeQualityOption({
    this.videoURL,
    this.resolution,
  });
}

class YouTubeMux {
  final List<YouTubeQualityOption> videoQualities;
  final String audioURL;

  YouTubeMux({
    this.videoQualities,
    this.audioURL,
  });
}

Future<YouTubeMux> getPlayerYouTubeInfo(String webURL) async {
  var videoID = YoutubePlayer.convertUrlToId(webURL);
  if (videoID != null) {
    YoutubeExplode yt = YoutubeExplode();
    StreamManifest streamManifest =
        await yt.videos.streamsClient.getManifest(webURL);

    List<YouTubeQualityOption> videoQualities = [];
    List<String> videoResolutions = [];
    for (var stream in streamManifest.videoOnly.sortByBitrate()) {
      if (!videoResolutions.contains(stream.videoQualityLabel)) {
        videoQualities.add(
          YouTubeQualityOption(
              videoURL: stream.url.toString(),
              resolution: stream.videoQualityLabel),
        );
        videoResolutions.add(stream.videoQualityLabel);
      }

      print(stream.videoQualityLabel);
    }

    AudioStreamInfo streamAudioInfo =
        streamManifest.audioOnly.sortByBitrate().last;
    String audioURL = streamAudioInfo.url.toString();

    return YouTubeMux(
      videoQualities: videoQualities,
      audioURL: audioURL,
    );
  } else {
    return null;
  }
}

Future<bool> checkYouTubeClosedCaptionAvailable(String videoID) async {
  String httpSubs = await http
      .read("https://www.youtube.com/api/timedtext?lang=ja&v=" + videoID);
  return (httpSubs.isNotEmpty);
}

String getTimestampFromDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String threeDigits(int n) => n.toString().padLeft(3, "0");

  String hours = twoDigits(duration.inHours);
  String mins = twoDigits(duration.inMinutes.remainder(60));
  String secs = twoDigits(duration.inSeconds.remainder(60));
  String mills = threeDigits(duration.inMilliseconds.remainder(1000));
  return "$hours:$mins:$secs.$mills";
}

String getYouTubeDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");

  String hours = twoDigits(duration.inHours);
  String mins = twoDigits(duration.inMinutes.remainder(60));
  String secs = twoDigits(duration.inSeconds.remainder(60));

  if (duration.inHours != 0) {
    return "  $hours:$mins:$secs  ";
  } else if (duration.inMinutes != 0) {
    return "  $mins:$secs  ";
  } else {
    return "  0:$secs";
  }
}

String getTimeAgoFormatted(DateTime videoDate) {
  final int diffInHours = DateTime.now().difference(videoDate).inHours;

  String timeAgo = '';
  String timeUnit = '';
  int timeValue = 0;

  if (diffInHours < 1) {
    final diffInMinutes = DateTime.now().difference(videoDate).inMinutes;
    timeValue = diffInMinutes;
    timeUnit = 'minute';
  } else if (diffInHours < 24) {
    timeValue = diffInHours;
    timeUnit = 'hour';
  } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
    timeValue = (diffInHours / 24).floor();
    timeUnit = 'day';
  } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
    timeValue = (diffInHours / (24 * 7)).floor();
    timeUnit = 'week';
  } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
    timeValue = (diffInHours / (24 * 30)).floor();
    timeUnit = 'month';
  } else {
    timeValue = (diffInHours / (24 * 365)).floor();
    timeUnit = 'year';
  }

  timeAgo = timeValue.toString() + ' ' + timeUnit;
  timeAgo += timeValue > 1 ? 's' : '';

  return timeAgo + ' ago';
}

String getViewCountFormatted(int num) {
  if (num > 999 && num < 99999) {
    return "${(num / 1000).toStringAsFixed(1)}K";
  } else if (num > 99999 && num < 999999) {
    return "${(num / 1000).toStringAsFixed(0)}K";
  } else if (num > 999999 && num < 999999999) {
    return "${(num / 1000000).toStringAsFixed(1)}M";
  } else if (num > 999999999) {
    return "${(num / 1000000000).toStringAsFixed(1)}B";
  } else {
    return num.toString();
  }
}

String formatTimeString(double time) {
  double msDouble = time * 1000;
  int milliseconds = (msDouble % 1000).floor();
  int seconds = (time % 60).floor();
  int minutes = (time / 60 % 60).floor();
  int hours = (time / 60 / 60 % 60).floor();

  String millisecondsPadded = milliseconds.toString().padLeft(3, "0");
  String secondsPadded = seconds.toString().padLeft(2, "0");
  String minutesPadded = minutes.toString().padLeft(2, "0");
  String hoursPadded = hours.toString().padLeft(2, "0");

  String formatted = hoursPadded +
      ":" +
      minutesPadded +
      ":" +
      secondsPadded +
      "," +
      millisecondsPadded;
  return formatted;
}

Future<List<Video>> searchYouTubeVideos(String searchQuery) async {
  YoutubeExplode yt = YoutubeExplode();
  SearchList searchResults = await yt.search.getVideos(searchQuery);

  List<Video> videos = [];
  for (Video video in searchResults) {
    videos.add(video);
  }

  return videos;
}

Future<List<Video>> searchYouTubeTrendingVideos() {
  YoutubeExplode yt = YoutubeExplode();
  return yt.playlists.getVideos("PLuXL6NS58Dyx-wTr5o7NiC7CZRbMA91DC").toList();
}

Future<void> requestPermissions() async {
  const platform = const MethodChannel('com.lrorpilla.api/ankidroid');
  await platform.invokeMethod('requestPermissions');
}

Future<void> addNote(
  String deck,
  String image,
  String audio,
  String sentence,
  String answer,
  String meaning,
  String reading,
) async {
  const platform = const MethodChannel('com.lrorpilla.api/ankidroid');

  try {
    await platform.invokeMethod('addNote', <String, dynamic>{
      'deck': deck,
      'image': image,
      'audio': audio,
      'sentence': sentence,
      'answer': answer,
      'meaning': meaning,
      'reading': reading,
    });
  } on PlatformException catch (e) {
    print("Failed to add note via AnkiDroid API");
    print(e);
  }
}

Future<List<String>> getDecks() async {
  const platform = const MethodChannel('com.lrorpilla.api/ankidroid');
  Map<dynamic, dynamic> deckMap = await platform.invokeMethod('getDecks');

  return deckMap.values.toList().cast<String>();
}

class DeckDropDown extends StatefulWidget {
  final List<String> decks;
  final ValueNotifier<String> selectedDeck;

  const DeckDropDown({this.decks, this.selectedDeck});

  @override
  _DeckDropDownState createState() =>
      _DeckDropDownState(this.selectedDeck, this.decks);
}

class _DeckDropDownState extends State<DeckDropDown> {
  final ValueNotifier<String> _selectedDeck;
  final List<String> _decks;

  _DeckDropDownState(this._selectedDeck, this._decks);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: _selectedDeck.value,
      items: _decks.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text("  $value"),
        );
      }).toList(),
      onChanged: (selectedDeck) async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("lastDeck", selectedDeck);

        setState(() {
          _selectedDeck.value = selectedDeck;
        });
      },
    );
  }
}

List<List<Word>> getLinesFromWords(
    BuildContext context, SubtitleStyle style, List<Word> words) {
  List<List<Word>> lines = [];
  List<Word> working = [];
  String concatenate = "";
  TextPainter textPainter;
  double width = MediaQuery.of(context).size.width;
  words.add(Word("", "", Grammar.Unassigned, "", Pos.TBD, "", TokenNode("")));

  for (int i = 0; i < words.length; i++) {
    Word word = words[i];
    textPainter = TextPainter()
      ..text = TextSpan(text: concatenate, style: TextStyle(fontSize: 24))
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: double.infinity);

    if (word.word == '␜' ||
        i == words.length - 1 ||
        textPainter.width >=
            width - style.position.left - style.position.right) {
      List<Word> line = [];
      for (int i = 0; i < working.length; i++) {
        line.add(working[i]);
      }

      lines.add(line);
      working = [];
      concatenate = "";

      working.add(word);
      concatenate += word.word;
    } else {
      working.add(word);
      concatenate += word.word;
    }
  }

  return lines;
}

List<List<int>> getIndexesFromWords(
    BuildContext context, SubtitleStyle style, List<Word> words) {
  words.add(Word("", "", Grammar.Unassigned, "", Pos.TBD, "", TokenNode("")));

  List<List<int>> lines = [];
  List<int> working = [];
  String concatenate = "";
  TextPainter textPainter;

  double width = MediaQuery.of(context).size.width;

  for (int i = 0; i < words.length; i++) {
    Word word = words[i];
    textPainter = TextPainter()
      ..text = TextSpan(text: concatenate, style: TextStyle(fontSize: 24))
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: double.infinity);

    if (word.word == '␜' ||
        i == words.length - 1 ||
        textPainter.width >=
            width - style.position.left - style.position.right) {
      List<int> line = [];
      for (int i = 0; i < working.length; i++) {
        line.add(working[i]);
      }

      lines.add(line);
      working = [];
      concatenate = "";

      working.add(i);
      concatenate += word.word;
    } else {
      working.add(i);
      concatenate += word.word;
    }
  }

  return lines;
}

String getBetterNumberTag(String text) {
  text = text.replaceAll("50)", "㊿");
  text = text.replaceAll("49)", "㊾");
  text = text.replaceAll("48)", "㊽");
  text = text.replaceAll("47)", "㊼");
  text = text.replaceAll("46)", "㊻");
  text = text.replaceAll("45)", "㊺");
  text = text.replaceAll("44)", "㊹");
  text = text.replaceAll("43)", "㊸");
  text = text.replaceAll("42)", "㊷");
  text = text.replaceAll("41)", "㊶");
  text = text.replaceAll("39)", "㊴");
  text = text.replaceAll("38)", "㊳");
  text = text.replaceAll("37)", "㊲");
  text = text.replaceAll("36)", "㊱");
  text = text.replaceAll("35)", "㉟");
  text = text.replaceAll("34)", "㉞");
  text = text.replaceAll("33)", "㉝");
  text = text.replaceAll("32)", "㉜");
  text = text.replaceAll("31)", "㉛");
  text = text.replaceAll("30)", "㉚");
  text = text.replaceAll("29)", "㉙");
  text = text.replaceAll("28)", "㉘");
  text = text.replaceAll("27)", "㉗");
  text = text.replaceAll("26)", "㉖");
  text = text.replaceAll("25)", "㉕");
  text = text.replaceAll("24)", "㉔");
  text = text.replaceAll("23)", "㉓");
  text = text.replaceAll("22)", "㉒");
  text = text.replaceAll("21)", "㉑");
  text = text.replaceAll("20)", "⑳");
  text = text.replaceAll("19)", "⑲");
  text = text.replaceAll("18)", "⑱");
  text = text.replaceAll("17)", "⑰");
  text = text.replaceAll("16)", "⑯");
  text = text.replaceAll("15)", "⑮");
  text = text.replaceAll("14)", "⑭");
  text = text.replaceAll("13)", "⑬");
  text = text.replaceAll("12)", "⑫");
  text = text.replaceAll("11)", "⑪");
  text = text.replaceAll("10)", "⑩");
  text = text.replaceAll("9)", "⑨");
  text = text.replaceAll("8)", "⑧");
  text = text.replaceAll("7)", "⑦");
  text = text.replaceAll("6)", "⑥");
  text = text.replaceAll("5)", "⑤");
  text = text.replaceAll("4)", "④");
  text = text.replaceAll("3)", "③");
  text = text.replaceAll("2)", "②");
  text = text.replaceAll("1)", "①");

  return text;
}

YouTubeQualityOption getLastPlayedQuality(
    List<YouTubeQualityOption> qualities) {
  String lastPlayedQuality = globalPrefs.getString("lastPlayedQuality");

  if (lastPlayedQuality != null) {
    for (YouTubeQualityOption quality in qualities) {
      // If we find the quality they last played, we return that.
      if (quality.resolution == lastPlayedQuality) {
        return quality;
      }
    }
    // In this case, we know that they have set a quality that doesn't exist,
    // maybe it's a low quality video -- so we take the best quality.
    print(lastPlayedQuality);
    return qualities.last;
  } else {
    // We don't know if we could abuse their mobile data,
    // let's try the average.
    return (qualities[(qualities.length - 2).ceil()]);
  }
}

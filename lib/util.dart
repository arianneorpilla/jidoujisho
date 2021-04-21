import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter_youtube_dl/youtube_dl.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:mecab_dart/mecab_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:shell/shell.dart';
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

  String inputPath = (controller.dataSourceType == DataSourceType.network)
      ? chewie.currentVideoQuality.videoURL
      : controller.dataSource;
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

  String inputPath;

  if (controller.dataSourceType == DataSourceType.file) {
    inputPath = controller.dataSource;
  } else {
    inputPath = chewie.streamData.audioURL;
  }

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

  List<String> decks;
  try {
    requestPermissions();
    decks = await getDecks();
    await exportCurrentFrame(chewie, controller);
    await exportCurrentAudio(chewie, controller, subtitle);

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
  } catch (ex) {
    clipboard.value = "&<&>exportlong&<&>";
  }
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
  final String videoResolution;

  YouTubeQualityOption({
    this.videoURL,
    this.videoResolution,
  });
}

class YouTubeMux {
  final String title;
  final String channel;
  final List<YouTubeQualityOption> videoQualities;
  final String audioURL;
  final String audioMetadata;
  final String thumbnailURL;
  final String videoURL;

  YouTubeMux({
    this.title,
    this.channel,
    this.videoQualities,
    this.audioURL,
    this.audioMetadata,
    this.thumbnailURL,
    this.videoURL,
  });
}

Future<YouTubeMux> getPlayerYouTubeInfo(String webURL) async {
  var videoID = YoutubePlayer.convertUrlToId(webURL);

  if (videoID != null) {
    YoutubeExplode yt = YoutubeExplode();
    Video video = await yt.videos.get(videoID);
    String title = video.title;
    String channel = video.author;
    String thumbnailURL = video.thumbnails.highResUrl;

    StreamManifest streamManifest =
        await yt.videos.streamsClient.getManifest(webURL);

    List<YouTubeQualityOption> videoQualities = [];
    List<String> videoResolutions = [];

    for (var stream in streamManifest.videoOnly.sortByBitrate()) {
      String resolutionLabel = stream.videoQualityLabel;
      if (!stream.videoQualityLabel.contains("p")) {
        resolutionLabel = stream.videoQualityLabel + "p";
      }
      if (stream.videoQualityLabel.contains("p60")) {
        resolutionLabel = stream.videoQualityLabel.replaceAll("p60", "p");
      }

      if (!videoResolutions.contains(resolutionLabel)) {
        videoQualities.add(
          YouTubeQualityOption(
            videoURL: stream.url.toString(),
            videoResolution: resolutionLabel,
          ),
        );
        videoResolutions.add(resolutionLabel);
      }
    }

    AudioStreamInfo streamAudioInfo =
        streamManifest.audioOnly.sortByBitrate().last;
    String audioURL = streamAudioInfo.url.toString();
    String audioMetadata =
        "[${streamAudioInfo.container.name}] - [${streamAudioInfo.bitrate.kiloBitsPerSecond.floor()} Kbps]";

    return YouTubeMux(
      title: title,
      channel: channel,
      videoQualities: videoQualities,
      audioURL: audioURL,
      audioMetadata: audioMetadata,
      thumbnailURL: thumbnailURL,
      videoURL: webURL,
    );
  } else {
    return null;
  }
}

Future<bool> checkYouTubeClosedCaptionAvailable(String videoID) async {
  String httpSubs = await http.read(
      Uri.parse("https://www.youtube.com/api/timedtext?lang=ja&v=" + videoID));
  return (httpSubs.isNotEmpty);
}

FutureOr<String> getPublishMetadata(Video result) async {
  String videoPublishTime =
      result.uploadDate == null ? "" : getTimeAgoFormatted(result.uploadDate);
  String videoViewCount = getViewCountFormatted(result.engagement.viewCount);
  String videoDetails = "$videoPublishTime · $videoViewCount views";

  if (result.uploadDate != null) {
    return videoDetails;
  } else {
    YoutubeExplode yt = YoutubeExplode();
    Video video = await yt.videos.get(result.id);

    String videoPublishTime =
        video.uploadDate == null ? "" : getTimeAgoFormatted(video.uploadDate);
    String videoViewCount = getViewCountFormatted(video.engagement.viewCount);
    String videoDetails = "$videoPublishTime · $videoViewCount views";

    return videoDetails;
  }
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
    return "  0:$secs  ";
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

Future<List<Video>> getLatestChannelVideos(String channelID) async {
  YoutubeExplode yt = YoutubeExplode();
  List<Video> searchResults = await yt.channels.getUploads(channelID).toList();

  return searchResults;
}

Future<List<Video>> getLatestPlaylistVideos(String playlistID) async {
  YoutubeExplode yt = YoutubeExplode();
  SearchList searchResults = await yt.playlists.getVideos(playlistID).toList();
  return searchResults;
}

Future<List<Video>> searchYouTubeTrendingVideos() {
  YoutubeExplode yt = YoutubeExplode();
  return yt.playlists.getVideos("PLuXL6NS58Dyx-wTr5o7NiC7CZRbMA91DC").toList();
}

FutureOr<List<Channel>> getSubscribedChannels() async {
  YoutubeExplode yt = YoutubeExplode();
  String prefsChannels = globalPrefs.getString('subscribedChannels') ?? '[]';
  List<String> channelIDs =
      (jsonDecode(prefsChannels) as List<dynamic>).cast<String>();

  List<Future<Channel>> futureChannels = [];
  channelIDs.forEach(
      (channelID) async => {futureChannels.add(yt.channels.get(channelID))});

  List<Channel> channels = await Future.wait(futureChannels);
  channels
      .sort(((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase())));

  return channels;
}

FutureOr<List<Playlist>> getSubscribedPlaylists() {
  YoutubeExplode yt = YoutubeExplode();
  String prefsChannels = globalPrefs.getString('subscribedPlaylists') ?? '[]';
  List<String> playlistIDs =
      (jsonDecode(prefsChannels) as List<dynamic>).cast<String>();

  List<Future<Playlist>> futurePlaylists = [];
  playlistIDs.forEach((playlistID) async =>
      {futurePlaylists.add(yt.playlists.get(playlistID))});

  return Future.wait(futurePlaylists);
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
      ..text = TextSpan(
          text: concatenate + word.word, style: TextStyle(fontSize: 24))
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: double.infinity);

    if (word.word.contains('␜') ||
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
      ..text = TextSpan(
          text: concatenate + word.word, style: TextStyle(fontSize: 24))
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: double.infinity);

    if (word.word.contains('␜') ||
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
      if (quality.videoResolution == lastPlayedQuality) {
        return quality;
      }
    }
    // In this case, we know that they have set a quality that doesn't exist,
    // maybe it's a low quality video -- so we take the best quality.
    return qualities.last;
  } else {
    // We don't know if we could abuse their mobile data,
    // let's try the average.
    return qualities
            .firstWhere((element) => element.videoResolution == "360p") ??
        qualities.first;
  }
}

Future<void> addNewChannel(String videoURL) async {
  YoutubeExplode yt = YoutubeExplode();

  String channelID = (await yt.channels.getByVideo(videoURL)).id.value;
  String prefsChannels = globalPrefs.getString('subscribedChannels') ?? '[]';
  List<String> channelIDs =
      (jsonDecode(prefsChannels) as List<dynamic>).cast<String>();

  channelCache = AsyncMemoizer();
  if (!channelIDs.contains(channelID)) {
    channelIDs.add(channelID);
  }

  await globalPrefs.setString('subscribedChannels', jsonEncode(channelIDs));
}

Future<void> removeChannel(Channel channel) async {
  String channelID = channel.id.value;
  String prefsChannels = globalPrefs.getString('subscribedChannels') ?? '[]';
  List<String> channelIDs =
      (jsonDecode(prefsChannels) as List<dynamic>).cast<String>();

  channelCache = AsyncMemoizer();
  channelIDs.remove(channelID);
  await globalPrefs.setString('subscribedChannels', jsonEncode(channelIDs));
}

List<String> getSearchHistory() {
  String prefsHistory = globalPrefs.getString('searchHistory') ?? '[]';
  List<String> history =
      (jsonDecode(prefsHistory) as List<dynamic>).cast<String>();

  return history;
}

Future<void> addSearchHistory(String term) async {
  List<String> history = getSearchHistory();

  if (history.contains(term.trim())) {
    history.remove(term.trim());
  }
  if (term.trim() != "") {
    history.add(term.trim());
  }

  if (history.length >= 14) {
    history = history.sublist(history.length - 14);
  }

  await globalPrefs.setString('searchHistory', jsonEncode(history));
}

Future<void> removeSearchHistory(String term) async {
  List<String> history = getSearchHistory();

  history.remove(term);
  await globalPrefs.setString('searchHistory', jsonEncode(history));
}

class VideoHistory {
  String url;
  String heading;
  String subheading;
  String thumbnail;

  VideoHistory(
    this.url,
    this.heading,
    this.subheading,
    this.thumbnail,
  );

  Map<String, dynamic> toMap() {
    return {
      "url": this.url,
      "heading": this.heading,
      "subheading": this.subheading,
      "thumbnail": this.thumbnail,
    };
  }

  VideoHistory.fromMap(Map<String, dynamic> map) {
    this.url = map['url'];
    this.heading = map['heading'];
    this.subheading = map['subheading'];
    this.thumbnail = map['thumbnail'];
  }
}

List<VideoHistory> getVideoHistory() {
  String prefsVideoHistory = globalPrefs.getString('videoHistory') ?? '[]';
  List<dynamic> history = (jsonDecode(prefsVideoHistory) as List<dynamic>);

  List<VideoHistory> histories = [];
  history.forEach((entry) {
    VideoHistory videoHistory = VideoHistory.fromMap(entry);
    histories.add(videoHistory);
  });

  return histories;
}

Future<void> setVideoHistory(List<VideoHistory> videoHistories) async {
  List<Map<String, dynamic>> maps = [];
  videoHistories.forEach((entry) {
    maps.add(entry.toMap());
  });

  await globalPrefs.setString('videoHistory', jsonEncode(maps));
}

Future<void> addVideoHistory(VideoHistory videoHistory) async {
  List<VideoHistory> videoHistories = getVideoHistory();

  if (videoHistory.thumbnail == null) {
    File videoFile = File(videoHistory.url);
    String photoFileNameDir =
        "$appDirPath/" + path.basenameWithoutExtension(videoFile.path) + ".jpg";
    File photoFile = File(photoFileNameDir);
    if (photoFile.existsSync()) {
      photoFile.deleteSync();
    }

    String formatted = getTimestampFromDuration(Duration(seconds: 5));

    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

    String inputPath = videoHistory.url;
    String exportPath = "\"$photoFileNameDir\"";

    String command =
        "-loglevel quiet -ss $formatted -y -i \"$inputPath\" -frames:v 1 -q:v 2 $exportPath";

    await _flutterFFmpeg.execute(command);

    videoHistory.thumbnail = photoFileNameDir;
  }

  videoHistories.removeWhere((entry) => entry.url == videoHistory.url);
  videoHistories.add(videoHistory);

  if (videoHistories.length >= 20) {
    videoHistories.sublist(0, videoHistories.length - 20).forEach((entry) {
      if (!entry.thumbnail.startsWith("http")) {
        File photoFile = File(entry.thumbnail);
        if (photoFile.existsSync()) {
          photoFile.deleteSync();
        }
      }
    });
    videoHistories = videoHistories.sublist(videoHistories.length - 20);
  }

  await setVideoHistory(videoHistories);
}

Future<void> removeVideoHistory(VideoHistory videoHistory) async {
  List<VideoHistory> videoHistories = getVideoHistory();

  videoHistories.removeWhere((entry) => entry.url == videoHistory.url);
  if (!videoHistory.thumbnail.startsWith("http")) {
    File photoFile = File(videoHistory.thumbnail);
    if (photoFile.existsSync()) {
      photoFile.deleteSync();
    }
  }

  await setVideoHistory(videoHistories);
}

List<DictionaryEntry> getDictionaryHistory() {
  String prefsDictionary = globalPrefs.getString('dictionaryHistory') ?? '[]';
  List<dynamic> history = (jsonDecode(prefsDictionary) as List<dynamic>);

  List<DictionaryEntry> entries = [];
  history.forEach((map) {
    DictionaryEntry entry = DictionaryEntry.fromMap(map);
    entries.add(entry);
  });

  return entries;
}

Future<void> setDictionaryHistory(
    List<DictionaryEntry> dictionaryEntries) async {
  List<Map<String, dynamic>> maps = [];
  dictionaryEntries.forEach((entry) {
    maps.add(entry.toMap());
  });

  await globalPrefs.setString('dictionaryHistory', jsonEncode(maps));
}

Future<void> addDictionaryEntryToHistory(
    DictionaryEntry dictionaryEntry) async {
  List<DictionaryEntry> dictionaryEntries = getDictionaryHistory();

  dictionaryEntries.removeWhere(
    (entry) => entry.word == dictionaryEntry.word,
  );
  dictionaryEntries.add(dictionaryEntry);

  if (dictionaryEntries.length >= 50) {
    dictionaryEntries =
        dictionaryEntries.sublist(dictionaryEntries.length - 50);
  }

  await setDictionaryHistory(dictionaryEntries);
}

Future<void> removeDictionaryEntryFromHistory(
    DictionaryEntry dictionaryEntry) async {
  List<DictionaryEntry> dictionaryEntries = getDictionaryHistory();

  dictionaryEntries.removeWhere(
    (entry) => entry.word == dictionaryEntry.word,
  );

  await setDictionaryHistory(dictionaryEntries);
}

Future<void> initialiseYouTubeDL() async {
  await YoutubeDL.init(null);
}

Future<String> requestAutoGeneratedSubtitles(
  String url,
  ValueNotifier<String> clipboard,
  ValueNotifier<int> subtrack,
) async {
  File autogenSubFile = File('$appDirPath/jidoujisho-autogenSubtitles');
  File vttFile = (Directory("$appDirPath").listSync().firstWhere(
    (fileEntity) => path
        .basename(fileEntity.path)
        .startsWith("jidoujisho-autogenSubtitles"),
    orElse: () {
      return null;
    },
  )) as File;
  if (vttFile != null) {
    vttFile.deleteSync();
  }

  var dir = await getApplicationSupportDirectory();
  var bin = await YoutubeDL.getLibraryDirectory();
  var shell = new Shell();

  shell.navigate(bin.path);
  shell.environment['LD_LIBRARY_PATH'] =
      path.join(dir.path, 'python', 'usr', 'lib');
  shell.environment['SSL_CERT_FILE'] =
      path.join(dir.path, 'python', 'usr', 'etc', 'tls', 'cert.pem');
  shell.environment['PYTHONHOME'] = path.join(dir.path, 'python', 'usr');

  List<String> pparam = [];

  pparam.insert(0, autogenSubFile.path);
  pparam.insert(0, '-o');
  pparam.insert(0, '--verbose');
  pparam.insert(0, 'ja');
  pparam.insert(0, '--sub-lang');
  pparam.insert(0, url);
  pparam.insert(0, '--skip-download');
  pparam.insert(0, '--write-auto-sub');

  pparam.insert(
      0, path.join(dir.path, 'python', 'usr', 'youtube_dl', '__main__.py'));
  pparam.add('--cache-dir');
  pparam.add(path.join(dir.path, 'python', 'usr', 'bin', '.cache'));
  print(pparam);

  var echo = await shell.start('./libpython3.so', pparam);
  var stdout = await echo.stdout.readAsString();
  print(stdout);
  var stderr = await echo.stderr.readAsString();
  print(stderr);
  print("Finished execution");

  vttFile = (Directory("$appDirPath").listSync().firstWhere(
      (fileEntity) => path
          .basename(fileEntity.path)
          .startsWith("jidoujisho-autogenSubtitles"), orElse: () {
    clipboard.value = "&<&>autogenbad&<&>";
    subtrack.value = -51;
    return null;
  })) as File;

  return vttFile.readAsStringSync();
}

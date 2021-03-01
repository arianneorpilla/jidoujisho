import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:ext_video_player/ext_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:unofficial_jisho_api/api.dart';
import 'package:xml2json/xml2json.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:jidoujisho/main.dart';

String getDefaultSubtitles(File file, List<File> internalSubtitles) {
  if (internalSubtitles.isNotEmpty) {
    return internalSubtitles.first.readAsStringSync();
  } else {
    return "";
  }
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

  String startTime = formatTimeString(start);
  String endTime = formatTimeString(start + duration);
  String lineNumber = lineCount.toString();

  String srtLine = "$lineNumber\n$startTime --> $endTime\n$text\n\n";

  return srtLine;
}

Future exportCurrentFrame(VideoPlayerController controller) async {
  File imageFile = File(previewImageDir);
  if (imageFile.existsSync()) {
    imageFile.deleteSync();
  }

  Duration currentTime = controller.value.position;
  String formatted = getTimestampFromDuration(currentTime);

  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  String inputPath = controller.dataSource;
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

Future exportCurrentAudio(
    VideoPlayerController controller, Subtitle subtitle) async {
  File audioFile = File(previewAudioDir);
  if (audioFile.existsSync()) {
    audioFile.deleteSync();
  }

  String timeStart;
  String timeEnd;
  String audioIndex;

  timeStart = getTimestampFromDuration(subtitle.startTime);
  timeEnd = getTimestampFromDuration(subtitle.endTime);

  audioIndex = controller.getCurrentAudioIndex().toString();

  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  String inputPath = controller.dataSource;
  String outputPath = "\"$appDirPath/exportAudio.mp3\"";
  String command =
      "-loglevel quiet -ss $timeStart -to $timeEnd -y -i \"$inputPath\" -map 0:a:$audioIndex $outputPath";

  await _flutterFFmpeg.execute(command);

  return;
}

Future<List<File>> extractSubtitles(File file) async {
  String inputPath = file.path;
  List<File> files = [];

  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

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
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

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

Future exportToAnki(BuildContext context, VideoPlayerController controller,
    Subtitle subtitle, String word, String definition, String reading) async {
  await exportCurrentFrame(controller);
  await exportCurrentAudio(controller, subtitle);

  showAnkiDialog(context, subtitle.text, word, reading, definition);
}

void showAnkiDialog(BuildContext context, String sentence, String answer,
    String reading, String meaning) {
  TextEditingController _sentenceController =
      new TextEditingController(text: sentence);
  TextEditingController _answerController =
      new TextEditingController(text: answer);
  TextEditingController _readingController =
      new TextEditingController(text: reading);
  TextEditingController _meaningController =
      new TextEditingController(text: meaning);

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
      _sentenceController);
  Widget answerField = displayField(
    "Word",
    "Enter the word in the back here",
    Icons.speaker_notes_outlined,
    _answerController,
  );
  Widget readingField = displayField(
      "Reading",
      "Enter the reading of the word here",
      Icons.surround_sound_outlined,
      _readingController);
  Widget meaningField = displayField(
      "Meaning",
      "Enter the meaning in the back here",
      Icons.translate_rounded,
      _meaningController);

  AudioPlayer audioPlayer = AudioPlayer();
  imageCache.clear();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        contentPadding: EdgeInsets.all(8),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Image.file(File(previewImageDir)),
              sentenceField,
              answerField,
              readingField,
              meaningField,
            ],
          ),
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
                _sentenceController.text,
                _answerController.text,
                _readingController.text,
                _meaningController.text,
              );
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

void exportAnkiCard(
    String sentence, String answer, String reading, String meaning) {
  String frontText;
  String backText;

  DateTime now = DateTime.now();
  String newFileName =
      "jidoujisho-" + DateFormat('yyyyMMddTkkmmss').format(now);

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

  frontText =
      "$addAudio\n$addImage\n<p style=\"font-size:30px;\">$sentence</p>";
  backText =
      "<p style=\"margin: 0\">$reading</h6>\n<h2 style=\"margin: 0\">$answer</h2><p><small>$meaning</p></small>";

  Share.share(
    backText,
    subject: frontText,
  );
}

Future<List<String>> getWordDetails(String searchTerm) async {
  bool forceJisho = searchTerm.contains("@usejisho@");
  searchTerm = searchTerm.replaceAll("@usejisho@", "");

  String removeLastNewline(String n) => n = n.substring(0, n.length - 2);
  bool hasDuplicateReading(String readings, String reading) =>
      readings.contains("$reading; ");

  JishoAPIResult results = await searchForPhrase(searchTerm);
  JishoResult bestResult = results.data.first;

  List<JishoJapaneseWord> words = bestResult.japanese;
  List<JishoWordSense> senses = bestResult.senses;

  String exportTerm = "";
  String exportReadings = "";
  String exportDefinitions = "";

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
      exportTerm = bestResult.slug;
    }
  }

  if (exportReadings == searchTerm || bestResult.slug == exportReadings) {
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

      exportDefinitions =
          "$exportDefinitions$i) $definitions -$partsOfSpeech \n";
    },
  );
  exportDefinitions = removeLastNewline(exportDefinitions);

  List<String> details = [];

  print("SEARCH TERM: $searchTerm");
  print("EXPORT TERM: $exportTerm");

  if (customDictionary.isEmpty || forceJisho) {
    details.add(exportTerm ?? searchTerm);
    details.add(exportReadings);
    details.add(exportDefinitions);
  } else {
    int resultIndex;

    final searchResult = customDictionaryFuzzy.search(searchTerm, 1);
    print(searchResult);

    if (searchResult.isNotEmpty && searchResult.first.score == 0) {
      resultIndex = searchResult.first.matches.first.arrayIndex;

      details.add(customDictionary[resultIndex].word);
      details.add(customDictionary[resultIndex].reading);
      details.add(customDictionary[resultIndex].meaning);

      return details;
    } else {
      words.forEach((word) {
        String term = word.word;

        if (term != null) {
          final termResult = customDictionaryFuzzy.search(term, 1);

          print(termResult);

          if (termResult.isNotEmpty && termResult.first.score == 0.0) {
            resultIndex = termResult.first.matches.first.arrayIndex;
            print("$resultIndex set - $term");
          }
        }
      });
    }

    if (resultIndex == null) {
      resultIndex = searchResult.first.matches.first.arrayIndex;
    }

    details.add(customDictionary[resultIndex].word);
    details.add(customDictionary[resultIndex].reading);
    details.add(customDictionary[resultIndex].meaning);
  }

  return details;
}

class DictionaryEntry {
  String word;
  String reading;
  String meaning;

  DictionaryEntry(
    this.word,
    this.reading,
    this.meaning,
  );
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
            entry[0].toString(), entry[1].toString(), entry[5].toString()));
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

Future<String> getPlayerYouTubeInfo(String webURL) async {
  var videoID = YoutubePlayer.convertUrlToId(webURL);
  if (videoID != null) {
    YoutubeExplode yt = YoutubeExplode();
    var streamManifest = await yt.videos.streamsClient.getManifest(webURL);
    var streamInfo = streamManifest.muxed.withHighestBitrate();
    var streamURL = streamInfo.url.toString();

    return streamURL;
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
  } else {
    if ("$secs" == "00") {
      return "  0:$mins  ";
    } else {
      return "  $secs:$mins  ";
    }
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

Future<SearchList> searchYouTubeVideos(String searchQuery) {
  YoutubeExplode yt = YoutubeExplode();
  return yt.search.getVideos(searchQuery);
}

Future<ClosedCaptionManifest> getCaptions(String videoID) async {
  YoutubeExplode yt = YoutubeExplode();
  return yt.videos.closedCaptions.getManifest(videoID);
}

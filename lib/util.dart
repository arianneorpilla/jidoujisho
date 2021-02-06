import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:ext_video_player/ext_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:path/path.dart' as path;
import 'package:unofficial_jisho_api/api.dart';
import 'package:xml2json/xml2json.dart';

import 'package:jidoujisho/main.dart';

String getTimestampFromDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String threeDigits(int n) => n.toString().padLeft(3, "0");

  String hours = twoDigits(duration.inHours);
  String mins = twoDigits(duration.inMinutes.remainder(60));
  String secs = twoDigits(duration.inSeconds.remainder(60));
  String mills = threeDigits(duration.inMilliseconds.remainder(1000));
  return "$hours:$mins:$secs.$mills";
}

String loadDefaultSubtitles(File file, List<File> internalSubtitles) {
  String content = "";

  if (hasExternalSubtitles(file)) {
    content = getExternalSubtitles(file).readAsStringSync();
  } else if (internalSubtitles.isNotEmpty) {
    content = (internalSubtitles[0]).readAsStringSync();
  }

  return content;
}

File getExternalSubtitles(File file) {
  String videoDir = path.dirname(file.path);
  String videoBasename = path.basenameWithoutExtension(file.path);
  String subtitlePath = "$videoDir/$videoBasename.srt";

  return File(subtitlePath);
}

bool hasExternalSubtitles(File file) {
  String subtitlePath = getExternalSubtitles(file).path;
  File subtitleFile = File(subtitlePath);

  return subtitleFile.existsSync();
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
      "-ss $formatted -y -i \"$inputPath\" -frames:v 1 -q:v 2 $exportPath";

  await _flutterFFmpeg.execute(command);

  return;
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
      "-ss $timeStart -to $timeEnd -y -i \"$inputPath\" -map 0:a:$audioIndex $outputPath";

  await _flutterFFmpeg.execute(command);

  return;
}

Future<List<File>> extractSubtitles(File file) async {
  List<File> files = [];
  if (hasExternalSubtitles(file)) {
    files.add(getExternalSubtitles(file));
  }

  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  String inputPath = file.path;

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

  AudioPlayer audioPlayer = AudioPlayer();
  imageCache.clear();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(8),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Image.file(File(previewImageDir)),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: _sentenceController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.format_align_center_rounded),
                  suffixIcon: IconButton(
                    iconSize: 12,
                    onPressed: () => _sentenceController.clear(),
                    icon: Icon(Icons.clear),
                  ),
                  labelText: "Sentence",
                  hintText: "Enter front of card or sentence here",
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: _answerController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.speaker_notes_outlined),
                  suffixIcon: IconButton(
                    iconSize: 12,
                    onPressed: () => _answerController.clear(),
                    icon: Icon(Icons.clear),
                  ),
                  labelText: "Word",
                  hintText: "Enter the word in the back here",
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: _readingController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.surround_sound_outlined),
                  suffixIcon: IconButton(
                    iconSize: 12,
                    onPressed: () => _readingController.clear(),
                    icon: Icon(Icons.clear),
                  ),
                  labelText: "Reading",
                  hintText: "Enter the reading of the word here",
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: _meaningController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.translate_rounded),
                  suffixIcon: IconButton(
                    iconSize: 12,
                    onPressed: () => _meaningController.clear(),
                    icon: Icon(Icons.clear),
                  ),
                  labelText: "Meaning",
                  hintText: "Enter the meaning in the back here",
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('PREVIEW AUDIO'),
            onPressed: () async {
              await audioPlayer.stop();
              await audioPlayer.play(previewAudioDir, isLocal: true);
            },
          ),
          FlatButton(
            child: Text('CANCEL'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('EXPORT'),
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
  String newFileName = DateFormat('yyyyMMddTkkmmss').format(now);

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

Future exportToAnki(
    BuildContext context,
    VideoPlayerController controller,
    Subtitle subtitle,
    String clipboard,
    String definition,
    String reading) async {
  await exportCurrentFrame(controller);
  await exportCurrentAudio(controller, subtitle);

  showAnkiDialog(context, subtitle.text, clipboard, reading, definition);
}

Future<List<String>> getWordDetails(String searchTerm) async {
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

  details.add(exportTerm ?? searchTerm);
  details.add(exportReadings);
  details.add(exportDefinitions);

  return details;
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
  String text = line["\$"];

  text.replaceAll("\\n", "\n");

  String startTime = formatTimeString(start);
  String endTime = formatTimeString(start + duration);

  String srtLine = lineCount.toString() +
      "\n" +
      startTime +
      " --> " +
      endTime +
      "\n" +
      text +
      "\n\n";

  return srtLine;
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

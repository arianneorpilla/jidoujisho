import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as im;
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jidoujisho/dictionary.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:path/path.dart' as path;
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ve_dart/ve_dart.dart';
import 'package:wakelock/wakelock.dart';

import 'package:jidoujisho/main.dart';
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:jidoujisho/viewer.dart';

void unlockLandscape() {
  setResumableByMediaType();
  Wakelock.disable();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top]);
}

void lockLandscape() {
  Wakelock.enable();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIOverlays([]);
}

enum JidoujishoPlayerMode {
  localFile,
  youtubeStream,
  networkStream,
}

class HistoryItemPosition {
  String url;
  int position;

  HistoryItemPosition(this.url, this.position);

  Map<String, dynamic> toMap() {
    return {
      "url": this.url,
      "position": this.position,
    };
  }

  HistoryItemPosition.fromMap(Map<String, dynamic> map) {
    this.url = map['url'];
    this.position = map['position'];
  }

  @override
  String toString() {
    return "HistoryPosition ($url)";
  }
}

class HistoryItem {
  String url;
  String heading;
  String subheading;
  String thumbnail;
  String channelId;
  int duration;
  int position;

  HistoryItem(
    this.url,
    this.heading,
    this.subheading,
    this.thumbnail,
    this.channelId,
    this.duration,
  );

  Map<String, dynamic> toMap() {
    return {
      "url": this.url,
      "heading": this.heading,
      "subheading": this.subheading,
      "thumbnail": this.thumbnail,
      "channelId": this.channelId,
      "duration": this.duration,
    };
  }

  HistoryItem.fromMap(Map<String, dynamic> map) {
    this.url = map['url'];
    this.heading = map['heading'];
    this.subheading = map['subheading'];
    this.thumbnail = map['thumbnail'];
    this.channelId = map['channelId'];
    this.duration = map['duration'];
  }

  @override
  String toString() {
    return "History ($url)";
  }
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

List<File> extractWebSubtitle(String webSubtitle) {
  List<File> files = [];

  String subPath = "$gAppDirPath/extractWebSrt.srt";
  File subFile = File(subPath);
  if (subFile.existsSync()) {
    subFile.deleteSync();
  }

  subFile.createSync();
  subFile.writeAsStringSync(webSubtitle);
  files.add(subFile);

  return files;
}

Future<List<File>> extractSubtitles(String inputPath) async {
  List<File> files = [];
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  final FlutterFFmpegConfig _flutterFFmpegConfig = new FlutterFFmpegConfig();

  for (int i = 0; i < 99; i++) {
    String outputPath = "\"$gAppDirPath/extractSrt$i.srt\"";
    String command =
        "-loglevel verbose -i \"$inputPath\" -map 0:s:$i $outputPath";

    String subPath = "$gAppDirPath/extractSrt$i.srt";
    File subFile = File(subPath);

    if (subFile.existsSync()) {
      subFile.deleteSync();
    }

    await _flutterFFmpeg.execute(command);
    String output = await _flutterFFmpegConfig.getLastCommandOutput();
    if (output.contains("Stream map '0:s:$i' matches no streams.")) {
      break;
    }

    files.add(subFile);
  }

  return files;
}

// Future<File> extractSingleSubtitle(String inputPath, int i) async {
//   final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

//   String outputPath = "\"$gAppDirPath/extractSrt$i.srt\"";
//   String command = "-loglevel quiet -i \"$inputPath\" -map 0:s:$i $outputPath";

//   String subPath = "$gAppDirPath/extractSrt$i.srt";
//   File subFile = File(subPath);

//   if (subFile.existsSync()) {
//     subFile.deleteSync();
//   }

//   await _flutterFFmpeg.execute(command);

//   if (await subFile.exists()) {
//     if (subFile.readAsStringSync().isEmpty) {
//       subFile.deleteSync();
//       return null;
//     } else {
//       return subFile;
//     }
//   } else {
//     return null;
//   }
// }

String sanitizeSrtNewlines(String text) {
  List<String> split = text.split("\n");

  for (int i = 0; i < 10; i++) {
    for (int i = 1; i < split.length; i++) {
      String currentLine = split[i];
      String previousLine = split[i - 1];

      if (previousLine.contains("-->") && currentLine.trim().isEmpty) {
        split.removeAt(i);
        split.removeAt(i - 1);
        split.removeAt(i - 2);
      }
    }
  }

  return split.join("\n");
}

String sanitizeVttNewlines(String text) {
  List<String> split = text.split("\n ");

  for (int i = 0; i < 10; i++) {
    for (int i = 1; i < split.length; i++) {
      String currentLine = split[i];
      String previousLine = split[i - 1];

      if (previousLine.contains("-->") && currentLine.trim().isEmpty) {
        split.removeAt(i);
      }
      if (previousLine.contains("-->") && currentLine.trim().isEmpty) {
        split.removeAt(i);
      }
    }
  }

  return split.join("\n");
}

Future<File> extractExternalSubtitles(File file) async {
  if (!file.existsSync()) {
    return null;
  } else if (file.path.toLowerCase().endsWith("srt")) {
    return file;
  }

  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  String inputPath = file.path;
  String outputPath = "\"$gAppDirPath/extractExternal.srt\"";
  String command =
      "-loglevel quiet -f ass -c:s ass -i \"$inputPath\" -map 0:s:0 -c:s subrip $outputPath";

  String subPath = "$gAppDirPath/extractExternal.srt";
  File subFile = File(subPath);

  if (subFile.existsSync()) {
    subFile.deleteSync();
  }

  await _flutterFFmpeg.execute(command);
  return subFile;
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

List<List<Word>> getLinesFromWords(BuildContext context, SubtitleStyle style,
    List<Word> words, double fontSize) {
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
        text: concatenate + word.word,
        style: TextStyle(fontSize: fontSize),
      )
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: double.infinity);

    if (word.word.contains('␜') ||
        i == words.length - 1 ||
        textPainter.width >=
            width - style.position.left - style.position.right - 20) {
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
  BuildContext context,
  SubtitleStyle style,
  List<Word> words,
  double fontSize,
) {
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
          text: concatenate + word.word,
          style: TextStyle(
            fontSize: fontSize,
          ))
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: double.infinity);

    if (word.word.contains('␜') ||
        i == words.length - 1 ||
        textPainter.width >=
            width - style.position.left - style.position.right - 20) {
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
  text = text.replaceAll("40)", "㊵");
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

String getMonolingualNumberTag(String text) {
  text = text.replaceAll("(50)", "\n㊿ ");
  text = text.replaceAll("(49)", "\n㊾ ");
  text = text.replaceAll("(48)", "\n㊽ ");
  text = text.replaceAll("(47)", "\n㊼ ");
  text = text.replaceAll("(46)", "\n㊻ ");
  text = text.replaceAll("(45)", "\n㊺ ");
  text = text.replaceAll("(44)", "\n㊹ ");
  text = text.replaceAll("(43)", "\n㊸ ");
  text = text.replaceAll("(42)", "\n㊷ ");
  text = text.replaceAll("(41)", "\n㊶ ");
  text = text.replaceAll("(40)", "\n㊵ ");
  text = text.replaceAll("(39)", "\n㊴ ");
  text = text.replaceAll("(38)", "\n㊳ ");
  text = text.replaceAll("(37)", "\n㊲ ");
  text = text.replaceAll("(36)", "\n㊱ ");
  text = text.replaceAll("(35)", "\n㉟ ");
  text = text.replaceAll("(34)", "\n㉞ ");
  text = text.replaceAll("(33)", "\n㉝ ");
  text = text.replaceAll("(32)", "\n㉜ ");
  text = text.replaceAll("(31)", "\n㉛ ");
  text = text.replaceAll("(30)", "\n㉚ ");
  text = text.replaceAll("(29)", "\n㉙ ");
  text = text.replaceAll("(28)", "\n㉘ ");
  text = text.replaceAll("(27)", "\n㉗ ");
  text = text.replaceAll("(26)", "\n㉖ ");
  text = text.replaceAll("(25)", "\n㉕ ");
  text = text.replaceAll("(24)", "\n㉔ ");
  text = text.replaceAll("(23)", "\n㉓ ");
  text = text.replaceAll("(22)", "\n㉒ ");
  text = text.replaceAll("(21)", "\n㉑ ");
  text = text.replaceAll("(20)", "\n⑳ ");
  text = text.replaceAll("(19)", "\n⑲ ");
  text = text.replaceAll("(18)", "\n⑱ ");
  text = text.replaceAll("(17)", "\n⑰ ");
  text = text.replaceAll("(16)", "\n⑯ ");
  text = text.replaceAll("(15)", "\n⑮ ");
  text = text.replaceAll("(14)", "\n⑭ ");
  text = text.replaceAll("(13)", "\n⑬ ");
  text = text.replaceAll("(12)", "\n⑫ ");
  text = text.replaceAll("(11)", "\n⑪ ");
  text = text.replaceAll("(10)", "\n⑩ ");
  text = text.replaceAll("(9)", "\n⑨ ");
  text = text.replaceAll("(8)", "\n⑧ ");
  text = text.replaceAll("(7)", "\n⑦ ");
  text = text.replaceAll("(6)", "\n⑥ ");
  text = text.replaceAll("(5)", "\n⑤ ");
  text = text.replaceAll("(4)", "\n④ ");
  text = text.replaceAll("(3)", "\n③ ");
  text = text.replaceAll("(2)", "\n② ");
  text = text.replaceAll("(1)", "\n① ");

  return text;
}

// bool isCharacterFullWidthNumber(String number) {
//   switch (number.substring(0, 0)) {
//     case "１":
//     case "２":
//     case "３":
//     case "４":
//     case "５":
//     case "６":
//     case "７":
//     case "８":
//     case "９":
//     case "０":
//       return true;
//     default:
//       return false;
//   }
// }

Future<List<String>> scrapeBingImages(
    BuildContext context, String searchTerm) async {
  List<String> entries = [];

  var client = http.Client();
  http.Response response = await client.get(Uri.parse(
      'https://www.bing.com/images/search?q=$searchTerm&FORM=HDRSC2'));
  var document = parser.parse(response.body);

  List<dom.Element> imgElements = document.getElementsByClassName("iusc");

  if (imgElements == null) {
    return [];
  }

  for (dom.Element imgElement in imgElements) {
    Map<dynamic, dynamic> imgMap = jsonDecode(imgElement.attributes["m"]);
    String imageURL = imgMap["turl"];
    entries.add(imageURL);

    precacheImage(new NetworkImage(imageURL), context);
  }

  return entries;
}

String stripLatinCharactersFromText(String subtitleText) {
  subtitleText =
      subtitleText.replaceAll(RegExp(r'(?![×])[A-zÀ-ú\u0160-\u0161œûōī]'), "○");
  subtitleText = subtitleText.replaceAll(
      RegExp(r"[-!%^&*_+|=`;'?,.\/"
          '"'
          "]"),
      "○");

  List<String> splitText = subtitleText.split("\n");
  splitText.removeWhere((line) {
    line = line.replaceAll(":", " ");
    line = line.replaceAll("(", " ");
    line = line.replaceAll(")", " ");
    line = line.replaceAll("[", " ");
    line = line.replaceAll("]", " ");
    line = line.replaceAll("{", " ");
    line = line.replaceAll("}", " ");
    line = line.replaceAll("<", " ");
    line = line.replaceAll(">", " ");
    line = line.replaceAll("\$", " ");
    line = line.replaceAll("…", " ");
    line = line.replaceAll("~", " ");
    line = line.replaceAll("’", " ");
    line = line.replaceAll("○", " ");
    line = line.replaceAll("«", " ");
    line = line.replaceAll("»", " ");
    line = line.replaceAll("“", " ");
    line = line.replaceAll("”", " ");
    line = line.replaceAll("—", " ");
    line = line.replaceAll("♪", " ");
    line = line.replaceAll("「", " ");
    line = line.replaceAll("」", " ");
    line = line.replaceAll("‘", " ");
    line = line.replaceAll(RegExp(r"[0-9]"), " ");
    line = line.trim();

    return line.isEmpty;
  });
  subtitleText = splitText.join("\n");

  return subtitleText;
}

class BlurWidgetOptions {
  double width;
  double height;
  double left;
  double top;
  Color color;
  double blurRadius;
  bool visible;

  BlurWidgetOptions(
    this.width,
    this.height,
    this.left,
    this.top,
    this.color,
    this.blurRadius,
    this.visible,
  );
}

double parsePopularity(dynamic value) {
  if (value == null) {
    return 0;
  }
  return value.toDouble();
}

class DropDownMenu extends StatefulWidget {
  final List<String> options;
  final ValueNotifier<String> selectedOption;
  final DropdownCallback dropdownCallback;

  const DropDownMenu({
    this.options,
    this.selectedOption,
    this.dropdownCallback,
  });

  @override
  DropDownMenuState createState() => DropDownMenuState(
        this.selectedOption,
        this.options,
        this.dropdownCallback,
      );
}

class DropDownMenuState extends State<DropDownMenu> {
  final List<String> options;
  final ValueNotifier<String> selectedOption;
  final DropdownCallback dropdownCallback;

  DropDownMenuState(
    this.selectedOption,
    this.options,
    this.dropdownCallback,
  );

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: selectedOption.value,
      items: options.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text("  $value"),
        );
      }).toList(),
      onChanged: (selectedDeck) async {
        dropdownCallback(selectedDeck);

        setState(() {
          selectedOption.value = selectedDeck;
        });
      },
    );
  }
}

Future<String> processOcrTextFromBytes(Uint8List imageBytes) async {
  File cleanedImageFile = File("$gAppDirPath/extractOcr.jpg");
  cleanedImageFile.writeAsBytesSync(imageBytes);

  String text = await FlutterTesseractOcr.extractText(
    cleanedImageFile.path,
    language: (getOcrHorizontalMode()) ? 'jpn+jpn_vert' : 'jpn_vert+jpn',
    args: {
      "psm": "6",
    },
  );

  return text;
}

Future<String> processOcrTextFromFile(File inputImageFile) async {
  im.Image image = im.decodeImage(inputImageFile.readAsBytesSync());
  image = im.adjustColor(
    image.clone(),
  );
  File cleanedImageFile = File("$gAppDirPath/extractOcr.jpg");
  cleanedImageFile.writeAsBytesSync(im.encodeJpg(image));

  String text = await FlutterTesseractOcr.extractText(
    cleanedImageFile.path,
    language: (getOcrHorizontalMode()) ? 'jpn' : 'jpn_vert',
    args: {
      "psm": "6",
    },
  );

  return text;
}

class Manga {
  Directory directory;

  Manga({this.directory});

  String getMangaName() {
    return path.basename(directory.path);
  }

  String getMangaAliasName() {
    String nameAlias = getLibraryNameAlias(directory.path);
    if (nameAlias != null) {
      return nameAlias;
    }

    return getMangaName();
  }

  List<MangaChapter> getChapters() {
    List<MangaChapter> chapters = [];

    List<FileSystemEntity> entities = directory.listSync();
    entities.sort((a, b) => a.path.compareTo(b.path));
    entities.forEach((entity) {
      if (entity is Directory) {
        chapters.add(
          MangaChapter(
            directory: entity,
          ),
        );
      }
    });

    return chapters;
  }

  int getUnfinishedChapters() {
    int unfinishedChapters = 0;
    getChapters().forEach((chapter) {
      if (chapter.getMangaProgressState() !=
          MangaProgressState.MANGA_FINISHED) {
        unfinishedChapters += 1;
      }
    });

    return unfinishedChapters;
  }

  Future<void> setUpToChapterFinished(
    MangaChapter stopChapter, {
    bool unmark = false,
  }) async {
    for (MangaChapter chapter in getChapters()) {
      if (unmark) {
        await chapter.setUnstarted();
      } else {
        await chapter.setFinished();
      }
      if (chapter.directory.path == stopChapter.directory.path) {
        break;
      }
    }
  }

  Future<void> setLastChapterRead(MangaChapter chapter) async {
    await gSharedPrefs.setString(this.directory.path, chapter.directory.path);
  }

  MangaChapter getLastChapterRead() {
    String lastChapterPath = gSharedPrefs.getString(this.directory.path) ?? "";
    Directory lastChapterDirectory = Directory(lastChapterPath);

    if (lastChapterDirectory.existsSync()) {
      return MangaChapter(directory: lastChapterDirectory);
    } else {
      return null;
    }
  }

  ImageProvider getCover() {
    return getChapters().first.getCover();
  }

  ImageProvider getAliasCover() {
    File coverAliasFile = getLibraryCoverAlias(directory.path);
    if (coverAliasFile.existsSync()) {
      return FileImage(coverAliasFile);
    }
    return getCover();
  }

  File getCoverFile() {
    return getChapters().first.getCoverFile();
  }

  Widget getWidget(BuildContext context, VoidCallback updateCallback) {
    return InkWell(
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Container(
              color: Colors.grey[800].withOpacity(0.3),
              child: AspectRatio(
                aspectRatio: 250 / 350,
                child: FadeInImage(
                  image: getAliasCover(),
                  placeholder: MemoryImage(kTransparentImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (getUnfinishedChapters() != 0)
            Positioned(
              right: 11.0,
              top: 18.0,
              child: Container(
                height: 20,
                color: Colors.black.withOpacity(0.8),
                alignment: Alignment.center,
                child: Text(
                  "  " + getUnfinishedChapters().toString() + "  ",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.fromLTRB(2, 2, 2, 4),
              height: constraints.maxHeight * 0.175,
              width: double.maxFinite,
              color: Colors.black.withOpacity(0.6),
              child: Text(
                getMangaAliasName(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
            );
          }),
        ],
      ),
      onTap: () async {
        await openMangaMenu(context, updateCallback);
        updateCallback();
      },
      onLongPress: () async {
        await openMangaMenu(context, updateCallback);
        updateCallback();
      },
    );
  }

  Future openMangaMenu(
    BuildContext context,
    VoidCallback updateCallback, {
    bool inViewer = false,
  }) {
    ScrollController scrollController = ScrollController();
    ValueNotifier<bool> updateListener = ValueNotifier<bool>(true);

    List<MangaChapter> chapters = getChapters();

    Color getProgressColor(MangaProgressState mangaProgressState) {
      switch (mangaProgressState) {
        case MangaProgressState.MANGA_UNSTARTED:
          return Colors.white;
        case MangaProgressState.MANGA_VIEWED:
        case MangaProgressState.MANGA_FINISHED:
          return Colors.grey;
      }

      return null;
    }

    Widget buildProgressIndicator(MangaChapter chapter, Color color) {
      int progress = chapter.getMangaPageProgress();
      int pageCount = chapter.getImages().length;
      double percentage = progress / pageCount;

      if (progress == -1) {
        return Icon(Icons.play_arrow, color: color);
      } else if (percentage >= 1) {
        return Icon(Icons.check, color: color);
      }

      return Padding(
        child: SizedBox(
          height: 14,
          width: 14,
          child: CircularProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            strokeWidth: 2,
          ),
        ),
        padding: EdgeInsets.only(right: 5),
      );
    }

    Widget buildMangaMenuContent() {
      return Container(
        width: double.maxFinite,
        child: ValueListenableBuilder(
          valueListenable: updateListener,
          builder: (BuildContext context, bool value, Widget child) {
            return RawScrollbar(
              thumbColor: Colors.grey[600],
              controller: scrollController,
              child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    MangaChapter chapter = chapters[index];
                    Color progressColor = getProgressColor(
                      chapter.getMangaProgressState(),
                    );

                    return ListTile(
                      dense: true,
                      title: Row(
                        children: [
                          Icon(
                            Icons.book_sharp,
                            size: 20.0,
                            color: progressColor,
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              chapter.getChapterName(),
                              style: TextStyle(
                                fontSize: 16,
                                color: progressColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          buildProgressIndicator(chapter, progressColor),
                        ],
                      ),
                      onTap: () async {
                        if (!inViewer) {
                          await startViewer(
                            context,
                            chapter,
                            updateCallback,
                          );
                          updateListener.value = !updateListener.value;
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Viewer(
                                chapter,
                              ),
                            ),
                          );
                        }
                      },
                      onLongPress: () async {
                        if (!inViewer) {
                          await showChapterProgressDialog(context, chapter);
                          updateListener.value = !updateListener.value;
                        }
                      },
                    );
                  }),
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
          title: Text(
            getMangaAliasName(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          content: buildMangaMenuContent(),
          actions: (inViewer)
              ? []
              : [
                  TextButton(
                    child: Text(
                      'EDIT',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      await showAliasDialog(
                        context,
                        directory.path,
                        getMangaAliasName(),
                        getMangaName(),
                        getAliasCover(),
                        getCover(),
                      );

                      Navigator.pop(context);
                      updateCallback();
                    },
                  ),
                  TextButton(
                    child: Text(
                      (getLastChapterRead() == null) ? 'READ' : 'RESUME',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (getLastChapterRead() == null) {
                        await startViewer(
                          context,
                          getChapters().first,
                          updateCallback,
                        );
                      } else {
                        await startViewer(
                          context,
                          getLastChapterRead(),
                          updateCallback,
                        );
                      }
                    },
                  ),
                ],
        );
      },
    );
  }
}

Future showChapterProgressDialog(
    BuildContext context, MangaChapter chapter) async {
  Widget alertDialog = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),
    title: Text(chapter.getManga().getMangaName()),
    content: Text(chapter.getChapterName()),
    actions: <Widget>[
      new TextButton(
        child: Text(
          'MARK UP TO THIS UNSTARTED',
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
          await chapter
              .getManga()
              .setUpToChapterFinished(chapter, unmark: true);
          Navigator.pop(context);
        },
      ),
      new TextButton(
        child: Text(
          'MARK UP TO THIS DONE',
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
          await chapter.getManga().setUpToChapterFinished(chapter);
          Navigator.pop(context);
        },
      ),
      TextButton(
        child: Text(
          'MARK UNSTARTED',
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
          await chapter.setUnstarted();
          Navigator.pop(context);
        },
      ),
      TextButton(
        child: Text(
          'MARK DONE',
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
          await chapter.setFinished();
          Navigator.pop(context);
        },
      ),
      TextButton(
        child: Text(
          'BACK',
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
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );

  await showDialog(
    context: context,
    builder: (context) => alertDialog,
  );
}

enum MangaProgressState {
  MANGA_UNSTARTED,
  MANGA_VIEWED,
  MANGA_FINISHED,
}

class MangaChapter {
  Directory directory;

  MangaChapter({this.directory});

  Manga getManga() {
    return Manga(directory: Directory(path.dirname(directory.path)));
  }

  String getChapterName() {
    String basename = path.basename(directory.path);

    if (basename.indexOf("_") == -1) {
      return basename;
    }

    return basename.substring(basename.indexOf("_") + 1);
  }

  ImageProvider getCover() {
    List<FileSystemEntity> entities = directory.listSync();
    entities.sort((a, b) => a.path.compareTo(b.path));

    for (FileSystemEntity entity in entities) {
      if (entity is File) {
        switch (path.extension(entity.path)) {
          case ".jpg":
          case ".jpeg":
          case ".png":
            return FileImage(entity);
            break;
          default:
        }
      }
    }
    return MemoryImage(kTransparentImage);
  }

  File getCoverFile() {
    List<FileSystemEntity> entities = directory.listSync();
    entities.sort((a, b) => a.path.compareTo(b.path));

    for (FileSystemEntity entity in entities) {
      if (entity is File) {
        switch (path.extension(entity.path)) {
          case ".jpg":
          case ".jpeg":
          case ".png":
            return File(entity.path);
            break;
          default:
        }
      }
    }
    return null;
  }

  List<ImageProvider> getImages() {
    List<ImageProvider> images = [];

    List<FileSystemEntity> entities = directory.listSync();
    entities.sort((a, b) => a.path.compareTo(b.path));
    entities.forEach((entity) {
      if (entity is File) {
        switch (path.extension(entity.path)) {
          case ".jpg":
          case ".jpeg":
          case ".png":
            images.add(FileImage(entity));
            break;
          default:
        }
      }
    });

    return images;
  }

  MangaChapter getPreviousChapter() {
    List<MangaChapter> chapters = getManga().getChapters();
    int index = chapters
        .indexWhere((chapter) => chapter.directory.path == directory.path);

    if (index == 0) {
      return null;
    } else {
      return chapters[index - 1];
    }
  }

  MangaChapter getNextChapter() {
    List<MangaChapter> chapters = getManga().getChapters();
    int index = chapters
        .indexWhere((chapter) => chapter.directory.path == directory.path);

    if (index == chapters.length - 1) {
      return null;
    } else {
      return chapters[index + 1];
    }
  }

  MangaProgressState getMangaProgressState() {
    int pageProgress = getMangaPageProgress();
    if (pageProgress >= getImages().length) {
      return MangaProgressState.MANGA_FINISHED;
    } else if (pageProgress <= -1) {
      return MangaProgressState.MANGA_UNSTARTED;
    } else {
      return MangaProgressState.MANGA_VIEWED;
    }
  }

  Future<void> setMangaPageProgress(int pageProgress) async {
    await gSharedPrefs.setInt(this.directory.path, pageProgress);
  }

  int getMangaPageProgress() {
    return gSharedPrefs.getInt(this.directory.path) ?? -1;
  }

  Future<void> setFinished() async {
    await setMangaPageProgress(getImages().length);
  }

  Future<void> setUnstarted() async {
    await setMangaPageProgress(-1);
  }
}

List<Directory> getTachiyomiDirectoryFolders() {
  List<Directory> downloadSources = [];

  Directory downloadsDirectory =
      Directory(path.join(getTachiyomiDirectory().path, "downloads"));

  if (downloadsDirectory.existsSync()) {
    List<FileSystemEntity> entities = downloadsDirectory.listSync();
    entities.sort((a, b) => a.path.compareTo(b.path));
    entities.forEach((entity) {
      if (entity is Directory) {
        downloadSources.add(entity);
      }
    });
  }

  return downloadSources;
}

List<String> getTachiyomiSourceNames() {
  List<String> sourceNames = [];

  getTachiyomiDirectoryFolders().forEach((folder) {
    sourceNames.add(path.basename(folder.path));
  });

  return sourceNames;
}

class MangaSource {
  String sourceName;
  Directory directory;

  MangaSource.fromSourceName(String sourceName) {
    this.sourceName = sourceName;
    this.directory = Directory(
        path.join(getTachiyomiDirectory().path, "downloads", sourceName));
  }

  MangaSource.local() {
    this.sourceName = "Local source";
    this.directory = Directory(
      path.join(getTachiyomiDirectory().path, "local"),
    );
  }

  List<Manga> getMangaFromSource() {
    List<Manga> manga = [];

    if (!this.directory.existsSync()) {
      return manga;
    }

    List<FileSystemEntity> entities = directory.listSync();
    entities.sort((a, b) => a.path.compareTo(b.path));
    entities.forEach((entity) {
      if (entity is Directory) {
        manga.add(Manga(directory: entity));
      }
    });

    return manga;
  }
}

List<Manga> getAllManga() {
  List<Manga> allManga = [];
  List<String> sourceNames = getTachiyomiSourceNames();
  sourceNames
      .removeWhere((sourceName) => getHiddenSourcesList().contains(sourceName));

  for (String sourceName in sourceNames) {
    MangaSource mangaSource = MangaSource.fromSourceName(sourceName);
    allManga.addAll(mangaSource.getMangaFromSource());
  }
  allManga.addAll(MangaSource.local().getMangaFromSource());

  allManga.sort((a, b) => a.getMangaName().compareTo(b.getMangaName()));
  return allManga;
}

List<Manga> getMangaByDropdown() {
  List<Manga> manga;
  if (getLastTachiyomiSource() == "All sources") {
    manga = getAllManga();
  } else if (getLastTachiyomiSource() == "Local source") {
    MangaSource mangaSource = MangaSource.local();
    manga = mangaSource.getMangaFromSource();
  } else {
    MangaSource mangaSource =
        MangaSource.fromSourceName(getLastTachiyomiSource());
    manga = mangaSource.getMangaFromSource();
  }

  return manga;
}

Future showAliasDialog(
  BuildContext context,
  String path,
  String name,
  String actualName,
  ImageProvider cover,
  ImageProvider actualCover,
) async {
  TextEditingController _nameAliasController = TextEditingController(
    text: name,
  );
  TextEditingController _coverAliasController = TextEditingController(
    text: "a",
  );

  File newAliasCover;
  ValueNotifier<ImageProvider> imageProviderNotifier =
      ValueNotifier<ImageProvider>(cover);

  Widget showPreviewImage() {
    return ValueListenableBuilder(
      valueListenable: imageProviderNotifier,
      builder:
          (BuildContext context, ImageProvider imageProvider, Widget child) {
        return Image(image: imageProvider);
      },
    );
  }

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: double.maxFinite, height: 1),
              TextField(
                controller: _nameAliasController,
                decoration: InputDecoration(
                  labelText: 'Name alias',
                  suffixIcon: IconButton(
                    iconSize: 18,
                    onPressed: () async {
                      _nameAliasController.text = actualName;
                    },
                    icon: Icon(Icons.undo, color: Colors.white),
                  ),
                ),
              ),
              TextField(
                readOnly: true,
                controller: _coverAliasController,
                style: TextStyle(color: Colors.transparent),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Cover alias',
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Padding(
                          child: showPreviewImage(),
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                        ),
                      ),
                      SizedBox(width: 5),
                      IconButton(
                        iconSize: 18,
                        onPressed: () async {
                          final pickedFile = await ImagePicker.pickImage(
                              source: ImageSource.gallery);
                          newAliasCover = File(pickedFile.path);
                          imageProviderNotifier.value =
                              FileImage(newAliasCover);
                        },
                        icon: Icon(Icons.file_upload, color: Colors.white),
                      ),
                      IconButton(
                        iconSize: 18,
                        onPressed: () async {
                          newAliasCover = null;
                          imageProviderNotifier.value = actualCover;
                        },
                        icon: Icon(Icons.undo, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('CANCEL', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text('APPLY', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              String newNameAlias = _nameAliasController.text.trim();

              if (newNameAlias.isNotEmpty) {
                await setLibraryNameAlias(path, newNameAlias);

                if (newAliasCover != null) {
                  setLibraryCoverAlias(path, newAliasCover);
                } else {
                  if (getLibraryCoverAlias(path).existsSync()) {
                    getLibraryCoverAlias(path).deleteSync();
                  }
                }
              }

              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

void setResumableByMediaType() {
  bool resumable = false;
  switch (getLastMediaType()) {
    case MediaType.none:
      resumable = false;
      break;
    case MediaType.video:
      resumable = getVideoHistory().isNotEmpty;
      break;
    case MediaType.book:
      resumable = getBookHistory().isNotEmpty;
      break;
    case MediaType.manga:
      resumable = getLastReadMangaDirectory().isNotEmpty;
      break;
  }

  gIsResumable = ValueNotifier<bool>(resumable);
}

Future startViewer(
    BuildContext context, MangaChapter chapter, VoidCallback updateCallback,
    {int initialPage}) async {
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Viewer(
        chapter,
        initialPage: initialPage,
      ),
    ),
  ).then((result) {
    setResumableByMediaType();
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom, SystemUiOverlay.top]);

    updateCallback();
  });
}

TextSpan getContextDataSourceSpan(String contextDataSource) {
  String text = "";

  if (contextDataSource.startsWith("https://ttu-ebook.web.app/")) {
    text = "from reader ";
  } else if (contextDataSource.startsWith(getTachiyomiDirectory().path)) {
    text = "from viewer ";
  } else {
    text = "from player ";
  }

  return TextSpan(
    text: text,
    style: TextStyle(
      fontSize: 12,
      color: Colors.grey,
    ),
  );
}

String reorderOcrVerticalText(String raw) {
  String ordered = "";
  List<String> lines = raw.split("\n");
  print(lines);

  while (true) {
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      if (line.isNotEmpty) {
        String character = line[line.length - 1];
        ordered += character;

        if (line.length == 1) {
          lines[i] = "";
        } else {
          lines[i] = line.substring(0, line.length - 1);
        }
      }
    }
    if (lines.every((line) => line.isEmpty)) {
      break;
    }
  }

  return ordered;
}

List<Widget> getTextWidgetsFromWords(
    List<String> words, ValueNotifier<List<bool>> notifier) {
  List<Widget> widgets = [];
  for (int i = 0; i < words.length; i++) {
    widgets.add(
      GestureDetector(
        onTap: () {
          List<bool> values = notifier.value;
          values[i] = !values[i];
          notifier.value = []..addAll(values);
        },
        child: ValueListenableBuilder(
            valueListenable: notifier,
            builder: (BuildContext context, List<bool> values, Widget child) {
              return Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(top: 10, right: 10),
                  color: (notifier.value[i])
                      ? Colors.red.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  child: Text(
                    words[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ));
            }),
      ),
    );
  }

  return widgets;
}

class CreatorExportInformation {
  String initialSentence;
  DictionaryEntry dictionaryEntry;
  File initialFile;

  CreatorExportInformation({
    this.initialSentence,
    this.dictionaryEntry,
    this.initialFile,
  });
}

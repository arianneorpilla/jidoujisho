import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:jidoujishi/main.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:unofficial_jisho_api/api.dart' as jisho;
import 'package:ext_video_player/ext_video_player.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

String subtitles;

class WebPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String videoID = "";

    try {
      videoID = YoutubePlayer.convertUrlToId(webURL);
      print(videoID);
    } on Exception catch (exception) {
      print("Invalid link");
    } catch (error) {
      print("Invalid link");
    }

    return new FutureBuilder(
      future: http.read(
        "https://www.youtube.com/api/timedtext?lang=ja&v=" + videoID,
      ),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Container(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          default:
            print("https://www.youtube.com/api/timedtext?lang=ja&v=" + videoID);
            subtitles = timedTextToSRT(snapshot.data);
            return WebVideoPlayer();
        }
      },
    );
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
  String text = line["\$"];

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

Future<List<String>> getWordDetails(String searchTerm) async {
  jisho.JishoAPIResult results = await jisho.searchForPhrase(searchTerm);
  jisho.JishoResult bestResult = results.data.first;

  print(bestResult.toJson());

  List<String> details = [];

  details.add(bestResult.slug ?? searchTerm);

  String readings = "";
  bestResult.japanese.forEach((f) {
    if (!readings.contains(f.reading + "; ")) {
      readings = readings + f.reading + "; ";
    }
  });
  if (readings.isNotEmpty) {
    readings = readings.substring(0, readings.length - 2);
  }
  if (readings == bestResult.slug) {
    readings = "";
  }

  details.add(readings);

  String senses = "\n";
  int senseCount = 0;

  bestResult.senses.forEach(
    (sense) {
      senseCount++;

      String partsOfSpeech = "";
      sense.parts_of_speech.forEach(
        (part) => {partsOfSpeech = partsOfSpeech + part + "; "},
      );
      if (partsOfSpeech.isNotEmpty) {
        partsOfSpeech = partsOfSpeech.substring(0, partsOfSpeech.length - 2);
      }

      String definitions = "";
      sense.english_definitions.forEach(
        (part) => {definitions = definitions + part + "; "},
      );
      if (definitions.isNotEmpty) {
        definitions = definitions.substring(0, definitions.length - 2);
      }

      senses = senses +
          senseCount.toString() +
          ") " +
          definitions +
          " - " +
          partsOfSpeech +
          "\n";
    },
  );

  details.add(senses);

  return details;
}

class WebVideoPlayer extends StatefulWidget {
  WebVideoPlayer({
    Key key,
  }) : super(key: key);

  @override
  _WebVideoPlayerState createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('End Playback?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('NO'),
              ),
              new FlatButton(
                onPressed: () async {
                  Phoenix.rebirth(context);
                },
                child: new Text('YES'),
              ),
            ],
          ),
        )) ??
        false;
  }

  VideoPlayerController videoPlayerController;
  ChewieController chewieController;

  VideoPlayerController getVideoPlayerController() {
    videoPlayerController ??= VideoPlayerController.network(webURL);
    //videoPlayerController ??= VideoPlayerController.file(videoFile);
    return videoPlayerController;
  }

  ChewieController getChewieController() {
    chewieController ??= ChewieController(
      videoPlayerController: getVideoPlayerController(),
      aspectRatio: getVideoPlayerController().value.aspectRatio,
      autoPlay: true,
      autoInitialize: true,
      allowFullScreen: false,
      allowMuting: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.blue,
        handleColor: Colors.blue,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey,
      ),
      fullScreenByDefault: false,
      allowedScreenSleep: false,
    );
    return chewieController;
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            SubTitleWrapper(
              videoPlayerController: getVideoPlayerController(),
              subtitleController: SubtitleController(
                subtitlesContent: subtitles,
                showSubtitles: true,
                subtitleDecoder: SubtitleDecoder.utf8,
                subtitleType: SubtitleType.srt,
              ),
              subtitleStyle: SubtitleStyle(
                textColor: Colors.white,
                hasBorder: true,
                fontSize: 24,
              ),
              videoChild: FutureBuilder(
                  future: getVideoPlayerController().initialize(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Container();
                      default:
                        chewieController = getChewieController();
                        return Chewie(
                          controller: chewieController,
                        );
                    }
                  }),
            ),
            ValueListenableBuilder(
              valueListenable: globalClipboard,
              builder: (context, value, widget) {
                return FutureBuilder(
                  future: getWordDetails(value),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<String>> snapshot) {
                    if (globalClipboard.value == "") {
                      return Container();
                    }
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                color: Theme.of(context)
                                    .backgroundColor
                                    .withOpacity(0.6),
                                child: Column(
                                  children: [
                                    Text("Looking up \"" +
                                        value +
                                        "\" on Jisho.org...")
                                  ],
                                ),
                              ),
                            ),
                            Expanded(child: Container()),
                          ],
                        );

                      default:
                        if (!snapshot.hasData) {
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: InkWell(
                                  onTap: () {
                                    globalClipboard.value = "";
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16.0),
                                    color: Theme.of(context)
                                        .backgroundColor
                                        .withOpacity(0.6),
                                    child: Column(
                                      children: [
                                        Text("No match for \"" +
                                            value +
                                            "\" found")
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(child: Container()),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: GestureDetector(
                                onTap: () {
                                  globalClipboard.value = "";
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  color: Theme.of(context)
                                      .backgroundColor
                                      .withOpacity(0.6),
                                  child: Column(
                                    children: [
                                      Text(
                                        snapshot.data[0],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(snapshot.data[1]),
                                      Text(snapshot.data[2]),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(child: Container()),
                          ],
                        );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (videoPlayerController != null && chewieController != null) {
      videoPlayerController?.dispose();
      chewieController?.dispose();
    }
  }
}

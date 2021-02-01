import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:gx_file_picker/gx_file_picker.dart';
import 'package:jidoujishi/main.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:unofficial_jisho_api/api.dart' as jisho;
import 'package:path/path.dart' as path;
import 'package:ext_video_player/ext_video_player.dart';

class LocalPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: FilePicker.getFilePath(type: FileType.video),
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
            if (snapshot.hasData) {
              videoFile = File(snapshot.data);
              String subtitlesFilePath = path.dirname(videoFile.path) +
                  "/" +
                  path.basenameWithoutExtension(videoFile.path) +
                  ".srt";
              if (File(subtitlesFilePath).existsSync()) {
                subtitlesFile = File(subtitlesFilePath).readAsStringSync();
              } else {
                subtitlesFile = "";
              }
            } else {
              Navigator.pop(context);
              return Container();
            }

            return VideoPlayer();
        }
      },
    );
  }
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

class VideoPlayer extends StatefulWidget {
  VideoPlayer({
    Key key,
  }) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
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
    videoPlayerController ??= VideoPlayerController.file(videoFile);
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
                subtitlesContent: subtitlesFile,
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

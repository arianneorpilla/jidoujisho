import 'dart:convert';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gx_file_picker/gx_file_picker.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:unofficial_jisho_api/api.dart' as jisho;
import 'package:path/path.dart' as path;

File videoFile;
final globalClipboard = ValueNotifier<String>("");
final JsonEncoder encoder = JsonEncoder.withIndent('  ');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  startClipboardMonitor();

  runApp(
    Phoenix(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        /* light theme settings */
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
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
            if (snapshot.hasError) {
              SystemNavigator.pop();
            }
            if (snapshot.hasData) {
              videoFile = File(snapshot.data);
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

  List<String> details = [];

  details.add(bestResult.japanese.first.word ?? searchTerm);

  String readings = "";
  bestResult.japanese.forEach((f) => readings = readings + f.reading + "; ");
  readings = readings.substring(0, readings.length - 2);

  details.add(readings);

  String senses = "\n";

  bestResult.senses.forEach(
    (sense) {
      String partsOfSpeech = "";
      sense.parts_of_speech.forEach(
        (part) => {partsOfSpeech = partsOfSpeech + part + "; "},
      );
      partsOfSpeech = partsOfSpeech.substring(0, partsOfSpeech.length - 2);

      String definitions = "";
      sense.english_definitions.forEach(
        (part) => {definitions = definitions + part + "; "},
      );
      definitions = definitions.substring(0, definitions.length - 2);

      senses = senses + definitions + " - " + partsOfSpeech + "\n";
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

  final SubtitleController subtitleController = SubtitleController(
    subtitlesContent: File(path.dirname(videoFile.path) +
            "/" +
            path.basenameWithoutExtension(videoFile.path) +
            ".srt")
        .readAsStringSync(),
    showSubtitles: true,
    subtitleDecoder: SubtitleDecoder.utf8,
    subtitleType: SubtitleType.srt,
  );

  VideoPlayerController getVideoPlayerController() {
    videoPlayerController ??= VideoPlayerController.file(videoFile);
    return videoPlayerController;
  }

  ChewieController getChewieController() {
    chewieController ??= ChewieController(
      videoPlayerController: getVideoPlayerController(),
      aspectRatio: 16 / 9,
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
    var chewieController = getChewieController();

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            SubTitleWrapper(
              videoPlayerController: chewieController.videoPlayerController,
              subtitleController: subtitleController,
              subtitleStyle: SubtitleStyle(
                textColor: Colors.white,
                hasBorder: true,
                fontSize: 24,
              ),
              videoChild: Chewie(
                controller: chewieController,
              ),
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

void startClipboardMonitor() {
  ClipboardMonitor.registerCallback(onClipboardText);
}

void stopClipboardMonitor() {
  ClipboardMonitor.unregisterCallback(onClipboardText);
}

void onClipboardText(String text) {
  globalClipboard.value = text;
  print("clipboard changed: $text");
}

void stopAllClipboardMonitoring() {
  ClipboardMonitor.unregisterAllCallbacks();
}

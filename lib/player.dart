import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:gx_file_picker/gx_file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:wakelock/wakelock.dart';

import 'package:jidoujisho/main.dart';
import 'package:jidoujisho/util.dart';

class Player extends StatelessWidget {
  Player({this.url, this.initialPosition, this.video});

  final int initialPosition;
  final String url;
  final Video video;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    Wakelock.enable();

    // If webURL is empty, then use a local player.
    if (this.url != null && YoutubePlayer.convertUrlToId(url) != null) {
      return webPlayer(video, initialPosition);
    } else {
      return localPlayer(context, url, initialPosition);
    }
  }

  // Widget localPlayer() {
  //   return new FutureBuilder(
  //     future: FilePicker.platform.pickFiles(
  //       type: Platform.isIOS ? FileType.any : FileType.video,
  //       allowMultiple: false,
  //       allowCompression: false,
  //     ),
  //     builder:
  //         (BuildContext context, AsyncSnapshot<FilePickerResult> snapshot) {
  //       switch (snapshot.connectionState) {
  //         case ConnectionState.waiting:
  //           return loadingCircle();
  //         default:
  //           if (snapshot.hasData) {
  //             File videoFile = File(snapshot.data.files.single.path);
  //             print("VIDEO FILE: ${videoFile.path}");

  //             return FutureBuilder(
  //               future: extractSubtitles(videoFile),
  //               builder:
  //                   (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
  //                 switch (snapshot.connectionState) {
  //                   case ConnectionState.waiting:
  //                     return loadingCircle();
  //                   default:
  //                     List<File> internalSubs = snapshot.data;
  //                     String defaultSubtitles =
  //                         getDefaultSubtitles(videoFile, internalSubs);

  //                     return VideoPlayer(
  //                       videoFile: videoFile,
  //                       internalSubs: internalSubs,
  //                       defaultSubtitles: defaultSubtitles,
  //                     );
  //                 }
  //               },
  //             );
  //           }
  //           Navigator.pop(context);
  //           return Container();
  //       }
  //     },
  //   );
  // }

  Widget localPlayer(BuildContext context, String url, int initialPosition) {
    if (url != null) {
      return localPlayerHelper(
        context,
        File(url),
        initialPosition,
      );
    } else {
      return new FutureBuilder(
        future: FilePicker.getFile(
            type: Platform.isIOS ? FileType.any : FileType.video),
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return loadingCircle();
            default:
              if (snapshot.hasData) {
                File videoFile = snapshot.data;
                if (videoFile == null) {
                  Navigator.pop(context);
                }

                return localPlayerHelper(context, videoFile, initialPosition);
              }
              Navigator.pop(context);
              return Container();
          }
        },
      );
    }
  }

  Widget localPlayerHelper(
    BuildContext context,
    File videoFile,
    int initialPosition,
  ) {
    print("VIDEO FILE: ${videoFile.path}");

    if (videoFile == null) {
      Navigator.pop(context);
    }

    return FutureBuilder(
      future: extractSubtitles(videoFile),
      builder: (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return loadingCircle();
          default:
            List<File> internalSubs = snapshot.data;
            String defaultSubtitles =
                getDefaultSubtitles(videoFile, internalSubs);

            globalPrefs.setString("lastPlayedPath", videoFile.path);
            globalPrefs.setInt("lastPlayedPosition", 0);
            globalResumable.value = true;

            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);

            VideoHistory history = VideoHistory(
              videoFile.path,
              path.basenameWithoutExtension(videoFile.path),
              videoFile.path,
              null,
            );

            addVideoHistory(history);

            return VideoPlayer(
              videoFile: videoFile,
              internalSubs: internalSubs,
              defaultSubtitles: defaultSubtitles,
              initialPosition: initialPosition,
            );
        }
      },
    );
  }

  Widget webPlayer(Video video, int initialPosition) {
    String videoID = "";

    try {
      videoID = YoutubePlayer.convertUrlToId(url);
      print("VIDEO YOUTUBE ID: $videoID");
    } catch (error) {
      print("INVALID LINK");
      return Container();
    }

    return new FutureBuilder(
      future: getPlayerYouTubeInfo(url),
      builder: (BuildContext context, AsyncSnapshot<YouTubeMux> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Container(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ),
            );
          default:
            YouTubeMux streamData = snapshot.data;

            return new FutureBuilder(
              future: http.read(Uri.parse(
                  "https://www.youtube.com/api/timedtext?lang=ja&v=$videoID")),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Scaffold(
                      backgroundColor: Colors.black,
                      body: Center(
                        child: Container(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ),
                      ),
                    );
                  default:
                    String webSubtitles;
                    List<File> internalSubs;

                    if (!snapshot.hasData || snapshot.data.isEmpty) {
                      webSubtitles = "";
                      internalSubs = [];
                    } else {
                      webSubtitles = timedTextToSRT(snapshot.data);
                      internalSubs = extractWebSubtitle(webSubtitles);
                    }

                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                    ]);

                    VideoHistory history = VideoHistory(
                      url,
                      streamData.title,
                      streamData.channel,
                      streamData.thumbnailURL,
                    );

                    addVideoHistory(history);

                    return VideoPlayer(
                      streamData: streamData,
                      defaultSubtitles: webSubtitles,
                      internalSubs: internalSubs,
                      initialPosition: initialPosition,
                    );
                }
              },
            );
        }
      },
    );
  }

  Widget loadingCircle() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
      ),
    );
  }
}

class VideoPlayer extends StatefulWidget {
  VideoPlayer({
    this.videoFile,
    this.streamData,
    this.internalSubs,
    this.defaultSubtitles,
    this.initialPosition,
    Key key,
  }) : super(key: key);

  final File videoFile;
  final YouTubeMux streamData;
  final List<File> internalSubs;
  final String defaultSubtitles;
  final int initialPosition;

  @override
  _VideoPlayerState createState() => _VideoPlayerState(
        this.videoFile,
        this.streamData,
        this.internalSubs,
        this.defaultSubtitles,
        this.initialPosition,
      );
}

class _VideoPlayerState extends State<VideoPlayer> {
  _VideoPlayerState(
    this.videoFile,
    this.streamData,
    this.internalSubs,
    this.defaultSubtitles,
    this.initialPosition,
  );

  final File videoFile;
  final YouTubeMux streamData;
  final List<File> internalSubs;
  final String defaultSubtitles;
  int initialPosition;

  VlcPlayerController _videoPlayerController;
  ChewieController _chewieController;
  SubTitleWrapper _subTitleWrapper;
  SubtitleController _subTitleController;
  String _volatileText = "";
  FocusNode _subtitleFocusNode = new FocusNode();
  bool networkNotSet = true;

  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 1), (Timer t) => updateDurationOrSeek());
  }

  void updateDurationOrSeek() {
    if (getVideoPlayerController().value.isInitialized &&
        this.videoFile == null &&
        networkNotSet) {
      networkNotSet = false;
      _videoPlayerController.setMediaFromNetwork(
          getLastPlayedQuality(streamData.videoQualities).videoURL);
      _chewieController.currentVideoQuality =
          getLastPlayedQuality(streamData.videoQualities);
    }

    globalPrefs.setInt("lastPlayedPosition",
        getVideoPlayerController().value.position.inSeconds ?? 0);

    if (initialPosition != -1 &&
        getVideoPlayerController().value.isInitialized) {
      getVideoPlayerController().isSeekable().then(
        (isSeekable) {
          if (isSeekable && initialPosition != -1) {
            getVideoPlayerController()
                .seekTo(Duration(seconds: initialPosition))
                .then(
              (result) {
                getVideoPlayerController().getPosition().then(
                      (position) => {
                        if (position >= Duration(seconds: initialPosition - 1))
                          {initialPosition = -1}
                      },
                    );
              },
            );
          }
        },
      );
    }
  }

  final _clipboard = ValueNotifier<String>("");
  final _currentDictionaryEntry =
      ValueNotifier<DictionaryEntry>(DictionaryEntry(
    word: "",
    reading: "",
    meaning: "",
  ));
  final _currentSubtitle = ValueNotifier<Subtitle>(
    Subtitle(
      startTime: Duration.zero,
      endTime: Duration.zero,
      text: "",
    ),
  );
  final _currentSubTrack = ValueNotifier<int>(-1);

  @override
  void dispose() {
    super.dispose();
    if (_videoPlayerController != null && _chewieController != null) {
      _videoPlayerController?.stopRendererScanning();
      _videoPlayerController?.dispose();
      _chewieController?.dispose();
    }
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    startClipboardMonitor();

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 20) {
                  getVideoPlayerController()
                      .seekTo(_currentSubtitle.value.endTime);
                } else if (details.delta.dx < -20) {
                  getVideoPlayerController()
                      .seekTo(_currentSubtitle.value.startTime);
                }
              },
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 20) {
                  openTranscript(
                      _subTitleController.subtitleBloc.subtitles.subtitles);
                } else if (details.delta.dy < -20) {
                  openTranscript(
                      _subTitleController.subtitleBloc.subtitles.subtitles);
                }
              },
              child: getSubtitleWrapper(),
            ),
            buildSubTrackChanger(),
            buildDictionary(),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Widget alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: new Text('End Playback?'),
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
          onPressed: () => Navigator.of(context).pop(false),
        ),
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
            await Wakelock.disable();
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);

            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );

    return (await showDialog(
          context: context,
          builder: (context) => alertDialog,
        )) ??
        false;
  }

  VlcPlayerController getVideoPlayerController() {
    if (streamData == null) {
      _videoPlayerController ??= VlcPlayerController.file(
        videoFile,
        hwAcc: HwAcc.FULL,
        options: VlcPlayerOptions(
          audio: VlcAudioOptions(["--audio-track=0", "--sub-track=999"]),
        ),
      );
    } else {
      _videoPlayerController ??= VlcPlayerController.network(
        streamData.audioURL,
        hwAcc: HwAcc.FULL,
        options: VlcPlayerOptions(
          audio: VlcAudioOptions(["--input-slave=${streamData.audioURL}"]),
        ),
      );
    }
    return _videoPlayerController;
  }

  ChewieController getChewieController() {
    _chewieController ??= ChewieController(
      videoPlayerController: getVideoPlayerController(),
      internalSubs: internalSubs,
      clipboard: _clipboard,
      currentDictionaryEntry: _currentDictionaryEntry,
      currentSubtitle: _currentSubtitle,
      currentSubTrack: _currentSubTrack,
      playExternalSubtitles: playExternalSubtitles,
      streamData: streamData,
      aspectRatio: getVideoPlayerController().value.aspectRatio,
      autoPlay: true,
      autoInitialize: true,
      allowFullScreen: false,
      allowMuting: false,
      allowedScreenSleep: false,
      fullScreenByDefault: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.red,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.red[200],
      ),
    );
    return _chewieController;
  }

  SubtitleController getSubtitleController() {
    _subTitleController ??= SubtitleController(
      subtitlesContent: defaultSubtitles,
      showSubtitles: true,
      subtitleDecoder: SubtitleDecoder.utf8,
      subtitleType: SubtitleType.srt,
    );

    return _subTitleController;
  }

  SubTitleWrapper getSubtitleWrapper() {
    _subTitleWrapper ??= SubTitleWrapper(
      focusNode: _subtitleFocusNode,
      subtitleNotifier: _currentSubtitle,
      videoPlayerController: getVideoPlayerController(),
      subtitleController: getSubtitleController(),
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
              _chewieController = getChewieController();
              return Chewie(
                controller: _chewieController,
              );
          }
        },
      ),
    );

    return _subTitleWrapper;
  }

  void playEmbeddedSubtitles(int index) {
    _subTitleController.subtitleType = SubtitleType.srt;

    if (internalSubs.isEmpty) {
      return;
    }

    if (index < internalSubs.length) {
      getSubtitleWrapper().subtitleController.updateSubtitleContent(
          content: internalSubs[index].readAsStringSync());
      print("SUBTITLES SWITCHED TO TRACK $index");
    } else {
      _subTitleController.updateSubtitleContent(content: "");
      print("SUBTITLES SWITCHED OFF");
    }
  }

  // void playExternalSubtitles() async {
  //   FilePickerResult result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //     allowMultiple: false,
  //   );

  //   if (result != null) {
  //     File subFile = File(result.files.single.path);
  //     if (subFile.path.endsWith("srt")) {
  //       getSubtitleWrapper()
  //           .subtitleController
  //           .updateSubtitleContent(content: subFile.readAsStringSync());
  //       print("SUBTITLES SWITCHED TO EXTERNAL SRT");
  //     } else {
  //       getSubtitleWrapper().subtitleController.updateSubtitleContent(
  //           content: await extractNonSrtSubtitles(subFile));
  //       print("SUBTITLES SWITCHED TO EXTERNAL ASS");
  //     }
  //   }
  // }

  void playExternalSubtitles() async {
    _subTitleController.subtitleType = SubtitleType.srt;

    File result = await FilePicker.getFile(
      type: FileType.any,
    );

    if (result != null) {
      if (result.path.endsWith("srt")) {
        getSubtitleWrapper()
            .subtitleController
            .updateSubtitleContent(content: result.readAsStringSync());
        print("SUBTITLES SWITCHED TO EXTERNAL SRT");
      } else {
        getSubtitleWrapper().subtitleController.updateSubtitleContent(
            content: await extractNonSrtSubtitles(result));
        print("SUBTITLES SWITCHED TO EXTERNAL ASS");
      }
    }
  }

  Widget buildDictionaryLoading(String clipboard) {
    String lookupText = "Looking up『$clipboard』...";

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[800].withOpacity(0.6),
            child: Text(lookupText),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryExporting(String clipboard) {
    String lookupText = "Preparing to export...";

    // Future.delayed(Duration(seconds: 2), () {
    //   if (_clipboard.value == "&<&>export&<&>") {
    //     Future.delayed(Duration(seconds: 2), () {
    //       if (_clipboard.value == "&<&>export&<&>") {
    //         Future.delayed(Duration(seconds: 2), () {
    //           if (_clipboard.value == "&<&>export&<&>") {
    //             Future.delayed(Duration(seconds: 2), () {
    //               if (_clipboard.value == "&<&>export&<&>") {
    //                 Future.delayed(Duration(seconds: 2), () {
    //                   if (_clipboard.value == "&<&>export&<&>") {
    //                     _clipboard.value = "&<&>exportlong&<&>";
    //                   }
    //                 });
    //               }
    //             });
    //           }
    //         });
    //       }
    //     });
    //   }
    // });

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[800].withOpacity(0.6),
            child: Text(lookupText),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryExportingLong(String clipboard) {
    String lookupText =
        "Failed to communicate with the AnkiDroid background service.\n" +
            "If inactive, press here to launch it and try again.";

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            await LaunchApp.openApp(
              androidPackageName: 'com.ichi2.anki',
              openStore: true,
            );

            _clipboard.value = "";
          },
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[800].withOpacity(0.6),
              child: Text(lookupText),
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryExported(String clipboard) {
    String deckName = clipboard.substring(12, clipboard.length - 4);
    String lookupText = "Card exported to \"$deckName\".";

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[800].withOpacity(0.6),
            child: Text(lookupText),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryNoMatch(String clipboard) {
    String lookupText;
    if (globalSelectMode.value) {
      lookupText = "No matches for \"$clipboard\" could be queried.";
    } else {
      lookupText = "No matches for the selection could be queried.";
    }

    _subtitleFocusNode.unfocus();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {
              _clipboard.value = "";
              _currentDictionaryEntry.value = DictionaryEntry(
                word: "",
                reading: "",
                meaning: "",
              );
            },
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[800].withOpacity(0.6),
              child: Text(lookupText),
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryMatch(List<DictionaryEntry> results) {
    _subtitleFocusNode.unfocus();
    ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

    return ValueListenableBuilder(
        valueListenable: selectedIndex,
        builder: (BuildContext context, int _, Widget widget) {
          _currentDictionaryEntry.value = results[selectedIndex.value];
          addDictionaryEntryToHistory(_currentDictionaryEntry.value);

          return Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () {
                _clipboard.value = "";
                _currentDictionaryEntry.value = DictionaryEntry(
                  word: "",
                  reading: "",
                  meaning: "",
                );
              },
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == 0) return;

                if (details.primaryVelocity.compareTo(0) == -1) {
                  if (selectedIndex.value == results.length - 1) {
                    selectedIndex.value = 0;
                  } else {
                    selectedIndex.value += 1;
                  }
                } else {
                  if (selectedIndex.value == 0) {
                    selectedIndex.value = results.length - 1;
                  } else {
                    selectedIndex.value -= 1;
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 84),
                color: Colors.grey[800].withOpacity(0.6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      results[selectedIndex.value].word,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(results[selectedIndex.value].reading),
                    Flexible(
                      child: SingleChildScrollView(
                        child:
                            Text("\n${results[selectedIndex.value].meaning}\n"),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Showing search result ",
                          style: TextStyle(
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${selectedIndex.value + 1} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "out of ",
                          style: TextStyle(
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${results.length} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "found for",
                          style: TextStyle(
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "『${results[selectedIndex.value].searchTerm}』",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget buildDictionary() {
    return ValueListenableBuilder(
      valueListenable: _clipboard,
      builder: (context, clipboard, widget) {
        return FutureBuilder(
          future: getWordDetails(clipboard),
          builder: (BuildContext context,
              AsyncSnapshot<List<DictionaryEntry>> snapshot) {
            if (_clipboard.value == "&<&>export&<&>") {
              return buildDictionaryExporting(clipboard);
            }
            if (_clipboard.value == "&<&>exportlong&<&>") {
              return buildDictionaryExportingLong(clipboard);
            }
            if (_clipboard.value.startsWith("&<&>exported")) {
              return buildDictionaryExported(clipboard);
            }
            if (_clipboard.value == "") {
              return Container();
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return buildDictionaryLoading(clipboard);
              default:
                List<DictionaryEntry> entries = snapshot.data;

                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  _currentDictionaryEntry.value = entries.first;
                  return buildDictionaryMatch(entries);
                } else {
                  return buildDictionaryNoMatch(clipboard);
                }
            }
          },
        );
      },
    );
  }

  Widget buildSubTrackChanger() {
    return ValueListenableBuilder(
      valueListenable: _currentSubTrack,
      builder: (context, index, widget) {
        if (_currentSubTrack.value == -50) {
          playAutoGeneratedSubtitles();
          return Container();
        }
        if (_currentSubTrack.value != -1) {
          playEmbeddedSubtitles(index);
          return Container();
        }
        return Container();
      },
    );
  }

  void playAutoGeneratedSubtitles() async {
    _subTitleController.subtitleType = SubtitleType.webvtt;
    String unprocessed =
        await requestAutoGeneratedSubtitles(streamData.videoURL);

    List<String> split = unprocessed.split("\n ");

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

    String subtitles = split.join("\n");

    _subTitleController.updateSubtitleContent(content: subtitles);

    debugPrint(subtitles, wrapWidth: 1024);
    print("SUBTITLES SWITCHED TO AUTO GENERATED YOUTUBE SUBTITLES");
  }

  void startClipboardMonitor() {
    ClipboardMonitor.registerCallback(onClipboardText);
  }

  void stopClipboardMonitor() {
    ClipboardMonitor.unregisterCallback(onClipboardText);
  }

  void onClipboardText(String text) {
    _volatileText = text;

    Future.delayed(
        text.length == 1
            ? Duration(milliseconds: 1000)
            : Duration(milliseconds: 500), () {
      if (_volatileText == text) {
        print("CLIPBOARD CHANGED: $text");
        _clipboard.value = text;
      }
    });
  }

  void stopAllClipboardMonitoring() {
    ClipboardMonitor.unregisterAllCallbacks();
  }

  void openTranscript(List<dynamic> subtitles) async {
    ItemScrollController itemScrollController = ItemScrollController();
    ItemPositionsListener itemPositionsListener =
        ItemPositionsListener.create();
    _videoPlayerController.pause();

    int subIndex = 0;

    for (int i = 0; i < subtitles.length; i++) {
      if (subtitles[i].startTime.inMilliseconds <
          _videoPlayerController.value.position.inMilliseconds) {
        subIndex = i++;
      }
    }

    showModalBottomSheet<int>(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => transcriptDialog(
        subIndex,
        subtitles,
        itemScrollController,
        itemPositionsListener,
      ),
    );
  }

  Widget transcriptDialog(
      int i,
      List<dynamic> subtitles,
      ItemScrollController itemScrollController,
      ItemPositionsListener itemPositionsListener) {
    if (subtitles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.subtitles_off_outlined, color: Colors.white, size: 72),
            const SizedBox(height: 6),
            Text(
              "The transcript is empty.",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return ScrollablePositionedList.builder(
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      initialScrollIndex: (i - 2 > 0) ? i - 2 : 0,
      itemCount: subtitles.length,
      itemBuilder: (context, index) {
        Subtitle subtitle = subtitles[index];

        String subtitleText = "『 ${subtitle.text} 』";
        String subtitleStart = getTimestampFromDuration(subtitle.startTime);
        String subtitleEnd = getTimestampFromDuration(subtitle.endTime);
        String subtitleDuration = "$subtitleStart - $subtitleEnd";

        return ListTile(
          selected: i == index,
          selectedTileColor: Colors.red.withOpacity(0.15),
          dense: true,
          title: Column(
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.textsms_outlined,
                    size: 12.0,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    subtitleDuration,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitleText,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 6),
            ],
          ),
          onTap: () {
            Navigator.pop(context);
            _videoPlayerController.seekTo(subtitles[index].startTime);
            _videoPlayerController.play();
          },
        );
      },
    );
  }
}

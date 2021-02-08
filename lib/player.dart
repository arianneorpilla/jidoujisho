import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:jidoujisho/util.dart';

final currentClipboard = ValueNotifier<String>("");
final currentDefinition = ValueNotifier<String>("");
final currentReading = ValueNotifier<String>("");
final currentSubtitle = ValueNotifier<Subtitle>(
  Subtitle(startTime: Duration.zero, endTime: Duration.zero, text: ""),
);
final currentSubTrack = ValueNotifier<int>(0);
VoidCallback callback;

class Player extends StatelessWidget {
  Player(
    this.webURL,
  );

  final String webURL;

  @override
  Widget build(BuildContext context) {
    // If webURL is empty, then use a local player.
    if (this.webURL == "") {
      return localPlayer();
    } else {
      return webPlayer();
    }
  }

  Widget localPlayer() {
    return new FutureBuilder(
      future: FilePicker.platform.pickFiles(
        type: Platform.isIOS ? FileType.any : FileType.video,
        allowMultiple: false,
        allowCompression: false,
      ),
      builder:
          (BuildContext context, AsyncSnapshot<FilePickerResult> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return loadingCircle();
          default:
            if (snapshot.hasData) {
              File videoFile = File(snapshot.data.files.single.path);
              print(videoFile.path);

              return FutureBuilder(
                  future: extractSubtitles(videoFile),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<File>> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return loadingCircle();
                      default:
                        List<File> internalSubs = snapshot.data;
                        String defaultSubtitles =
                            loadDefaultSubtitles(videoFile, internalSubs);

                        return VideoPlayer(
                          videoFile: videoFile,
                          internalSubs: internalSubs,
                          defaultSubtitles: defaultSubtitles,
                        );
                    }
                  });
            }
            Navigator.pop(context);
            return Container();
        }
      },
    );
  }

  Widget webPlayer() {
    String videoID = "";

    try {
      videoID = YoutubePlayer.convertUrlToId(webURL);
      print(videoID);
    } catch (error) {
      print("Invalid link");
      return Container();
    }

    return new FutureBuilder(
      future: getPlayerYouTubeInfo(webURL),
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
            String webStream = snapshot.data;
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
                    String webSubtitles;

                    if (!snapshot.hasData || snapshot.data.isEmpty) {
                      webSubtitles = "";
                    } else {
                      webSubtitles = timedTextToSRT(snapshot.data);
                    }

                    return VideoPlayer(
                      webStream: webStream,
                      defaultSubtitles: webSubtitles,
                      internalSubs: [],
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
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class VideoPlayer extends StatefulWidget {
  VideoPlayer({
    this.videoFile,
    this.internalSubs,
    this.defaultSubtitles,
    this.webStream,
    Key key,
  }) : super(key: key);

  final File videoFile;
  final List<File> internalSubs;
  final String defaultSubtitles;
  final String webStream;

  @override
  _VideoPlayerState createState() => _VideoPlayerState(
        this.videoFile,
        this.internalSubs,
        this.defaultSubtitles,
        this.webStream,
      );
}

class _VideoPlayerState extends State<VideoPlayer> {
  _VideoPlayerState(
    File videoFile,
    List<File> internalSubs,
    String defaultSubtitles,
    String webStream,
  ) {
    _videoFile = videoFile;
    _internalSubs = internalSubs;
    _defaultSubtitles = defaultSubtitles;
    _webStream = webStream;
  }

  VlcPlayerController _videoPlayerController;
  ChewieController _chewieController;
  SubTitleWrapper _subTitleWrapper;
  SubtitleController _subTitleController;

  File _videoFile;
  List<File> _internalSubs;
  String _defaultSubtitles;
  String _webStream;

  bool isWeb() {
    return _webStream == null;
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
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

  @override
  Widget build(BuildContext context) {
    callback = playExternalSubtitles;
    startClipboardMonitor();

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 20) {
                  getVideoPlayerController()
                      .seekTo(currentSubtitle.value.endTime);
                } else if (details.delta.dx < -20) {
                  getVideoPlayerController()
                      .seekTo(currentSubtitle.value.startTime);
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
            buildDictionary(),
            buildSubTrackChanger(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_videoPlayerController != null && _chewieController != null) {
      _videoPlayerController?.dispose();
      _chewieController?.dispose();
    }
  }

  VlcPlayerController getVideoPlayerController() {
    if (_webStream == null) {
      _videoPlayerController ??= VlcPlayerController.file(_videoFile,
          options: VlcPlayerOptions(
              audio: VlcAudioOptions(["--audio-track=0", "--sub-track=999"])));
    } else {
      _videoPlayerController ??= VlcPlayerController.network(
        _webStream,
      );
    }
    return _videoPlayerController;
  }

  ChewieController getChewieController() {
    _chewieController ??= ChewieController(
      videoPlayerController: getVideoPlayerController(),
      aspectRatio: getVideoPlayerController().value.aspectRatio,
      autoPlay: true,
      autoInitialize: true,
      allowFullScreen: false,
      allowMuting: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.redAccent,
        handleColor: Colors.redAccent,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.redAccent[100],
      ),
      fullScreenByDefault: false,
      allowedScreenSleep: false,
    );
    return _chewieController;
  }

  void playEmbeddedSubtitles(int index) {
    if (_internalSubs.isEmpty) {
      return;
    }

    if (index < _internalSubs.length) {
      getSubtitleWrapper().subtitleController.updateSubtitleContent(
          content: _internalSubs[index].readAsStringSync());
      print("Switch Subtitle to Track $index");
    } else {
      _subTitleController.updateSubtitleContent(content: "");
      print("Turn Off");
    }
  }

  void playExternalSubtitles() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["srt"],
      allowMultiple: false,
    );

    if (result != null) {
      File subFile = File(result.files.single.path);
      getSubtitleWrapper()
          .subtitleController
          .updateSubtitleContent(content: subFile.readAsStringSync());
      print("Switch Subtitle to External SRT");
    }
  }

  SubtitleController getSubtitleController() {
    _subTitleController ??= SubtitleController(
      subtitlesContent: _defaultSubtitles,
      showSubtitles: true,
      subtitleDecoder: SubtitleDecoder.utf8,
      subtitleType: SubtitleType.srt,
    );

    return _subTitleController;
  }

  SubTitleWrapper getSubtitleWrapper() {
    _subTitleWrapper ??= SubTitleWrapper(
      subtitleNotifier: currentSubtitle,
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

  Widget buildDictionaryLoading(String clipboard) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Theme.of(context).backgroundColor.withOpacity(0.6),
            child: Column(
              children: [
                Text("Looking up \"" +
                    clipboard.replaceAll("@usejisho@", "") +
                    "\"...")
              ],
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryNoMatch(String clipboard) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {
              currentClipboard.value = "";
              currentDefinition.value = "";
              currentReading.value = "";
            },
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Theme.of(context).backgroundColor.withOpacity(0.6),
              child: Text("No matches for \"" +
                  clipboard.replaceAll("@usejisho@", "") +
                  "\" could be queried"),
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryMatch(List<String> results) {
    String slug = results[0];
    String readings = results[1];
    String definitions = results[2];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              currentClipboard.value = "";
              currentReading.value = "";
              currentDefinition.value = "";
            },
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
                color: Theme.of(context).backgroundColor.withOpacity(0.6),
                child: Column(
                  children: [
                    SelectableText(
                      slug,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SelectableText(readings),
                    SelectableText("\n$definitions\n"),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionary() {
    return ValueListenableBuilder(
      valueListenable: currentClipboard,
      builder: (context, clipboard, widget) {
        return FutureBuilder(
          future: getWordDetails(clipboard),
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (currentClipboard.value == "") {
              return Container();
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return buildDictionaryLoading(clipboard);
              default:
                List<String> results = snapshot.data;

                if (snapshot.hasData) {
                  currentReading.value = snapshot.data[1];
                  currentDefinition.value = snapshot.data[2];
                  return buildDictionaryMatch(results);
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
      valueListenable: currentSubTrack,
      builder: (context, index, widget) {
        playEmbeddedSubtitles(index);
        return Container();
      },
    );
  }

  void startClipboardMonitor() {
    ClipboardMonitor.registerCallback(onClipboardText);
  }

  void stopClipboardMonitor() {
    ClipboardMonitor.unregisterCallback(onClipboardText);
  }

  void onClipboardText(String text) {
    currentClipboard.value = text;
    print("clipboard changed: $text");
  }

  void stopAllClipboardMonitoring() {
    ClipboardMonitor.unregisterAllCallbacks();
  }

  void openTranscript(List<dynamic> subtitles) {
    ItemScrollController itemScrollController = ItemScrollController();
    ItemPositionsListener itemPositionsListener =
        ItemPositionsListener.create();

    _videoPlayerController.pause();

    int subIndex = 0;

    List<Subtitle> resorted = [];
    for (Subtitle sub in subtitles) {
      resorted.add(sub);
    }
    resorted.sort((a, b) => a.startTime.compareTo(b.startTime));

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
        builder: (context) {
          return Stack(children: [
            transcriptDialog(subtitles, subIndex, itemScrollController,
                itemPositionsListener),
            Container(
              height: 64,
              color: Colors.grey[900].withOpacity(0.9),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Center(
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Icon(
                        Icons.text_snippet_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Transcript",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]);
        });
  }

  Widget transcriptDialog(
    List<dynamic> subtitles,
    int i,
    ItemScrollController itemScrollController,
    ItemPositionsListener itemPositionsListener,
  ) {
    if (subtitles.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.subtitles_off_outlined, color: Colors.white, size: 72),
          SizedBox(height: 6),
          Center(
            child: Text(
              "The transcript is empty.",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      );
    }

    return ScrollablePositionedList.builder(
      padding: EdgeInsets.only(top: 64, bottom: 64),
      initialScrollIndex: (i - 3 > 0) ? i - 3 : 0,
      itemCount: subtitles.length,
      itemBuilder: (context, index) {
        Subtitle _subtitle = subtitles[index];

        String _text = _subtitle.text;
        String _startTime = getTimestampFromDuration(_subtitle.startTime);
        String _endTime = getTimestampFromDuration(_subtitle.endTime);

        return ListTile(
          selected: i == index,
          selectedTileColor: Colors.redAccent.withOpacity(0.15),
          dense: true,
          title: Column(
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.textsms_outlined,
                    size: 12.0,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    "$_startTime - $_endTime",
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
                "『 $_text 』",
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
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
    );
  }
}

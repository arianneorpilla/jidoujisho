import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:ext_video_player/ext_video_player.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:jidoujisho/util.dart';

class Player extends StatelessWidget {
  Player(this.webURL);

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
        type: FileType.video,
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
              webURL: webURL,
              defaultSubtitles: webSubtitles,
              internalSubs: [],
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
    this.webURL,
    Key key,
  }) : super(key: key);

  final File videoFile;
  final List<File> internalSubs;
  final String defaultSubtitles;
  final String webURL;

  @override
  _VideoPlayerState createState() => _VideoPlayerState(
        this.videoFile,
        this.internalSubs,
        this.defaultSubtitles,
        this.webURL,
      );
}

class _VideoPlayerState extends State<VideoPlayer> {
  _VideoPlayerState(
    File videoFile,
    List<File> internalSubs,
    String defaultSubtitles,
    String webURL,
  ) {
    _videoFile = videoFile;
    _internalSubs = internalSubs;
    _defaultSubtitles = defaultSubtitles;
    _webURL = webURL;
  }

  final _clipboard = ValueNotifier<String>("");
  final _currentDefinition = ValueNotifier<String>("");
  final _currentReading = ValueNotifier<String>("");
  final _currentSubtitle = ValueNotifier<Subtitle>(
    Subtitle(startTime: Duration.zero, endTime: Duration.zero, text: ""),
  );
  final _currentSubTrack = ValueNotifier<int>(0);

  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  SubTitleWrapper _subTitleWrapper;
  SubtitleController _subTitleController;

  File _videoFile;
  List<File> _internalSubs;
  String _defaultSubtitles;
  String _webURL;

  bool isWeb() {
    return _webURL == null;
  }

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

  @override
  Widget build(BuildContext context) {
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

  VideoPlayerController getVideoPlayerController() {
    if (_webURL == null) {
      _videoPlayerController ??= VideoPlayerController.file(
        _videoFile,
        _internalSubs,
        _clipboard,
        _currentDefinition,
        _currentReading,
        _currentSubtitle,
        _currentSubTrack,
        playExternalSubtitles,
      );
    } else {
      _videoPlayerController ??= VideoPlayerController.network(
        _webURL,
        _clipboard,
        _currentDefinition,
        _currentReading,
        _currentSubtitle,
        _currentSubTrack,
        playExternalSubtitles,
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
              return FutureBuilder(
                future: getVideoPlayerController().setAudioByIndex(0),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Container();
                    default:
                      return Chewie(
                        controller: _chewieController,
                      );
                  }
                },
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
                Text("Looking up \"" + clipboard + "\" on Jisho.org...")
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
              _clipboard.value = "";
              _currentDefinition.value = "";
              _currentReading.value = "";
            },
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Theme.of(context).backgroundColor.withOpacity(0.6),
              child:
                  Text("No matches for \"" + clipboard + "\" could be queried"),
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
              _clipboard.value = "";
              _currentReading.value = "";
              _currentDefinition.value = "";
            },
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Theme.of(context).backgroundColor.withOpacity(0.6),
              child: Column(
                children: [
                  Text(
                    slug,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(readings),
                  Text("\n$definitions\n"),
                ],
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
      valueListenable: _clipboard,
      builder: (context, clipboard, widget) {
        return FutureBuilder(
          future: getWordDetails(clipboard),
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (_clipboard.value == "") {
              return Container();
            }
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return buildDictionaryLoading(clipboard);
              default:
                List<String> results = snapshot.data;

                if (snapshot.hasData) {
                  _currentReading.value = snapshot.data[1];
                  _currentDefinition.value = snapshot.data[2];
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
      valueListenable: _currentSubTrack,
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
    _clipboard.value = text;
    print("clipboard changed: $text");
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
        builder: (context) => transcriptDialog(
            subtitles, subIndex, itemScrollController, itemPositionsListener));
  }

  Widget transcriptDialog(
      List<dynamic> subtitles,
      int i,
      ItemScrollController itemScrollController,
      ItemPositionsListener itemPositionsListener) {
    if (subtitles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.subtitles_off_outlined, color: Colors.white, size: 72),
            SizedBox(height: 6),
            Text(
              "The transcript is empty.",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return ScrollablePositionedList.builder(
      initialScrollIndex: (i - 2 > 0) ? i - 2 : 0,
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

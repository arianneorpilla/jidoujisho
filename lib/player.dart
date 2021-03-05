import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:ext_video_player/ext_video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:wakelock/wakelock.dart';

import 'package:jidoujisho/util.dart';

class Player extends StatelessWidget {
  Player({this.streamURL});

  final String streamURL;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    Wakelock.enable();

    // If webURL is empty, then use a local player.
    if (this.streamURL == null) {
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
              print("VIDEO FILE: ${videoFile.path}");

              return FutureBuilder(
                future: extractSubtitles(videoFile),
                builder:
                    (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return loadingCircle();
                    default:
                      List<File> internalSubs = snapshot.data;
                      String defaultSubtitles =
                          getDefaultSubtitles(videoFile, internalSubs);

                      return VideoPlayer(
                        videoFile: videoFile,
                        internalSubs: internalSubs,
                        defaultSubtitles: defaultSubtitles,
                      );
                  }
                },
              );
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
      videoID = YoutubePlayer.convertUrlToId(streamURL);
      print(videoID);
    } catch (error) {
      print("Invalid link");
      return Container();
    }

    return new FutureBuilder(
      future: getPlayerYouTubeInfo(streamURL),
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ),
            );
          default:
            String webStream = snapshot.data;
            return new FutureBuilder(
              future: http.read(
                  "https://www.youtube.com/api/timedtext?lang=ja&v=$videoID"),
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

                    return VideoPlayer(
                      webStream: webStream,
                      defaultSubtitles: webSubtitles,
                      internalSubs: internalSubs,
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

  final _clipboard = ValueNotifier<String>("");
  final _currentWord = ValueNotifier<String>("");
  final _currentDefinition = ValueNotifier<String>("");
  final _currentReading = ValueNotifier<String>("");
  final _currentSubtitle = ValueNotifier<Subtitle>(
    Subtitle(
      startTime: Duration.zero,
      endTime: Duration.zero,
      text: "",
    ),
  );
  final _currentSubTrack = ValueNotifier<int>(0);

  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  SubTitleWrapper _subTitleWrapper;
  SubtitleController _subTitleController;
  bool _isSelectionVolatile = false;
  String _volatileText = "";
  FocusNode _subtitleFocusNode = new FocusNode();

  File _videoFile;
  List<File> _internalSubs;
  String _defaultSubtitles;
  String _webStream;

  @override
  void dispose() {
    super.dispose();
    if (_videoPlayerController != null && _chewieController != null) {
      _videoPlayerController?.dispose();
      _chewieController?.dispose();
    }
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
            Wakelock.disable();
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

  VideoPlayerController getVideoPlayerController() {
    if (_videoFile != null) {
      _videoPlayerController ??= VideoPlayerController.file(
        _videoFile,
        _internalSubs,
        _clipboard,
        _currentWord,
        _currentDefinition,
        _currentReading,
        _currentSubtitle,
        _currentSubTrack,
        playExternalSubtitles,
      );
    } else {
      _videoPlayerController ??= VideoPlayerController.network(
        _webStream,
        _internalSubs,
        _clipboard,
        _currentWord,
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
      focusNode: _subtitleFocusNode,
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

  void playEmbeddedSubtitles(int index) {
    if (_internalSubs.isEmpty) {
      return;
    }

    if (index < _internalSubs.length) {
      getSubtitleWrapper().subtitleController.updateSubtitleContent(
          content: _internalSubs[index].readAsStringSync());
      print("SUBTITLES SWITCHED TO TRACK $index");
    } else {
      _subTitleController.updateSubtitleContent(content: "");
      print("SUBTITLES SWITCHED OFF");
    }
  }

  void playExternalSubtitles() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null) {
      File subFile = File(result.files.single.path);
      if (subFile.path.endsWith("srt")) {
        getSubtitleWrapper()
            .subtitleController
            .updateSubtitleContent(content: subFile.readAsStringSync());
        print("SUBTITLES SWITCHED TO EXTERNAL SRT");
      } else {
        getSubtitleWrapper().subtitleController.updateSubtitleContent(
            content: await extractNonSrtSubtitles(subFile));
        print("SUBTITLES SWITCHED TO EXTERNAL ASS");
      }
    }
  }

  Widget buildDictionaryLoading(String clipboard) {
    String clipboardText = clipboard.replaceAll("@usejisho@", "");
    String lookupText = "Looking up \"$clipboardText\"...";

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
    String clipboardText = clipboard.replaceAll("@usejisho@", "");
    String lookupText = "No matches for \"$clipboardText\" could be queried";

    _subtitleFocusNode.unfocus();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {
              _clipboard.value = "";
              _currentWord.value = "";
              _currentDefinition.value = "";
              _currentReading.value = "";
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

  Widget buildDictionaryMatch(List<String> results) {
    String slug = results[0];
    String readings = results[1];
    String definitions = results[2];

    _subtitleFocusNode.unfocus();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              _clipboard.value = "";
              _currentWord.value = "";
              _currentReading.value = "";
              _currentDefinition.value = "";
            },
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.grey[800].withOpacity(0.6),
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
                  _currentWord.value = results[0];
                  _currentReading.value = results[1];
                  _currentDefinition.value = results[2];

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

import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:chewie/chewie.dart';
import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
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

import 'package:jidoujisho/anki.dart';
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:jidoujisho/util.dart';
import 'package:jidoujisho/youtube.dart';

class Player extends StatelessWidget {
  Player({this.url, this.initialPosition = -1, this.video});

  final int initialPosition;
  final String url;
  final Video video;

  void lockLandscape() {
    AutoOrientation.landscapeAutoMode(forceSensor: true);

    SystemChrome.setEnabledSystemUIOverlays([]);
  }

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
    lockLandscape();

    print("VIDEO FILE: ${videoFile.path}");

    if (videoFile == null) {
      Navigator.pop(context);
    }

    return FutureBuilder(
      future: Future.wait(
        [
          extractSubtitles(videoFile),
          extractExternalSubtitles(getExternalSubtitles(videoFile))
        ],
      ),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return loadingCircle();
          default:
            List<dynamic> subtitleFutures = snapshot.data;
            List<File> internalSubs = subtitleFutures[0];
            File externalSubs = subtitleFutures[1];
            String unsanitized = "";
            if (externalSubs != null) {
              unsanitized = externalSubs.readAsStringSync();
            } else if (internalSubs.isNotEmpty) {
              unsanitized = internalSubs.first.readAsStringSync();
            }
            String defaultSubtitles = sanitizeSrtNewlines(unsanitized);

            setLastPlayedPath(videoFile.path);
            setLastPlayedPosition(0);
            gIsResumable.value = getResumeAvailable();

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
    lockLandscape();

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
            return loadingCircle();
          default:
            YouTubeMux streamData = snapshot.data;

            return new FutureBuilder(
              future: http.read(Uri.parse(
                  "https://www.youtube.com/api/timedtext?lang=ja&v=$videoID")),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return loadingCircle();
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
  ValueNotifier<bool> _wasPlaying = ValueNotifier<bool>(false);
  ValueNotifier<bool> _widgetVisibility = ValueNotifier<bool>(false);
  ValueNotifier<Subtitle> _shadowingSubtitle = ValueNotifier<Subtitle>(null);
  ValueNotifier<Subtitle> _comprehensionSubtitle =
      ValueNotifier<Subtitle>(null);
  ValueNotifier<int> _audioAllowance = ValueNotifier<int>(getAudioAllowance());

  Timer durationTimer;
  Timer visibilityTimer;

  @override
  void initState() {
    super.initState();
    durationTimer = Timer.periodic(
        Duration(seconds: 1), (Timer t) => updateDurationOrSeek());
    visibilityTimer = Timer.periodic(
        Duration(milliseconds: 100), (Timer t) => visibilityTimerAction());
  }

  Future<void> playPause() async {
    _wasPlaying.value = false;

    if (getVideoPlayerController().value.isPlaying) {
      await getVideoPlayerController().pause();
    } else {
      await getVideoPlayerController().play();
    }
  }

  Future<void> rewindFastForward() async {
    await getVideoPlayerController().seekTo(_currentSubtitle.value.startTime +
        Duration(milliseconds: _subTitleController.subtitlesOffset));
  }

  @override
  void dispose() {
    if (_videoPlayerController != null && _chewieController != null) {
      _videoPlayerController?.stopRendererScanning();
      _videoPlayerController?.dispose();
      _chewieController?.dispose();
    }
    durationTimer.cancel();
    visibilityTimer.cancel();
    super.dispose();
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

  void visibilityTimerAction() {
    if (getVideoPlayerController().value.isInitialized) {
      if (_comprehensionSubtitle.value != null) {
        if (getVideoPlayerController().value.position.inMilliseconds +
                    _audioAllowance.value -
                    getSubtitleController().subtitlesOffset <
                _comprehensionSubtitle.value.startTime.inMilliseconds - 10000 ||
            getVideoPlayerController().value.position.inMilliseconds -
                    _audioAllowance.value -
                    getSubtitleController().subtitlesOffset >
                _comprehensionSubtitle.value.endTime.inMilliseconds) {
          if (getSubtitleController().widgetVisibility.value) {
            getSubtitleController().widgetVisibility.value = false;
          }
        }
      }

      if (_shadowingSubtitle.value != null) {
        if (getVideoPlayerController().value.position.inMilliseconds +
                    _audioAllowance.value -
                    getSubtitleController().subtitlesOffset <
                _shadowingSubtitle.value.startTime.inMilliseconds - 10000 ||
            getVideoPlayerController().value.position.inMilliseconds -
                    _audioAllowance.value -
                    getSubtitleController().subtitlesOffset >
                _shadowingSubtitle.value.endTime.inMilliseconds) {
          getVideoPlayerController().seekTo(Duration(
              milliseconds: _shadowingSubtitle.value.startTime.inMilliseconds +
                  getSubtitleController().subtitlesOffset -
                  _audioAllowance.value));
        }
      }

      if (!getListeningComprehensionMode()) {
        Duration cutOffStart =
            _currentSubtitle.value.startTime - Duration(milliseconds: 100);
        Duration cutOffEnd =
            _currentSubtitle.value.endTime + Duration(milliseconds: 100);

        if (getVideoPlayerController().value.position.inMilliseconds -
                    getSubtitleController().subtitlesOffset >
                cutOffStart.inMilliseconds &&
            getVideoPlayerController().value.position.inMilliseconds -
                    getSubtitleController().subtitlesOffset <
                cutOffEnd.inMilliseconds) {
          getSubtitleController().widgetVisibility.value = true;
        } else {
          getSubtitleController().widgetVisibility.value = false;
        }
      }
    }
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

    int inSeconds = getVideoPlayerController().value.position.inSeconds ?? 0;
    setLastPlayedPosition(inSeconds);

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
  final _failureMetadata = ValueNotifier<AnkiExportMetadata>(null);

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
                if (details.delta.dx.abs() > 20) {
                  _comprehensionSubtitle.value = _currentSubtitle.value;
                  getSubtitleController().widgetVisibility.value = true;

                  getVideoPlayerController().seekTo(_currentSubtitle
                          .value.startTime +
                      Duration(
                          milliseconds: _subTitleController.subtitlesOffset));
                }
              },
              onVerticalDragUpdate: (details) {
                _wasPlaying.value =
                    (getVideoPlayerController().value.isPlaying ||
                        _wasPlaying.value);

                if (details.delta.dy.abs() > 20) {
                  openTranscript(
                      _subTitleController.subtitleBloc.subtitles.subtitles,
                      _wasPlaying.value);
                }
              },
              child: getSubtitleWrapper(),
            ),
            StreamBuilder(
              stream: AudioService.customEventStream,
              builder: (context, snapshot) {
                String response = snapshot.data;
                switch (response) {
                  case "playPause":
                    playPause();
                    break;
                  case "rewindFastForward":
                    rewindFastForward();
                    break;
                  default:
                }
                return Container();
              },
            ),
            buildSubTrackChanger(),
            buildDictionary(),
          ],
        ),
      ),
    );
  }

  void exportMultiCallback(
    Subtitle selectedSubtitle,
    List<Subtitle> selection,
    bool wasPlaying,
  ) {
    _clipboard.value = "&<&>export&<&>";

    exportToAnki(
      context,
      getChewieController(),
      getVideoPlayerController(),
      _clipboard,
      selectedSubtitle,
      _currentDictionaryEntry.value,
      wasPlaying,
      selection,
      _audioAllowance.value,
      getSubtitleController().subtitlesOffset,
      _failureMetadata,
    );
  }

  void exportSingleCallback() {
    getVideoPlayerController().pause();
    _clipboard.value = "&<&>export&<&>";

    exportToAnki(
      context,
      getChewieController(),
      getVideoPlayerController(),
      _clipboard,
      _currentSubtitle.value,
      _currentDictionaryEntry.value,
      _wasPlaying.value,
      [_currentSubtitle.value],
      _audioAllowance.value,
      getSubtitleController().subtitlesOffset,
      _failureMetadata,
    );
  }

  Future<bool> _onWillPop() async {
    if (getVideoPlayerController().value.isEnded) {
      Navigator.pop(context, true);
    }

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
            Navigator.pop(context, true);
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

  void toggleShadowingMode() {
    if (_shadowingSubtitle.value == null) {
      _shadowingSubtitle.value = _currentSubtitle.value;
    } else {
      _shadowingSubtitle.value = null;
    }
  }

  ChewieController getChewieController() {
    _chewieController ??= ChewieController(
      videoPlayerController: getVideoPlayerController(),
      internalSubs: internalSubs,
      clipboard: _clipboard,
      currentDictionaryEntry: _currentDictionaryEntry,
      currentSubtitle: _currentSubtitle,
      currentSubTrack: _currentSubTrack,
      wasPlaying: _wasPlaying,
      playExternalSubtitles: playExternalSubtitles,
      retimeSubtitles: retimeSubtitles,
      exportSingleCallback: exportSingleCallback,
      toggleShadowingMode: toggleShadowingMode,
      shadowingSubtitle: _shadowingSubtitle,
      audioAllowance: _audioAllowance,
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
      subtitlesOffset: getSubtitleDelay(),
      widgetVisibility: _widgetVisibility,
      comprehensionSubtitle: _comprehensionSubtitle,
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

    if (index < internalSubs.length) {
      getSubtitleWrapper().subtitleController.updateSubtitleContent(
          content: sanitizeSrtNewlines(internalSubs[index].readAsStringSync()));
      print("SUBTITLES SWITCHED TO TRACK $index");
    } else {
      _subTitleController.updateSubtitleContent(content: "");
      print("SUBTITLES SWITCHED OFF");
    }
  }

  void playExternalSubtitles() async {
    _subTitleController.subtitleType = SubtitleType.srt;

    File result = await FilePicker.getFile(
      type: FileType.any,
    );

    if (result != null) {
      if (result.path.endsWith("srt")) {
        getSubtitleWrapper().subtitleController.updateSubtitleContent(
            content: sanitizeSrtNewlines(result.readAsStringSync()));
        print("SUBTITLES SWITCHED TO EXTERNAL SRT");
      } else {
        getSubtitleWrapper().subtitleController.updateSubtitleContent(
            content: sanitizeSrtNewlines(
                (await extractExternalSubtitles(result)).readAsStringSync()));
        print("SUBTITLES SWITCHED TO EXTERNAL ASS");
      }
    }
  }

  void retimeSubtitles() async {
    TextEditingController _offsetController = TextEditingController(
        text: getSubtitleController().subtitlesOffset.toString());
    TextEditingController _allowanceController =
        TextEditingController(text: _audioAllowance.value.toString());

    void setValues(bool remember) {
      String offsetText = _offsetController.text;
      int newOffset = int.tryParse(offsetText);

      String allowanceText = _allowanceController.text;
      int newAllowance = int.tryParse(allowanceText);

      if (newOffset != null && newAllowance != null) {
        getSubtitleController().subtitlesOffset = newOffset;
        getSubtitleController().updateSubtitleContent(
            content: getSubtitleController().subtitlesContent);
        _audioAllowance.value = newAllowance;

        if (remember) {
          setSubtitleDelay(newOffset);
          setAudioAllowance(newAllowance);
        }

        Navigator.pop(context);
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * (1 / 3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _offsetController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: true,
                        decimal: false,
                      ),
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Subtitle delay",
                          hintText: "Enter subtitle delay",
                          suffixText: " ms"),
                    ),
                    TextField(
                      controller: _allowanceController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: true,
                        decimal: false,
                      ),
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Audio allowance",
                          hintText: "Enter audio allowance",
                          suffixText: " ms"),
                    ),
                  ],
                ),
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
                child: Text('SET AND REMEMBER',
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  setValues(true);
                },
              ),
              TextButton(
                child: Text('SET', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  setValues(false);
                },
              ),
            ],
          );
        });
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

  Widget buildDictionaryAutoGenDependencies(String clipboard) {
    String lookupText = "Setting up required dependencies...";

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

  Widget buildDictionaryAutoGenBad(String clipboard) {
    String lookupText = "Unable to query for automatic captions.";
    Future.delayed(Duration(seconds: 1), () {
      _clipboard.value = "";
    });

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

  Widget buildDictionaryAutoGenQuery(String clipboard) {
    String lookupText = "Querying for automatic captions...";

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
        "The AnkiDroid background service must be active for card export.\n" +
            "Press here to launch AnkiDroid and return to continue.";

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            await LaunchApp.openApp(
              androidPackageName: 'com.ichi2.anki',
              openStore: true,
            );

            _clipboard.value = "";

            try {
              await getDecks();
              AnkiExportMetadata metadata = _failureMetadata.value;

              _clipboard.value = "&<&>export&<&>";

              exportToAnki(
                context,
                metadata.chewie,
                metadata.controller,
                metadata.clipboard,
                metadata.subtitle,
                metadata.dictionaryEntry,
                metadata.wasPlaying,
                metadata.exportSubtitles,
                metadata.audioAllowance,
                metadata.subtitleDelay,
                _failureMetadata,
              );

              _failureMetadata.value = null;
            } catch (e) {
              print(e);
            }
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
    if (gIsSelectMode.value) {
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
              if (getFocusMode() && _wasPlaying.value) {
                _videoPlayerController.play();
                _wasPlaying.value = false;
              }

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
              if (getFocusMode() && _wasPlaying.value) {
                _videoPlayerController.play();
                _wasPlaying.value = false;
              }

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
                      child: gCustomDictionary.isNotEmpty ||
                              getMonolingualMode()
                          ? SelectableText(
                              "\n${results[selectedIndex.value].meaning}\n")
                          : Text("\n${results[selectedIndex.value].meaning}\n"),
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
      },
    );
  }

  Widget buildDictionary() {
    return ValueListenableBuilder(
      valueListenable: _clipboard,
      builder: (context, clipboard, widget) {
        return FutureBuilder(
          future: getMonolingualMode()
              ? getMonolingualWordDetails(clipboard, false)
              : getWordDetails(clipboard),
          builder: (BuildContext context,
              AsyncSnapshot<List<DictionaryEntry>> snapshot) {
            if (_clipboard.value == "&<&>export&<&>") {
              return buildDictionaryExporting(clipboard);
            }
            if (_clipboard.value == "&<&>exportlong&<&>") {
              return buildDictionaryExportingLong(clipboard);
            }
            if (_clipboard.value == "&<&>autogen&<&>") {
              return buildDictionaryAutoGenQuery(clipboard);
            }
            if (_clipboard.value == "&<&>autogendependencies&<&>") {
              return buildDictionaryAutoGenDependencies(clipboard);
            }
            if (_clipboard.value == "&<&>autogenbad&<&>") {
              return buildDictionaryAutoGenBad(clipboard);
            }
            if (_clipboard.value.startsWith("&<&>exported")) {
              return buildDictionaryExported(clipboard);
            }
            if (_clipboard.value == "") {
              return Container();
            }

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                if (getFocusMode()) {
                  _wasPlaying.value =
                      (getVideoPlayerController().value.isPlaying ||
                          _wasPlaying.value);
                  _videoPlayerController.pause();
                }

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
        if (_currentSubTrack.value == -51) {
          return Container();
        }
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
    _clipboard.value = "&<&>autogendependencies&<&>";
    await installYouTubeDLDependencies();

    _clipboard.value = "&<&>autogen&<&>";

    _subTitleController.subtitleType = SubtitleType.webvtt;
    String unprocessed = await requestAutoGeneratedSubtitles(
      streamData.videoURL,
      _clipboard,
      _currentSubTrack,
    );

    String subtitles = sanitizeVttNewlines(unprocessed);

    _subTitleController.updateSubtitleContent(content: subtitles);

    debugPrint(subtitles, wrapWidth: 1024);
    print("SUBTITLES SWITCHED TO AUTO GENERATED YOUTUBE SUBTITLES");

    _clipboard.value = "";
    // This is really not good, define this properly.
    _currentSubTrack.value = -51;
  }

  void openTranscript(List<dynamic> subtitles, bool wasPlaying) async {
    ItemScrollController itemScrollController = ItemScrollController();
    ItemPositionsListener itemPositionsListener =
        ItemPositionsListener.create();
    _videoPlayerController.pause();

    int subIndex = 0;
    bool isExporting = false;

    for (int i = 0; i < subtitles.length; i++) {
      if (subtitles[i].startTime.inMilliseconds ==
              _currentSubtitle.value.startTime.inMilliseconds &&
          subtitles[i].endTime.inMilliseconds ==
              _currentSubtitle.value.endTime.inMilliseconds &&
          subtitles[i].text == _currentSubtitle.value.text) {
        subIndex = i;
        break;
      }
    }

    Widget transcriptDialog(
        int selectedIndex,
        List<dynamic> subtitles,
        ItemScrollController itemScrollController,
        ItemPositionsListener itemPositionsListener,
        ChewieController chewie,
        VlcPlayerController controller,
        DictionaryEntry currentDictionaryEntry,
        bool wasPlaying) {
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
        initialScrollIndex: (selectedIndex - 2 > 0) ? selectedIndex - 2 : 0,
        itemCount: subtitles.length,
        itemBuilder: (context, index) {
          Subtitle subtitle = subtitles[index];

          String subtitleText = "『 ${subtitle.text} 』";
          String subtitleStart = getTimestampFromDuration(subtitle.startTime);
          String subtitleEnd = getTimestampFromDuration(subtitle.endTime);
          String subtitleDuration = "$subtitleStart - $subtitleEnd";

          return ListTile(
            selected: selectedIndex == index,
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
              _videoPlayerController.seekTo(subtitles[index].startTime +
                  Duration(milliseconds: _subTitleController.subtitlesOffset));
              _videoPlayerController.play();

              if (_shadowingSubtitle.value != null) {
                _shadowingSubtitle.value = subtitles[index];
              }

              _comprehensionSubtitle.value = subtitles[index];
              getSubtitleController().widgetVisibility.value = true;
            },
            onLongPress: () {
              List<Subtitle> selectedSubtitles = [];

              if (selectedIndex <= index) {
                for (int subIndex = selectedIndex;
                    subIndex <= index;
                    subIndex++) {
                  selectedSubtitles.add(subtitles[subIndex]);
                }
              } else {
                for (int subIndex = index;
                    subIndex <= selectedIndex;
                    subIndex++) {
                  selectedSubtitles.add(subtitles[subIndex]);
                }
              }

              String selectedText = "";
              String removeLastNewline(String n) =>
                  n = n.substring(0, n.length - 1);
              selectedSubtitles
                  .forEach((subtitle) => selectedText += subtitle.text + "\n");
              selectedText = removeLastNewline(selectedText);

              Duration selectedStartTime = selectedSubtitles.first.startTime;
              Duration selectedEndTime = selectedSubtitles.last.endTime;

              Subtitle selectedSubtitle = Subtitle(
                text: selectedText,
                startTime: selectedStartTime,
                endTime: selectedEndTime,
              );

              exportMultiCallback(
                  selectedSubtitle, selectedSubtitles, wasPlaying);
              isExporting = true;
              Navigator.pop(context);
            },
          );
        },
      );
    }

    await showModalBottomSheet<int>(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => transcriptDialog(
          subIndex,
          subtitles,
          itemScrollController,
          itemPositionsListener,
          getChewieController(),
          getVideoPlayerController(),
          _currentDictionaryEntry.value,
          _wasPlaying.value),
    );

    if (wasPlaying && !isExporting) {
      getVideoPlayerController().play();
    }
  }
}

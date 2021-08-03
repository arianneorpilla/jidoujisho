import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
//import 'package:gx_file_picker/gx_file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:progress_indicators/progress_indicators.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:jidoujisho/anki.dart';
import 'package:jidoujisho/cache.dart';
import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/pitch.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:jidoujisho/util.dart';
import 'package:jidoujisho/youtube.dart';

class JidoujishoPlayer extends StatefulWidget {
  JidoujishoPlayer({
    @required this.playerMode,
    this.url,
    this.initialPosition = -1,
    this.video,
  });

  final JidoujishoPlayerMode playerMode;
  final int initialPosition;
  final String url;
  final Video video;

  @override
  JidoujishoPlayerState createState() => JidoujishoPlayerState(
        playerMode: this.playerMode,
        initialPosition: this.initialPosition,
        url: this.url,
        video: this.video,
      );
}

class JidoujishoPlayerState extends State<JidoujishoPlayer> {
  JidoujishoPlayerState({
    @required this.playerMode,
    this.url,
    this.initialPosition = -1,
    this.video,
  });

  final JidoujishoPlayerMode playerMode;
  final int initialPosition;
  final String url;
  final Video video;

  @override
  Widget build(BuildContext context) {
    switch (playerMode) {
      case JidoujishoPlayerMode.localFile:
        return localPlayer(context, url, initialPosition);
        break;
      case JidoujishoPlayerMode.youtubeStream:
        return youtubePlayer(video, initialPosition);
        break;
      case JidoujishoPlayerMode.networkStream:
        return networkPlayer(url);
        break;
    }

    return Container();
  }

  @override
  void dispose() {
    super.dispose();
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
                  return Container();
                }

                return localPlayerHelper(
                  context,
                  videoFile,
                  initialPosition,
                );
              }
              Future.delayed((Duration(milliseconds: 200)), () {
                Navigator.pop(context);
              });
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

    return FutureBuilder(
      future: Future.wait(
        [
          extractSubtitles(videoFile.path),
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
            } else if (internalSubs != null && internalSubs.isNotEmpty) {
              unsanitized = internalSubs.first.readAsStringSync();
            }
            String defaultSubtitles = sanitizeSrtNewlines(unsanitized) ?? "";

            lockLandscape();

            return VideoPlayer(
              playerMode: JidoujishoPlayerMode.localFile,
              videoFile: videoFile,
              internalSubs: internalSubs,
              defaultSubtitles: defaultSubtitles,
              initialPosition: initialPosition,
            );
        }
      },
    );
  }

  Widget networkPlayer(String streamUrl) {
    lockLandscape();
    return VideoPlayer(
      playerMode: JidoujishoPlayerMode.networkStream,
      streamUrl: streamUrl,
      internalSubs: [],
      defaultSubtitles: "",
      initialPosition: -1,
    );
  }

  Widget youtubePlayer(Video video, int initialPosition) {
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
            if (streamData == null) {
              return youtubeWarning(context, url);
            }

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

                    lockLandscape();

                    return VideoPlayer(
                      playerMode: JidoujishoPlayerMode.youtubeStream,
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

  Widget youtubeWarning(BuildContext context, String webURL) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: Text("YouTube Error"),
      content: Text(
        "Unable to get the video. If this issue persists, please report the issue.",
        textAlign: TextAlign.justify,
      ),
      actions: <Widget>[
        TextButton(
          child: Text('TRY AGAIN', style: TextStyle(color: Colors.white)),
          onPressed: () async {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => JidoujishoPlayer(
                  playerMode: JidoujishoPlayerMode.youtubeStream,
                  url: webURL,
                ),
              ),
            );
          },
        ),
        TextButton(
          child: Text('OK', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
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
    this.playerMode,
    this.videoFile,
    this.streamData,
    this.internalSubs,
    this.defaultSubtitles,
    this.initialPosition,
    this.streamUrl,
    Key key,
  }) : super(key: key);

  final JidoujishoPlayerMode playerMode;
  final File videoFile;
  final YouTubeMux streamData;
  final List<File> internalSubs;
  final String defaultSubtitles;
  final int initialPosition;
  final String streamUrl;

  @override
  _VideoPlayerState createState() => _VideoPlayerState(
        this.playerMode,
        this.videoFile,
        this.streamData,
        this.internalSubs,
        this.defaultSubtitles,
        this.initialPosition,
        this.streamUrl,
      );
}

class _VideoPlayerState extends State<VideoPlayer>
    with SingleTickerProviderStateMixin {
  _VideoPlayerState(
    this.playerMode,
    this.videoFile,
    this.streamData,
    this.internalSubs,
    this.defaultSubtitles,
    this.initialPosition,
    this.streamUrl,
  );

  final JidoujishoPlayerMode playerMode;
  final File videoFile;
  final YouTubeMux streamData;
  final List<File> internalSubs;
  final String defaultSubtitles;
  final String streamUrl;

  int initialPosition;

  VlcPlayerController _videoPlayerController;
  ChewieController _chewieController;
  SubTitleWrapper _subTitleWrapper;
  SubtitleController _subTitleController;
  String _volatileText = "";
  FocusNode _subtitleFocusNode = new FocusNode();
  bool networkNotSet = true;
  bool historyNotSet = true;
  ValueNotifier<bool> _wasPlaying = ValueNotifier<bool>(false);
  ValueNotifier<bool> _widgetVisibility = ValueNotifier<bool>(false);
  ValueNotifier<Subtitle> _shadowingSubtitle = ValueNotifier<Subtitle>(null);
  ValueNotifier<Subtitle> _comprehensionSubtitle =
      ValueNotifier<Subtitle>(null);
  ValueNotifier<Subtitle> _contextSubtitle = ValueNotifier<Subtitle>(
    Subtitle(
      text: "",
      startTime: Duration.zero,
      endTime: Duration.zero,
    ),
  );
  ValueNotifier<bool> isCasting = ValueNotifier<bool>(false);
  ValueNotifier<int> _audioAllowance = ValueNotifier<int>(getAudioAllowance());
  ValueNotifier<int> _densePlaybackRepetitions =
      ValueNotifier<int>(getDensePlaybackRepetitions());
  ValueNotifier<double> _fontSize = ValueNotifier<double>(getFontSize());
  ValueNotifier<String> _regexFilter = ValueNotifier<String>(getRegExFilter());
  List<String> recursiveTerms = [];
  bool noPush = false;

  Timer durationTimer;
  Timer visibilityTimer;
  int initialSubTrack;
  int densePlaybackRepetitionsLeft = getDensePlaybackRepetitions();

  @override
  void initState() {
    super.initState();

    durationTimer = Timer.periodic(
        Duration(seconds: 1), (Timer t) => updateDurationOrSeek());
    visibilityTimer = Timer.periodic(
        Duration(milliseconds: 100), (Timer t) => visibilityTimerAction());

    if (defaultSubtitles.isEmpty) {
      initialSubTrack = 99999;
    } else if (videoFile != null && hasExternalSubtitles(videoFile)) {
      initialSubTrack = 99998;
    } else if (videoFile != null || streamUrl != null) {
      initialSubTrack = 0;
    } else {
      initialSubTrack = -1;
    }

    _currentSubTrack = ValueNotifier<int>(initialSubTrack);
    WidgetsBinding.instance.addPostFrameCallback((_) => scopedStorageWarning());
  }

  void scopedStorageWarning() async {
    if (!getScopedStorageDontShow() && videoFile.path.startsWith("/data/")) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            title: Text("Scoped Storage Warning"),
            content: Text(
              "The selected video file has been cached in the application's scoped storage by the file picker rather than direct play. This redundant duplication of the video file may have caused slower loading. Additionally, default external subtitles were not imported.\n\nFor faster loading and direct video playback, try using a different file picker.",
              textAlign: TextAlign.justify,
            ),
            actions: <Widget>[
              TextButton(
                child: Text('DON\'T SHOW AGAIN',
                    style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  setScopedStorageDontShow();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('OK', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> playPause() async {
    _wasPlaying.value = false;

    if (getVideoPlayerController().value.isPlaying) {
      await getVideoPlayerController().pause();
    } else {
      await getVideoPlayerController().play();
    }
  }

  void resetDensePlaybackRepetitions() {
    densePlaybackRepetitionsLeft = _densePlaybackRepetitions.value;
  }

  Future<void> rewindFastForward() async {
    resetDensePlaybackRepetitions();
    await getVideoPlayerController().seekTo(
      getRewindWithDelayAndAllowance(_currentSubtitle.value),
    );
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

  void emptyStack() {
    noPush = false;
    recursiveTerms = [];
  }

  void setNoPush() {
    noPush = true;
  }

  void onClipboardText(String text) {
    if (!getSelectMode() && isCustomDictionary()) {
      _clipboard.value = text;
      _contextSubtitle.value = _currentSubtitle.value;
      return;
    }

    text = text.trim();
    _volatileText = text.trim();

    Future.delayed(
        text.length == 1
            ? Duration(milliseconds: 1000)
            : Duration(milliseconds: 500), () {
      if (_volatileText.trim() == text.trim()) {
        _clipboard.value = text;
        _contextSubtitle.value = _currentSubtitle.value;
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
          getVideoPlayerController()
              .seekTo(getRewindWithDelayAndAllowance(_shadowingSubtitle.value));
        }
      } else if (_densePlaybackRepetitions.value != 0) {
        if (_currentSubtitle.value ==
            Subtitle(
                startTime: Duration.zero, endTime: Duration.zero, text: "")) {
          _currentSubtitle.value =
              _subTitleController.subtitleBloc.subtitles.subtitles.first;
        }

        if (getVideoPlayerController().value.position.inMilliseconds +
                    _audioAllowance.value -
                    getSubtitleController().subtitlesOffset <
                _currentSubtitle.value.startTime.inMilliseconds - 10000 ||
            getVideoPlayerController().value.position.inMilliseconds -
                    _audioAllowance.value -
                    getSubtitleController().subtitlesOffset >
                _currentSubtitle.value.endTime.inMilliseconds) {
          densePlaybackRepetitionsLeft -= 1;

          if (densePlaybackRepetitionsLeft == 0) {
            resetDensePlaybackRepetitions();
            Subtitle nextSubtitle = _currentSubtitle.value.nextSubtitle;
            if (nextSubtitle != null) {
              _currentSubtitle.value = nextSubtitle;
              if ((nextSubtitle.startTime.inSeconds -
                          _currentSubtitle.value.endTime.inSeconds)
                      .abs() >
                  1)
                getVideoPlayerController()
                    .seekTo(getRewindWithDelayAndAllowance(nextSubtitle));
            }
          } else {
            getVideoPlayerController()
                .seekTo(getRewindWithDelayAndAllowance(_currentSubtitle.value));
          }
        }
      }

      if (!getListeningComprehensionMode()) {
        int cutOffAllowance = 100;
        if (_currentSubTrack.value == -51) {
          cutOffAllowance = 10000;
        }

        Duration cutOffStart = _currentSubtitle.value.startTime -
            Duration(milliseconds: cutOffAllowance);
        Duration cutOffEnd = _currentSubtitle.value.endTime +
            Duration(milliseconds: cutOffAllowance);

        if (getVideoPlayerController().value.position.inMilliseconds -
                    getSubtitleController().subtitlesOffset >
                cutOffStart.inMilliseconds &&
            getVideoPlayerController().value.position.inMilliseconds -
                    getSubtitleController().subtitlesOffset <
                cutOffEnd.inMilliseconds) {
          if (!(getSubtitleController().widgetVisibility.value)) {
            getSubtitleController().widgetVisibility.value = true;
          }
        } else {
          if (getSubtitleController().widgetVisibility.value) {
            getSubtitleController().widgetVisibility.value = false;
          }
        }
      }
    }
  }

  void updateDurationOrSeek() async {
    if (playerMode == JidoujishoPlayerMode.networkStream) {
      return;
    }

    if (getVideoPlayerController().value.isInitialized &&
        this.videoFile == null &&
        networkNotSet) {
      networkNotSet = false;
      _videoPlayerController.setMediaFromNetwork(
          getPreferredYouTubeQuality(streamData.videoQualities).videoURL);
      _chewieController.currentVideoQuality =
          getPreferredYouTubeQuality(streamData.videoQualities);
    }

    if (getVideoPlayerController().value.isInitialized &&
        historyNotSet &&
        getVideoPlayerController().value.duration.inSeconds != 0) {
      historyNotSet = false;

      if (playerMode == JidoujishoPlayerMode.localFile) {
        setLastSetVideo();
        await addVideoHistory(
          HistoryItem(
            videoFile.path,
            path.basenameWithoutExtension(videoFile.path),
            videoFile.path,
            null,
            "",
            getVideoPlayerController().value.duration.inSeconds,
          ),
          (initialPosition == -1),
        );
      } else if (playerMode == JidoujishoPlayerMode.youtubeStream) {
        setLastSetVideo();
        await addVideoHistory(
          HistoryItem(
            streamData.videoURL,
            streamData.title,
            streamData.channel,
            streamData.thumbnailURL,
            streamData.channelId,
            getVideoPlayerController().value.duration.inSeconds,
          ),
          (initialPosition == -1),
        );
      }
    }

    if (getVideoPlayerController().value.isInitialized &&
        getVideoPlayerController().value.duration.inSeconds != 0 &&
        getVideoPlayerController().value.position.inSeconds <
            getVideoPlayerController().value.duration.inSeconds - 5) {
      int positionInSeconds =
          getVideoPlayerController().value.position.inSeconds;
      int durationInSeconds =
          getVideoPlayerController().value.duration.inSeconds;
      if (positionInSeconds > (durationInSeconds * 0.9)) {
        positionInSeconds = 0;
      }

      if (playerMode == JidoujishoPlayerMode.localFile) {
        addVideoHistoryPosition(
          HistoryItemPosition(
            videoFile.path,
            positionInSeconds,
          ),
        );
      } else if (playerMode == JidoujishoPlayerMode.youtubeStream) {
        addVideoHistoryPosition(
          HistoryItemPosition(
            streamData.videoURL,
            positionInSeconds,
          ),
        );
      }
    }

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
  ValueNotifier<int> _currentSubTrack;
  final _currentAudioTrack = ValueNotifier<int>(0);
  final _failureMetadata = ValueNotifier<AnkiExportMetadata>(null);

  void horizontalDrag() {
    _comprehensionSubtitle.value = _currentSubtitle.value;
    getSubtitleController().widgetVisibility.value = true;

    resetDensePlaybackRepetitions();
    getVideoPlayerController().seekTo(
      getRewindWithDelayAndAllowance(getExportSubtitle()),
    );
  }

  void verticalDrag() {
    _wasPlaying.value =
        getVideoPlayerController().value.isPlaying || _wasPlaying.value;
    openTranscript(_subTitleController.subtitleBloc.subtitles.subtitles,
        _wasPlaying.value);
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
            getSubtitleWrapper(),
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
            Container(),
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
      _regexFilter.value,
    );
  }

  Subtitle getExportSubtitle() {
    if (_currentSubTrack.value == 99999) {
      Duration allowanceDuration =
          Duration(milliseconds: _audioAllowance.value);
      if (_audioAllowance.value == 0) {
        allowanceDuration = Duration(milliseconds: 5000);
      }

      return Subtitle(
        startTime: _videoPlayerController.value.position - allowanceDuration,
        endTime: _videoPlayerController.value.position + allowanceDuration,
        text: "",
      );
    } else {
      return _currentSubtitle.value;
    }
  }

  Duration getRewindWithDelayAndAllowance(Subtitle subtitle) {
    return Duration(
        milliseconds: subtitle.startTime.inMilliseconds +
            getSubtitleController().subtitlesOffset);
  }

  void exportSingleCallback() {
    getVideoPlayerController().pause();
    _clipboard.value = "&<&>export&<&>";

    exportToAnki(
      context,
      getChewieController(),
      getVideoPlayerController(),
      _clipboard,
      getExportSubtitle(),
      _currentDictionaryEntry.value,
      _wasPlaying.value,
      [_currentSubtitle.value],
      _audioAllowance.value,
      getSubtitleController().subtitlesOffset,
      _failureMetadata,
      _regexFilter.value,
    );
  }

  Future<bool> _onWillPop() async {
    if (getVideoPlayerController().value.isEnded) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return false;
    }

    Widget alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: new Text('Exit Player?'),
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
            Navigator.of(context).popUntil((route) => route.isFirst);
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
    switch (playerMode) {
      case JidoujishoPlayerMode.localFile:
        _videoPlayerController ??= VlcPlayerController.file(
          videoFile,
          hwAcc: HwAcc.FULL,
          options: VlcPlayerOptions(
            audio: VlcAudioOptions(["--audio-track=0", "--sub-track=999"]),
          ),
        );
        break;
      case JidoujishoPlayerMode.youtubeStream:
        _videoPlayerController ??= VlcPlayerController.network(
          streamData.audioURL,
          hwAcc: HwAcc.FULL,
          options: VlcPlayerOptions(
            audio: VlcAudioOptions(["--input-slave=${streamData.audioURL}"]),
          ),
        );
        break;
      case JidoujishoPlayerMode.networkStream:
        _videoPlayerController ??= VlcPlayerController.network(
          streamUrl,
          hwAcc: HwAcc.FULL,
          options: VlcPlayerOptions(
            audio: VlcAudioOptions(["--audio-track=0", "--sub-track=999"]),
          ),
        );
        break;
    }
    return _videoPlayerController;
  }

  void toggleShadowingMode() {
    if (_shadowingSubtitle.value == null) {
      _shadowingSubtitle.value = getExportSubtitle();
    } else {
      _shadowingSubtitle.value = null;
    }
  }

  void densePlayback() async {
    String defaultRepetitions = getDensePlaybackRepetitions().toString();
    if (getDensePlaybackRepetitions() == 0) {
      defaultRepetitions = "1";
    }
    TextEditingController _repetitionsController =
        TextEditingController(text: defaultRepetitions);

    void setValues(bool remember) {
      String repetitionsText = _repetitionsController.text;
      int newRepetitions = int.tryParse(repetitionsText);

      if (repetitionsText != null && newRepetitions >= 1) {
        _densePlaybackRepetitions.value = newRepetitions;
        resetDensePlaybackRepetitions();

        if (remember) {
          setDensePlaybackRepetitions(newRepetitions);
        }

        Navigator.pop(context);
      }
    }

    _chewieController.wasPlaying.value =
        _videoPlayerController.value.isPlaying ||
            _chewieController.wasPlaying.value;

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
                      controller: _repetitionsController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: false,
                      ),
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Number of repetitions",
                          hintText: "Enter number of repetitions",
                          suffixText: " repetitions"),
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
        }).then((result) {
      if (_wasPlaying.value) {
        _videoPlayerController.play();
      }
    });
  }

  ChewieController getChewieController() {
    _chewieController ??= ChewieController(
      videoPlayerController: getVideoPlayerController(),
      playerMode: playerMode,
      internalSubs: internalSubs,
      clipboard: _clipboard,
      currentDictionaryEntry: _currentDictionaryEntry,
      currentSubtitle: _currentSubtitle,
      currentSubTrack: _currentSubTrack,
      currentAudioTrack: _currentAudioTrack,
      wasPlaying: _wasPlaying,
      densePlayback: densePlayback,
      densePlaybackRepetitions: _densePlaybackRepetitions,
      resetDensePlaybackRepetitions: resetDensePlaybackRepetitions,
      playExternalSubtitles: playExternalSubtitles,
      retimeSubtitles: retimeSubtitles,
      exportSingleCallback: exportSingleCallback,
      toggleShadowingMode: toggleShadowingMode,
      isCasting: isCasting,
      shadowingSubtitle: _shadowingSubtitle,
      comprehensionSubtitle: _comprehensionSubtitle,
      setNoPush: setNoPush,
      audioAllowance: _audioAllowance,
      streamData: streamData,
      streamUrl: streamUrl,
      aspectRatio: getVideoPlayerController().value.aspectRatio,
      autoPlay: true,
      autoInitialize: true,
      allowFullScreen: false,
      allowMuting: false,
      allowedScreenSleep: false,
      fullScreenByDefault: false,
      horizontalDrag: horizontalDrag,
      verticalDrag: verticalDrag,
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
      emptyStack: emptyStack,
      subtitleNotifier: _currentSubtitle,
      contextSubtitle: _contextSubtitle,
      videoPlayerController: getVideoPlayerController(),
      subtitleController: getSubtitleController(),
      subtitleStyle: SubtitleStyle(
        textColor: Colors.white,
        hasBorder: true,
        fontSize: 24,
      ),
      fontSize: _fontSize,
      regexFilter: _regexFilter,
      isCasting: isCasting,
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

  void playEmbeddedSubtitles(int index) async {
    _subTitleController.subtitleType = SubtitleType.srt;
    if (index == 99999) {
      _subTitleController.updateSubtitleContent(content: "");
      print("SUBTITLES SWITCHED OFF");
    } else {
      print(internalSubs);
      getSubtitleWrapper().subtitleController.updateSubtitleContent(
          content: sanitizeSrtNewlines(internalSubs[index].readAsStringSync()));
      print("SUBTITLES SWITCHED TO TRACK $index");
    }
  }

  void playExternalSubtitles() async {
    _subTitleController.subtitleType = SubtitleType.srt;

    File result = await FilePicker.getFile(
      type: FileType.any,
    );

    if (result != null) {
      _currentSubTrack.value = 99998;
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
    TextEditingController _fontSizeController =
        TextEditingController(text: _fontSize.value.toString());
    TextEditingController _regexFilterController =
        TextEditingController(text: _regexFilter.value.trim());

    void setValues(bool remember) {
      String offsetText = _offsetController.text;
      int newOffset = int.tryParse(offsetText);

      String allowanceText = _allowanceController.text;
      int newAllowance = int.tryParse(allowanceText);

      String fontSizeText = _fontSizeController.text;
      double newFontSize = double.tryParse(fontSizeText);

      String newRegexFilter = _regexFilterController.text.trim();

      if (newOffset != null &&
          newAllowance != null &&
          newFontSize != null &&
          RegExp(newRegexFilter) != null) {
        getSubtitleController().subtitlesOffset = newOffset;
        getSubtitleController().updateSubtitleContent(
            content: getSubtitleController().subtitlesContent);
        _audioAllowance.value = newAllowance;
        _fontSize.value = newFontSize;
        _regexFilter.value = newRegexFilter;

        if (remember) {
          setSubtitleDelay(newOffset);
          setAudioAllowance(newAllowance);
          setFontSize(newFontSize);
          setRegExFilter(newRegexFilter);
        }

        Navigator.pop(context);
      }
    }

    _chewieController.wasPlaying.value =
        _videoPlayerController.value.isPlaying ||
            _chewieController.wasPlaying.value;

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
                    TextField(
                      controller: _fontSizeController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Font size",
                          hintText: "Enter font size",
                          suffixText: " px"),
                    ),
                    TextField(
                      controller: _regexFilterController,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: "Regular expression filter",
                        hintText: "Enter regular expression filter",
                      ),
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
        }).then((result) {
      if (_wasPlaying.value) {
        _videoPlayerController.play();
      }
    });
  }

  Widget buildDictionaryLoading(String clipboard) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[800].withOpacity(0.6),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    text: '',
                    children: <InlineSpan>[
                      TextSpan(
                        text: "Looking up",
                      ),
                      TextSpan(
                        text: "『",
                        style: TextStyle(
                          color: Colors.grey[300],
                        ),
                      ),
                      TextSpan(
                        text: clipboard,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "』",
                        style: TextStyle(
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 12,
                  width: 12,
                  child: JumpingDotsProgressIndicator(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryExporting(String clipboard) {
    String lookupText = "Preparing to export";

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[800].withOpacity(0.6),
            child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(lookupText),
                  SizedBox(
                    height: 12,
                    width: 12,
                    child: JumpingDotsProgressIndicator(color: Colors.white),
                  ),
                ]),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryAutoGenDependencies(String clipboard) {
    String lookupText = "Setting up required dependencies";

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[800].withOpacity(0.6),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(lookupText),
                SizedBox(
                  height: 12,
                  width: 12,
                  child: JumpingDotsProgressIndicator(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryNetworkSubtitlesBad(String clipboard) {
    String lookupText = "Unable to query subtitles over network stream.";
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

  Widget buildDictionaryNetworkSubtitlesRequest(String clipboard) {
    String lookupText = "Requesting subtitles over network stream";

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[800].withOpacity(0.6),
            child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(lookupText),
                  SizedBox(
                    height: 12,
                    width: 12,
                    child: JumpingDotsProgressIndicator(color: Colors.white),
                  ),
                ]),
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
    String lookupText = "Querying for automatic captions";

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[800].withOpacity(0.6),
            child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(lookupText),
                  SizedBox(
                    height: 12,
                    width: 12,
                    child: JumpingDotsProgressIndicator(color: Colors.white),
                  ),
                ]),
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
                _regexFilter.value,
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
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[800].withOpacity(0.6),
            child: Text.rich(
              TextSpan(
                text: '',
                children: <InlineSpan>[
                  TextSpan(
                    text: "Card exported to",
                  ),
                  TextSpan(
                    text: "『",
                    style: TextStyle(
                      color: Colors.grey[300],
                    ),
                  ),
                  TextSpan(
                    text: getLastDeck(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "』",
                    style: TextStyle(
                      color: Colors.grey[300],
                    ),
                  ),
                  TextSpan(
                    text: "deck.",
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryNoMatch(String clipboard) {
    switch (getCurrentDictionary()) {
      case "Jisho.org API":
        gBilingualSearchCache[clipboard] = null;
        break;
      case "Sora Dictionary API":
        gMonolingualSearchCache[clipboard] = null;
        break;
      default:
        gCustomDictionarySearchCache[getCurrentDictionary()][clipboard] = null;
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
            child: GestureDetector(
              onLongPress: () {
                openDictionaryMenu(context, false);
              },
              onVerticalDragEnd: (details) async {
                if (details.primaryVelocity == 0) return;
                if (details.primaryVelocity.compareTo(0) == -1) {
                  await setNextDictionary();
                } else {
                  await setPrevDictionary();
                }
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.grey[800].withOpacity(0.6),
                child: Text.rich(
                  TextSpan(
                    text: '',
                    children: <InlineSpan>[
                      TextSpan(
                        text: "No matches for",
                      ),
                      TextSpan(
                        text: "『",
                        style: TextStyle(
                          color: Colors.grey[300],
                        ),
                      ),
                      TextSpan(
                        text: clipboard,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "』",
                        style: TextStyle(
                          color: Colors.grey[300],
                        ),
                      ),
                      TextSpan(
                        text: "could be queried.",
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryMatch(DictionaryHistoryEntry results) {
    if (noPush) {
      noPush = false;
    } else if (recursiveTerms.isEmpty ||
        results.searchTerm != recursiveTerms.last) {
      recursiveTerms.add(results.searchTerm);
    }

    _subtitleFocusNode.unfocus();
    ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

    return ValueListenableBuilder(
      valueListenable: selectedIndex,
      builder: (BuildContext context, int _, Widget widget) {
        _currentDictionaryEntry.value = results.entries[selectedIndex.value];
        DictionaryEntry pitchEntry =
            getClosestPitchEntry(_currentDictionaryEntry.value);
        ScrollController scrollController = ScrollController();

        addDictionaryEntryToHistory(
          DictionaryHistoryEntry(
            entries: results.entries,
            searchTerm: results.searchTerm,
            swipeIndex: selectedIndex.value,
            contextDataSource: results.contextDataSource,
            contextPosition: results.contextPosition,
            dictionarySource: results.dictionarySource,
          ),
        );

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
                if (selectedIndex.value == results.entries.length - 1) {
                  selectedIndex.value = 0;
                } else {
                  selectedIndex.value += 1;
                }
              } else {
                if (selectedIndex.value == 0) {
                  selectedIndex.value = results.entries.length - 1;
                } else {
                  selectedIndex.value -= 1;
                }
              }
            },
            onVerticalDragEnd: (details) async {
              if (details.primaryVelocity == 0) return;
              if (details.primaryVelocity.compareTo(0) == -1) {
                await setNextDictionary();
              } else {
                await setPrevDictionary();
              }
            },
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 84),
              color: Colors.grey[800].withOpacity(0.6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onLongPress: () {
                      openDictionaryMenu(context, false);
                    },
                    child: Text(
                      results.entries[selectedIndex.value].word,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  GestureDetector(
                    onLongPress: () {
                      openDictionaryMenu(context, false);
                    },
                    child: (pitchEntry != null)
                        ? getAllPitchWidgets(pitchEntry)
                        : Text(results.entries[selectedIndex.value].reading),
                  ),
                  if (results
                      .entries[selectedIndex.value].yomichanTermTags.isNotEmpty)
                    SizedBox(height: 5),
                  if (results
                      .entries[selectedIndex.value].yomichanTermTags.isNotEmpty)
                    Wrap(
                      children: results.entries[selectedIndex.value]
                          .generateTagWidgets(context),
                    ),
                  results.entries[selectedIndex.value]
                      .generateMeaningWidgetsDialog(context, selectable: true),
                  Text.rich(
                    TextSpan(
                      text: '',
                      children: <InlineSpan>[
                        TextSpan(
                          text: "Selecting search result ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                        TextSpan(
                          text: "${selectedIndex.value + 1} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: "out of ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                        TextSpan(
                          text: "${results.entries.length} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: "found for",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                        TextSpan(
                          text: "『",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                        TextSpan(
                          text: "${results.searchTerm}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: "』",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  (recursiveTerms.length > 1)
                      ? GestureDetector(
                          onTap: () {
                            noPush = true;
                            recursiveTerms.removeLast();
                            _clipboard.value = recursiveTerms.last;
                          },
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "『 ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey[300],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Icon(Icons.arrow_back, size: 11),
                              SizedBox(width: 5),
                              Text(
                                "Return ",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "to ",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "previous ",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "definition",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                " 』",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey[300],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future dictionaryFutureHelper(String clipboard) {
    String contextDataSource = getContextDataSource();
    int contextPosition = _contextSubtitle.value.startTime.inSeconds;

    switch (getCurrentDictionary()) {
      case "Jisho.org API":
        return fetchBilingualSearchCache(
          searchTerm: clipboard,
          contextDataSource: contextDataSource,
          contextPosition: contextPosition,
        );
      case "Sora Dictionary API":
        return fetchMonolingualSearchCache(
          searchTerm: clipboard,
          recursive: false,
          contextDataSource: contextDataSource,
          contextPosition: contextPosition,
        );
      default:
        return fetchCustomDictionarySearchCache(
          dictionaryName: getCurrentDictionary(),
          searchTerm: clipboard,
          contextDataSource: contextDataSource,
          contextPosition: contextPosition,
        );
    }
  }

  String getContextDataSource() {
    switch (playerMode) {
      case JidoujishoPlayerMode.localFile:
        return videoFile.path;
      case JidoujishoPlayerMode.youtubeStream:
        return streamData.videoURL;
      case JidoujishoPlayerMode.networkStream:
        return "-1";
    }

    return "-1";
  }

  Widget buildDictionary() {
    return ValueListenableBuilder(
      valueListenable: _clipboard,
      builder: (context, clipboard, widget) {
        return ValueListenableBuilder(
          valueListenable: gActiveDictionary,
          builder:
              (BuildContext context, String activeDictionary, Widget child) {
            return FutureBuilder(
              future: dictionaryFutureHelper(clipboard),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                if (_clipboard.value == "&<&>netsubsrequest&<&>") {
                  return buildDictionaryNetworkSubtitlesRequest(clipboard);
                }
                if (_clipboard.value == "&<&>netsubsbad&<&>") {
                  return buildDictionaryNetworkSubtitlesBad(clipboard);
                }
                if (_clipboard.value == "&<&>exported&<&>") {
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
                    DictionaryHistoryEntry results = snapshot.data;

                    if (snapshot.hasData && results.entries.isNotEmpty) {
                      return buildDictionaryMatch(results);
                    } else {
                      return buildDictionaryNoMatch(clipboard);
                    }
                }
              },
            );
          },
        );
      },
    );
  }

  Widget buildSubTrackChanger() {
    return ValueListenableBuilder(
      valueListenable: _currentSubTrack,
      builder: (context, index, widget) {
        if (_currentSubTrack.value == -51 || _currentSubTrack.value == 99998) {
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

          String subtitleText = subtitle.text;
          if (getLatinFilterMode()) {
            subtitleText = stripLatinCharactersFromText(subtitleText);
          }
          if (_regexFilter.value.isNotEmpty) {
            subtitleText =
                subtitleText.replaceAll(RegExp(_regexFilter.value), "").trim();
          }
          if (subtitleText.trim().isNotEmpty) {
            subtitleText = "『 $subtitleText 』";
          }

          print(subtitleText);

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

              resetDensePlaybackRepetitions();
              _currentSubtitle.value = subtitles[index];
              getVideoPlayerController().seekTo(
                getRewindWithDelayAndAllowance(subtitles[index]),
              );

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

              if (_regexFilter.value.isNotEmpty) {
                selectedSubtitles.forEach((subtitle) => selectedText += subtitle
                        .text
                        .replaceAll(RegExp(_regexFilter.value), "")
                        .trim() +
                    "\n");
              } else {
                selectedSubtitles.forEach(
                    (subtitle) => selectedText += subtitle.text + "\n");
              }

              selectedText = removeLastNewline(selectedText);

              Duration selectedStartTime = selectedSubtitles.first.startTime;
              Duration selectedEndTime = selectedSubtitles.last.endTime;

              if (getLatinFilterMode()) {
                selectedText = stripLatinCharactersFromText(selectedText);
              }

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

    if (wasPlaying &&
        !isExporting &&
        (!getFocusMode() || _clipboard.value == "")) {
      getVideoPlayerController().play();
    }
  }
}

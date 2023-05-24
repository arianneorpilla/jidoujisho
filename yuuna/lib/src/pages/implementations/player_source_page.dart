import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spaces/spaces.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakelock/wakelock.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/pages/implementations/player_comments_page.dart';
import 'package:yuuna/utils.dart';
import 'package:path/path.dart' as path;

/// The media page used for the [PlayerMediaSource].
class PlayerSourcePage extends BaseSourcePage {
  /// Create an instance of this page.
  const PlayerSourcePage({
    required this.source,
    required this.useHistory,
    super.item,
    super.key,
  });

  /// The media source used for this page.
  final MediaSource source;

  /// Whether or not to add media items to history.
  final bool useHistory;

  @override
  BaseSourcePageState createState() => _PlayerSourcePageState();
}

class _PlayerSourcePageState extends BaseSourcePageState<PlayerSourcePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final VlcPlayerController _playerController;
  late SubtitleItem _subtitleItem;
  late SubtitleItem _emptySubtitleItem;
  late List<SubtitleItem> _subtitleItems;

  late AnimationController _playPauseAnimationController;

  final ValueNotifier<Duration> _positionNotifier =
      ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<Duration> _durationNotifier =
      ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<bool> _playingNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _endedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _bufferingNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<bool> _isMenuHidden = ValueNotifier<bool>(false);

  late final ValueNotifier<Subtitle?> _currentSubtitle;
  final ValueNotifier<Subtitle?> _currentSubtitleMemory =
      ValueNotifier<Subtitle?>(null);
  final ValueNotifier<Subtitle?> _shadowingSubtitle =
      ValueNotifier<Subtitle?>(null);
  final ValueNotifier<Subtitle?> _listeningSubtitle =
      ValueNotifier<Subtitle?>(null);
  final ValueNotifier<bool> _subtitleItemNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _transcriptOpenNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<bool> _transcriptBackgroundNotifier =
      ValueNotifier<bool>(false);

  late final ValueNotifier<BlurOptions> _blurOptionsNotifier;
  late final ValueNotifier<SubtitleOptions> _subtitleOptionsNotifier;

  StreamSubscription<void>? _playPauseSubscription;

  Timer? _notPlayingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Action to perform within the source page upon closing the media.
  @override
  Future<void> onSourcePagePop() async {
    if (_playerInitialised) {
      await _playerController.stop();
    }
  }

  @override
  void dispose() async {
    _playPauseSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    _playerController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        _session.setActive(true);

        if (mounted) {
          if (appModelNoUpdate.isPlayerOrientationPortrait) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
          } else {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          }

          Wakelock.enable();
        }

        break;
      case AppLifecycleState.inactive:
        _session.setActive(false);
        if (source is PlayerNetworkStreamSource) {
          await ReceiveIntent.setResult(
            kActivityResultOk,
            action: 'is.xyz.mpv.MPVActivity.result',
            data: {
              'position': _positionNotifier.value.inMilliseconds,
              'duration': _durationNotifier.value.inMilliseconds,
            },
          );
          appModel.shutdown();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _session.setActive(false);
        break;
    }
  }

  /// Controls height of bottom menu.
  static const double _menuHeight = 48;

  /// Allows customisation of opacity of dictionary entries.
  @override
  double get dictionaryBackgroundOpacity => 0.75;

  @override
  double get dictionaryEntryOpacity => 0.5;

  Timer? _menuHideTimer;

  /// Allows programmatic changing of the current text selection.
  final JidoujishoSelectableTextController _selectableTextController =
      JidoujishoSelectableTextController();

  bool _unhideDuringInitFlag = false;

  bool _dialogSmartPaused = false;
  bool _dialogSmartFocusFlag = false;

  bool _autoPauseFlag = false;
  Subtitle? _autoPauseSubtitle;

  /// Subtitle delay. May be temporarily different from saved value.
  Duration get subtitleDelay =>
      Duration(milliseconds: _subtitleOptionsNotifier.value.subtitleDelay);

  /// Current audio allowance. May be temporarily different from saved value.
  Duration get audioAllowance =>
      Duration(milliseconds: _subtitleOptionsNotifier.value.audioAllowance);

  /// This is used to control focus of selected text.
  final FocusNode _dragToSelectFocusNode = FocusNode();

  bool _playerInitialised = false;

  late final AudioSession _session;

  Duration? _bufferingDuration;

  PlayerMediaSource get source => widget.source as PlayerMediaSource;

  /// Executed on dictionary dismiss.
  @override
  void onDictionaryDismiss() {
    if (appModel.isPlayerDefinitionFocusMode) {
      dialogSmartResume(
        isSmartFocus: true,
      );
    }

    _selectableTextController.clearSelection();
    super.clearDictionaryResult();
  }

  /// This prepares the player for use and sets a lot of initial variables.
  void initialisePlayer() async {
    if (_playerInitialised) {
      return;
    }

    await Future.delayed(const Duration(seconds: 1), () {});

    appModel.currentMediaPauseStream.listen((event) {
      dialogSmartPause();
    });

    _emptySubtitleItem = SubtitleItem(
      controller: SubtitleController(
        provider: SubtitleProvider.fromString(
          data: '',
          type: SubtitleType.srt,
        ),
      ),
      type: SubtitleItemType.noneSubtitle,
    );

    _subtitleItem = _emptySubtitleItem;
    _playPauseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
    );

    await source.prepareMediaResources(
        appModel: appModel, ref: ref, item: widget.item!);
    final futures = await Future.wait(
      [
        source.preparePlayerController(
          appModel: appModel,
          ref: ref,
          item: widget.item!,
        ),
        source.prepareSubtitles(
          appModel: appModel,
          ref: ref,
          item: widget.item!,
        ),
      ],
    );

    _playerController = futures.elementAt(0) as VlcPlayerController;
    _subtitleItems = futures.elementAt(1) as List<SubtitleItem>;
    _transcriptBackgroundNotifier.value = appModel.isTranscriptOpaque;

    if (_subtitleItems.isNotEmpty) {
      _subtitleItem = _subtitleItems.first;
    }
    if (!_subtitleItem.controller.initialized) {
      await _subtitleItem.controller.initial();
    }

    _blurOptionsNotifier = ValueNotifier<BlurOptions>(appModel.blurOptions);

    /// This is so cursed.
    appModel.currentPlayerController = _playerController;
    _currentSubtitle = appModel.currentSubtitle;
    _subtitleOptionsNotifier = appModel.currentSubtitleOptions!;

    _currentSubtitle.value = null;
    appModel.blockCreatorInitialMedia = true;

    _playerController.addOnInitListener(() async {
      if (!mounted) {
        return;
      }

      initialiseEmbeddedSubtitles(_playerController);

      Future.delayed(const Duration(seconds: 5), () {
        appModel.blockCreatorInitialMedia = false;
      });
    });

    if (mounted && appModel.isMediaOpen) {
      if (appModelNoUpdate.isPlayerOrientationPortrait) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      } else {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
      await Wakelock.enable();
    }

    _playPauseSubscription = appModel.audioHandlerStream.listen((_) {
      playPause();
    });

    _session = await AudioSession.instance;
    await _session.configure(const AudioSessionConfiguration.music());

    _session.becomingNoisyEventStream.listen((event) async {
      await _playerController.pause();
      _session.setActive(false);
    });

    _session.setActive(true);

    setState(() {
      _playerInitialised = true;
    });

    _playerController.addListener(listener);

    startHideTimer();

    Future.delayed(const Duration(seconds: 3), () {
      _unhideDuringInitFlag = true;
    });
  }

  double _lastAspectRatio = 1;

  /// This is called each time the player ticks.
  void listener() async {
    if (!mounted) {
      return;
    }

    if (_playerController.value.isInitialized) {
      _positionNotifier.value = _playerController.value.position;
      _durationNotifier.value = _playerController.value.duration;
      _playingNotifier.value = _playerController.value.isPlaying;
      _endedNotifier.value = _playerController.value.isEnded;

      if (_playerController.value.aspectRatio != _lastAspectRatio) {
        _lastAspectRatio = _playerController.value.aspectRatio;
        setState(() {});
      }

      if (_playingNotifier.value) {
        if (_notPlayingTimer == null) {
          _bufferingDuration = _positionNotifier.value;
        }
        _notPlayingTimer ??= Timer(const Duration(milliseconds: 1000), () {
          _bufferingNotifier.value =
              _bufferingDuration == _positionNotifier.value;
          _notPlayingTimer?.cancel();
          _notPlayingTimer = null;
        });
      } else {
        _bufferingNotifier.value = false;
        _bufferingDuration = null;
      }

      Subtitle? newSubtitle = _subtitleItem.controller
          .durationSearch(_positionNotifier.value + subtitleDelay);
      String sentence = _currentSubtitle.value?.data ?? '';
      String regex = _subtitleOptionsNotifier.value.regexFilter;
      if (regex.isNotEmpty) {
        sentence = sentence.replaceAll(RegExp(regex), '');
      }

      if (!_transcriptOpenNotifier.value &&
          widget.source.currentSentence.text != sentence) {
        widget.source.setCurrentSentence(
          selection: JidoujishoTextSelection(
            text: sentence,
          ),
        );
      }

      if (_currentSubtitle.value != newSubtitle) {
        // if (!_sliderBeingDragged &&
        //     !_autoPauseFlag &&

        //     _currentSubtitle.value != null) {
        //   _autoPauseSubtitle = _currentSubtitle.value;
        //   _autoPauseFlag = true;
        //   dialogSmartPause();
        //   return;
        // }

        _currentSubtitle.value = newSubtitle;
        // For remembering the last subtitle even if it has disappeared.
        if (newSubtitle != null) {
          _currentSubtitleMemory.value = newSubtitle;
        }
      }

      if (_shadowingSubtitle.value != null) {
        Duration allowance = audioAllowance;

        if (allowance == Duration.zero &&
            _subtitleItem.controller.subtitles.isEmpty) {
          allowance = const Duration(seconds: 5);
        }

        if (_positionNotifier.value <
                _shadowingSubtitle.value!.start -
                    subtitleDelay -
                    const Duration(seconds: 15) -
                    allowance ||
            _positionNotifier.value >
                _shadowingSubtitle.value!.end - subtitleDelay + allowance) {
          _playerController.seekTo(
              _shadowingSubtitle.value!.start + subtitleDelay - allowance);
          _bufferingNotifier.value = true;
        }
      }

      if (_listeningSubtitle.value != null) {
        if (_positionNotifier.value <
                _listeningSubtitle.value!.start +
                    subtitleDelay -
                    const Duration(seconds: 15) ||
            _positionNotifier.value >
                _listeningSubtitle.value!.end +
                    subtitleDelay +
                    const Duration(seconds: 5)) {
          _listeningSubtitle.value = null;
        }
      }

      if (_durationNotifier.value != Duration.zero &&
          _positionNotifier.value != Duration.zero) {
        updateHistory();
      }
    }
  }

  /// This prepares the subtitles included with the video for use.
  void initialiseEmbeddedSubtitles(VlcPlayerController controller) async {
    if (controller.dataSourceType != DataSourceType.file) {
      return;
    }
    appModel.isProcessingEmbeddedSubtitles = true;

    await SubtitleUtils.targetSubtitleFromVideo(
      file: File(controller.dataSource),
      language: appModel.targetLanguage,
      onItemComplete: (item) async {
        _subtitleItems.add(item);

        if (_subtitleItem.type == SubtitleItemType.noneSubtitle) {
          await item.controller.initial();

          _subtitleItem = item;
          _currentSubtitle.value = null;
          widget.source.clearCurrentSentence();
          refreshSubtitleWidget();
        }
        _subtitleItemNotifier.value = !_subtitleItemNotifier.value;
      },
    );

    await Future.delayed(const Duration(seconds: 2), () {});

    int embeddedTrackCount = await _playerController.getSpuTracksCount() ?? 0;

    await SubtitleUtils.subtitlesFromVideo(
      file: File(controller.dataSource),
      embeddedTrackCount: embeddedTrackCount,
      onItemComplete: (item) async {
        _subtitleItems.add(item);
        if (_subtitleItem.type == SubtitleItemType.noneSubtitle) {
          await item.controller.initial();
          _subtitleItem = item;
          _currentSubtitle.value = null;
          widget.source.clearCurrentSentence();
          refreshSubtitleWidget();
        }
        _subtitleItemNotifier.value = !_subtitleItemNotifier.value;
      },
    );

    appModel.isProcessingEmbeddedSubtitles = false;
  }

  /// This updates the media item to its new position and duration and also
  /// persists the change in media history.
  void updateHistory() async {
    if (source is PlayerNetworkStreamSource) {
      if (_positionNotifier.value.inMilliseconds != 0) {
        ReceiveIntent.setResult(
          kActivityResultOk,
          action: 'is.xyz.mpv.MPVActivity.result',
          data: {
            'position': _positionNotifier.value.inMilliseconds,
            'duration': _durationNotifier.value.inMilliseconds,
          },
        );
      }
    }

    if (!widget.useHistory) {
      return;
    }

    widget.item!.position = _positionNotifier.value.inSeconds;
    widget.item!.duration = _durationNotifier.value.inSeconds;

    if (widget.item!.position != 0) {
      appModel.updateMediaItem(widget.item!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: buildBody(),
      ),
    );
  }

  /// This shows the loading indicator when uninitialised and shows
  /// the player once initialised.
  Widget buildBody() {
    if (!_playerInitialised) {
      initialisePlayer();
      return buildLoading();
    }

    Widget buildBuffering() {
      return ValueListenableBuilder<bool>(
        valueListenable: _bufferingNotifier,
        builder: (context, isBuffering, _) {
          if (isBuffering) {
            return buildLoading();
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        buildPlayer(),
        buildGestureArea(),
        buildBlurWidget(),
        buildBuffering(),
        buildMenuArea(),
        if (MediaQuery.of(context).orientation == Orientation.landscape)
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: buildSubtitleArea(),
            ),
          )
        else
          buildSubtitleArea(),
        buildCentralPlayPause(),
        Padding(
          padding: MediaQuery.of(context).orientation == Orientation.landscape
              ? Spacing.of(context).insets.horizontal.extraBig * 5
              : EdgeInsets.zero,
          child: MediaQuery.of(context).orientation == Orientation.landscape
              ? buildDictionary()
              : Padding(
                  padding: Spacing.of(context).insets.onlyTop.big,
                  child: buildDictionary(),
                ),
        ),
        buildTranscriptCover(),
      ],
    );
  }

  /// This renders the backing player.
  Widget buildPlayer() {
    return Container(
      alignment: Alignment.center,
      height: double.maxFinite,
      width: double.maxFinite,
      color: Colors.black,
      child: Center(
        child: Transform.scale(
          scale: appModel.isStretchToFill
              ? max(_playerController.value.aspectRatio,
                      MediaQuery.of(context).size.aspectRatio) /
                  min(_playerController.value.aspectRatio,
                      MediaQuery.of(context).size.aspectRatio)
              : 1,
          child: VlcPlayer(
            controller: _playerController,
            aspectRatio: _playerController.value.aspectRatio,
            placeholder: buildLoading(),
            virtualDisplay: false,
          ),
        ),
      ),
    );
  }

  /// This renders over the player to hide it if the transcript is set to be
  /// opaque.
  Widget buildTranscriptCover() {
    return MultiValueListenableBuilder(
      valueListenables: [
        _transcriptBackgroundNotifier,
        _transcriptOpenNotifier,
      ],
      builder: (context, transcriptOpen, _) {
        return Visibility(
          visible: _transcriptOpenNotifier.value &&
              _transcriptBackgroundNotifier.value,
          child: Container(
            alignment: Alignment.center,
            height: double.maxFinite,
            width: double.maxFinite,
            color: Colors.black,
          ),
        );
      },
    );
  }

  bool _dragHorizontal = false;
  bool _dragVertical = false;

  /// This enables gestures for repeating the current subtitle
  /// and for showing the transcript.
  Widget buildGestureArea() {
    return GestureDetector(
      child: buildScrubDetectors(),
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        toggleMenuVisibility();
      },
      onHorizontalDragStart: (details) {
        _dragHorizontal = false;
      },
      onHorizontalDragUpdate: (details) async {
        if (details.delta.dx.abs() > 20) {
          _dragHorizontal = true;
        }
      },
      onHorizontalDragEnd: (details) async {
        if (_dragHorizontal) {
          _dragHorizontal = false;
          repeatCurrentSubtitle();
        }
      },
      onVerticalDragStart: (details) {
        _dragVertical = false;
      },
      onVerticalDragUpdate: (details) async {
        if (details.delta.dy.abs() > 5) {
          _dragVertical = true;
        }
      },
      onVerticalDragEnd: (details) {
        if (_dragVertical) {
          _dragVertical = false;
          openTranscript();
        }
      },
    );
  }

  Future<void> repeatCurrentSubtitle() async {
    Subtitle? nearestSubtitle = getNearestSubtitle();

    _listeningSubtitle.value = nearestSubtitle;

    if (nearestSubtitle != null) {
      await _playerController.seekTo(nearestSubtitle.start - subtitleDelay);
      _bufferingNotifier.value = true;
    }
  }

  Future<void> openTranscript() async {
    clearDictionaryResult();

    bool exporting = false;
    bool shouldResume = !_dialogSmartPaused;
    if (!appModel.isTranscriptPlayerMode) {
      await dialogSmartPause();
    }

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await Future.delayed(const Duration(milliseconds: 5), () {});

    _transcriptOpenNotifier.value = true;

    _menuHideTimer?.cancel();
    _isMenuHidden.value = true;

    try {
      await appModel.temporarilyDisableStatusBarHiding(action: () async {
        await Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, _, __) => PlayerTranscriptPage(
              title: widget.item!.title,
              subtitles: _subtitleItem.controller.subtitles,
              currentSubtitle: _currentSubtitle,
              subtitleOptions: _subtitleOptionsNotifier.value,
              controller: _playerController,
              nearestSubtitle: getNearestSubtitle(),
              playingNotifier: _playingNotifier,
              endedNotifier: _endedNotifier,
              transcriptBackgroundNotifier: _transcriptBackgroundNotifier,
              alignMode: false,
              onTap: (index) async {
                await Future.delayed(const Duration(milliseconds: 5), () {});
                await SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.immersiveSticky);
                Navigator.pop(context);
                await _playerController.seekTo(
                    _subtitleItem.controller.subtitles[index].start -
                        subtitleDelay);
                _bufferingNotifier.value = true;
                _listeningSubtitle.value =
                    _subtitleItem.controller.subtitles[index];

                if (_shadowingSubtitle.value != null) {
                  _shadowingSubtitle.value =
                      _subtitleItem.controller.subtitles[index];
                }

                if (!_playingNotifier.value) {
                  _playerController.play();
                }
              },
              onLongPress: (index) async {
                Navigator.pop(context);
                exporting = true;
                await exportMultipleSubtitles(index);
                if (shouldResume) {
                  await dialogSmartResume();
                }
              },
            ),
          ),
        );
      });
    } finally {
      (widget.source as PlayerMediaSource).clearTranscriptSubtitle();
      widget.source.setCurrentSentence(
        selection: JidoujishoTextSelection(
          text: _currentSubtitle.value?.data ?? '',
        ),
      );
      _transcriptOpenNotifier.value = false;
    }

    if (!exporting) {
      if (shouldResume) {
        await dialogSmartResume();
      }

      await Future.delayed(const Duration(milliseconds: 5), () {});
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  /// This allows export of multiple subtitles as one sentence and
  /// for multiple images.
  Future<void> exportMultipleSubtitles(int selectedIndex) async {
    int maxSubtitles = 10;

    Subtitle? nearestSubtitle = getNearestSubtitle();
    if (nearestSubtitle == null) {
      return;
    }

    List<Subtitle> subtitles = _subtitleItem.controller.subtitles;
    List<Subtitle> selectedSubtitles = [];

    if (selectedIndex < nearestSubtitle.index - 1) {
      for (int i = selectedIndex; i <= nearestSubtitle.index - 1; i++) {
        selectedSubtitles.add(subtitles[i]);
        if (selectedSubtitles.length == maxSubtitles) {
          break;
        }
      }
    } else if (selectedIndex > nearestSubtitle.index - 1) {
      for (int i = nearestSubtitle.index - 1; i <= selectedIndex; i++) {
        selectedSubtitles.add(subtitles[i]);
        if (selectedSubtitles.length == maxSubtitles) {
          break;
        }
      }
    } else {
      selectedSubtitles.add(nearestSubtitle);
    }
    await openCardCreator(selectedSubtitles);
  }

  /// This allows the user to double tap to seek.
  Widget buildScrubDetectors() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onDoubleTap: () async {
              cancelHideTimer();

              await _playerController.seekTo(
                  _positionNotifier.value - const Duration(seconds: 10));
              _bufferingNotifier.value = true;
              _listeningSubtitle.value = getNearestSubtitle();

              if (!_isMenuHidden.value) {
                _menuHideTimer = Timer(const Duration(seconds: 3), () {
                  if (_playingNotifier.value) {
                    _isMenuHidden.value = true;
                  }
                });
              }
            },
            child: const SizedBox.expand(
              child: ColoredBox(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onDoubleTap: () async {
              cancelHideTimer();

              await _playerController.seekTo(
                  _positionNotifier.value + const Duration(seconds: 10));
              _bufferingNotifier.value = true;
              _listeningSubtitle.value = getNearestSubtitle();

              if (!_isMenuHidden.value) {
                _menuHideTimer = Timer(const Duration(seconds: 3), () {
                  if (_playingNotifier.value) {
                    _isMenuHidden.value = true;
                  }
                });
              }
            },
            child: const SizedBox.expand(
              child: ColoredBox(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// This renders the blur widget that can be used to mask
  /// burned in subtitles.
  Widget buildBlurWidget() {
    return ResizeableWidget(
      notifier: _blurOptionsNotifier,
    );
  }

  /// This affects the visibility of the bottom menu depending
  /// on the state of the menu timeout.
  Widget buildMenuArea() {
    return Align(
      alignment: Alignment.topCenter,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isMenuHidden,
        builder: (context, value, _) {
          return AnimatedOpacity(
            opacity: value ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: buildMenuContent(),
          );
        },
      ),
    );
  }

  /// This arranges the contents of the bottom menu.
  Widget buildMenuContent() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: _menuHeight,
        color: theme.cardColor.withOpacity(0.8),
        child: GestureDetector(
          onTap: toggleMenuVisibility,
          child: AbsorbPointer(
            absorbing: _isMenuHidden.value,
            child: Row(
              children: [
                const Space.small(),
                buildPlayButton(),
                buildDurationAndPosition(),
                buildSlider(),
                buildSourceButton(),
                buildAudioSubtitlesButton(),
                buildOptionsButton(),
                const Space.small(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// This shows the play/pause button in the bottomleft of the screen.
  Widget buildPlayButton() {
    return MultiValueListenableBuilder(
      valueListenables: [
        _playingNotifier,
        _endedNotifier,
      ],
      builder: (context, values, _) {
        bool playing = values.elementAt(0);
        bool ended = values.elementAt(1);

        return Material(
          color: Colors.transparent,
          child: JidoujishoIconButton(
            size: 24,
            icon: ended
                ? Icons.replay
                : playing
                    ? Icons.pause
                    : Icons.play_arrow,
            tooltip: ended
                ? t.replay
                : playing
                    ? t.pause
                    : t.play,
            onTap: () async {
              await playPause();
            },
          ),
        );
      },
    );
  }

  /// This gets the icon for the central play/pause button.
  Widget getCentralIcon() {
    if (_playerController.value.isEnded) {
      return const Icon(Icons.replay, size: 32);
    } else {
      if (!_playerController.value.isInitialized) {
        return const Icon(Icons.play_arrow, color: Colors.transparent);
      }

      if (!_playerController.value.isPlaying) {
        return const Icon(Icons.play_arrow);
      }

      return AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: _playPauseAnimationController,
        size: 32,
      );
    }
  }

  /// Shows when the player is paused, and can be used to play/pause the player.
  Widget buildCentralPlayPause() {
    return MultiValueListenableBuilder(
      valueListenables: [
        _playingNotifier,
        _endedNotifier,
        _transcriptOpenNotifier,
      ],
      builder: (context, values, _) {
        bool playing = values.elementAt(0);
        bool ended = values.elementAt(1);
        bool transcriptOpen = values.elementAt(2);

        if (transcriptOpen) {
          return const SizedBox.shrink();
        }

        return Center(
          child: AnimatedOpacity(
            opacity: _unhideDuringInitFlag && (!playing || ended) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(48),
                ),
                child: Padding(
                  padding: Spacing.of(context).insets.all.normal,
                  child: IconButton(
                    icon: getCentralIcon(),
                    onPressed: () async {
                      await playPause();
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows current position and duration.
  Widget buildDurationAndPosition() {
    return MultiValueListenableBuilder(
      valueListenables: [
        _durationNotifier,
        _positionNotifier,
        _endedNotifier,
        _shadowingSubtitle,
      ],
      builder: (context, values, _) {
        Duration duration = values.elementAt(0);
        Duration position = values.elementAt(1);
        bool isEnded = values.elementAt(2);
        Subtitle? shadowingSubtitle = values.elementAt(3);

        if (duration == Duration.zero) {
          return const SizedBox.shrink();
        }

        String getPositionText() {
          if (isEnded && shadowingSubtitle == null) {
            position = duration;
          }

          return JidoujishoTimeFormat.getVideoDurationText(position).trim();
        }

        String getDurationText() {
          Duration allowance = audioAllowance;
          if (allowance == Duration.zero &&
              _subtitleItem.controller.subtitles.isEmpty) {
            allowance = const Duration(seconds: 5);
          }

          if (shadowingSubtitle != null) {
            duration = shadowingSubtitle.end + subtitleDelay + allowance;
          }

          return JidoujishoTimeFormat.getVideoDurationText(duration).trim();
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            child: Tooltip(
              message: t.shadowing_mode,
              child: Container(
                alignment: Alignment.center,
                height: _menuHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${getPositionText()} / ${getDurationText()}',
                  style: TextStyle(
                    color: (shadowingSubtitle != null)
                        ? Colors.red
                        : appModel.isDarkMode
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
              ),
            ),
            onTap: setShadowingSubtitle,
          ),
        );
      },
    );
  }

  /// Shows the slider representing duration and position.
  Widget buildSlider() {
    return MultiValueListenableBuilder(
      valueListenables: [
        _durationNotifier,
        _positionNotifier,
        _endedNotifier,
      ],
      builder: (context, values, _) {
        Duration duration = values.elementAt(0);
        Duration position = values.elementAt(1);
        bool isEnded = values.elementAt(2);

        bool validPosition = duration.compareTo(position) >= 0;
        double sliderValue = validPosition ? position.inSeconds.toDouble() : 0;

        if (isEnded) {
          sliderValue = 1;
        }

        return Expanded(
          child: Slider(
            activeColor: Colors.red,
            inactiveColor: Theme.of(context).unselectedWidgetColor,
            value: sliderValue,
            max: (!validPosition || isEnded)
                ? 1.0
                : _playerController.value.duration.inSeconds.toDouble(),
            onChangeStart: (value) {
              _autoPauseSubtitle = null;
              _autoPauseFlag = false;
              _dialogSmartPaused = false;
              _dialogSmartFocusFlag = false;

              cancelHideTimer();
            },
            onChangeEnd: (value) {
              if (!_isMenuHidden.value) {
                _menuHideTimer = Timer(const Duration(seconds: 3), () {
                  if (_playingNotifier.value) {
                    _isMenuHidden.value = true;
                  }
                });
              }
              _bufferingNotifier.value = true;
            },
            onChanged: validPosition
                ? (progress) {
                    cancelHideTimer();

                    sliderValue = progress.floor().toDouble();
                    _playerController.setTime(sliderValue.toInt() * 1000);
                    _listeningSubtitle.value = getNearestSubtitle();
                  }
                : null,
          ),
        );
      },
    );
  }

  /// This builds the source-specific button.
  Widget buildSourceButton() {
    MediaSource source = widget.item!.getMediaSource(appModel: appModel);
    if (source is PlayerLocalMediaSource) {
      return buildPickVideoFileButton();
    } else if (source is PlayerYoutubeSource) {
      return Row(
        children: [
          buildCommentsButton(),
          buildChangeQualityButton(),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget buildPickVideoFileButton() {
    PlayerLocalMediaSource source = widget.item!
        .getMediaSource(appModel: appModel) as PlayerLocalMediaSource;

    return Material(
      color: Colors.transparent,
      child: JidoujishoIconButton(
        size: 24,
        icon: Icons.perm_media,
        tooltip: t.pick_video_file,
        onTap: () async {
          bool shouldResume = !_dialogSmartPaused;
          dialogSmartPause();

          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          await Future.delayed(const Duration(milliseconds: 5), () {});

          await source.pickVideoFile(
            appModel: appModel,
            context: context,
            ref: ref,
            pushReplacement: true,
            onFileSelected: (path) async {
              await _playerController.stop();
            },
          );

          if (mounted) {
            await Future.delayed(const Duration(milliseconds: 5), () {});
            await SystemChrome.setEnabledSystemUIMode(
                SystemUiMode.immersiveSticky);

            if (shouldResume) {
              await dialogSmartResume();
            }
          }
        },
      ),
    );
  }

  Widget buildChangeQualityButton() {
    PlayerYoutubeSource source =
        widget.item!.getMediaSource(appModel: appModel) as PlayerYoutubeSource;

    return Material(
      color: Colors.transparent,
      child: JidoujishoIconButton(
        size: 24,
        icon: Icons.video_settings,
        tooltip: t.change_quality,
        onTap: () async {
          StreamManifest manifest = source.getStreamManifest(widget.item!);

          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => JidoujishoBottomSheet(
              options: getQualityOptions(
                manifest: manifest,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCommentsButton() {
    return Material(
      color: Colors.transparent,
      child: JidoujishoIconButton(
        size: 24,
        icon: Icons.comment_outlined,
        tooltip: t.comments,
        onTap: () async {
          clearDictionaryResult();

          await dialogSmartPause();
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          await Future.delayed(const Duration(milliseconds: 5), () {});

          try {
            widget.source.setShouldGenerateAudio(value: false);

            await appModel.temporarilyDisableStatusBarHiding(action: () async {
              await Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (context, _, __) =>
                      PlayerCommentsPage(videoUrl: widget.item!.uniqueKey),
                  settings: RouteSettings(
                    name: (PlayerCommentsPage).toString(),
                  ),
                ),
              );
            });
          } finally {
            widget.source.setShouldGenerateAudio(value: true);
            widget.source.setCurrentSentence(
              selection: JidoujishoTextSelection(
                text: _currentSubtitle.value?.data ?? '',
              ),
            );
          }

          await Future.delayed(const Duration(milliseconds: 5), () {});
          await SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.immersiveSticky);
          await dialogSmartResume();
        },
      ),
    );
  }

  List<JidoujishoBottomSheetOption> getQualityOptions({
    required StreamManifest manifest,
  }) {
    PlayerYoutubeSource source =
        widget.item!.getMediaSource(appModel: appModel) as PlayerYoutubeSource;

    List<JidoujishoBottomSheetOption> options = [];

    List<VideoQuality> qualities = source.getVideoQualities(manifest);

    for (VideoQuality quality in qualities) {
      String currentQualityVideoUrl = source.getVideoUrlForQuality(
        manifest: manifest,
        quality: quality,
      );
      bool active = currentQualityVideoUrl == _playerController.dataSource;

      JidoujishoBottomSheetOption option = JidoujishoBottomSheetOption(
        label: quality.label,
        icon: quality.icon,
        active: currentQualityVideoUrl == _playerController.dataSource,
        action: () async {
          source.setPreferredQuality(quality);

          if (!active) {
            await _playerController.stop();

            appModel.openMedia(
              mediaSource: source,
              context: context,
              ref: ref,
              item: widget.item,
              pushReplacement: true,
            );
          }
        },
      );

      options.add(option);
    }

    return options;
  }

  /// This is the second bottomrightmost button in the menu.
  Widget buildAudioSubtitlesButton() {
    JidoujishoBottomSheetOption audioOption = JidoujishoBottomSheetOption(
      label: t.player_option_select_audio,
      icon: Icons.music_note_outlined,
      action: () async {
        Map<int, String> audioEmbeddedTracks =
            await _playerController.getAudioTracks();
        int audioTrack = await _playerController.getAudioTrack() ?? 0;

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => JidoujishoBottomSheet(
            options: getAudioDialogOptions(
                embeddedTracks: audioEmbeddedTracks, audioTrack: audioTrack),
          ),
        );
      },
    );
    List<JidoujishoBottomSheetOption> options = [];
    MediaSource source = widget.item!.getMediaSource(appModel: appModel);
    if (source is! PlayerYoutubeSource) {
      options.add(audioOption);
    }

    options.addAll([
      JidoujishoBottomSheetOption(
        label: t.player_option_select_subtitle,
        icon: Icons.subtitles_outlined,
        action: () async {
          Map<int, String> subtitleEmbeddedTracks =
              await _playerController.getSpuTracks();

          if (source is PlayerNetworkStreamSource) {
            Fluttertoast.showToast(msg: t.network_subtitles_warning);
          }

          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => ValueListenableBuilder(
              valueListenable: _subtitleItemNotifier,
              builder: (context, _, child) {
                return JidoujishoBottomSheet(
                  scrollToExtent: false,
                  options: getSubtitleDialogOptions(subtitleEmbeddedTracks),
                );
              },
            ),
          );

          refreshSubtitleWidget();
        },
      ),
      JidoujishoBottomSheetOption(
        label: t.player_align_subtitle_transcript,
        icon: Icons.timer,
        action: () async {
          clearDictionaryResult();

          bool shouldResume = !_dialogSmartPaused;

          await dialogSmartPause();

          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          await Future.delayed(const Duration(milliseconds: 5), () {});

          _transcriptOpenNotifier.value = true;

          await Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, _, __) => PlayerTranscriptPage(
                title: widget.item!.title,
                subtitles: _subtitleItem.controller.subtitles,
                controller: _playerController,
                playingNotifier: _playingNotifier,
                endedNotifier: _endedNotifier,
                nearestSubtitle: getNearestSubtitle(),
                currentSubtitle: _currentSubtitle,
                subtitleOptions: _subtitleOptionsNotifier.value,
                transcriptBackgroundNotifier: _transcriptBackgroundNotifier,
                alignMode: true,
                onTap: (index) async {
                  Navigator.pop(context);
                  Subtitle subtitle = _subtitleItem.controller.subtitles[index];

                  _subtitleOptionsNotifier.value.subtitleDelay =
                      subtitle.start.inMilliseconds -
                          _positionNotifier.value.inMilliseconds;
                  Fluttertoast.showToast(
                    msg: t.subtitle_delay_set(
                        ms: _subtitleOptionsNotifier.value.subtitleDelay),
                  );

                  refreshSubtitleWidget();
                },
                onLongPress: (index) async {
                  Navigator.pop(context);
                  Subtitle subtitle = _subtitleItem.controller.subtitles[index];

                  _subtitleOptionsNotifier.value.subtitleDelay =
                      subtitle.start.inMilliseconds -
                          _positionNotifier.value.inMilliseconds;
                  Fluttertoast.showToast(
                    msg: t.subtitle_delay_set(
                        ms: _subtitleOptionsNotifier.value.subtitleDelay),
                  );

                  refreshSubtitleWidget();
                },
              ),
            ),
          );

          _transcriptOpenNotifier.value = false;

          await Future.delayed(const Duration(milliseconds: 5), () {});
          await SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.immersiveSticky);

          if (shouldResume) {
            await dialogSmartResume();
          }
        },
      ),
      JidoujishoBottomSheetOption(
        label: t.player_option_subtitle_appearance,
        icon: Icons.text_fields,
        action: () async {
          bool shouldResume = !_dialogSmartPaused;
          await dialogSmartPause();
          await showDialog(
            context: context,
            builder: (context) => SubtitleOptionsDialogPage(
              notifier: _subtitleOptionsNotifier,
            ),
          );

          if (shouldResume) {
            await dialogSmartResume();
          }
        },
      ),
      JidoujishoBottomSheetOption(
        label: t.player_option_blur_preferences,
        icon: Icons.blur_circular_sharp,
        action: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => JidoujishoBottomSheet(
              options: getBlurOptions(),
            ),
          );
        },
      ),
      JidoujishoBottomSheetOption(
        label: t.player_option_load_subtitles,
        icon: Icons.upload_file,
        action: () async {
          bool shouldResume = !_dialogSmartPaused;
          await dialogSmartPause();
          await importExternalSubtitle();
          if (shouldResume) {
            await dialogSmartResume();
          }
        },
      ),
    ]);

    return Material(
      color: Colors.transparent,
      child: JidoujishoIconButton(
        size: 24,
        icon: Icons.queue_music_outlined,
        tooltip: t.audio_subtitles,
        onTap: () async {
          if (await _playerController.getAudioTracksCount() == 0) {
            options.remove(audioOption);
          }

          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => JidoujishoBottomSheet(
              options: options,
            ),
          );
        },
      ),
    );
  }

  /// These options are shown when having selected to view the
  /// blur widget options.
  List<JidoujishoBottomSheetOption> getBlurOptions() {
    List<JidoujishoBottomSheetOption> options = [
      JidoujishoBottomSheetOption(
        label: t.player_option_blur_use,
        active: appModel.blurOptions.visible,
        icon: appModel.blurOptions.visible
            ? Icons.blur_on_outlined
            : Icons.blur_off_outlined,
        action: () async {
          BlurOptions options = appModel.blurOptions;
          options.visible = !options.visible;
          appModel.setBlurOptions(options);
          _blurOptionsNotifier.value = options;
        },
      ),
      JidoujishoBottomSheetOption(
        label: t.player_option_blur_options,
        icon: Icons.blur_circular_sharp,
        action: () async {
          bool shouldResume = !_dialogSmartPaused;
          await dialogSmartPause();
          await showDialog(
            context: context,
            builder: (context) => const BlurOptionsDialogPage(),
          );
          _blurOptionsNotifier.value = appModel.blurOptions;
          if (shouldResume) {
            await dialogSmartResume();
          }
        },
      ),
      JidoujishoBottomSheetOption(
        label: t.player_option_blur_reset,
        icon: Icons.timer_sharp,
        action: () async {
          BlurOptions options = appModel.blurOptions;
          options.left = -1;
          options.top = -1;
          options.width = 200;
          options.height = 200;

          appModel.setBlurOptions(options);
          _blurOptionsNotifier.value = options;
        },
      ),
    ];

    return options;
  }

  /// This lists all the current available audio tracks.
  List<JidoujishoBottomSheetOption> getAudioDialogOptions({
    required Map<int, String> embeddedTracks,
    required int audioTrack,
  }) {
    List<JidoujishoBottomSheetOption> options = [];

    embeddedTracks.forEach((index, label) {
      JidoujishoBottomSheetOption option = JidoujishoBottomSheetOption(
        label: '${t.player_option_audio} - $label',
        icon: Icons.music_note_outlined,
        active: audioTrack == index,
        action: () async {
          await _playerController.setAudioTrack(index);
        },
      );

      options.add(option);
    });

    return options;
  }

  /// This appropriately labels a given subtitle item.
  String getSubtitleLabel({
    required SubtitleItem item,
    required Map<int, String> embeddedTracks,
  }) {
    switch (item.type) {
      case SubtitleItemType.externalSubtitle:
        if (item.metadata != null) {
          return '${t.player_option_subtitle} - ${t.player_option_subtitle_external} [${item.metadata}]';
        } else {
          return '${t.player_option_subtitle} - ${t.player_option_subtitle_external}';
        }
      case SubtitleItemType.embeddedSubtitle:
        if (item.index != null) {
          return '${t.player_option_subtitle} - ${embeddedTracks.values.toList()[item.index!]}';
        } else {
          return '${t.player_option_subtitle} - ${t.default_option}';
        }
      case SubtitleItemType.webSubtitle:
        if (item.metadata != null) {
          return '${t.player_option_subtitle} - ${item.metadata}';
        } else {
          return t.player_option_subtitle;
        }
      case SubtitleItemType.noneSubtitle:
        return '${t.player_option_subtitle} - ${t.player_option_subtitle_none}';
    }
  }

  /// This lists all the current available subtitles.
  List<JidoujishoBottomSheetOption> getSubtitleDialogOptions(
      Map<int, String> embeddedTracks) {
    List<JidoujishoBottomSheetOption> options = [];
    for (SubtitleItem item in _subtitleItems) {
      JidoujishoBottomSheetOption option = JidoujishoBottomSheetOption(
        label: getSubtitleLabel(item: item, embeddedTracks: embeddedTracks),
        icon: Icons.subtitles_outlined,
        active: _subtitleItem == item,
        action: () {
          _subtitleItem = item;
          if (!_subtitleItem.controller.initialized) {
            _subtitleItem.controller.initial();
          }
          _currentSubtitle.value = null;
          widget.source.clearCurrentSentence();
          refreshSubtitleWidget();
        },
      );

      options.add(option);
    }

    options.add(
      JidoujishoBottomSheetOption(
        label: getSubtitleLabel(
            item: _emptySubtitleItem, embeddedTracks: embeddedTracks),
        icon: Icons.subtitles_off_outlined,
        active: _subtitleItem == _emptySubtitleItem,
        action: () {
          _subtitleItem = _emptySubtitleItem;
          _currentSubtitle.value = null;
          widget.source.clearCurrentSentence();
          refreshSubtitleWidget();
        },
      ),
    );

    return options;
  }

  /// This is the bottomrightmost button in the menu.
  Widget buildOptionsButton() {
    return Material(
      color: Colors.transparent,
      child: JidoujishoIconButton(
        size: 24,
        icon: Icons.more_vert,
        tooltip: t.show_options,
        onTap: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => JidoujishoBottomSheet(
              options: getOptions(),
            ),
          );
        },
      ),
    );
  }

  /// This lists the options available when the bottom-right option is tapped.
  List<JidoujishoBottomSheetOption> getOptions() {
    List<JidoujishoBottomSheetOption> options = [
      JidoujishoBottomSheetOption(
        label: t.player_option_definition_focus,
        icon: appModel.isPlayerDefinitionFocusMode
            ? Icons.flash_on
            : Icons.flash_off,
        active: appModel.isPlayerDefinitionFocusMode,
        action: appModel.togglePlayerDefinitionFocusMode,
      ),
      JidoujishoBottomSheetOption(
        label: t.player_option_listening_comprehension,
        icon: appModel.isPlayerListeningComprehensionMode
            ? Icons.hearing
            : Icons.hearing_disabled,
        active: appModel.isPlayerListeningComprehensionMode,
        action: () async {
          appModel.togglePlayerListeningComprehensionMode();
          refreshSubtitleWidget();
        },
      ),
      JidoujishoBottomSheetOption(
        label: t.player_change_player_orientation,
        icon: appModel.isPlayerOrientationPortrait
            ? Icons.stay_current_landscape
            : Icons.stay_current_portrait,
        action: () async {
          appModel.togglePlayerOrientationPortrait();

          await _playerController.stop();

          await appModel.openMedia(
            context: context,
            ref: ref,
            mediaSource: widget.source,
            pushReplacement: true,
            item: widget.item!.copyWith(
              position: _positionNotifier.value.inSeconds,
              duration: _durationNotifier.value.inSeconds,
            ),
          );
        },
      ),
      JidoujishoBottomSheetOption(
        label: t.stretch_to_fill_screen,
        icon: appModel.isStretchToFill
            ? Icons.fit_screen
            : Icons.fit_screen_outlined,
        active: appModel.isStretchToFill,
        action: () async {
          appModel.toggleStretchToFill();

          await _playerController.stop();

          await appModel.openMedia(
            context: context,
            ref: ref,
            mediaSource: widget.source,
            pushReplacement: true,
            item: widget.item!.copyWith(
              position: _positionNotifier.value.inSeconds,
              duration: _durationNotifier.value.inSeconds,
            ),
          );
        },
      ),
      JidoujishoBottomSheetOption(
        label: t.player_option_share_subtitle,
        icon: Icons.share,
        action: () async {
          await Share.share(getNearestSubtitle()?.data ?? '');
        },
      ),
      JidoujishoBottomSheetOption(
        label: t.player_option_export,
        icon: Icons.mobile_screen_share,
        action: () async {
          List<Subtitle> subtitles = [];
          Subtitle? singleSubtitle = getNearestSubtitle();
          if (singleSubtitle != null) {
            subtitles.add(singleSubtitle);
          }

          if (subtitles.isEmpty) {
            subtitles.add(
              Subtitle(
                index: 0,
                data: '',
                start: _positionNotifier.value -
                    Duration(
                        milliseconds: max(
                            _subtitleOptionsNotifier.value.audioAllowance,
                            2500)),
                end: _positionNotifier.value +
                    Duration(
                        milliseconds: max(
                            _subtitleOptionsNotifier.value.audioAllowance,
                            2500)),
              ),
            );
          }

          bool shouldResume = !_dialogSmartPaused;
          await dialogSmartPause();
          await openCardCreator(subtitles);
          if (shouldResume) {
            await dialogSmartResume();
          }
        },
      ),
    ];

    return options;
  }

  /// This renders the subtitle area with padding, reactive to whether or not
  /// the menu is shown.
  Widget buildSubtitleArea() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isMenuHidden,
      child: buildSubtitle(),
      builder: (context, isMenuHidden, child) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: _isMenuHidden.value &&
                    !_subtitleOptionsNotifier.value.alwaysAboveBottomBar
                ? const EdgeInsets.only(bottom: 20)
                : const EdgeInsets.only(bottom: _menuHeight + 8),
            child: child,
          ),
        );
      },
    );
  }

  /// This renders the current subtitle.
  Widget buildSubtitle() {
    return MultiValueListenableBuilder(
      valueListenables: [
        _currentSubtitle,
        _listeningSubtitle,
        _playingNotifier,
        _transcriptOpenNotifier,
      ],
      builder: (context, values, _) {
        Subtitle? currentSubtitle = values.elementAt(0);
        Subtitle? listeningSubtitle = values.elementAt(1);
        bool isPlaying = values.elementAt(2);
        bool transcriptOpen = values.elementAt(3);

        if (currentSubtitle == null || transcriptOpen) {
          return const SizedBox.shrink();
        }

        if (appModel.isPlayerListeningComprehensionMode &&
            !(listeningSubtitle != null || !isPlaying)) {
          return const SizedBox.shrink();
        }

        String subtitleText = currentSubtitle.data;
        if (_autoPauseFlag) {
          subtitleText = _autoPauseSubtitle!.data;
        }
        String regex = _subtitleOptionsNotifier.value.regexFilter;
        if (regex.isNotEmpty) {
          subtitleText = subtitleText.replaceAll(RegExp(regex), '');
        }

        return tapToSelectSubtitle(subtitleText);
      },
    );
  }

  /// This renders the subtitle with a [SelectableText] widget.
  Widget tapToSelectSubtitle(String subtitleText) {
    double blurRadius =
        _subtitleOptionsNotifier.value.subtitleBackgroundBlurRadius;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
        child: Container(
          color: Colors.black.withOpacity(
            _subtitleOptionsNotifier.value.subtitleBackgroundOpacity,
          ),
          padding: EdgeInsets.only(
            top: Spacing.of(context).spaces.small * 0.6,
            bottom: Spacing.of(context).spaces.extraSmall,
            left: Spacing.of(context).spaces.small,
            right: Spacing.of(context).spaces.small * 0.4,
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              JidoujishoSelectableText.rich(
                TextSpan(children: getSubtitleOutlineSpans(subtitleText)),
                textAlign: TextAlign.center,
                contextMenuBuilder: (_, __) {
                  return const SizedBox.shrink();
                },
                enableInteractiveSelection: false,
              ),
              JidoujishoSelectableText.rich(
                TextSpan(children: getSubtitleSpans(subtitleText)),
                textAlign: TextAlign.center,
                controller: _selectableTextController,
                focusNode: _dragToSelectFocusNode,
                selectionControls: EmptyTextSelectionControls(),
                contextMenuBuilder: (_, __) {
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// This renders the subtitle and assigns each character an action
  /// according to its index.
  List<InlineSpan> getSubtitleSpans(String text) {
    List<InlineSpan> spans = [];

    text.runes.forEachIndexed((index, rune) {
      String character = String.fromCharCode(rune);
      spans.add(
        TextSpan(
          text: character,
          style: subtitleTextStyle,
          recognizer: TapGestureRecognizer()
            ..onTapDown = (details) async {
              onTapDown(
                character: character,
                text: text,
                index: index,
              );
            },
        ),
      );
    });

    return spans;
  }

  void onTapDown({
    required String text,
    required String character,
    required int index,
  }) {
    bool wholeWordCondition =
        _selectableTextController.selection.start <= index &&
            _selectableTextController.selection.end > index;

    if (wholeWordCondition && currentResult != null) {
      if (appModel.isPlayerDefinitionFocusMode) {
        dialogSmartResume(
          isSmartFocus: true,
          hideInstantly: false,
        );
      }

      _selectableTextController.clearSelection();
      clearDictionaryResult();
      return;
    } else {
      String searchTerm = appModel.targetLanguage.getSearchTermFromIndex(
        text: text,
        index: index,
      );

      _selectableTextController.clearSelection();
      setSearchTerm(
        searchTerm: searchTerm,
        text: text,
        index: index,
      );
    }
  }

  /// Used for subtitle outline design.
  List<InlineSpan> getSubtitleOutlineSpans(String subtitleText) {
    List<InlineSpan> spans = [];

    subtitleText.runes.forEachIndexed((index, rune) {
      String character = String.fromCharCode(rune);
      spans.add(TextSpan(
        text: character,
        style: subtitleOutlineStyle,
      ));
    });

    return spans;
  }

  /// Subtitle paint style.
  Paint get subtitlePaintStyle => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _subtitleOptionsNotifier.value.subtitleOutlineWidth
    ..color = Colors.black.withOpacity(
        _subtitleOptionsNotifier.value.subtitleOutlineWidth == 0 ? 0 : 0.75);

  /// Subtitle outline text style.
  ///
  TextStyle get subtitleOutlineStyle =>
      _subtitleOptionsNotifier.value.fontName.trim().isEmpty
          ? TextStyle(
              fontSize: _subtitleOptionsNotifier.value.fontSize,
              foreground: subtitlePaintStyle,
            )
          : GoogleFonts.getFont(
              _subtitleOptionsNotifier.value.fontName,
              fontSize: _subtitleOptionsNotifier.value.fontSize,
              foreground: subtitlePaintStyle,
            );

  /// Subtitle text style.
  TextStyle get subtitleTextStyle =>
      _subtitleOptionsNotifier.value.fontName.trim().isEmpty
          ? TextStyle(
              fontSize: _subtitleOptionsNotifier.value.fontSize,
              color: Colors.white,
            )
          : GoogleFonts.getFont(
              _subtitleOptionsNotifier.value.fontName,
              fontSize: _subtitleOptionsNotifier.value.fontSize,
              color: Colors.white,
            );

  /// This is used to set the search term upon pressing on a character
  /// or selecting text.
  void setSearchTerm({
    required String text,
    required String searchTerm,
    required int index,
  }) {
    /// If we cut off at a lone surrogate, offset the index back by 1. The
    /// selection meant to select the index before.
    RegExp loneSurrogate = RegExp(
      '[\uD800-\uDBFF](?![\uDC00-\uDFFF])|(?:[^\uD800-\uDBFF]|^)[\uDC00-\uDFFF]',
    );
    if (index != 0 && text.substring(index).startsWith(loneSurrogate)) {
      index = index - 1;
    }

    int whitespaceOffset = searchTerm.length - searchTerm.trimLeft().length;
    int offsetIndex =
        appModel.targetLanguage.getStartingIndex(text: text, index: index) +
            whitespaceOffset;
    int length = appModel.targetLanguage.getGuessHighlightLength(
      searchTerm: searchTerm,
    );

    _selectableTextController.setSelection(offsetIndex, offsetIndex + length);
    if (searchTerm.isNotEmpty) {
      if (appModel.isPlayerDefinitionFocusMode) {
        dialogSmartPause();
      }
    }

    searchDictionaryResult(
      searchTerm: searchTerm,
      position: JidoujishoPopupPosition.topThreeFourths,
    ).then((result) {
      length = appModel.targetLanguage.getFinalHighlightLength(
        result: currentResult,
        searchTerm: searchTerm,
      );

      _selectableTextController.setSelection(offsetIndex, offsetIndex + length);
      final range = TextRange(start: offsetIndex, end: offsetIndex + length);

      source.setCurrentSentence(
        selection: JidoujishoTextSelection(
          text: text,
          range: range,
        ),
      );
    });
  }

  /// This is used to invoke opening the card creator given possibly
  /// multiple subtitles. See the transcript multiple subtitles long
  /// press action and the menu option for exporting.
  Future<void> openCardCreator(List<Subtitle> subtitles) async {
    StringBuffer buffer = StringBuffer();
    for (Subtitle subtitle in subtitles) {
      String subtitleText = subtitle.data;
      String regex = _subtitleOptionsNotifier.value.regexFilter;
      if (regex.isNotEmpty) {
        subtitleText = subtitleText.replaceAll(RegExp(regex), '');
      }
      buffer.writeln(subtitleText);
    }

    String sentence = buffer.toString().trim();

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await Future.delayed(const Duration(milliseconds: 5), () {});

    await appModel.openCreator(
      ref: ref,
      killOnPop: false,
      subtitles: subtitles,
      creatorFieldValues: CreatorFieldValues(
        textValues: {
          SentenceField.instance: sentence,
          TermField.instance: '',
          ClozeAfterField.instance: '',
          ClozeBeforeField.instance: '',
          ClozeInsideField.instance: '',
        },
      ),
    );

    await Future.delayed(const Duration(milliseconds: 5), () {});
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// This makes the subtitle widget force to reflect a change, for example
  /// in settings and reflect that in its appearance.
  void refreshSubtitleWidget() {
    Subtitle? holder = _currentSubtitle.value;
    _currentSubtitle.value = null;
    _currentSubtitle.value = holder;
    if (holder != null) {
      String sentence = _currentSubtitle.value?.data ?? '';
      String regex = _subtitleOptionsNotifier.value.regexFilter;
      if (regex.isNotEmpty) {
        sentence = sentence.replaceAll(RegExp(regex), '');
      }

      if (!_transcriptOpenNotifier.value) {
        source.setCurrentSentence(
          selection: JidoujishoTextSelection(
            text: sentence,
          ),
        );
      }
    } else {
      widget.source.clearCurrentSentence();
    }
  }

  /// Used to start the timeout that hides the menu. Called when the screen
  /// is tapped.
  void startHideTimer() {
    _menuHideTimer = Timer(const Duration(seconds: 3), toggleMenuVisibility);
  }

  /// Used to cancel the timeout that hides the menu. Called when the screen
  /// is tapped.
  void cancelHideTimer() {
    _menuHideTimer?.cancel();
    _isMenuHidden.value = false;
  }

  /// This hides or shows the menu.
  void toggleMenuVisibility() async {
    Wakelock.enable();
    _menuHideTimer?.cancel();
    _isMenuHidden.value = !_isMenuHidden.value;
    if (!_isMenuHidden.value) {
      _menuHideTimer = Timer(const Duration(seconds: 3), () {
        if (_playingNotifier.value) {
          _isMenuHidden.value = true;
        }
      });
    }
  }

  /// This plays or pauses the player.
  Future<void> playPause() async {
    _autoPauseFlag = false;
    _dialogSmartPaused = false;

    final isFinished = _playerController.value.isEnded;

    if (_playerController.value.isPlaying) {
      _playPauseAnimationController.reverse();
      _menuHideTimer?.cancel();
      _isMenuHidden.value = false;

      await _playerController.pause();
      _session.setActive(false);
    } else {
      if (!_playerController.value.isInitialized) {
        _playerController.initialize().then((_) async {
          await _playerController.play();
          _session.setActive(true);
          _playPauseAnimationController.forward();

          _menuHideTimer?.cancel();
          _isMenuHidden.value = true;
        });
      } else {
        _playPauseAnimationController.forward();

        if (isFinished) {
          await _playerController.stop();
          await _playerController.play();
          _session.setActive(true);
          await Future.delayed(const Duration(seconds: 2), () async {
            _menuHideTimer?.cancel();
            _isMenuHidden.value = true;

            await _playerController.seekTo(Duration.zero);
            _bufferingNotifier.value = true;
          });
        } else {
          _menuHideTimer?.cancel();
          _isMenuHidden.value = true;

          await _playerController.play();
          _session.setActive(true);
        }
      }
    }
  }

  /// This fetches the nearest relevant subtitle for highlighting and
  /// exporting and seeking purposes.
  Subtitle? getNearestSubtitle() {
    if (_currentSubtitle.value != null) {
      return _currentSubtitle.value!;
    } else {
      if (_subtitleItem.controller.subtitles.isEmpty) {
        return null;
      }

      Subtitle? lastSubtitle;
      for (Subtitle subtitle in _subtitleItem.controller.subtitles) {
        if (_positionNotifier.value < subtitle.start + subtitleDelay) {
          return lastSubtitle;
        }

        lastSubtitle = subtitle;
      }

      return null;
    }
  }

  /// This sets the subtitle to be repeated.
  void setShadowingSubtitle() {
    if (_shadowingSubtitle.value != null) {
      _shadowingSubtitle.value = null;
    } else {
      if (_subtitleItem.controller.subtitles.isEmpty) {
        _shadowingSubtitle.value = Subtitle(
          data: '',
          start: _positionNotifier.value,
          end: _positionNotifier.value,
          index: 0,
        );
      } else {
        _shadowingSubtitle.value = getNearestSubtitle();
      }
    }
  }

  /// This is called when opening dialogs such as the transcript and the
  /// creator, where it is appropriate to pause the player.
  Future<void> dialogSmartPause() async {
    if (_playerController.value.isPlaying) {
      _menuHideTimer?.cancel();
      _dialogSmartPaused = true;
      await _playerController.pause();
      _session.setActive(false);
    }
  }

  /// Resumes the dialog only if smart paused. This is called when dialogs
  /// are closed after being smart paused.
  Future<void> dialogSmartResume({
    bool isSmartFocus = false,
    bool hideInstantly = true,
  }) async {
    _autoPauseFlag = false;

    if (_dialogSmartFocusFlag && !isSmartFocus) {
      return;
    }

    if (isSmartFocus) {
      _dialogSmartFocusFlag = false;
    }

    if (_dialogSmartPaused) {
      if (hideInstantly) {
        _menuHideTimer?.cancel();
        _isMenuHidden.value = true;
      } else {
        _menuHideTimer = Timer(const Duration(seconds: 3), () {
          if (_playingNotifier.value) {
            _isMenuHidden.value = true;
          }
        });
      }

      await _playerController.play();
      _session.setActive(true);
    }

    _dialogSmartPaused = false;
  }

  /// Shows the dialog for importing an external subtitle.
  Future<void> importExternalSubtitle() async {
    Iterable<String>? filePaths = await FilesystemPicker.open(
      title: '',
      allowedExtensions: ['.ass', '.srt'],
      pickText: t.dialog_select,
      cancelText: t.dialog_cancel,
      context: context,
      rootDirectories: await appModel
          .getFilePickerDirectoriesForMediaType(PlayerMediaType.instance),
      fsType: FilesystemType.file,
      folderIconColor: Colors.red,
      themeData: Theme.of(context),
    );

    if (filePaths == null || filePaths.isEmpty) {
      return;
    }

    String filePath = filePaths.first;

    appModel.setLastPickedDirectory(
      type: PlayerMediaType.instance,
      directory: Directory(path.dirname(filePath)),
    );

    File file = File(filePath);

    String fileExtension = path.extension(filePath);

    SubtitleItem? item = await SubtitleUtils.subtitlesFromFile(
      file: file,
      type: SubtitleItemType.externalSubtitle,
      metadata: fileExtension,
    );

    await item.controller.initial();

    _subtitleItems.add(item);
    _subtitleItem = item;
    _currentSubtitle.value = null;
    widget.source.clearCurrentSentence();
    refreshSubtitleWidget();
  }
}

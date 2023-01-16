import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spaces/spaces.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakelock/wakelock.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
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
  String get playLabel => appModel.translate('player_play');
  String get pauseLabel => appModel.translate('player_pause');
  String get replayLabel => appModel.translate('player_replay');
  String get playerOptionSelectAudio =>
      appModel.translate('player_option_select_audio');
  String get playerOptionSelectSubtitle =>
      appModel.translate('player_option_select_subtitle');
  String get playerAlignSubtitleTranscript =>
      appModel.translate('player_align_subtitle_transcript');
  String get playerOptionSubtitleAppearance =>
      appModel.translate('player_option_subtitle_appearance');
  String get playerOptionBlurPreferences =>
      appModel.translate('player_option_blur_preferences');
  String get playerOptionLoadSubtitles =>
      appModel.translate('player_option_load_subtitles');
  String get playerOptionBlurUse =>
      appModel.translate('player_option_blur_use');
  String get playerOptionBlurOptions =>
      appModel.translate('player_option_blur_options');
  String get playerOptionBlurReset =>
      appModel.translate('player_option_blur_reset');
  String get playerOptionAudio => appModel.translate('player_option_audio');

  String get playerOptionShadowing =>
      appModel.translate('player_option_shadowing');
  String get playerOptionDefinitionFocus =>
      appModel.translate('player_option_definition_focus');
  String get playerOptionListeningComprehension =>
      appModel.translate('player_option_listening_comprehension');
  String get playerChangePlayerOrientation =>
      appModel.translate('player_change_player_orientation');
  String get playerOptionShareSubtitle =>
      appModel.translate('player_option_share_subtitle');
  String get playerOptionExport => appModel.translate('player_option_export');

  String get audioSubtitlesLabel => appModel.translate('audio_subtitles');
  String get showOptions => appModel.translate('show_options');

  String get optionSubtitle => appModel.translate('player_option_subtitle');
  String get optionSubtitleExternal =>
      appModel.translate('player_option_subtitle_external');
  String get optionSubtitleNone =>
      appModel.translate('player_option_subtitle_none');

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

  final ValueNotifier<bool> _isMenuHidden = ValueNotifier<bool>(false);

  late final ValueNotifier<Subtitle?> _currentSubtitle;
  final ValueNotifier<Subtitle?> _currentSubtitleMemory =
      ValueNotifier<Subtitle?>(null);
  final ValueNotifier<Subtitle?> _shadowingSubtitle =
      ValueNotifier<Subtitle?>(null);
  final ValueNotifier<Subtitle?> _listeningSubtitle =
      ValueNotifier<Subtitle?>(null);

  late final ValueNotifier<BlurOptions> _blurOptionsNotifier;
  late final ValueNotifier<SubtitleOptions> _subtitleOptionsNotifier;

  StreamSubscription<void>? _playPauseSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _playPauseSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _session.setActive(true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
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
  Timer? _dragSubtitlesTimer;

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

  /// Hide the dictionary and dispose of the current result.
  @override
  void clearDictionaryResult() {
    if (appModel.isPlayerDefinitionFocusMode) {
      dialogSmartResume(isSmartFocus: true);
    }

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

    _playerInitialised = true;

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

    _playerController =
        await (widget.source as PlayerMediaSource).preparePlayerController(
      appModel: appModel,
      ref: ref,
      item: widget.item!,
    );
    _subtitleItems =
        await (widget.source as PlayerMediaSource).prepareSubtitles(
      appModel: appModel,
      ref: ref,
      item: widget.item!,
    );

    if (_subtitleItems.isNotEmpty) {
      _subtitleItem = _subtitleItems.first;
    }
    await _subtitleItem.controller.initial();

    _blurOptionsNotifier = ValueNotifier<BlurOptions>(appModel.blurOptions);

    /// This is so cursed.
    appModel.currentPlayerController = _playerController;
    _currentSubtitle = appModel.currentSubtitle;
    _subtitleOptionsNotifier = appModel.currentSubtitleOptions!;

    _currentSubtitle.value = null;
    appModel.blockCreatorInitialMedia = true;

    _playerController.addOnInitListener(() async {
      initialiseEmbeddedSubtitles(_playerController);

      Future.delayed(const Duration(seconds: 5), () {
        appModel.blockCreatorInitialMedia = false;
      });
    });

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

    _playPauseSubscription = appModel.audioHandlerStream.listen((_) {
      playPause();
    });

    _session = await AudioSession.instance;
    await _session.configure(const AudioSessionConfiguration.music());

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

      Subtitle? newSubtitle = _subtitleItem.controller
          .durationSearch(_positionNotifier.value + subtitleDelay);
      String sentence = _currentSubtitle.value?.data ?? '';
      String regex = _subtitleOptionsNotifier.value.regexFilter;
      if (regex.isNotEmpty) {
        sentence = sentence.replaceAll(RegExp(regex), '');
      }
      widget.source.setCurrentSentence(sentence);

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
        if (_subtitleItem.controller.subtitles.isEmpty) {
          if (allowance == Duration.zero) {
            allowance = const Duration(seconds: 5);
          }
        }

        if (_positionNotifier.value <
                _shadowingSubtitle.value!.start -
                    subtitleDelay -
                    const Duration(seconds: 15) -
                    audioAllowance ||
            _positionNotifier.value >
                _shadowingSubtitle.value!.end -
                    subtitleDelay +
                    audioAllowance) {
          _playerController.seekTo(
              _shadowingSubtitle.value!.start + subtitleDelay - audioAllowance);
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

      if (!appModel.isIncognitoMode) {
        updateHistory();
      }
    }
  }

  /// This prepares the subtitles included with the video for use.
  void initialiseEmbeddedSubtitles(VlcPlayerController controller) async {
    if (controller.dataSourceType != DataSourceType.file) {
      return;
    }

    await Future.delayed(const Duration(seconds: 2), () {});

    int embeddedTrackCount = await _playerController.getSpuTracksCount() ?? 0;

    List<SubtitleItem> embeddedItems = await SubtitleUtils.subtitlesFromVideo(
        File(controller.dataSource), embeddedTrackCount);

    _subtitleItems.addAll(embeddedItems);

    if (_subtitleItem.type == SubtitleItemType.noneSubtitle) {
      for (int i = 0; i < _subtitleItems.length; i++) {
        SubtitleItem item = _subtitleItems[i];
        if (item.controller.subtitles.isNotEmpty) {
          await item.controller.initial();
          _subtitleItem = item;
          break;
        }
      }
    }
  }

  /// This updates the media item to its new position and duration and also
  /// persists the change in media history.
  void updateHistory() async {
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

    return Stack(
      alignment: Alignment.center,
      children: [
        buildPlayer(),
        buildGestureArea(),
        buildBlurWidget(),
        buildMenuArea(),
        buildSubtitleArea(),
        buildCentralPlayPause(),
        Padding(
          padding: MediaQuery.of(context).orientation == Orientation.landscape
              ? Spacing.of(context).insets.horizontal.extraBig * 5
              : EdgeInsets.zero,
          child: buildDictionary(),
        ),
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
        child: VlcPlayer(
          controller: _playerController,
          aspectRatio: 16 / 9,
          placeholder: buildLoading(),
        ),
      ),
    );
  }

  /// This enables gestures for repeating the current subtitle
  /// and for showing the transcript.
  Widget buildGestureArea() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) async {
        if (details.delta.dx.abs() > 20) {
          Subtitle? nearestSubtitle = getNearestSubtitle();

          _listeningSubtitle.value = nearestSubtitle;
          await _playerController
              .seekTo(nearestSubtitle!.start - subtitleDelay);
        }
      },
      onHorizontalDragEnd: (dragEndDetails) async {
        if (dragEndDetails.primaryVelocity!.abs() > 0) {
          Subtitle? nearestSubtitle = getNearestSubtitle();

          _listeningSubtitle.value = nearestSubtitle;
          await _playerController
              .seekTo(nearestSubtitle!.start - subtitleDelay);
        }
      },
      onVerticalDragEnd: (details) async {
        if (details.primaryVelocity!.abs() > 0) {
          bool exporting = false;
          await dialogSmartPause();

          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          await Future.delayed(const Duration(milliseconds: 5), () {});

          await Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, _, __) => PlayerTranscriptPage(
                title: widget.item!.title,
                subtitles: _subtitleItem.controller.subtitles,
                currentSubtitle: getNearestSubtitle(),
                subtitleOptions: _subtitleOptionsNotifier.value,
                onTap: (index) async {
                  await Future.delayed(const Duration(milliseconds: 5), () {});
                  await SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.immersiveSticky);
                  Navigator.pop(context);
                  await _playerController.seekTo(
                      _subtitleItem.controller.subtitles[index].start -
                          subtitleDelay);
                },
                onLongPress: (index) async {
                  Navigator.pop(context);
                  exporting = true;
                  await exportMultipleSubtitles(index);
                  await dialogSmartResume();
                },
              ),
            ),
          );

          if (!exporting) {
            await dialogSmartResume();
            await Future.delayed(const Duration(milliseconds: 5), () {});
            await SystemChrome.setEnabledSystemUIMode(
                SystemUiMode.immersiveSticky);
          }
        }
      },
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        toggleMenuVisibility();
      },
      child: buildScrubDetectors(),
    );
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

              startHideTimer();
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

              startHideTimer();
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
                ? replayLabel
                : playing
                    ? pauseLabel
                    : playLabel,
            onTap: () async {
              cancelHideTimer();
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
      ],
      builder: (context, values, _) {
        bool playing = values.elementAt(0);
        bool ended = values.elementAt(1);

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

          if (position.inHours == 0) {
            var strPosition = position.toString().split('.')[0];
            return "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
          } else {
            return position.toString().split('.')[0];
          }
        }

        String getDurationText() {
          if (shadowingSubtitle != null) {
            duration = shadowingSubtitle.end + subtitleDelay + audioAllowance;
          }

          if (duration.inHours == 0) {
            var strDuration = duration.toString().split('.')[0];
            return "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
          } else {
            return duration.toString().split('.')[0];
          }
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
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
              startHideTimer();
            },
            onChanged: validPosition
                ? (progress) {
                    cancelHideTimer();

                    sliderValue = progress.floor().toDouble();
                    _playerController.setTime(sliderValue.toInt() * 1000);
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
      return buildChangeQualityButton();
    }
    return const SizedBox.shrink();
  }

  Widget buildPickVideoFileButton() {
    PlayerLocalMediaSource source = widget.item!
        .getMediaSource(appModel: appModel) as PlayerLocalMediaSource;
    String pickVideoFileLabel = appModel.translate('pick_video_file');

    return Material(
      color: Colors.transparent,
      child: JidoujishoIconButton(
        size: 24,
        icon: Icons.perm_media,
        tooltip: pickVideoFileLabel,
        onTap: () async {
          dialogSmartPause();

          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          await Future.delayed(const Duration(milliseconds: 5), () {});

          await source.pickVideoFile(
            appModel: appModel,
            context: context,
            ref: ref,
            pushReplacement: true,
          );

          await Future.delayed(const Duration(milliseconds: 5), () {});
          await SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.immersiveSticky);

          dialogSmartResume();
        },
      ),
    );
  }

  Widget buildChangeQualityButton() {
    PlayerYoutubeSource source =
        widget.item!.getMediaSource(appModel: appModel) as PlayerYoutubeSource;
    String pickVideoFileLabel = appModel.translate('change_quality');

    return Material(
      color: Colors.transparent,
      child: JidoujishoIconButton(
        size: 24,
        icon: Icons.video_settings,
        tooltip: pickVideoFileLabel,
        onTap: () async {
          StreamManifest manifest =
              await source.getStreamManifest(widget.item!);

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
      label: playerOptionSelectAudio,
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
        label: playerOptionSelectSubtitle,
        icon: Icons.subtitles_outlined,
        action: () async {
          Map<int, String> subtitleEmbeddedTracks =
              await _playerController.getSpuTracks();

          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => JidoujishoBottomSheet(
              options: getSubtitleDialogOptions(subtitleEmbeddedTracks),
            ),
          );

          refreshSubtitleWidget();
        },
      ),
      JidoujishoBottomSheetOption(
        label: playerAlignSubtitleTranscript,
        icon: Icons.timer,
        action: () async {
          await dialogSmartPause();

          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          await Future.delayed(const Duration(milliseconds: 5), () {});

          await Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, _, __) => PlayerTranscriptPage(
                title: widget.item!.title,
                subtitles: _subtitleItem.controller.subtitles,
                currentSubtitle: getNearestSubtitle(),
                subtitleOptions: _subtitleOptionsNotifier.value,
                onTap: (index) async {
                  Navigator.pop(context);
                  Subtitle subtitle = _subtitleItem.controller.subtitles[index];

                  _subtitleOptionsNotifier.value.subtitleDelay =
                      subtitle.start.inMilliseconds -
                          _positionNotifier.value.inMilliseconds;

                  refreshSubtitleWidget();
                },
                onLongPress: (index) async {
                  Navigator.pop(context);
                  Subtitle subtitle = _subtitleItem.controller.subtitles[index];

                  _subtitleOptionsNotifier.value.subtitleDelay =
                      subtitle.start.inMilliseconds -
                          _positionNotifier.value.inMilliseconds;

                  refreshSubtitleWidget();
                },
              ),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 5), () {});
          await SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.immersiveSticky);

          await dialogSmartResume();
        },
      ),
      JidoujishoBottomSheetOption(
        label: playerOptionSubtitleAppearance,
        icon: Icons.text_fields,
        action: () async {
          await dialogSmartPause();
          await showDialog(
            context: context,
            builder: (context) => SubtitleOptionsDialogPage(
              notifier: _subtitleOptionsNotifier,
            ),
          );
          await dialogSmartResume();
        },
      ),
      JidoujishoBottomSheetOption(
        label: playerOptionBlurPreferences,
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
        label: playerOptionLoadSubtitles,
        icon: Icons.upload_file,
        action: () async {
          await dialogSmartPause();
          await importExternalSubtitle();
          await dialogSmartResume();
        },
      ),
    ]);

    return Material(
      color: Colors.transparent,
      child: JidoujishoIconButton(
        size: 24,
        icon: Icons.queue_music_outlined,
        tooltip: audioSubtitlesLabel,
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
        label: playerOptionBlurUse,
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
        label: playerOptionBlurOptions,
        icon: Icons.blur_circular_sharp,
        action: () async {
          await dialogSmartPause();
          await showDialog(
            context: context,
            builder: (context) => const BlurOptionsDialogPage(),
          );
          _blurOptionsNotifier.value = appModel.blurOptions;
          await dialogSmartResume();
        },
      ),
      JidoujishoBottomSheetOption(
        label: playerOptionBlurReset,
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
        label: '$playerOptionAudio - $label',
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
        return '$optionSubtitle - $optionSubtitleExternal [${item.metadata}]';
      case SubtitleItemType.embeddedSubtitle:
        return '$optionSubtitle - ${embeddedTracks.values.toList()[item.index!]}';
      case SubtitleItemType.webSubtitle:
        return '$optionSubtitle - ${item.metadata}';
      case SubtitleItemType.noneSubtitle:
        return '$optionSubtitle - $optionSubtitleNone';
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

    options.add(JidoujishoBottomSheetOption(
        label: getSubtitleLabel(
            item: _emptySubtitleItem, embeddedTracks: embeddedTracks),
        icon: Icons.subtitles_off_outlined,
        active: _subtitleItem == _emptySubtitleItem,
        action: () {
          _subtitleItem = _emptySubtitleItem;
          _currentSubtitle.value = null;
          widget.source.clearCurrentSentence();
          refreshSubtitleWidget();
        }));

    return options;
  }

  /// This is the bottomrightmost button in the menu.
  Widget buildOptionsButton() {
    return Material(
      color: Colors.transparent,
      child: JidoujishoIconButton(
        size: 24,
        icon: Icons.more_vert,
        tooltip: showOptions,
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
        label: playerOptionShadowing,
        icon: Icons.loop,
        active: _shadowingSubtitle.value != null,
        action: setShadowingSubtitle,
      ),
      JidoujishoBottomSheetOption(
        label: playerOptionDefinitionFocus,
        icon: appModel.isPlayerDefinitionFocusMode
            ? Icons.flash_on
            : Icons.flash_off,
        active: appModel.isPlayerDefinitionFocusMode,
        action: appModel.togglePlayerDefinitionFocusMode,
      ),
      JidoujishoBottomSheetOption(
        label: playerOptionListeningComprehension,
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
        label: playerChangePlayerOrientation,
        icon: appModel.isPlayerOrientationPortrait
            ? Icons.stay_current_landscape
            : Icons.stay_current_portrait,
        action: () async {
          appModel.togglePlayerOrientationPortrait();

          Navigator.pop(context);
          await appModel.openMedia(
            context: context,
            ref: ref,
            mediaSource: widget.source,
            item: widget.item!.copyWith(
              position: _positionNotifier.value.inSeconds,
              duration: _durationNotifier.value.inSeconds,
            ),
          );
        },
      ),
      JidoujishoBottomSheetOption(
        label: playerOptionShareSubtitle,
        icon: Icons.share,
        action: () async {
          await Share.share(getNearestSubtitle()?.data ?? '');
        },
      ),
      JidoujishoBottomSheetOption(
        label: playerOptionExport,
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

          await dialogSmartPause();
          await openCardCreator(subtitles);
          await dialogSmartResume();
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
      builder: (context, isMenuHidden, _) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: _isMenuHidden.value
                ? const EdgeInsets.only(bottom: 20)
                : const EdgeInsets.only(bottom: _menuHeight + 8),
            child: buildSubtitle(),
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
      ],
      builder: (context, values, _) {
        Subtitle? currentSubtitle = values.elementAt(0);
        Subtitle? listeningSubtitle = values.elementAt(1);
        bool isPlaying = values.elementAt(2);

        if (currentSubtitle == null) {
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

        return dragToSelectSubtitle(subtitleText);
      },
    );
  }

  /// This renders the subtitle with a [SelectableText] widget.
  Widget dragToSelectSubtitle(String subtitleText) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        SelectableText.rich(
          TextSpan(children: getSubtitleOutlineSpans(subtitleText)),
          textAlign: TextAlign.center,
          toolbarOptions: const ToolbarOptions(),
          enableInteractiveSelection: false,
        ),
        SelectableText.rich(
          TextSpan(children: getSubtitleSpans(subtitleText)),
          textAlign: TextAlign.center,
          focusNode: _dragToSelectFocusNode,
          toolbarOptions: const ToolbarOptions(),
          onSelectionChanged: (selection, cause) {
            String newTerm = selection.textInside(subtitleText);
            startDragSubtitlesTimer(newTerm);
          },
        ),
      ],
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
              String searchTerm =
                  appModel.targetLanguage.getSearchTermFromIndex(
                text: text,
                index: index,
              );

              setSearchTerm(searchTerm);
            },
        ),
      );
    });

    return spans;
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
    ..strokeWidth = 3
    ..color = Colors.black.withOpacity(0.75);

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

  /// Used to cancel the timeout that deselects selected text.
  /// Called when text is selected.
  void cancelDragSubtitlesTimer() {
    if (_dragSubtitlesTimer != null) {
      _dragSubtitlesTimer?.cancel();
    }
  }

  /// Used to start the timeout that deselects selected text.
  /// Called when text is selected.
  void startDragSubtitlesTimer(String newTerm) {
    cancelDragSubtitlesTimer();
    _dragSubtitlesTimer = Timer(const Duration(milliseconds: 500), () {
      if (newTerm.isNotEmpty) {
        setSearchTerm(newTerm);
      }
      refreshSubtitleWidget();
    });
  }

  /// This is used to set the search term upon pressing on a character
  /// or selecting text.
  void setSearchTerm(String searchTerm) {
    if (searchTerm.isNotEmpty) {
      if (appModel.isPlayerDefinitionFocusMode) {
        dialogSmartPause();
      }
    }

    searchDictionaryResult(
      searchTerm: searchTerm,
      position: JidoujishoPopupPosition.topThreeFourths,
    );
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
      widget.source.setCurrentSentence(sentence);
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
    _menuHideTimer?.cancel();
    _isMenuHidden.value = !_isMenuHidden.value;
    if (!_isMenuHidden.value) {
      startHideTimer();
    }
  }

  /// This plays or pauses the player.
  Future<void> playPause() async {
    _autoPauseFlag = false;
    _dialogSmartPaused = false;

    final isFinished = _playerController.value.isEnded;

    if (_playerController.value.isPlaying) {
      _playPauseAnimationController.reverse();
      startHideTimer();

      await _playerController.pause();
      _session.setActive(false);
    } else {
      cancelHideTimer();

      if (!_playerController.value.isInitialized) {
        _playerController.initialize().then((_) async {
          await _playerController.play();
          _session.setActive(true);
          _playPauseAnimationController.forward();
        });
      } else {
        _playPauseAnimationController.forward();

        await _playerController.play();
        _session.setActive(true);

        if (isFinished) {
          await _playerController.stop();
          await _playerController.play();
          _session.setActive(true);
          await Future.delayed(const Duration(seconds: 2), () async {
            await _playerController.seekTo(Duration.zero);
          });
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
      _dialogSmartPaused = true;
      await _playerController.pause();
      _session.setActive(false);
    }
  }

  /// Resumes the dialog only if smart paused. This is called when dialogs
  /// are closed after being smart paused.
  Future<void> dialogSmartResume({bool isSmartFocus = false}) async {
    _autoPauseFlag = false;

    if (_dialogSmartFocusFlag && !isSmartFocus) {
      return;
    }

    if (isSmartFocus) {
      _dialogSmartFocusFlag = false;
    }

    if (_dialogSmartPaused) {
      await _playerController.play();
      _session.setActive(true);
    }

    _dialogSmartPaused = false;
  }

  /// Shows the dialog for importing an external subtitle.
  Future<void> importExternalSubtitle() async {
    String pickText = appModel.translate('dialog_select');
    String cancelText = appModel.translate('dialog_cancel');

    Iterable<String>? filePaths = await FilesystemPicker.open(
      title: '',
      allowedExtensions: ['.ass', '.srt'],
      pickText: pickText,
      cancelText: cancelText,
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

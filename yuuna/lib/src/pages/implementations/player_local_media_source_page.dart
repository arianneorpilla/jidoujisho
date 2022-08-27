import 'dart:async';
import 'dart:io';

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
import 'package:yuuna/media.dart';
import 'package:yuuna/src/pages/base_source_page.dart';
import 'package:yuuna/utils.dart';
import 'package:path/path.dart' as path;

/// The media page used for unimplemented sources.
class PlayerLocalMediaSourcePage extends BaseSourcePage {
  /// Create an instance of this page.
  const PlayerLocalMediaSourcePage({
    super.item,
    super.key,
  });

  @override
  BaseSourcePageState createState() => _PlayerLocalMediaSourcePage();
}

class _PlayerLocalMediaSourcePage extends BaseSourcePageState
    with TickerProviderStateMixin {
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

  Orientation? _currentOrientation;

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

  final ValueNotifier<Subtitle?> _currentSubtitle =
      ValueNotifier<Subtitle?>(null);
  final ValueNotifier<Subtitle?> _currentSubtitleMemory =
      ValueNotifier<Subtitle?>(null);
  final ValueNotifier<Subtitle?> _shadowingSubtitle =
      ValueNotifier<Subtitle?>(null);
  final ValueNotifier<Subtitle?> _listeningSubtitle =
      ValueNotifier<Subtitle?>(null);

  late final ValueNotifier<BlurOptions> _blurOptionsNotifier;
  late final ValueNotifier<SubtitleOptions> _subtitleOptionsNotifier;

  static const double menuHeight = 48;

  /// Allows customisation of opacity of dictionary entries.
  @override
  double get dictionaryBackgroundOpacity => 0.75;

  @override
  double get dictionaryEntryOpacity => 0.5;

  Timer? _menuHideTimer;
  Timer? _dragSubtitlesTimer;

  bool unhideDuringInitFlag = false;

  double subtitleFontSize = 24;
  int subtitlesDelay = 0;
  int _currentAudioTrack = 0;

  bool _dialogSmartPaused = false;
  bool _dialogSmartFocusFlag = false;

  bool _autoPauseFlag = false;
  Subtitle? _autoPauseSubtitle;
  bool _sliderBeingDragged = false;

  Duration get subtitleDelay =>
      Duration(milliseconds: _subtitleOptionsNotifier.value.subtitleDelay);
  Duration get audioAllowance =>
      Duration(milliseconds: _subtitleOptionsNotifier.value.audioAllowance);

  final FocusNode dragToSelectFocusNode = FocusNode();

  bool _playerInitialised = false;

  void initialisePlayer(PlayerPayload payload) async {
    if (_playerInitialised) {
      return;
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (appModel.isPlayerOrientationPortrait) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

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

    _playerController = payload.controller;
    _subtitleItems = payload.subtitleItems;

    if (_subtitleItems.isNotEmpty) {
      _subtitleItem = _subtitleItems.first;
    }
    await _subtitleItem.controller.initial();

    _blurOptionsNotifier = ValueNotifier<BlurOptions>(appModel.blurOptions);
    _subtitleOptionsNotifier =
        ValueNotifier<SubtitleOptions>(appModel.subtitleOptions);

    _playerController.addOnInitListener(() {
      initialiseEmbeddedSubtitles(_playerController);
    });

    /// appModel.playPauseFlipflop.addListener(playPause);

    setState(() {
      _playerInitialised = true;
    });

    _playerController.addListener(listener);

    startHideTimer();

    Future.delayed(const Duration(seconds: 3), () {
      unhideDuringInitFlag = true;
    });
  }

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

  void initialiseEmbeddedSubtitles(VlcPlayerController controller) async {
    if (controller.dataSourceType != DataSourceType.file) {
      return;
    }

    await Future.delayed(const Duration(seconds: 2), () {});

    int embeddedTrackCount = await _playerController.getSpuTracksCount() ?? 0;
    _currentAudioTrack = await _playerController.getAudioTrack() ?? 0;

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

  void updateHistory() async {
    MediaItem item = widget.item!;
    item.position = _positionNotifier.value.inSeconds;
    item.duration = _durationNotifier.value.inSeconds;

    if (item.position != 0) {
      appModel.addMediaItem(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerPayload>(
      future: PlayerLocalMediaSource.instance.preparePayload(widget.item!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildLoading();
        } else if (snapshot.hasError) {
          return buildError();
        } else {
          return buildData(snapshot.data!);
        }
      },
    );
  }

  Widget buildData(PlayerPayload payload) {
    if (!_playerInitialised) {
      initialisePlayer(payload);
      return buildLoading();
    }

    _currentOrientation ??= MediaQuery.of(context).orientation;

    // Duration position = _playerController.value.position;
    // if (_currentOrientation != MediaQuery.of(context).orientation) {
    //   _currentOrientation = MediaQuery.of(context).orientation;
    //   Future.delayed(const Duration(milliseconds: 50), () {
    //     _playerController.seekTo(position - const Duration(milliseconds: 50));
    //   });
    // }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: [
            buildPlayer(),
            buildGestureArea(),
            buildBlurWidget(),
            buildMenuArea(),
            buildSubtitleArea(),
            Padding(
              padding: _currentOrientation == Orientation.landscape
                  ? Spacing.of(context).insets.horizontal.extraBig * 5
                  : EdgeInsets.zero,
              child: buildDictionary(),
            ),
            buildCentralPlayPause(),
          ],
        ),
      ),
    );
  }

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

          // await openTranscript(
          //     context: context,
          //     subtitles: _subtitleItem.controller.subtitles,
          //     subtitleDelay: subtitleDelay,
          //     currentSubtitle: getNearestSubtitle(),
          //     fontSize: _subtitleOptionsNotifier.value.fontSize,
          //     fontName: _subtitleOptionsNotifier.value.fontName,
          //     regexFilter: _subtitleOptionsNotifier.value.regexFilter,
          //     onTapCallback: (index) async {
          //       await _playerController.seekTo(
          //           _subtitleItem.controller.subtitles[index].start -
          //               subtitleDelay);
          //     },
          //     onLongPressCallback: (index) async {
          //       exporting = true;
          //       await exportMultipleSubtitles(index);
          //     });

          if (!exporting) {
            await dialogSmartResume();
          }
        }
      },
      onTap: toggleMenuVisibility,
      child: buildScrubDetectors(),
    );
  }

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
            child: SizedBox.expand(
              child: ColoredBox(
                color: Colors.red.withOpacity(0),
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
            child: SizedBox.expand(
              child: ColoredBox(
                color: Colors.blue.withOpacity(0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBlurWidget() {
    return ResizeableWidget(
      notifier: _blurOptionsNotifier,
    );
  }

  Widget buildMenuArea() {
    return Align(
      alignment: Alignment.topCenter,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isMenuHidden,
        builder: (context, value, _) {
          return AnimatedOpacity(
            opacity: value ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: buildMenuContent(),
          );
        },
      ),
    );
  }

  Widget buildMenuContent() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: menuHeight,
        color: theme.cardColor,
        child: GestureDetector(
          onTap: toggleMenuVisibility,
          child: AbsorbPointer(
            absorbing: _isMenuHidden.value,
            child: Row(
              children: [
                buildPlayButton(),
                buildDurationAndPosition(),
                buildSlider(),
                buildSourceButton(),
                buildAudioSubtitlesButton(),
                buildOptionsButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget getIcon() {
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
            opacity: unhideDuringInitFlag && (!playing || ended) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(48),
                ),
                child: Padding(
                  padding: Spacing.of(context).insets.all.normal,
                  child: IconButton(
                    icon: getIcon(),
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
              height: menuHeight,
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
              _sliderBeingDragged = true;
              _autoPauseSubtitle = null;
              _autoPauseFlag = false;
              _dialogSmartPaused = false;
              _dialogSmartFocusFlag = false;

              cancelHideTimer();
            },
            onChangeEnd: (value) {
              _sliderBeingDragged = false;
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

  Widget buildSourceButton() {
    return const SizedBox.shrink();
  }

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
            options: getAudioDialogOptions(audioEmbeddedTracks, audioTrack),
          ),
        );
      },
    );
    List<JidoujishoBottomSheetOption> options = [];
    options.add(audioOption);

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

          // await openTranscript(
          //     context: context,
          //     subtitles: _subtitleItem.controller.subtitles,
          //     subtitleDelay: subtitleDelay,
          //     currentSubtitle: getNearestSubtitle(),
          //     fontSize: _subtitleOptionsNotifier.value.fontSize,
          //     fontName: _subtitleOptionsNotifier.value.fontName,
          //     regexFilter: _subtitleOptionsNotifier.value.regexFilter,
          //     onTapCallback: (index) async {
          //       Subtitle subtitle = _subtitleItem.controller.subtitles[index];

          //       _subtitleOptionsNotifier.value.subtitleDelay =
          //           subtitle.end.inMilliseconds -
          //               _positionNotifier.value.inMilliseconds;

          //       refreshSubtitleWidget();
          //     },
          //     onLongPressCallback: (index) async {
          //       Subtitle subtitle = _subtitleItem.controller.subtitles[index];

          //       _subtitleOptionsNotifier.value.subtitleDelay =
          //           subtitle.end.inMilliseconds -
          //               _positionNotifier.value.inMilliseconds;

          //       SubtitleOptions subtitleOptions = appModel.subtitleOptions;
          //       subtitleOptions.subtitleDelay = subtitle.end.inMilliseconds -
          //           _positionNotifier.value.inMilliseconds;
          //        appModel.setSubtitleOptions(subtitleOptions);

          //       refreshSubtitleWidget();
          //     });

          await dialogSmartResume();
        },
      ),
      JidoujishoBottomSheetOption(
        label: playerOptionSubtitleAppearance,
        icon: Icons.text_fields,
        action: () async {
          await dialogSmartPause();
          // await showSubtitleOptionsDialog(context, subtitleOptionsNotifier);
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
          // await showBlurWidgetOptionsDialog(context, _blurOptionsNotifier);
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

  List<JidoujishoBottomSheetOption> getAudioDialogOptions(
      Map<int, String> embeddedTracks, int audioTrack) {
    List<JidoujishoBottomSheetOption> options = [];

    embeddedTracks.forEach((index, label) {
      JidoujishoBottomSheetOption option = JidoujishoBottomSheetOption(
        label: '$playerOptionAudio - $label',
        icon: Icons.music_note_outlined,
        active: audioTrack == index,
        action: () {
          _playerController.setAudioTrack(index);
        },
      );

      options.add(option);
    });

    return options;
  }

  String getSubtitleLabel(SubtitleItem item, Map<int, String> embeddedTracks) {
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

  List<JidoujishoBottomSheetOption> getSubtitleDialogOptions(
      Map<int, String> embeddedTracks) {
    List<JidoujishoBottomSheetOption> options = [];
    for (SubtitleItem item in _subtitleItems) {
      JidoujishoBottomSheetOption option = JidoujishoBottomSheetOption(
        label: getSubtitleLabel(item, embeddedTracks),
        icon: Icons.subtitles_outlined,
        active: _subtitleItem == item,
        action: () {
          _subtitleItem = item;
          if (!_subtitleItem.controller.initialized) {
            _subtitleItem.controller.initial();
          }
          _currentSubtitle.value = null;
          refreshSubtitleWidget();
        },
      );

      options.add(option);
    }

    options.add(JidoujishoBottomSheetOption(
        label: getSubtitleLabel(_emptySubtitleItem, embeddedTracks),
        icon: Icons.subtitles_off_outlined,
        active: _subtitleItem == _emptySubtitleItem,
        action: () {
          _subtitleItem = _emptySubtitleItem;
          _currentSubtitle.value = null;
          refreshSubtitleWidget();
        }));

    return options;
  }

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
          if (appModel.isPlayerOrientationPortrait) {
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
          } else {
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
          }
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

          dialogSmartPause();
          await openCardCreator(subtitles);
        },
      ),
    ];

    return options;
  }

  Widget buildSubtitleArea() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: menuHeight + 8),
        child: buildSubtitle(),
      ),
    );
  }

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
          focusNode: dragToSelectFocusNode,
          toolbarOptions: const ToolbarOptions(),
          onSelectionChanged: (selection, cause) {
            String newTerm = selection.textInside(subtitleText);
            startDragSubtitlesTimer(newTerm);
          },
        ),
      ],
    );
  }

  Paint get subtitlePaintStyle => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..color = Colors.black.withOpacity(0.75);

  TextStyle get subtitleOutlineStyle => GoogleFonts.getFont(
        _subtitleOptionsNotifier.value.fontName,
        fontSize: _subtitleOptionsNotifier.value.fontSize,
        foreground: subtitlePaintStyle,
      );

  TextStyle get subtitleTextStyle => GoogleFonts.getFont(
        _subtitleOptionsNotifier.value.fontName,
        fontSize: _subtitleOptionsNotifier.value.fontSize,
        color: Colors.white,
      );

  List<InlineSpan> getSubtitleSpans(String text) {
    List<InlineSpan> spans = [];

    text.runes.forEachIndexed((index, rune) {
      String character = String.fromCharCode(rune);
      spans.add(
        TextSpan(
          text: character,
          style: subtitleTextStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              String searchTerm = text.substring(index);
              setSearchTerm(searchTerm);
            },
        ),
      );
    });

    return spans;
  }

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

  void cancelDragSubtitlesTimer() {
    if (_dragSubtitlesTimer != null) {
      _dragSubtitlesTimer?.cancel();
    }
  }

  void startDragSubtitlesTimer(String newTerm) {
    cancelDragSubtitlesTimer();
    _dragSubtitlesTimer = Timer(const Duration(milliseconds: 500), () {
      if (newTerm.isNotEmpty) {
        setSearchTerm(newTerm);
      }
      refreshSubtitleWidget();
    });
  }

  void setSearchTerm(String searchTerm) {
    searchDictionaryResult(
      searchTerm: searchTerm,
      position: JidoujishoPopupPosition.topTwoThirds,
    );
  }

  Future<void> openCardCreator(List<Subtitle> subtitles) async {
    // setDictionaryMessage(appModel.translate("player_prepare_export"));

    // imageCache!.clear();
    // AnkiExportParams initialParams = await prepareExportParams(subtitles);

    // searchTerm.value = "";

    // ClipboardListener.removeListener(copyClipboardAction);

    // clearDictionaryMessage();
    // dialogSmartPause();

    // await navigateToCreator(
    //     context: context,
    //     appModel: appModel,
    //     initialParams: initialParams,
    //     backgroundColor: dictionaryColor,
    //     appBarColor: Colors.transparent,
    //     hideActions: true,
    //     popOnExport: true,
    //     exportCallback: () {
    //       Navigator.of(context).pop();
    //       String lastDeck = appModel.getLastAnkiDroidDeck();
    //       setDictionaryMessage(
    //         "deckExport://$lastDeck",
    //         duration: const Duration(seconds: 3),
    //       );
    //     });

    // dialogSmartResume(isSmartFocus: true);

    // await Clipboard.setData(const ClipboardData(text: ""));
    // ClipboardListener.addListener(copyClipboardAction);
  }

  void refreshSubtitleWidget() {
    Subtitle? holder = _currentSubtitle.value;
    _currentSubtitle.value = null;
    _currentSubtitle.value = holder;
  }

  void startHideTimer() {
    _menuHideTimer = Timer(const Duration(seconds: 3), toggleMenuVisibility);
  }

  void cancelHideTimer() {
    _menuHideTimer?.cancel();
    _isMenuHidden.value = false;
  }

  void toggleMenuVisibility() async {
    _menuHideTimer?.cancel();
    _isMenuHidden.value = !_isMenuHidden.value;
    if (!_isMenuHidden.value) {
      startHideTimer();
    }
  }

  Future<void> playPause() async {
    _autoPauseFlag = false;
    _dialogSmartPaused = false;

    final isFinished = _playerController.value.isEnded;

    if (_playerController.value.isPlaying) {
      _playPauseAnimationController.reverse();
      startHideTimer();

      await _playerController.pause();
    } else {
      cancelHideTimer();

      if (!_playerController.value.isInitialized) {
        _playerController.initialize().then((_) async {
          await _playerController.play();
          _playPauseAnimationController.forward();
        });
      } else {
        _playPauseAnimationController.forward();

        await _playerController.play();

        if (isFinished) {
          await _playerController.stop();
          await _playerController.play();
          await Future.delayed(const Duration(seconds: 2), () async {
            await _playerController.seekTo(Duration.zero);
          });
        }
      }
    }
  }

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

  Future<void> dialogSmartPause() async {
    if (_playerController.value.isPlaying) {
      _dialogSmartPaused = true;
      await _playerController.pause();
    }
  }

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
    }

    _dialogSmartPaused = false;
  }

  Future<void> importExternalSubtitle() async {
    String pickText = appModel.translate('dialog_select');
    String cancelText = appModel.translate('dialog_cancel');

    Iterable<String>? filePaths = await FilesystemPicker.open(
      title: '',
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
    refreshSubtitleWidget();
  }
}

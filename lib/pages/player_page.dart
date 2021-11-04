import 'dart:async';
import 'dart:io';

import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/language/tap_to_select.dart';
import 'package:chisa/media/media_history.dart';
import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/blur_widget.dart';
import 'package:chisa/util/bottom_sheet_dialog.dart';
import 'package:chisa/util/dictionary_scrollable_widget.dart';
import 'package:chisa/util/export_paths.dart';
import 'package:chisa/util/subtitle_options.dart';
import 'package:chisa/util/time_format.dart';
import 'package:chisa/util/transcript_dialog.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakelock/wakelock.dart';

class PlayerPage extends StatefulWidget {
  final PlayerLaunchParams params;

  const PlayerPage({
    Key? key,
    required this.params,
  }) : super(key: key);

  @override
  PlayerPageState createState() => PlayerPageState();
}

class PlayerPageState extends State<PlayerPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AppModel appModel;

  late VlcPlayerController playerController;
  SubtitleController? subtitleController;
  late AnimationController playPauseIconAnimationController;

  List<SubtitleController> allSubtitleControllers = [];

  final ValueNotifier<int> latestResultEntryIndex = ValueNotifier<int>(0);
  DictionarySearchResult? latestResult;

  final ValueNotifier<Subtitle?> currentSubtitle =
      ValueNotifier<Subtitle?>(null);
  final ValueNotifier<Subtitle?> currentSubtitleMemory =
      ValueNotifier<Subtitle?>(null);
  ValueNotifier<Duration> position = ValueNotifier<Duration>(Duration.zero);
  ValueNotifier<Duration> duration = ValueNotifier<Duration>(Duration.zero);
  ValueNotifier<bool> isPlaying = ValueNotifier<bool>(true);
  ValueNotifier<bool> isEnded = ValueNotifier<bool>(false);

  late ValueNotifier<BlurWidgetOptions> blurWidgetOptionsNotifier;
  late ValueNotifier<SubtitleOptions> subtitleOptionsNotifier;

  Color menuColor = const Color(0xcc424242);
  Color dictionaryColor = Colors.grey.shade800.withOpacity(0.6);
  double menuHeight = 48;

  final ValueNotifier<bool> isMenuHidden = ValueNotifier<bool>(false);
  Timer? menuHideTimer;
  Timer? dragSearchTimer;

  bool isPlayerReady = false;
  bool unhideDuringInitFlag = false;

  bool tapToSelectMode = true;
  double subtitleFontSize = 24;
  int audioAllowance = 10;
  int subtitlesDelay = 0;
  final FocusNode dragToSelectFocusNode = FocusNode();

  DictionarySearchResult? searchResult;
  ValueNotifier<String> searchTerm = ValueNotifier<String>("");
  ValueNotifier<Subtitle?> shadowingSubtitle = ValueNotifier<Subtitle?>(null);
  ValueNotifier<Subtitle?> listeningSubtitle = ValueNotifier<Subtitle?>(null);
  String searchMessage = "";

  Future<bool> onWillPop() async {
    if (playerController.value.isEnded) {
      Navigator.pop(context, true);
    }

    Widget alertDialog = AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: Text(
        appModel.translate("dialog_exit_player"),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            appModel.translate("dialog_yes"),
            style: TextStyle(
              color: Theme.of(context).focusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
        TextButton(
          child: Text(
            appModel.translate("dialog_no"),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () async {
            Navigator.pop(context, false);
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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    playerController = preparePlayerController(widget.params);
    playPauseIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
    );

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      allSubtitleControllers = await prepareSubtitleControllers(widget.params);
      for (SubtitleController controller in allSubtitleControllers) {
        await controller.initial();
      }

      if (allSubtitleControllers.isNotEmpty) {
        subtitleController = allSubtitleControllers.first;
      }

      playerController.addListener(listener);
      isPlayerReady = true;

      blurWidgetOptionsNotifier =
          ValueNotifier<BlurWidgetOptions>(appModel.getBlurWidgetOptions());
      subtitleOptionsNotifier =
          ValueNotifier<SubtitleOptions>(appModel.getSubtitleOptions());

      setState(() {});
      startHideTimer();

      Future.delayed(const Duration(seconds: 3), () {
        unhideDuringInitFlag = true;
      });
    });
  }

  void cancelHideTimer() {
    menuHideTimer!.cancel();
    isMenuHidden.value = false;
  }

  void startHideTimer() {
    menuHideTimer = Timer(const Duration(seconds: 3), toggleMenuVisibility);
  }

  void cancelDragSubtitlesTimer() {
    if (dragSearchTimer != null) {
      dragSearchTimer!.cancel();
    }
  }

  void startDragSubtitlesTimer(String newTerm) {
    cancelDragSubtitlesTimer();
    dragSearchTimer = Timer(const Duration(milliseconds: 500), () {
      setSearchTerm(newTerm);
    });
  }

  void setSearchTerm(String newTerm) {
    searchTerm.value = newTerm;
  }

  Widget buildDictionary() {
    return ValueListenableBuilder<String>(
      valueListenable: searchTerm,
      builder: (BuildContext context, String searchTerm, _) {
        if (searchTerm.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 96,
            ),
            child: GestureDetector(
              onTap: () {
                setSearchTerm("");
              },
              child: Container(
                color: dictionaryColor,
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<DictionarySearchResult>(
                  future: appModel.searchDictionary(
                    searchTerm,
                    contextSource: playerController.dataSource,
                    contextPosition: playerController.value.duration.inSeconds,
                    contextMediaTypeName:
                        widget.params.mediaSource.getIdentifier(),
                  ), // a previously-obtained Future<String> or null
                  builder: (BuildContext context,
                      AsyncSnapshot<DictionarySearchResult> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return buildDictionarySearching();
                      default:
                        latestResult = snapshot.data;

                        dragToSelectFocusNode.unfocus();

                        if (!snapshot.hasData ||
                            latestResult!.entries.isEmpty) {
                          return buildDictionaryNoMatch();
                        } else {
                          return buildDictionaryMatch();
                        }
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildDictionaryMatch() {
    latestResultEntryIndex.value = 0;

    return DictionaryScrollableWidget.fromLatestResult(
      appModel: appModel,
      result: latestResult!,
      indexNotifier: latestResultEntryIndex,
    );
  }

  Widget buildDictionarySearching() {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: appModel.translate("dictionary_searching_before"),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              color: Colors.grey[300],
            ),
          ),
          TextSpan(
            text: searchTerm.value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              color: Colors.grey[300],
            ),
          ),
          TextSpan(
            text: appModel.translate("dictionary_searching_after"),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          WidgetSpan(
            child: SizedBox(
              height: 12,
              width: 12,
              child: JumpingDotsProgressIndicator(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDictionaryNoMatch() {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: appModel.translate("dictionary_nomatch_before"),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              color: Colors.grey[300],
            ),
          ),
          TextSpan(
            text: searchTerm.value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              color: Colors.grey[300],
            ),
          ),
          TextSpan(
            text: appModel.translate("dictionary_nomatch_after"),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  VlcPlayerController preparePlayerController(PlayerLaunchParams params) {
    int startTime = widget.params.mediaHistoryItem.currentProgress;

    List<String> advancedParams = ["--start-time=$startTime"];
    List<String> audioParams = ["--audio-track=0", "--sub-track=99999"];
    if (params.audioPath != null) {
      audioParams.add("--input-slave=${params.audioPath}");
    }

    VlcAdvancedOptions advanced = VlcAdvancedOptions(advancedParams);
    VlcAudioOptions audio = VlcAudioOptions(audioParams);

    VlcPlayerOptions options = VlcPlayerOptions(
      advanced: advanced,
      audio: audio,
    );

    switch (params.getMode()) {
      case MediaLaunchMode.file:
        return VlcPlayerController.file(
          params.videoFile!,
          options: options,
        );
      case MediaLaunchMode.network:
        return VlcPlayerController.network(
          params.networkPath!,
          options: options,
        );
    }
  }

  Future<List<SubtitleController>> prepareSubtitleControllers(
      PlayerLaunchParams params) async {
    return await params.mediaSource.provideSubtitles(params);
  }

  @override
  void dispose() {
    playerController.removeListener(listener);
    super.dispose();
  }

  void listener() async {
    if (!mounted) return;

    if (playerController.value.isInitialized) {
      position.value = playerController.value.position;
      duration.value = playerController.value.duration;

      isPlaying.value = playerController.value.isPlaying;
      isEnded.value = playerController.value.isEnded;

      if (subtitleController != null) {
        Subtitle? newSubtitle =
            subtitleController!.durationSearch(position.value);

        if (currentSubtitle.value != newSubtitle) {
          currentSubtitle.value = newSubtitle;
          // For remembering the last subtitle even if it has disappeared.
          if (newSubtitle != null) {
            currentSubtitleMemory.value = newSubtitle;
          }
        }
      }

      if (shadowingSubtitle.value != null) {
        if (position.value <
                shadowingSubtitle.value!.start - const Duration(seconds: 15) ||
            position.value > shadowingSubtitle.value!.end) {
          playerController.seekTo(shadowingSubtitle.value!.start);
        }
      }

      if (listeningSubtitle.value != null) {
        if (position.value <
                listeningSubtitle.value!.start - const Duration(seconds: 15) ||
            position.value >
                listeningSubtitle.value!.end + const Duration(seconds: 5)) {
          listeningSubtitle.value = null;
        }
      }

      updateHistory();
    }
  }

  Future<void> updateHistory() async {
    MediaHistory history =
        widget.params.mediaSource.mediaType.getMediaHistory(appModel);
    MediaHistoryItem item = widget.params.mediaHistoryItem;
    item.currentProgress = position.value.inSeconds;
    item.completeProgress = duration.value.inSeconds;

    if (item.completeProgress != 0) {
      await history.addItem(item);
    }
  }

  Widget buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).focusColor),
          ),
        ),
      ),
    );
  }

  Widget buildPlayer() {
    return Center(
      child: VlcPlayer(
        controller: playerController,
        aspectRatio: 16 / 9,
        placeholder: buildPlaceholder(),
      ),
    );
  }

  Widget buildPlayerArea() {
    return Container(
      alignment: Alignment.center,
      height: double.maxFinite,
      width: double.maxFinite,
      color: Colors.black,
      child: buildPlayer(),
    );
  }

  Widget buildSubtitleArea() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: menuHeight + 8),
        child: buildSubtitle(),
      ),
    );
  }

  Widget buildSubtitle() {
    return MultiValueListenableBuider(
      // Add all ValueListenables here.
      valueListenables: [
        currentSubtitle,
        listeningSubtitle,
        isPlaying,
      ],
      builder: (context, values, _) {
        Subtitle? currentSubtitle = values.elementAt(0);
        Subtitle? listeningSubtitle = values.elementAt(1);
        bool isPlaying = values.elementAt(2);

        if (currentSubtitle == null) {
          return const SizedBox.shrink();
        }

        if (appModel.getListeningComprehensionMode() &&
            !(listeningSubtitle != null || !isPlaying)) {
          return const SizedBox.shrink();
        }

        if (appModel.getPlayerDragToSelectMode()) {
          return tapToSelectWidget(currentSubtitle);
        } else {
          return dragToSelectSubtitle(currentSubtitle);
        }
      },
    );
  }

  Widget getOutlineText(String character) {
    return Text(
      character,
      style: TextStyle(
        fontSize: subtitleFontSize,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.black.withOpacity(0.75),
      ),
    );
  }

  Widget getText(String character, int index) {
    return InkWell(
      onTap: () async {
        String word = await appModel
            .getCurrentLanguage()
            .wordFromIndex(currentSubtitle.value!.data, index);

        setSearchTerm(word);
      },
      child: Text(
        character,
        style: TextStyle(
          fontSize: subtitleFontSize,
        ),
      ),
    );
  }

  Widget tapToSelectWidget(Subtitle subtitle) {
    String subtitleText = subtitle.data;

    List<List<String>> lines = getLinesFromCharacters(
      context,
      subtitleText.split(''),
      subtitleFontSize,
    );

    List<Widget> rows = [];
    List<Widget> outlinedRows = [];
    for (List<String> line in lines) {
      List<Widget> textWidgets = [];
      List<Widget> outlinedTextWidgets = [];

      for (int i = 0; i < line.length; i++) {
        String character = line[i];
        outlinedTextWidgets.add(getOutlineText(character));
        textWidgets.add(getText(character, i));
      }

      outlinedRows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: outlinedTextWidgets,
        ),
      );
      rows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: textWidgets,
        ),
      );
    }

    return Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: outlinedRows,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: rows,
        ),
      ],
    );
  }

  Widget dragToSelectSubtitle(Subtitle subtitle) {
    String subtitleText = subtitle.data;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        SelectableText(
          subtitleText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleFontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.black.withOpacity(0.75),
          ),
          enableInteractiveSelection: false,
        ),
        SelectableText(
          subtitleText,
          textAlign: TextAlign.center,
          onSelectionChanged: (selection, cause) {
            String newTerm = selection.textInside(subtitleText);
            startDragSubtitlesTimer(newTerm);
          },
          style: TextStyle(
            fontSize: subtitleFontSize,
            color: Colors.white,
          ),
          focusNode: dragToSelectFocusNode,
          toolbarOptions: const ToolbarOptions(
            copy: false,
            cut: false,
            selectAll: false,
            paste: false,
          ),
        ),
      ],
    );
  }

  // Widget buildDictionaryMatch() {
  //   return Container(padding: EdgeInsets.fromLTRB(16, 16, 16, menuHeight + 16, child: DictionaryScrollableWidget(appModel: appModel, dictionary: appModel.getCurrentDictionary(), dictionaryFormat: appModel.getDictionaryFormatFromName(appModel.getCurrentDictionary().formatName),
  // }

  void toggleMenuVisibility() async {
    SystemChrome.setEnabledSystemUIOverlays([]);

    menuHideTimer!.cancel();
    isMenuHidden.value = !isMenuHidden.value;
    if (!isMenuHidden.value) {
      startHideTimer();
    }
  }

  Widget buildMenuArea() {
    return Align(
      alignment: Alignment.topCenter,
      child: ValueListenableBuilder(
        valueListenable: isMenuHidden,
        builder: (BuildContext context, bool value, _) {
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
        color: menuColor,
        child: GestureDetector(
          onTap: () {
            toggleMenuVisibility();
          },
          child: AbsorbPointer(
            absorbing: isMenuHidden.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildPlayButton(),
                buildDurationAndPosition(),
                buildSlider(),
                buildAudioSubtitlesButton(),
                buildOptionsButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Subtitle? getNearestSubtitle() {
    if (currentSubtitle.value != null) {
      return currentSubtitle.value!;
    } else {
      if (subtitleController == null || subtitleController!.subtitles.isEmpty) {
        return null;
      }

      Subtitle? lastSubtitle;
      for (Subtitle subtitle in subtitleController!.subtitles) {
        if (position.value < subtitle.start) {
          return lastSubtitle;
        }

        lastSubtitle = subtitle;
      }

      return null;
    }
  }

  Future<void> playPause() async {
    final isFinished = playerController.value.isEnded;

    if (playerController.value.isPlaying) {
      playPauseIconAnimationController.reverse();
      startHideTimer();
      await playerController.pause();
    } else {
      cancelHideTimer();

      if (!playerController.value.isInitialized) {
        playerController.initialize().then((_) async {
          await playerController.play();
          playPauseIconAnimationController.forward();
        });
      } else {
        if (isFinished) {
          await playerController.stop();
        }
        playPauseIconAnimationController.forward();
        await playerController.play();

        if (isFinished) {
          Future.delayed(const Duration(seconds: 3), () async {
            await playerController.seekTo(Duration.zero);
          });
        }
      }
    }
  }

  Widget buildCentralPlayPause() {
    if (playerController.value.isEnded) {
      Wakelock.disable();
    } else {
      Wakelock.enable();
    }

    Widget getIcon() {
      if (playerController.value.isEnded) {
        return const Icon(Icons.replay, size: 32.0);
      } else {
        if (!playerController.value.isInitialized) {
          return const Icon(Icons.play_arrow, color: Colors.transparent);
        }

        return AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: playPauseIconAnimationController,
          size: 32.0,
        );
      }
    }

    return MultiValueListenableBuider(
      // Add all ValueListenables here.
      valueListenables: [
        isPlaying,
        isEnded,
      ],
      builder: (context, values, _) {
        bool playing = values.elementAt(0);
        bool ended = values.elementAt(1);

        return Center(
          child: AnimatedOpacity(
            opacity: unhideDuringInitFlag && (!playing || ended) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(48.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
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

  Widget buildScrubDetectors() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onDoubleTap: () async {
              cancelHideTimer();
              await playerController
                  .seekTo(position.value - const Duration(seconds: 10));

              startHideTimer();
            },
            child: Container(
              color: Colors.red.withOpacity(0.0),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onDoubleTap: () async {
              cancelHideTimer();
              await playerController
                  .seekTo(position.value + const Duration(seconds: 10));

              startHideTimer();
            },
            child: Container(
              color: Colors.blue.withOpacity(0.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGestureArea() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) async {
        if (details.delta.dx.abs() > 10) {
          Subtitle? nearestSubtitle = getNearestSubtitle();

          listeningSubtitle.value = nearestSubtitle;
          await playerController.seekTo(nearestSubtitle!.start);
        }
      },
      onVerticalDragUpdate: (details) async {
        if (details.delta.dy.abs() > 10) {
          await openTranscript(
            context: context,
            subtitles: subtitleController?.subtitles ?? [],
            currentSubtitle: getNearestSubtitle(),
            regexFilter: null,
            onTapCallback: (int selectedIndex) async {
              await playerController
                  .seekTo(subtitleController!.subtitles[selectedIndex].start);
            },
          );
        }
      },
      onTap: () {
        toggleMenuVisibility();
      },
      child: Stack(
        children: [
          buildScrubDetectors(),
        ],
      ),
    );
  }

  Widget buildBlurWidget() {
    return ResizeableWidget(
      context: context,
      blurWidgetNotifier: blurWidgetOptionsNotifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);
    super.build(context);

    if (!isPlayerReady) {
      return buildPlaceholder();
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Theme(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          body: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              buildPlayerArea(),
              buildGestureArea(),
              buildBlurWidget(),
              buildMenuArea(),
              buildCentralPlayPause(),
              buildSubtitleArea(),
              buildDictionary(),
            ],
          ),
        ),
        data: appModel.getDarkTheme(context),
      ),
    );
  }

  Widget buildDurationAndPosition() {
    return MultiValueListenableBuider(
      valueListenables: [
        duration,
        position,
        isEnded,
        shadowingSubtitle,
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
            duration = shadowingSubtitle.end;
          }

          if (duration.inHours == 0) {
            var strDuration = duration.toString().split('.')[0];
            return "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
          } else {
            return duration.toString().split('.')[0];
          }
        }

        return InkWell(
          child: Text(
            "${getPositionText()} / ${getDurationText()}",
            style: TextStyle(
              color: (shadowingSubtitle != null)
                  ? Theme.of(context).focusColor
                  : Colors.white,
            ),
          ),
          onTap: () {
            setShadowingSubtitle();
          },
        );
      },
    );
  }

  Widget buildPlayButton() {
    return MultiValueListenableBuider(
      // Add all ValueListenables here.
      valueListenables: [
        isPlaying,
        isEnded,
      ],
      builder: (context, values, _) {
        bool playing = values.elementAt(0);
        bool ended = values.elementAt(1);

        return IconButton(
          color: Colors.white,
          icon: ended
              ? const Icon(Icons.replay)
              : playing
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
          onPressed: () async {
            cancelHideTimer();

            await playPause();
          },
        );
      },
    );
  }

  Widget buildAudioSubtitlesButton() {
    return IconButton(
      color: Colors.white,
      icon: const Icon(Icons.queue_music_outlined),
      onPressed: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => BottomSheetDialog(
            options: getAudioSubtitles(),
          ),
        );
      },
    );
  }

  List<BottomSheetDialogOption> getBlurOptions() {
    List<BottomSheetDialogOption> options = [
      BottomSheetDialogOption(
        label: appModel.translate("player_option_blur_use"),
        active: appModel.getBlurWidgetOptions().visible,
        icon: appModel.getBlurWidgetOptions().visible
            ? Icons.blur_on_outlined
            : Icons.blur_off_outlined,
        action: () async {
          BlurWidgetOptions blurWidgetOptions = appModel.getBlurWidgetOptions();
          blurWidgetOptions.visible = !blurWidgetOptions.visible;
          await appModel.setBlurWidgetOptions(blurWidgetOptions);
          blurWidgetOptionsNotifier.value = blurWidgetOptions;
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_blur_options"),
        icon: Icons.blur_circular_sharp,
        action: () async {
          await showBlurWidgetOptionsDialog(context, blurWidgetOptionsNotifier);
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_blur_reset"),
        icon: Icons.timer_sharp,
        action: () async {
          BlurWidgetOptions blurWidgetOptions = appModel.getBlurWidgetOptions();
          blurWidgetOptions.left = -1;
          blurWidgetOptions.top = -1;
          blurWidgetOptions.width = 200;
          blurWidgetOptions.height = 200;

          await appModel.setBlurWidgetOptions(blurWidgetOptions);
          blurWidgetOptionsNotifier.value = blurWidgetOptions;
        },
      ),
    ];

    return options;
  }

  List<BottomSheetDialogOption> getAudioSubtitles() {
    List<BottomSheetDialogOption> options = [
      BottomSheetDialogOption(
        label: appModel.translate("player_option_text_filter"),
        active: appModel.getUseRegexFilter(),
        icon: appModel.getUseRegexFilter()
            ? Icons.do_disturb_on_outlined
            : Icons.do_disturb_off_outlined,
        action: () async {
          await appModel.toggleUseRegexFilter();
          refreshSubtitleWidget();
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_blur_preferences"),
        icon: Icons.blur_circular_sharp,
        action: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => BottomSheetDialog(
              options: getBlurOptions(),
            ),
          );
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_subtitle_appearance"),
        icon: Icons.timer_sharp,
        action: () async {
          await showSubtitleOptionsDialog(context, subtitleOptionsNotifier);
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_load_subtitles"),
        icon: Icons.upload_file,
        action: () async {},
      ),
    ];

    return options;
  }

  Widget buildOptionsButton() {
    return IconButton(
      color: Colors.white,
      icon: const Icon(Icons.more_vert),
      onPressed: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => BottomSheetDialog(
            options: getOptions(),
          ),
        );
      },
    );
  }

  void refreshSubtitleWidget() {
    Subtitle? holder = currentSubtitle.value;
    currentSubtitle.value = null;
    currentSubtitle.value = holder;
  }

  void refreshDictionaryWidget() {
    String holder = searchTerm.value;
    searchTerm.value = "";
    searchTerm.value = holder;
  }

  void setShadowingSubtitle() {
    if (shadowingSubtitle.value != null) {
      shadowingSubtitle.value = null;
    } else {
      if (subtitleController == null || subtitleController!.subtitles.isEmpty) {
        shadowingSubtitle.value = Subtitle(
          data: "",
          start: position.value - Duration(seconds: audioAllowance),
          end: position.value + Duration(seconds: audioAllowance),
          index: 0,
        );
      } else {
        shadowingSubtitle.value = getNearestSubtitle();
      }
    }
  }

  List<BottomSheetDialogOption> getOptions() {
    List<BottomSheetDialogOption> options = [
      BottomSheetDialogOption(
        label: appModel.translate("player_option_shadowing"),
        icon: Icons.loop,
        active: shadowingSubtitle.value != null,
        action: () {
          setShadowingSubtitle();
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_definition_focus"),
        icon: (appModel.getPlayerDefinitionFocusMode())
            ? Icons.flash_on
            : Icons.flash_off,
        active: appModel.getPlayerDefinitionFocusMode(),
        action: () async {
          await appModel.togglePlayerDefinitionFocusMode();
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_listening_comprehension"),
        icon: (appModel.getListeningComprehensionMode())
            ? Icons.hearing
            : Icons.hearing_disabled,
        active: appModel.getListeningComprehensionMode(),
        action: () async {
          await appModel.toggleListeningComprehensionMode();
          refreshSubtitleWidget();
        },
      ),
      BottomSheetDialogOption(
        label: (appModel.getPlayerDragToSelectMode())
            ? appModel.translate("player_option_drag_to_select")
            : appModel.translate("player_option_tap_to_select"),
        icon: (appModel.getPlayerDragToSelectMode())
            ? Icons.select_all
            : Icons.touch_app,
        action: () async {
          await appModel.togglePlayerDragToSelectMode();
          refreshSubtitleWidget();
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_dictionary_menu"),
        icon: Icons.auto_stories,
        action: () async {
          await appModel.showDictionaryMenu(context);
          refreshDictionaryWidget();
        },
      ),
      // BottomSheetDialogOption(
      //   label: appModel.translate("player_option_cast_video"),
      //   icon: Icons.cast_connected,
      //   action: () {
      //   },
      // ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_share_subtitle"),
        icon: Icons.share,
        action: () {
          Share.share(getNearestSubtitle()?.data ?? "");
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_export"),
        icon: Icons.mobile_screen_share,
        action: () async {
          List<Subtitle> subtitles = [];
          Subtitle? singleSubtitle = getNearestSubtitle();
          if (singleSubtitle != null) {
            subtitles.add(singleSubtitle);
          }
          await openCardCreator(subtitles);
        },
      ),
    ];

    return options;
  }

  Future<AnkiExportParams> prepareExportParams(List<Subtitle> subtitles) async {
    String sentence = "";
    String word = "";
    String meaning = "";
    String reading = "";

    for (Subtitle subtitle in subtitles) {
      sentence += "${subtitle.data}\n";
    }
    if (subtitles.isNotEmpty) {
      String removeLastNewline(String n) => n = n.substring(0, n.length - 1);
      sentence = removeLastNewline(sentence);
    }

    if (latestResult != null) {
      DictionaryEntry entry =
          latestResult!.entries[latestResultEntryIndex.value];
      word = entry.word;
      meaning = entry.meaning;
      reading = entry.reading;
    }

    List<File> imageFiles = [];

    File? imageFile;
    File? audioFile;

    try {
      imageFiles = await exportImages(subtitles);
      if (imageFiles.isNotEmpty) {
        imageFile = imageFiles.first;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    try {
      audioFile = await exportCurrentAudio(
        subtitles,
        subtitleOptionsNotifier.value.audioAllowance,
        subtitleOptionsNotifier.value.subtitleDelay,
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    await Future.delayed(const Duration(seconds: 1), () {});

    return AnkiExportParams(
      sentence: sentence,
      word: word,
      meaning: meaning,
      reading: reading,
      imageFiles: imageFiles,
      imageFile: imageFile,
      audioFile: audioFile,
    );
  }

  Future<List<File>> exportImages(
    List<Subtitle> subtitles,
  ) async {
    List<File> imageFiles = [];

    for (int i = 0; i < subtitles.length; i++) {
      Subtitle subtitle = subtitles[i];

      String outputPath = getPreviewImageMultiPath(i);
      File imageFile = File(outputPath);
      if (imageFile.existsSync()) {
        imageFile.deleteSync();
      }

      int msStart = subtitle.start.inMilliseconds;
      int msEnd = subtitle.end.inMilliseconds;
      int msMean = ((msStart + msEnd) / 2).floor();
      Duration currentTime = Duration(milliseconds: msMean);
      String formatted = getTimestampFromDuration(currentTime);

      String inputPath = "";

      switch (widget.params.getMode()) {
        case MediaLaunchMode.file:
          inputPath = widget.params.videoFile!.path;
          break;
        case MediaLaunchMode.network:
          inputPath = widget.params.networkPath!;
          break;
      }

      String command =
          "-loglevel verbose -ss $formatted -y -i \"$inputPath\" -frames:v 1 -q:v 2 \"$outputPath\"";

      await FFmpegKit.executeAsync(command, (session) async {
        debugPrint(await session.getOutput());
      });

      await precacheImage(FileImage(imageFile), context);

      imageFiles.add(imageFile);
    }

    return imageFiles;
  }

  Future<File> exportCurrentAudio(
    List<Subtitle> subtitles,
    int audioAllowance,
    int subtitleDelay,
  ) async {
    File audioFile = File(getPreviewAudioPath());
    String outputPath = audioFile.path;
    if (audioFile.existsSync()) {
      audioFile.deleteSync();
    }

    String timeStart = "";
    String timeEnd = "";
    String audioIndex = "${playerController.value.activeAudioTrack - 1}";

    Duration allowance = Duration(milliseconds: audioAllowance);
    Duration delay = Duration(milliseconds: subtitleDelay);
    Duration adjustedStart = subtitles.first.start + delay - allowance;
    Duration adjustedEnd = subtitles.last.end + delay + allowance;

    timeStart = getTimestampFromDuration(adjustedStart);
    timeEnd = getTimestampFromDuration(adjustedEnd);

    String inputPath = "";

    switch (widget.params.getMode()) {
      case MediaLaunchMode.file:
        inputPath = widget.params.videoFile!.path;
        break;
      case MediaLaunchMode.network:
        inputPath = widget.params.networkPath!;
        break;
    }

    String command =
        "-loglevel quiet -ss $timeStart -to $timeEnd -y -i \"$inputPath\" -map 0:a:$audioIndex \"$outputPath\"";

    await FFmpegKit.executeAsync(command, (session) async {
      debugPrint(await session.getOutput());
    });

    return audioFile;
  }

  Future<void> openCardCreator(List<Subtitle> subtitles) async {
    AnkiExportParams initialParams = await prepareExportParams(subtitles);

    Subtitle? subtitleHolder = currentSubtitle.value;
    currentSubtitle.value = null;
    searchTerm.value = "";

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => CreatorPage(
          initialParams: initialParams,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
          appBarColor: Colors.transparent,
        ),
      ),
    );

    currentSubtitle.value = subtitleHolder;
  }

  Widget buildSlider() {
    return MultiValueListenableBuider(
      // Add all ValueListenables here.
      valueListenables: [
        duration,
        position,
        isEnded,
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
            activeColor: Theme.of(context).focusColor,
            inactiveColor: Theme.of(context).unselectedWidgetColor,
            value: sliderValue,
            min: 0.0,
            max: (!validPosition || isEnded)
                ? 1.0
                : playerController.value.duration.inSeconds.toDouble(),
            onChangeStart: (value) {
              cancelHideTimer();
            },
            onChangeEnd: (value) {
              startHideTimer();
            },
            onChanged: validPosition
                ? (progress) {
                    cancelHideTimer();
                    if (!isEnded) {
                      sliderValue = progress.floor().toDouble();
                      playerController.setTime(sliderValue.toInt() * 1000);
                    }
                  }
                : null,
          ),
        );
      },
    );
  }
}

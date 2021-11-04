import 'dart:async';

import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/language/tap_to_select.dart';
import 'package:chisa/media/media_history.dart';
import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/bottom_sheet_dialog.dart';
import 'package:chisa/util/dictionary_scrollable_widget.dart';
import 'package:chisa/util/transcript_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:subtitle/subtitle.dart';

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
    with AutomaticKeepAliveClientMixin {
  late AppModel appModel;

  late VlcPlayerController playerController;
  SubtitleController? subtitleController;

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

  Color menuColor = const Color(0xcc424242);
  Color dictionaryColor = Colors.grey.shade800.withOpacity(0.6);
  double menuHeight = 48;

  final ValueNotifier<bool> isMenuHidden = ValueNotifier<bool>(false);
  Timer? menuHideTimer;
  Timer? dragSearchTimer;

  bool isPlayerReady = false;

  bool tapToSelectMode = true;
  double subtitleFontSize = 24;
  FocusNode dragToSelectFocusNode = FocusNode();

  DictionarySearchResult? searchResult;
  ValueNotifier<String> searchTerm = ValueNotifier<String>("");
  ValueNotifier<Subtitle?> shadowingSubtitle = ValueNotifier<Subtitle?>(null);
  String searchMessage = "";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    playerController = preparePlayerController(widget.params);

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

      setState(() {});
      startHideTimer();
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
        if (position.value > shadowingSubtitle.value!.end) {
          playerController.seekTo(shadowingSubtitle.value!.start);
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
    return ValueListenableBuilder<Subtitle?>(
      valueListenable: currentSubtitle,
      builder: (BuildContext context, Subtitle? currentSubtitle, _) {
        if (currentSubtitle == null) {
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

    return Stack(
      children: <Widget>[
        ListView.builder(
          shrinkWrap: true,
          itemCount: lines.length,
          itemBuilder: (BuildContext context, int lineIndex) {
            List<dynamic> line = lines[lineIndex];
            List<Widget> textWidgets = [];

            for (int i = 0; i < line.length; i++) {
              String word = line[i];
              textWidgets.add(getOutlineText(word));
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: textWidgets,
            );
          },
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: lines.length,
          itemBuilder: (BuildContext context, int lineIndex) {
            List<dynamic> line = lines[lineIndex];
            List<Widget> textWidgets = [];

            for (int i = 0; i < line.length; i++) {
              String character = line[i];
              textWidgets.add(
                getText(character, i),
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: textWidgets,
            );
          },
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
        child: AbsorbPointer(
          absorbing: isMenuHidden.value,
          child: GestureDetector(
            onTap: () {
              toggleMenuVisibility();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildPlayButton(),
                buildDurationAndPosition(),
                buildSlider(),
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

  Widget buildGestureArea() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) async {
        if (details.delta.dx.abs() > 10) {
          await playerController.seekTo(getNearestSubtitle()!.start);
        }
      },
      onVerticalDragUpdate: (details) async {
        if (details.delta.dy.abs() > 10) {
          await openTranscript(
            context: context,
            subtitles: subtitleController!.subtitles,
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
      child: Row(
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
                color: Colors.red.withOpacity(0.2),
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
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);
    super.build(context);

    if (!isPlayerReady) {
      return buildPlaceholder();
    }

    return Theme(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            buildPlayerArea(),
            buildGestureArea(),
            buildMenuArea(),
            Positioned.fill(
              child: buildSubtitleArea(),
            ),
            buildDictionary(),
          ],
        ),
      ),
      data: appModel.getDarkTheme(context),
    );
  }

  Widget buildDurationAndPosition() {
    return MultiValueListenableBuider(
      // Add all ValueListenables here.
      valueListenables: [
        duration,
        position,
        shadowingSubtitle,
      ],
      builder: (context, values, _) {
        Duration duration = values.elementAt(0);
        Duration position = values.elementAt(1);
        Subtitle? shadowingSubtitle = values.elementAt(2);

        if (duration == Duration.zero) {
          return const SizedBox.shrink();
        }

        String getPositionText() {
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
    return ValueListenableBuilder<bool>(
      valueListenable: isPlaying,
      builder: (context, bool playing, _) {
        return IconButton(
          color: Colors.white,
          icon:
              playing ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
          onPressed: () async {
            cancelHideTimer();

            isPlaying.value = !playing;

            if (playing) {
              cancelHideTimer();
              await playerController.pause();
            } else {
              startHideTimer();
              await playerController.play();
            }
          },
        );
      },
    );
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
      shadowingSubtitle.value = currentSubtitle.value;
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
          Share.share(currentSubtitle.value?.data ?? "");
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_export"),
        icon: Icons.mobile_screen_share,
        action: () {},
      ),
    ];

    return options;
  }

  Widget buildSlider() {
    return MultiValueListenableBuider(
      // Add all ValueListenables here.
      valueListenables: [
        duration,
        position,
      ],
      builder: (context, values, _) {
        Duration duration = values.elementAt(0);
        Duration position = values.elementAt(1);

        bool validPosition = duration.compareTo(position) >= 0;
        double sliderValue = validPosition ? position.inSeconds.toDouble() : 0;

        return Expanded(
          child: Slider(
            activeColor: Theme.of(context).focusColor,
            inactiveColor: Theme.of(context).unselectedWidgetColor,
            value: sliderValue,
            min: 0.0,
            max: (!validPosition)
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
                    sliderValue = progress.floor().toDouble();
                    playerController.setTime(sliderValue.toInt() * 1000);
                  }
                : null,
          ),
        );
      },
    );
  }
}

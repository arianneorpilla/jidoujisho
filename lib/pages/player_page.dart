import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakelock/wakelock.dart';
import 'package:path/path.dart' as p;

import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/language/tap_to_select.dart';
import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/blur_widget.dart';
import 'package:chisa/util/bottom_sheet_dialog.dart';
import 'package:chisa/util/dictionary_scrollable_widget.dart';
import 'package:chisa/util/export_paths.dart';
import 'package:chisa/util/subtitle_options.dart';
import 'package:chisa/util/subtitle_utils.dart';
import 'package:chisa/util/time_format.dart';
import 'package:chisa/util/transcript_dialog.dart';

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
    with SingleTickerProviderStateMixin {
  late AppModel appModel;

  late VlcPlayerController playerController;
  late SubtitleItem subtitleItem;
  late SubtitleItem emptySubtitleItem;
  late AnimationController playPauseIconAnimationController;

  /// Public for a [MediaSource] to edit and store session-specific details
  /// for its source button.
  Map<dynamic, dynamic> sourceOptions = {};

  List<SubtitleItem> subtitleItems = [];

  final ValueNotifier<int> latestResultEntryIndex = ValueNotifier<int>(0);
  DictionarySearchResult? latestResult;

  int currentAudioTrack = 0;

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

  late Color menuColor;
  late Color dictionaryColor;
  double menuHeight = 48;

  final ValueNotifier<bool> isMenuHidden = ValueNotifier<bool>(false);
  Timer? menuHideTimer;
  Timer? dragSearchTimer;

  bool isPlayerReady = false;
  bool unhideDuringInitFlag = false;

  bool tapToSelectMode = true;
  double subtitleFontSize = 24;
  int subtitlesDelay = 0;
  final FocusNode dragToSelectFocusNode = FocusNode();

  bool dialogSmartPaused = false;
  bool dialogSmartFocusFlag = false;

  String? audioPath;

  Orientation? currentOrientation;

  DictionarySearchResult? searchResult;
  ValueNotifier<String> searchTerm = ValueNotifier<String>("");
  ValueNotifier<String> searchMessage = ValueNotifier<String>("");
  ValueNotifier<Subtitle?> shadowingSubtitle = ValueNotifier<Subtitle?>(null);
  ValueNotifier<Subtitle?> listeningSubtitle = ValueNotifier<Subtitle?>(null);

  Future<bool> onWillPop() async {
    if (playerController.value.isEnded) {
      Navigator.pop(context, true);
      appModel.dictionaryUpdateFlipflop.value =
          !appModel.dictionaryUpdateFlipflop.value;
    } else {
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
                ),
              ),
              onPressed: () async {
                Navigator.pop(context, true);
                appModel.dictionaryUpdateFlipflop.value =
                    !appModel.dictionaryUpdateFlipflop.value;
              }),
          TextButton(
            child: Text(
              appModel.translate("dialog_no"),
            ),
            onPressed: () async {
              Navigator.pop(context, false);
            },
          ),
        ],
      );

      return await showDialog(
            context: context,
            builder: (context) => alertDialog,
          ) ??
          false;
    }

    return false;
  }

  void initialiseEmbeddedSubtitles() async {
    if (widget.params.getMode() == MediaLaunchMode.network) {
      return;
    }

    await Future.delayed(const Duration(seconds: 2), () {});

    int embeddedTrackCount = await playerController.getSpuTracksCount() ?? 0;
    currentAudioTrack = await playerController.getAudioTrack() ?? 0;

    List<SubtitleItem> embeddedItems =
        await prepareSubtitleControllersFromVideo(
            widget.params.videoFile!, embeddedTrackCount);

    subtitleItems.addAll(embeddedItems);

    if (subtitleItem.type == SubtitleItemType.noneSubtitle) {
      for (int i = 0; i < subtitleItems.length; i++) {
        SubtitleItem item = subtitleItems[i];
        if (item.controller.subtitles.isNotEmpty) {
          await item.controller.initial();
          subtitleItem = item;

          break;
        }
      }
    }
  }

  @override
  void dispose() async {
    playerController.removeListener(listener);
    playerController.dispose();
    ClipboardListener.removeListener(copyClipboardAction);

    await Wakelock.disable();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  Future<void> copyClipboardAction() async {
    setSearchTerm((await Clipboard.getData(Clipboard.kTextPlain))!
        .text!
        .replaceAll("￼", ""));
  }

  @override
  void initState() {
    super.initState();

    ClipboardListener.addListener(copyClipboardAction);

    emptySubtitleItem = SubtitleItem(
      controller: SubtitleController(
        provider: SubtitleProvider.fromString(
          data: "",
          type: SubtitleType.srt,
        ),
      ),
      type: SubtitleItemType.noneSubtitle,
    );

    subtitleItem = emptySubtitleItem;

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      menuColor = appModel.getIsDarkMode()
          ? const Color(0xcc424242)
          : const Color(0xdeeeeeee);
      dictionaryColor = appModel.getIsDarkMode()
          ? Colors.grey.shade800.withOpacity(0.97)
          : Colors.grey.shade200.withOpacity(0.97);

      playerController = await preparePlayerController(widget.params);
      playPauseIconAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
        reverseDuration: const Duration(milliseconds: 400),
      );

      subtitleItems = await prepareSubtitleControllers(widget.params);

      if (subtitleItems.isNotEmpty) {
        subtitleItem = subtitleItems.first;
      }

      await subtitleItem.controller.initial();

      blurWidgetOptionsNotifier =
          ValueNotifier<BlurWidgetOptions>(appModel.getBlurWidgetOptions());
      subtitleOptionsNotifier =
          ValueNotifier<SubtitleOptions>(appModel.getSubtitleOptions());

      playerController.addListener(listener);
      playerController.addOnInitListener(() {
        initialiseEmbeddedSubtitles();
      });

      isPlayerReady = true;

      setState(() {});
      startHideTimer();

      Future.delayed(const Duration(seconds: 3), () {
        unhideDuringInitFlag = true;
      });
    });
  }

  void cancelHideTimer() {
    menuHideTimer?.cancel();
    isMenuHidden.value = false;
  }

  void startHideTimer() {
    menuHideTimer = Timer(const Duration(seconds: 3), toggleMenuVisibility);
  }

  void cancelDragSubtitlesTimer() {
    if (dragSearchTimer != null) {
      dragSearchTimer?.cancel();
    }
  }

  void startDragSubtitlesTimer(String newTerm) {
    cancelDragSubtitlesTimer();
    dragSearchTimer = Timer(const Duration(milliseconds: 500), () {
      setSearchTerm(newTerm);
    });
  }

  void setSearchTerm(String newTerm) {
    searchTerm.value = newTerm.trim();
    latestResult = null;
  }

  MediaHistoryItem? generateContextHistoryItem() {
    if (!widget.params.saveHistoryItem) {
      return null;
    }

    MediaHistoryItem item = widget.params.mediaHistoryItem;
    item.currentProgress = position.value.inSeconds;
    item.completeProgress = duration.value.inSeconds;
    return item;
  }

  Widget buildDictionary() {
    return MultiValueListenableBuider(
      valueListenables: [
        searchTerm,
        searchMessage,
      ],
      builder: (context, values, _) {
        String searchTerm = values.elementAt(0);
        String searchMessage = values.elementAt(1);

        if (searchMessage.isNotEmpty) {
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
                  child: buildDictionaryMessage(searchMessage),
                ),
              ),
            ),
          );
        }

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
                if (appModel.getPlayerDefinitionFocusMode()) {
                  dialogSmartResume(isSmartFocus: true);
                }

                setSearchTerm("");
              },
              onLongPress: () async {
                await appModel.showDictionaryMenu(context,
                    onDictionaryChange: () {
                  refreshDictionaryWidget();
                });
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity == 0) return;

                if (details.primaryVelocity!.compareTo(0) == -1) {
                  appModel.setPrevDictionary();
                } else {
                  appModel.setNextDictionary();
                }
                refreshDictionaryWidget();
              },
              child: Container(
                color: dictionaryColor,
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<DictionarySearchResult>(
                  future: appModel.searchDictionary(
                    searchTerm,
                    mediaHistoryItem: generateContextHistoryItem(),
                  ), // a previously-obtained Future<String> or null
                  builder: (BuildContext context,
                      AsyncSnapshot<DictionarySearchResult> snapshot) {
                    if (appModel.getPlayerDefinitionFocusMode()) {
                      dialogSmartFocusFlag = true;
                      dialogSmartPause();
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return buildDictionarySearching();
                    }

                    latestResult = snapshot.data;

                    if (!snapshot.hasData || latestResult!.entries.isEmpty) {
                      return buildDictionaryNoMatch();
                    } else {
                      return buildDictionaryMatch();
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
      selectable: true,
    );
  }

  Widget buildDictionarySearching() {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: appModel.translate("searching_before"),
            style: const TextStyle(),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: searchTerm.value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: appModel.translate("searching_after"),
          ),
          WidgetSpan(
            child: SizedBox(
              height: 12,
              width: 12,
              child: JumpingDotsProgressIndicator(
                color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget buildDictionaryMessage1Argument(
    String beforeText,
    String boldedText,
    String afterText,
    bool jumpingDots,
  ) {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: beforeText,
            style: const TextStyle(),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: boldedText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(text: afterText),
          if (jumpingDots)
            WidgetSpan(
              child: SizedBox(
                height: 12,
                width: 12,
                child: JumpingDotsProgressIndicator(
                  color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDictionaryMessageArgument(
    String beforeText,
    String boldedText,
    String afterText,
    bool jumpingDots,
  ) {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: beforeText,
            style: const TextStyle(),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: boldedText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(text: afterText),
          if (jumpingDots)
            WidgetSpan(
              child: SizedBox(
                height: 12,
                width: 12,
                child: JumpingDotsProgressIndicator(
                  color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDictionaryMessage(String messageText) {
    // Handle special cases with certain reserved patterns.
    if (messageText.startsWith("deckExport://")) {
      String deckName = messageText.replaceAll("deckExport://", "");
      return buildDictionaryMessageArgument(
        appModel.translate("deck_label_before"),
        deckName,
        appModel.translate("deck_label_after"),
        false,
      );
    }

    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: messageText.replaceAll("...", ""),
          ),
          if (messageText.endsWith("..."))
            WidgetSpan(
              child: SizedBox(
                height: 12,
                width: 12,
                child: JumpingDotsProgressIndicator(
                  color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
                ),
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
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: searchTerm.value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: appModel.translate("dictionary_nomatch_after"),
            style: const TextStyle(),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<VlcPlayerController> preparePlayerController(
      PlayerLaunchParams params) async {
    int startTime = widget.params.mediaHistoryItem.currentProgress;
    List<String> advancedParams = ["--start-time=$startTime"];
    List<String> audioParams = ["--audio-track=0", "--sub-track=99999"];
    if (params.audioPath != null) {
      audioParams.add("--input-slave=${params.audioPath}");
      audioPath = params.audioPath!;
    }

    switch (params.getMode()) {
      case MediaLaunchMode.file:
        return VlcPlayerController.file(
          params.videoFile!,
          options: VlcPlayerOptions(
            advanced: VlcAdvancedOptions(advancedParams),
            audio: VlcAudioOptions(audioParams),
          ),
        );
      case MediaLaunchMode.network:
        String streamUrl = await params.mediaSource.getNetworkStreamUrl(params);
        String? audioUrl = await params.mediaSource.getAudioStreamUrl(params);

        if (audioUrl != null) {
          audioParams.add("--input-slave=$audioUrl");
          audioPath = audioUrl;
        }

        return VlcPlayerController.network(
          streamUrl,
          options: VlcPlayerOptions(
            advanced: VlcAdvancedOptions(advancedParams),
            audio: VlcAudioOptions(audioParams),
          ),
        );
    }
  }

  Future<List<SubtitleItem>> prepareSubtitleControllers(
      PlayerLaunchParams params) async {
    return await params.mediaSource.provideSubtitles(params);
  }

  void listener() async {
    if (!mounted) return;

    if (playerController.value.isInitialized) {
      position.value = playerController.value.position;
      duration.value = playerController.value.duration;
      isPlaying.value = playerController.value.isPlaying;
      isEnded.value = playerController.value.isEnded;

      Subtitle? newSubtitle = subtitleItem.controller
          .durationSearch(position.value + getSubtitleDelay());

      if (currentSubtitle.value != newSubtitle) {
        currentSubtitle.value = newSubtitle;
        // For remembering the last subtitle even if it has disappeared.
        if (newSubtitle != null) {
          currentSubtitleMemory.value = newSubtitle;
        }
      }

      if (shadowingSubtitle.value != null) {
        Duration allowance = getAudioAllowance();
        if (subtitleItem.controller.subtitles.isEmpty) {
          if (allowance == Duration.zero) {
            allowance = const Duration(seconds: 5);
          }
        }

        if (position.value <
                shadowingSubtitle.value!.start -
                    getSubtitleDelay() -
                    const Duration(seconds: 15) -
                    getAudioAllowance() ||
            position.value >
                shadowingSubtitle.value!.end -
                    getSubtitleDelay() +
                    getAudioAllowance()) {
          playerController.seekTo(shadowingSubtitle.value!.start +
              getSubtitleDelay() -
              getAudioAllowance());
        }
      }

      if (listeningSubtitle.value != null) {
        if (position.value <
                listeningSubtitle.value!.start +
                    getSubtitleDelay() -
                    const Duration(seconds: 15) ||
            position.value >
                listeningSubtitle.value!.end +
                    getSubtitleDelay() +
                    const Duration(seconds: 5)) {
          listeningSubtitle.value = null;
        }
      }

      if (widget.params.saveHistoryItem) {
        if (!appModel.getIncognitoMode()) {
          updateHistory();
        }
      }
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
      color: Colors.transparent,
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

        String subtitleText = currentSubtitle.data;
        String regex = subtitleOptionsNotifier.value.regexFilter;
        if (regex.isNotEmpty) {
          subtitleText = subtitleText.replaceAll(RegExp(regex), "");
        }

        if (appModel.getPlayerDragToSelectMode()) {
          return dragToSelectSubtitle(subtitleText);
        } else {
          return tapToSelectWidget(subtitleText);
        }
      },
    );
  }

  Widget getOutlineText(String character) {
    return Text(
      character,
      style: TextStyle(
        fontSize: subtitleOptionsNotifier.value.fontSize,
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
          fontSize: subtitleOptionsNotifier.value.fontSize,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget tapToSelectWidget(String subtitleText) {
    TapToSelectInfo tapToSelectInfo = getLinesFromCharacters(
      context,
      subtitleText.split(''),
      subtitleFontSize,
    );

    List<Widget> rows = [];
    List<Widget> outlinedRows = [];
    for (int i = 0; i < tapToSelectInfo.lines.length; i++) {
      List<String> line = tapToSelectInfo.lines[i];
      List<int> lineIndex = tapToSelectInfo.lineIndexes[i];

      List<Widget> textWidgets = [];
      List<Widget> outlinedTextWidgets = [];

      for (int i = 0; i < line.length; i++) {
        String character = line[i];
        int index = lineIndex[i];
        outlinedTextWidgets.add(getOutlineText(character));
        textWidgets.add(getText(character, index));
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

  Widget dragToSelectSubtitle(String subtitleText) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        SelectableText(
          subtitleText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleOptionsNotifier.value.fontSize,
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
            fontSize: subtitleOptionsNotifier.value.fontSize,
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

  void toggleMenuVisibility() async {
    menuHideTimer?.cancel();
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

  Widget buildSourceButton() {
    Widget? sourceButton =
        widget.params.mediaSource.buildSourceButton(context, this);

    if (sourceButton == null) {
      return const SizedBox.shrink();
    } else {
      return sourceButton;
    }
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

  Subtitle? getNearestSubtitle() {
    if (currentSubtitle.value != null) {
      return currentSubtitle.value!;
    } else {
      if (subtitleItem.controller.subtitles.isEmpty) {
        return null;
      }

      Subtitle? lastSubtitle;
      for (Subtitle subtitle in subtitleItem.controller.subtitles) {
        if (position.value < subtitle.start + getSubtitleDelay()) {
          return lastSubtitle;
        }

        lastSubtitle = subtitle;
      }

      return null;
    }
  }

  Future<void> playPause() async {
    dialogSmartPaused = false;

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

  void setDictionaryMessage(String messageText, {Duration? duration}) {
    searchMessage.value = messageText;
    if (duration != null) {
      Future.delayed(duration, () {
        clearDictionaryMessage();
      });
    }
  }

  void clearDictionaryMessage() {
    searchMessage.value = "";
  }

  Duration getSubtitleDelay() {
    return Duration(milliseconds: subtitleOptionsNotifier.value.subtitleDelay);
  }

  Duration getAudioAllowance() {
    return Duration(milliseconds: subtitleOptionsNotifier.value.audioAllowance);
  }

  Widget buildGestureArea() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) async {
        if (details.delta.dx.abs() > 20) {
          Subtitle? nearestSubtitle = getNearestSubtitle();

          listeningSubtitle.value = nearestSubtitle;
          await playerController
              .seekTo(nearestSubtitle!.start - getSubtitleDelay());
        }
      },
      onHorizontalDragEnd: (dragEndDetails) async {
        if (dragEndDetails.primaryVelocity!.abs() > 0) {
          Subtitle? nearestSubtitle = getNearestSubtitle();

          listeningSubtitle.value = nearestSubtitle;
          await playerController
              .seekTo(nearestSubtitle!.start - getSubtitleDelay());
        }
      },
      onVerticalDragEnd: (details) async {
        if (details.primaryVelocity!.abs() > 0) {
          bool exporting = false;
          await dialogSmartPause();
          await openTranscript(
              context: context,
              subtitles: subtitleItem.controller.subtitles,
              subtitleDelay: getSubtitleDelay(),
              currentSubtitle: getNearestSubtitle(),
              regexFilter: subtitleOptionsNotifier.value.regexFilter,
              onTapCallback: (int selectedIndex) async {
                await playerController.seekTo(
                    subtitleItem.controller.subtitles[selectedIndex].start -
                        getSubtitleDelay());
              },
              onLongPressCallback: (int selectedIndex) async {
                exporting = true;
                await exportMultipleSubtitles(selectedIndex);
              });

          if (!exporting) {
            await dialogSmartResume();
          }
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

  Future<void> exportMultipleSubtitles(int selectedIndex) async {
    int maxSubtitles = 10;

    Subtitle? nearestSubtitle = getNearestSubtitle();
    if (nearestSubtitle == null) {
      return;
    }

    List<Subtitle> subtitles = subtitleItem.controller.subtitles;
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

  Widget buildBlurWidget() {
    return ResizeableWidget(
      context: context,
      blurWidgetNotifier: blurWidgetOptionsNotifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);
    currentOrientation ??= MediaQuery.of(context).orientation;

    if (!isPlayerReady) {
      return buildPlaceholder();
    }

    Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (appModel.isPlayerOrientationPortrait()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    Duration position = playerController.value.position;
    if (currentOrientation != MediaQuery.of(context).orientation) {
      currentOrientation = MediaQuery.of(context).orientation;
      Future.delayed(const Duration(milliseconds: 50), () {
        playerController.seekTo(position - const Duration(milliseconds: 50));
      });
    }

    return WillPopScope(
      onWillPop: onWillPop,
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
            duration = shadowingSubtitle.end +
                getSubtitleDelay() +
                getAudioAllowance();
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
                  : appModel.getIsDarkMode()
                      ? Colors.white
                      : Colors.black,
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
      valueListenables: [
        isPlaying,
        isEnded,
      ],
      builder: (context, values, _) {
        bool playing = values.elementAt(0);
        bool ended = values.elementAt(1);

        return IconButton(
          color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
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
    BottomSheetDialogOption audioOption = BottomSheetDialogOption(
      label: appModel.translate("player_option_select_audio"),
      icon: Icons.music_note_outlined,
      action: () async {
        Map<int, String> audioEmbeddedTracks =
            await playerController.getAudioTracks();
        int audioTrack = await playerController.getAudioTrack() ?? 0;
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => BottomSheetDialog(
            options: getAudioDialogOptions(audioEmbeddedTracks, audioTrack),
          ),
        );
      },
    );
    List<BottomSheetDialogOption> options = [];
    options.add(audioOption);

    options.addAll([
      BottomSheetDialogOption(
        label: appModel.translate("player_option_select_subtitle"),
        icon: Icons.subtitles_outlined,
        action: () async {
          Map<int, String> subtitleEmbeddedTracks =
              await playerController.getSpuTracks();

          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => BottomSheetDialog(
              options: getSubtitleDialogOptions(subtitleEmbeddedTracks),
            ),
          );
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_align_subtitle_transcript"),
        icon: Icons.timer,
        action: () async {
          await dialogSmartPause();
          await openTranscript(
              context: context,
              subtitles: subtitleItem.controller.subtitles,
              subtitleDelay: getSubtitleDelay(),
              currentSubtitle: getNearestSubtitle(),
              regexFilter: subtitleOptionsNotifier.value.regexFilter,
              onTapCallback: (int selectedIndex) async {
                Subtitle subtitle =
                    subtitleItem.controller.subtitles[selectedIndex];

                subtitleOptionsNotifier.value.subtitleDelay =
                    subtitle.end.inMilliseconds - position.value.inMilliseconds;

                refreshSubtitleWidget();
              },
              onLongPressCallback: (int selectedIndex) async {
                Subtitle subtitle =
                    subtitleItem.controller.subtitles[selectedIndex];

                subtitleOptionsNotifier.value.subtitleDelay =
                    subtitle.end.inMilliseconds - position.value.inMilliseconds;

                SubtitleOptions subtitleOptions = appModel.getSubtitleOptions();
                subtitleOptions.subtitleDelay =
                    subtitle.end.inMilliseconds - position.value.inMilliseconds;
                await appModel.setSubtitleOptions(subtitleOptions);

                refreshSubtitleWidget();
              });
          await dialogSmartResume();
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_subtitle_appearance"),
        icon: Icons.text_fields,
        action: () async {
          await dialogSmartPause();
          ClipboardListener.removeListener(copyClipboardAction);
          await showSubtitleOptionsDialog(context, subtitleOptionsNotifier);
          ClipboardListener.addListener(copyClipboardAction);
          await dialogSmartResume();
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
        label: appModel.translate("player_change_player_orientation"),
        icon: appModel.isPlayerOrientationPortrait()
            ? Icons.stay_current_landscape
            : Icons.stay_current_portrait,
        action: () async {
          await appModel.togglePlayerOrientationPortrait();
          if (appModel.isPlayerOrientationPortrait()) {
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
      BottomSheetDialogOption(
        label: appModel.translate("player_option_load_subtitles"),
        icon: Icons.upload_file,
        action: () async {
          await dialogSmartPause();
          await importExternalSubtitle();
          await dialogSmartResume();
        },
      ),
    ]);

    return IconButton(
      color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
      icon: const Icon(Icons.queue_music_outlined),
      onPressed: () async {
        if (await playerController.getAudioTracksCount() == 0 ||
            audioPath != null) {
          options.remove(audioOption);
        }

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => BottomSheetDialog(
            options: options,
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
          await dialogSmartPause();
          ClipboardListener.removeListener(copyClipboardAction);
          await showBlurWidgetOptionsDialog(context, blurWidgetOptionsNotifier);
          ClipboardListener.addListener(copyClipboardAction);
          await dialogSmartResume();
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

  List<BottomSheetDialogOption> getAudioDialogOptions(
      Map<int, String> embeddedTracks, int audioTrack) {
    List<BottomSheetDialogOption> options = [];
    String audio = appModel.translate("player_option_audio");

    embeddedTracks.forEach((index, label) {
      BottomSheetDialogOption option = BottomSheetDialogOption(
          label: "$audio - $label",
          icon: Icons.music_note_outlined,
          active: audioTrack == index,
          action: () {
            playerController.setAudioTrack(index);
          });

      options.add(option);
    });

    return options;
  }

  String getSubtitleLabel(SubtitleItem item, Map<int, String> embeddedTracks) {
    String subtitle = appModel.translate("player_option_subtitle");
    String subtitleExternal =
        appModel.translate("player_option_subtitle_external");
    String subtitleNone = appModel.translate("player_option_subtitle_none");

    switch (item.type) {
      case SubtitleItemType.externalSubtitle:
        return "$subtitle - $subtitleExternal [${item.metadata}]";
      case SubtitleItemType.embeddedSubtitle:
        return "$subtitle - ${embeddedTracks.values.toList()[item.index!]}";
      case SubtitleItemType.webSubtitle:
        return "$subtitle - ${item.metadata}";
      case SubtitleItemType.noneSubtitle:
        return "$subtitle - $subtitleNone";
    }
  }

  List<BottomSheetDialogOption> getSubtitleDialogOptions(
      Map<int, String> embeddedTracks) {
    List<BottomSheetDialogOption> options = [];
    for (SubtitleItem item in subtitleItems) {
      BottomSheetDialogOption option = BottomSheetDialogOption(
          label: getSubtitleLabel(item, embeddedTracks),
          icon: Icons.subtitles_outlined,
          active: subtitleItem == item,
          action: () {
            subtitleItem = item;
            if (!subtitleItem.controller.initialized) {
              subtitleItem.controller.initial();
            }
          });

      options.add(option);
    }

    options.add(BottomSheetDialogOption(
        label: getSubtitleLabel(emptySubtitleItem, embeddedTracks),
        icon: Icons.subtitles_off_outlined,
        active: subtitleItem == emptySubtitleItem,
        action: () {
          subtitleItem = emptySubtitleItem;
        }));

    return options;
  }

  Widget buildOptionsButton() {
    return IconButton(
      color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
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
      if (subtitleItem.controller.subtitles.isEmpty) {
        shadowingSubtitle.value = Subtitle(
          data: "",
          start: position.value,
          end: position.value,
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
            ? appModel.translate("player_option_tap_to_select")
            : appModel.translate("player_option_drag_to_select"),
        icon: (appModel.getPlayerDragToSelectMode())
            ? Icons.touch_app
            : Icons.select_all,
        action: () async {
          await appModel.togglePlayerDragToSelectMode();
          refreshSubtitleWidget();
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_dictionary_menu"),
        icon: Icons.auto_stories,
        action: () async {
          await dialogSmartPause();
          await appModel.showDictionaryMenu(context, onDictionaryChange: () {
            refreshDictionaryWidget();
          });
          await dialogSmartResume();
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
        action: () async {
          await Share.share(getNearestSubtitle()?.data ?? "");
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

          dialogSmartPause();
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

    int allowanceMs = subtitleOptionsNotifier.value.audioAllowance;

    if (subtitles.isEmpty) {
      if (allowanceMs == 0) {
        allowanceMs = 5000;
      }

      Duration allowance = Duration(milliseconds: allowanceMs);

      subtitles = [
        Subtitle(
          start: position.value - allowance,
          end: position.value + allowance,
          data: "",
          index: 0,
        )
      ];
    }

    for (Subtitle subtitle in subtitles) {
      String subtitleText = subtitle.data;
      String regex = subtitleOptionsNotifier.value.regexFilter;
      if (regex.isNotEmpty) {
        subtitleText = subtitleText.replaceAll(RegExp(regex), "");
      }
      sentence += "$subtitleText\n";
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

    List<NetworkToFileImage> imageFiles = [];

    File? imageFile;
    File? audioFile;

    try {
      imageFiles = await exportImages(subtitles);

      audioFile = await exportCurrentAudio(
        subtitles,
        allowanceMs,
        subtitleOptionsNotifier.value.subtitleDelay,
      );

      if (imageFiles.isNotEmpty) {
        imageFile = imageFiles.first.file;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    AnkiExportParams exportParams = AnkiExportParams(
      sentence: sentence,
      word: word,
      meaning: meaning,
      reading: reading,
      imageFiles: imageFiles,
      imageFile: imageFile,
      audioFile: audioFile,
    );

    MediaHistoryItem? contextItem = generateContextHistoryItem();
    if (contextItem != null) {
      exportParams.context = Uri.encodeFull(
          "https://jidoujisho.context/${generateContextHistoryItem()!.toJson()}");
    }

    return exportParams;
  }

  Future<List<NetworkToFileImage>> exportImages(
    List<Subtitle> subtitles,
  ) async {
    List<NetworkToFileImage> imageFiles = [];

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
      if (subtitles.length == 1) {
        currentTime = position.value;
      }
      String timestamp = getTimestampFromDuration(currentTime);
      String inputPath = playerController.dataSource;

      String? altInputPath = await widget.params.mediaSource
          .getExportVideoDataSource(widget.params);
      if (altInputPath != null) {
        inputPath = altInputPath;
      }

      String command =
          "-loglevel quiet -ss $timestamp -y -i \"$inputPath\" -frames:v 1 -q:v 2 \"$outputPath\"";

      final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
      await _flutterFFmpeg.execute(command);

      while (!imageFile.existsSync()) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      NetworkToFileImage networkToFileImage =
          NetworkToFileImage(file: imageFile);

      imageFiles.add(networkToFileImage);
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
    if (audioPath != null) {
      audioIndex = "0";
    }

    Duration allowance = Duration(milliseconds: audioAllowance);
    Duration delay = Duration(milliseconds: subtitleDelay);
    Duration adjustedStart = subtitles.first.start - delay - allowance;

    Duration adjustedEnd = subtitles.last.end - delay + allowance;

    timeStart = getTimestampFromDuration(adjustedStart);
    timeEnd = getTimestampFromDuration(adjustedEnd);

    String inputPath = playerController.dataSource;

    String? altInputPath =
        await widget.params.mediaSource.getExportAudioDataSource(widget.params);
    if (altInputPath != null) {
      inputPath = altInputPath;
    }

    String command =
        "-loglevel quiet -ss $timeStart -to $timeEnd -y -i \"$inputPath\" -map 0:a:$audioIndex \"$outputPath\"";

    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
    await _flutterFFmpeg.execute(command);

    return audioFile;
  }

  Future<void> openCardCreator(List<Subtitle> subtitles) async {
    setDictionaryMessage(appModel.translate("player_prepare_export"));

    imageCache!.clear();
    AnkiExportParams initialParams = await prepareExportParams(subtitles);

    searchTerm.value = "";

    ClipboardListener.removeListener(copyClipboardAction);

    clearDictionaryMessage();
    dialogSmartPause();
    await navigateToCreator(
        context: context,
        appModel: appModel,
        initialParams: initialParams,
        backgroundColor: dictionaryColor,
        appBarColor: Colors.transparent,
        hideActions: true,
        popOnExport: true,
        exportCallback: () {
          Navigator.of(context).pop();
          String lastDeck = appModel.getLastAnkiDroidDeck();
          setDictionaryMessage(
            "deckExport://$lastDeck",
            duration: const Duration(seconds: 3),
          );
        });

    dialogSmartResume(isSmartFocus: true);

    await Clipboard.setData(const ClipboardData(text: ""));
    ClipboardListener.addListener(copyClipboardAction);
  }

  Widget buildSlider() {
    return MultiValueListenableBuider(
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

                    sliderValue = progress.floor().toDouble();
                    playerController.setTime(sliderValue.toInt() * 1000);
                  }
                : null,
          ),
        );
      },
    );
  }

  Future<void> dialogSmartPause() async {
    if (playerController.value.isPlaying) {
      dialogSmartPaused = true;
      await playerController.pause();
    }
  }

  Future<void> dialogSmartResume({bool isSmartFocus = false}) async {
    if (dialogSmartFocusFlag && !isSmartFocus) {
      return;
    }

    if (isSmartFocus) {
      dialogSmartFocusFlag = false;
    }

    if (dialogSmartPaused) {
      await playerController.play();
    }
    dialogSmartPaused = false;
  }

  Future<void> importExternalSubtitle() async {
    MediaType mediaType = widget.params.mediaSource.mediaType;
    Iterable<String>? filePaths = await FilesystemPicker.open(
      title: "",
      pickText: appModel.translate("dialog_select"),
      cancelText: appModel.translate("dialog_return"),
      context: context,
      rootDirectories: await appModel.getMediaTypeDirectories(mediaType),
      fsType: FilesystemType.file,
      multiSelect: false,
      folderIconColor: Colors.red,
      themeData: Theme.of(context),
    );

    if (filePaths == null || filePaths.isEmpty) {
      return;
    }

    String filePath = filePaths.first;

    appModel.setLastPickedDirectory(mediaType, Directory(p.dirname(filePath)));
    File file = File(filePath);

    String fileExtension = p.extension(filePath);

    SubtitleItem? item = await prepareSubtitleControllerFromFile(
      file: file,
      type: SubtitleItemType.externalSubtitle,
      metadata: fileExtension,
    );

    await item.controller.initial();

    subtitleItems.add(item);
    subtitleItem = item;
    refreshSubtitleWidget();
  }
}

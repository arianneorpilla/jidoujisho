import 'dart:async';
import 'dart:math';

import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:spaces/spaces.dart';
import 'package:subtitle/subtitle.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:collection/collection.dart';

/// Shown when the user scrolls vertically in the player.
class PlayerTranscriptPage extends BaseSourcePage {
  /// Create an instance of this page.
  const PlayerTranscriptPage({
    required this.title,
    required this.subtitles,
    required this.currentSubtitle,
    required this.nearestSubtitle,
    required this.subtitleOptions,
    required this.controller,
    required this.playingNotifier,
    required this.onTap,
    required this.onLongPress,
    required this.alignMode,
    super.key,
    super.item,
  });

  /// Title of video.
  final String title;

  /// All subtitles in the current video.
  final List<Subtitle> subtitles;

  /// Subtitle to be highlighted.
  final ValueNotifier<Subtitle?> currentSubtitle;

  /// Nearest subtitle if no initial subtitle.
  final Subtitle? nearestSubtitle;

  /// Current subtitle options used in the player.
  final SubtitleOptions subtitleOptions;

  /// Controller for the player.
  final VlcPlayerController controller;

  /// Notifier for whether or not the player is playing.
  final ValueNotifier<bool> playingNotifier;

  /// Seek action.
  final FutureOr<void> Function(int)? onTap;

  /// Mine action.
  final FutureOr<void> Function(int)? onLongPress;

  /// Whether or not the transcript was opened for aligning subtitles.
  final bool alignMode;

  @override
  BaseSourcePageState createState() => _PlayerTranscriptPageState();
}

class _PlayerTranscriptPageState
    extends BaseSourcePageState<PlayerTranscriptPage> with ChangeNotifier {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });

    widget.currentSubtitle.addListener(scrollTo);
  }

  @override
  void dispose() {
    widget.currentSubtitle.removeListener(scrollTo);
    super.dispose();
  }

  void scrollTo() {
    if (widget.currentSubtitle.value != null) {
      int selectedIndex = widget.currentSubtitle.value!.index;
      int scrollIndex = (selectedIndex - 2 > 0) ? selectedIndex - 2 : 0;

      _itemScrollController.scrollTo(
        index: scrollIndex,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: buildAppBar(),
          backgroundColor: Theme.of(context).cardColor.withOpacity(0.85),
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: clearDictionaryResult,
                  child: buildBody(),
                ),
                buildDictionary(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  final ChangeNotifier _playerModeNotifier = ChangeNotifier();

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: buildBackButton(),
      title: buildTitle(),
      actions: [
        if (!widget.alignMode) buildPlayPauseButton(),
        if (!widget.alignMode) buildToggleButton(),
        if (!widget.alignMode) const Space.normal(),
      ],
      titleSpacing: 8,
    );
  }

  Widget buildToggleButton() {
    return ChangeNotifierBuilder(
      notifier: _playerModeNotifier,
      builder: (context, _, __) {
        return JidoujishoIconButton(
          enabledColor: appModel.isTranscriptPlayerMode ? Colors.red : null,
          tooltip: t.transcript_playback_mode,
          icon: Icons.playlist_play,
          onTap: () async {
            appModel.toggleTranscriptPlayerMode();
            _playerModeNotifier.notifyListeners();

            if (!appModel.isTranscriptPlayerMode) {
              widget.controller.pause();
            }
          },
        );
      },
    );
  }

  Widget buildPlayPauseButton() {
    return ChangeNotifierBuilder(
      notifier: _playerModeNotifier,
      builder: (context, _, __) {
        if (!appModel.isTranscriptPlayerMode) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<bool>(
          valueListenable: widget.playingNotifier,
          builder: (context, playing, _) {
            return JidoujishoIconButton(
              tooltip: playing ? t.pause : t.play,
              icon: playing ? Icons.pause : Icons.play_arrow,
              onTap: () async {
                if (playing) {
                  widget.controller.pause();
                } else {
                  widget.controller.play();
                }
              },
            );
          },
        );
      },
    );
  }

  Widget buildBackButton() {
    return JidoujishoIconButton(
      tooltip: t.back,
      icon: Icons.arrow_back,
      onTap: () async {
        Navigator.pop(context);
      },
    );
  }

  Widget buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: JidoujishoMarquee(
            text: widget.title,
            style: TextStyle(
              fontSize: textTheme.titleMedium?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBody() {
    if (widget.subtitles.isEmpty) {
      return buildPlaceholder();
    } else {
      return buildSubtitles();
    }
  }

  Widget buildPlaceholder() {
    return Padding(
      padding: Spacing.of(context).insets.onlyBottom.extraBig,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.subtitles_off_outlined,
                size: 72,
              ),
              const Space.normal(),
              Text(
                t.player_subtitles_transcript_empty,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const Space.big(),
            ],
          ),
        ),
      ),
    );
  }

  List<InlineSpan> getTextSpans({
    required JidoujishoSelectableTextController controller,
    required Subtitle subtitle,
    required String text,
  }) {
    List<InlineSpan> spans = [];

    text.runes.forEachIndexed((index, rune) {
      String character = String.fromCharCode(rune);
      spans.add(
        TextSpan(
          text: character,
          style: style,
          recognizer: TapGestureRecognizer()
            ..onTapDown = (details) async {
              if (!widget.alignMode) {
                (appModel.currentMediaSource as PlayerMediaSource)
                    .setTranscriptSubtitle(subtitle);

                onTapDown(
                  text: text,
                  character: character,
                  index: index,
                  controller: controller,
                  details: details,
                );
              }
            },
        ),
      );
    });

    return spans;
  }

  JidoujishoSelectableTextController? _lastTappedController;

  void onTapDown({
    required String text,
    required String character,
    required int index,
    required TapDownDetails details,
    required JidoujishoSelectableTextController controller,
  }) {
    _lastTappedController?.clearSelection();
    _lastTappedController = controller;

    bool wholeWordCondition =
        controller.selection.start <= index && controller.selection.end > index;

    if (wholeWordCondition && currentResult != null) {
      clearDictionaryResult();
      return;
    }

    appModel.currentMediaSource?.setCurrentSentence(text);

    double x = details.globalPosition.dx;
    double y = details.globalPosition.dy;

    late JidoujishoPopupPosition position;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      if (y < MediaQuery.of(context).size.height / 2) {
        position = JidoujishoPopupPosition.bottomHalf;
      } else {
        position = JidoujishoPopupPosition.topHalf;
      }
    } else {
      if (x < MediaQuery.of(context).size.width / 2) {
        position = JidoujishoPopupPosition.rightHalf;
      } else {
        position = JidoujishoPopupPosition.leftHalf;
      }
    }

    String searchTerm = appModel.targetLanguage.getSearchTermFromIndex(
      text: text,
      index: index,
    );

    if (character.trim().isNotEmpty) {
      /// If we cut off at a lone surrogate, offset the index back by 1. The
      /// selection meant to select the index before
      RegExp loneSurrogate = RegExp(
        '[\uD800-\uDBFF](?![\uDC00-\uDFFF])|(?:[^\uD800-\uDBFF]|^)[\uDC00-\uDFFF]',
      );
      if (index != 0 && text.substring(index).startsWith(loneSurrogate)) {
        index = index - 1;
      }
      bool isSpaceDelimited = appModel.targetLanguage.isSpaceDelimited;
      int whitespaceOffset = searchTerm.length - searchTerm.trimLeft().length;
      int offsetIndex =
          appModel.targetLanguage.getStartingIndex(text: text, index: index) +
              whitespaceOffset;
      int length = appModel.targetLanguage
          .textToWords(searchTerm)
          .firstWhere((e) => e.trim().isNotEmpty)
          .length;

      controller.setSelection(
        offsetIndex,
        offsetIndex + length,
      );
      if (searchTerm.isNotEmpty) {
        if (appModel.isPlayerDefinitionFocusMode) {
          dialogSmartPause();
        }
      }

      searchDictionaryResult(
        searchTerm: searchTerm,
        position: position,
      ).then((result) {
        int length = isSpaceDelimited
            ? appModel.targetLanguage
                .textToWords(searchTerm)
                .firstWhere((e) => e.trim().isNotEmpty)
                .length
            : max(1, currentResult?.bestLength ?? 0);

        controller.setSelection(offsetIndex, offsetIndex + length);
      });
    } else {
      clearDictionaryResult();
    }

    FocusScope.of(context).unfocus();
  }

  TextStyle? get style => widget.subtitleOptions.fontName.trim().isEmpty
      ? TextStyle(
          fontSize: widget.subtitleOptions.fontSize,
        )
      : GoogleFonts.getFont(
          widget.subtitleOptions.fontName,
          fontSize: widget.subtitleOptions.fontSize,
        );

  @override
  void clearDictionaryResult() {
    super.clearDictionaryResult();
    _lastTappedController?.clearSelection();
    appModel.currentMediaSource?.clearCurrentSentence();
    (appModel.currentMediaSource as PlayerMediaSource)
        .clearTranscriptSubtitle();
    dialogSmartResume();
  }

  Widget buildSubtitles() {
    int selectedIndex =
        (widget.currentSubtitle.value ?? widget.nearestSubtitle)?.index ?? -1;
    int initialScrollIndex = (selectedIndex - 2 > 0) ? selectedIndex - 2 : 0;

    return ScrollablePositionedList.builder(
      padding: const EdgeInsets.only(bottom: 48),
      physics: const BouncingScrollPhysics(),
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      initialScrollIndex: initialScrollIndex,
      itemCount: widget.subtitles.length,
      itemBuilder: (context, index) {
        final JidoujishoSelectableTextController controller =
            JidoujishoSelectableTextController();

        Subtitle subtitle = widget.subtitles[index];
        String subtitleText = subtitle.data;

        if (widget.subtitleOptions.regexFilter.isNotEmpty) {
          subtitleText = subtitleText.replaceAll(
              RegExp(widget.subtitleOptions.regexFilter), '');
        }

        Color durationColor = Theme.of(context).unselectedWidgetColor;

        Duration offsetStart = subtitle.start -
            Duration(milliseconds: widget.subtitleOptions.subtitleDelay);
        Duration offsetEnd = subtitle.end -
            Duration(milliseconds: widget.subtitleOptions.subtitleDelay);
        String offsetStartText =
            JidoujishoTimeFormat.getFfmpegTimestamp(offsetStart);
        String offsetEndText =
            JidoujishoTimeFormat.getFfmpegTimestamp(offsetEnd);
        String subtitleDuration = '$offsetStartText - $offsetEndText';

        return Material(
          color: Colors.transparent,
          child: ValueListenableBuilder<Subtitle?>(
            valueListenable: widget.currentSubtitle,
            builder: (context, currentSubtitle, child) {
              int selectedIndex = widget.currentSubtitle.value?.index ?? -1;

              return ListTile(
                selected: selectedIndex - 1 == index,
                selectedTileColor: Colors.red.withOpacity(0.15),
                dense: true,
                title: child,
                onTap: () async {
                  if (appModel.isTranscriptPlayerMode && !widget.alignMode) {
                    widget.controller.seekTo(subtitle.start);
                    widget.controller.play();
                    return;
                  }
                  if (widget.onTap != null) {
                    await widget.onTap?.call(index);
                  }
                },
                onLongPress: () async {
                  if (appModel.isTranscriptPlayerMode && !widget.alignMode) {
                    return;
                  }
                  if (widget.onLongPress != null) {
                    await widget.onLongPress?.call(index);
                  }
                },
              );
            },
            child: Column(
              children: [
                const Space.small(),
                Row(
                  children: [
                    const Icon(
                      Icons.textsms_outlined,
                      size: 12,
                      color: Colors.red,
                    ),
                    const Space.semiBig(),
                    Text(
                      subtitleDuration,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: durationColor,
                      ),
                    ),
                    const Space.small(),
                  ],
                ),
                const Space.small(),
                Row(
                  children: [
                    const Space.extraBig(),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            flex: 6,
                            child: JidoujishoSelectableText.rich(
                              TextSpan(
                                children: getTextSpans(
                                  controller: controller,
                                  subtitle: subtitle,
                                  text: subtitleText,
                                ),
                              ),
                              enableInteractiveSelection: !widget.alignMode,
                              selectionControls:
                                  JidoujishoTextSelectionControls(
                                searchAction: (selection) async {
                                  (appModel.currentMediaSource
                                          as PlayerMediaSource)
                                      .setTranscriptSubtitle(subtitle);
                                  appModel.currentMediaSource
                                      ?.setCurrentSentence(subtitleText);
                                  await appModel.openRecursiveDictionarySearch(
                                    searchTerm: selection,
                                    killOnPop: false,
                                  );
                                  appModel.currentMediaSource
                                      ?.clearCurrentSentence();
                                },
                                stashAction: onStash,
                                shareAction: onShare,
                                creatorAction: (selection) async {
                                  (appModel.currentMediaSource
                                          as PlayerMediaSource)
                                      .setTranscriptSubtitle(subtitle);
                                  launchCreator(term: '', sentence: selection);
                                },
                                allowCopy: true,
                                allowSelectAll: false,
                                allowCut: true,
                                allowPaste: true,
                              ),
                              controller: controller,
                              style: style,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    if (!widget.alignMode) buildSeekButton(subtitle, index),
                    if (!widget.alignMode)
                      buildCardCreatorButton(subtitleText, subtitle),
                    if (widget.alignMode) buildAlignButton(index),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSeekButton(
    Subtitle subtitle,
    int index,
  ) {
    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: t.seek,
        icon: Icons.play_circle_fill,
        onTap: () async {
          if (appModel.isTranscriptPlayerMode && !widget.alignMode) {
            widget.controller.seekTo(subtitle.start);
            widget.controller.play();
            return;
          }

          widget.onTap?.call(index);
        },
      ),
    );
  }

  Widget buildCardCreatorButton(
    String message,
    Subtitle subtitle,
  ) {
    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: t.card_creator,
        icon: Icons.note_add,
        onTap: () async {
          (appModel.currentMediaSource as PlayerMediaSource)
              .setTranscriptSubtitle(subtitle);

          launchCreator(term: '', sentence: message);
        },
      ),
    );
  }

  void launchCreator({required String term, required String sentence}) async {
    await appModel.openCreator(
      creatorFieldValues: CreatorFieldValues(
        textValues: {
          SentenceField.instance: sentence,
          TermField.instance: term,
        },
      ),
      killOnPop: false,
      ref: ref,
    );
  }

  Widget buildAlignButton(int index) {
    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: t.player_align_subtitle_transcript,
        icon: Icons.timer,
        onTap: () async {
          if (widget.onTap != null) {
            await widget.onTap?.call(index);
          }
        },
      ),
    );
  }

  /// Action upon selecting the Search option.
  @override
  void onSearch(String searchTerm, {String? sentence = ''}) async {
    await appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
    );
  }

  bool _dialogSmartPaused = false;

  /// This is called when opening dialogs such as the transcript and the
  /// creator, where it is appropriate to pause the player.
  Future<void> dialogSmartPause() async {
    _dialogSmartPaused = true;
    await widget.controller.pause();
  }

  /// Resumes the dialog only if smart paused. This is called when dialogs
  /// are closed after being smart paused.
  Future<void> dialogSmartResume({bool isSmartFocus = false}) async {
    if (_dialogSmartPaused) {
      _dialogSmartPaused = false;
      await widget.controller.play();
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:spaces/spaces.dart';
import 'package:subtitle/subtitle.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// Shown when the user scrolls vertically in the player.
class PlayerTranscriptPage extends BasePage {
  /// Create an instance of this page.
  const PlayerTranscriptPage({
    required this.subtitles,
    required this.currentSubtitle,
    required this.subtitleOptions,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  /// All subtitles in the current video.
  final List<Subtitle> subtitles;

  /// Subtitle to be highlighted.
  final Subtitle? currentSubtitle;

  /// Current subtitle options used in the player.
  final SubtitleOptions subtitleOptions;

  /// Seek action.
  final FutureOr<void> Function(int)? onTap;

  /// Mine action.
  final FutureOr<void> Function(int)? onLongPress;

  @override
  BasePageState createState() => _PlayerTranscriptPageState();
}

class _PlayerTranscriptPageState extends BasePageState<PlayerTranscriptPage> {
  String get playerSubtitlesTranscriptEmpty =>
      appModel.translate('player_subtitles_transcript_empty');

  int _selectedIndex = 0;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    if (widget.currentSubtitle != null) {
      _selectedIndex = widget.currentSubtitle!.index - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
  return  Scaffold(
      backgroundColor: Theme.of(context).cardColor.withOpacity(0.85),
      resizeToAvoidBottomInset: false,
      body: buildBody(),
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
    return Material(
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
              playerSubtitlesTranscriptEmpty,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSubtitles() {
    return ScrollablePositionedList.builder(
      physics: const BouncingScrollPhysics(),
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      initialScrollIndex: (_selectedIndex - 2 > 0) ? _selectedIndex - 2 : 0,
      itemCount: widget.subtitles.length,
      itemBuilder: (context, index) {
        Subtitle subtitle = widget.subtitles[index];
        String subtitleText = subtitle.data;

        if (widget.subtitleOptions.regexFilter.isNotEmpty) {
          subtitleText = subtitleText.replaceAll(
              RegExp(widget.subtitleOptions.regexFilter), '');
        }
        if (subtitleText.trim().isNotEmpty) {
          subtitleText = '『$subtitleText』';
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
          child: ListTile(
            selected: _selectedIndex == index,
            selectedTileColor: Colors.red.withOpacity(0.15),
            dense: true,
            title: Column(
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
                Text(
                  subtitleText,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: GoogleFonts.getFont(
                    widget.subtitleOptions.fontName,
                    fontSize: widget.subtitleOptions.fontSize,
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
            onTap: () async {
              if (widget.onTap != null) {
                widget.onTap?.call(index);
                Navigator.pop(context);
              }
            },
            onLongPress: () async {
              if (widget.onLongPress != null) {
                widget.onLongPress?.call(index);
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }
}

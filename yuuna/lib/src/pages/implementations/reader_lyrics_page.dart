import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A page for [ReaderLyricsSource] which shows lyrics of current playing
/// media.
class ReaderLyricsPage extends BaseSourcePage {
  /// Create an instance of this tab page.
  const ReaderLyricsPage({
    super.item,
    super.key,
  });

  @override
  BaseSourcePageState createState() => _ReaderLyricsPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class _ReaderLyricsPageState<ReaderLyricsPage> extends BaseSourcePageState {
  String get noCurrentMediaLabel => appModel.translate('no_current_media');
  String get lyricsPermissionRequiredLabel =>
      appModel.translate('lyrics_permission_required');
  String get noLyricsFound => appModel.translate('no_lyrics_found');

  Orientation? lastOrientation;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation != lastOrientation) {
      clearDictionaryResult();
      lastOrientation = orientation;
    }

    AsyncValue<bool> permissionGranted = ref.watch(lyricsPermissionsProvider);

    return permissionGranted.when(
      loading: buildLoading,
      error: (error, stack) => buildError(
        error: error,
        stack: stack,
        refresh: () {
          ref.refresh(lyricsPermissionsProvider);
        },
      ),
      data: (permissionGranted) => buildPermissions(
        permissionGranted: permissionGranted,
      ),
    );
  }

  Widget buildPermissions({required bool permissionGranted}) {
    if (permissionGranted) {
      return buildTrackWhen();
    } else {
      return buildNeedPermission();
    }
  }

  Widget buildNeedPermission() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.error,
        message: lyricsPermissionRequiredLabel,
      ),
    );
  }

  Widget buildNoLyricsFound() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.music_off,
        message: noLyricsFound,
      ),
    );
  }

  Widget buildNoCurrentMedia() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.lyrics,
        message: noCurrentMediaLabel,
      ),
    );
  }

  Widget buildTrackWhen() {
    return StreamBuilder<NowPlayingTrack>(
      stream: NowPlaying.instance.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return buildNoCurrentMedia();
        }

        NowPlayingTrack track = snapshot.data!;
        if (track.artist == null || track.title == null) {
          return buildNoCurrentMedia();
        }

        JidoujishoLyricsParameters parameters = JidoujishoLyricsParameters(
          artist: track.artist!,
          title: track.title!,
        );
        return buildLyricsWhen(
          parameters: parameters,
          track: track,
        );
      },
    );
  }

  Widget buildLyricsWhen({
    required JidoujishoLyricsParameters parameters,
    required NowPlayingTrack track,
  }) {
    AsyncValue<String?> lyrics = ref.watch(lyricsProvider(parameters));
    return lyrics.when(
      loading: buildLoading,
      error: (error, stack) => buildError(
        error: error,
        stack: stack,
        refresh: () {
          ref.refresh(lyricsProvider(parameters));
        },
      ),
      data: (lyrics) => buildLyrics(
        lyrics: lyrics,
        parameters: parameters,
        track: track,
      ),
    );
  }

  Widget buildLyrics({
    required String? lyrics,
    required JidoujishoLyricsParameters parameters,
    required NowPlayingTrack track,
  }) {
    if (lyrics == null) {
      return buildNoLyricsFound();
    }

    return GestureDetector(
      onTap: clearDictionaryResult,
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            primary: false,
            child: Padding(
              padding: Spacing.of(context).insets.horizontal.extraBig,
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const Space.extraBig(),
                  const Space.big(),
                  Row(
                    children: [
                      if (track.hasImage)
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: Image(image: track.image!),
                        ),
                      if (track.hasImage) const Space.semiBig(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              parameters.title,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              parameters.artist,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Space.big(),
                  buildLyricsText(lyrics),
                  const Space.big(),
                ],
              ),
            ),
          ),
          Column(
            children: [
              const Space.extraBig(),
              Expanded(
                child: buildDictionary(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _currentSelection = '';
  final FocusNode _lyricsFocusNode = FocusNode(skipTraversal: true);

  Widget buildLyricsText(String text) {
    return SelectableText.rich(

      TextSpan(children: getSubtitleSpans(text)),
      focusNode: _lyricsFocusNode,
      selectionControls: selectionControls,
      onSelectionChanged: (selection, cause) {
        String textSelection = selection.textInside(text);
        _currentSelection = textSelection;
      },
    );
  }

  List<InlineSpan> getSubtitleSpans(String text) {
    List<InlineSpan> spans = [];

    text.runes.forEachIndexed((index, rune) {
      String character = String.fromCharCode(rune);
      spans.add(
        TextSpan(
          text: character,
          style: const TextStyle(fontSize: 22),
          recognizer: TapGestureRecognizer()
            ..onTapUp = (details) async {
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

              String searchTerm = text.substring(index);

              if (_currentSelection.isEmpty) {
                searchDictionaryResult(
                  searchTerm: searchTerm,
                  position: position,
                );
              } else {
                clearDictionaryResult();
                _currentSelection = '';
              }

              FocusScope.of(context).unfocus();
            },
        ),
      );
    });

    return spans;
  }

  void creatorAction(String text) async {
    await appModel.openCreator(
      creatorFieldValues: CreatorFieldValues(
        textValues: {
          SentenceField.instance: text,
        },
      ),
      killOnPop: false,
      ref: ref,
    );
  }

  @override
  MaterialTextSelectionControls get selectionControls =>
      JidoujishoTextSelectionControls(
        searchAction: onContextSearch,
        searchActionLabel: searchLabel,
        stashAction: onContextStash,
        stashActionLabel: stashLabel,
        creatorActionLabel: creatorLabel,
        creatorAction: creatorAction,
        allowCopy: true,
        allowSelectAll: false,
        allowCut: true,
        allowPaste: true,
      );
}

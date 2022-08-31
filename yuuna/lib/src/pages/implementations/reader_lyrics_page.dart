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
class ReaderLyricsPage extends HistoryReaderPage {
  /// Create an instance of this tab page.
  const ReaderLyricsPage({
    super.key,
  });

  @override
  BaseHistoryPageState<BaseHistoryPage> createState() =>
      _ReaderLyricsSourceHistoryPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class _ReaderLyricsSourceHistoryPageState<T extends HistoryReaderPage>
    extends HistoryReaderPageState {
  /// The message to be shown in the placeholder that displays when
  /// [shouldPlaceholderBeShown] is true. This should be a localised message.

  String get noCurrentMediaLabel => appModel.translate('no_current_media');
  String get lyricsPermissionRequiredLabel =>
      appModel.translate('lyrics_permission_required');
  String get noLyricsFound => appModel.translate('no_lyrics_found');
  String get creatorLabel => appModel.translate('creator');

  @override
  MediaType get mediaType => mediaSource.mediaType;

  @override
  ReaderLyricsSource get mediaSource => ReaderLyricsSource.instance;

  @override
  Widget build(BuildContext context) {
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
        icon: Icons.lyrics,
        message: noLyricsFound,
      ),
    );
  }

  Widget buildNoCurrentMedia() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.music_off,
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

    return SingleChildScrollView(
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
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        parameters.artist,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Space.big(),
            SelectableText(
              lyrics,
              selectionControls: selectionControls,
              style: const TextStyle(fontSize: 16),
            ),
            const Space.big(),
          ],
        ),
      ),
    );
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

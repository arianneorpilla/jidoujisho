import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:yuuna/src/pages/implementations/lyrics_dialog_page.dart';
import 'package:yuuna/utils.dart';

/// A global [Provider] for getting lyrics from Google.
final lyricsProvider =
    FutureProvider.family<String?, JidoujishoLyricsParameters>((ref, track) {
  return ReaderLyricsSource.instance.getLyrics(track);
});

/// A global [Provider] for getting lyrics from Google.
final lyricsPermissionsProvider = FutureProvider<bool>((ref) {
  return ReaderLyricsSource.instance.requestPermissions();
});

/// A media source that allows the user to fetch lyrics from Google.
class ReaderLyricsSource extends ReaderMediaSource {
  /// Define this media source.
  ReaderLyricsSource._privateConstructor()
      : super(
          uniqueKey: 'reader_lyrics',
          sourceName: 'Lyrics',
          description:
              'Allows fetching and highlighting lyrics of current played media '
              'fetched from Google.',
          icon: Icons.queue_music,
          implementsSearch: false,
          implementsHistory: false,
        );

  /// Get the singleton instance of this media type.
  static ReaderLyricsSource get instance => _instance;

  static final ReaderLyricsSource _instance =
      ReaderLyricsSource._privateConstructor();

  /// Used f>or manual search.
  String? get overrideTitle => _overrideTitle;
  String? _overrideTitle;

  /// Used for manual search.
  String? get overrideArtist => _overrideArtist;
  String? _overrideArtist;

  /// Manual search action.
  void setOverrideTitleAndArtist({
    required String title,
    required String artist,
  }) {
    _overrideTitle = title;
    _overrideArtist = artist;
  }

  /// Manual search action.
  void clearOverrideTitleAndAuthor() {
    _overrideTitle = null;
    _overrideArtist = null;
  }

  /// Communicates override changes.
  Stream<void> get overrideStream => _overrideController.stream;
  final StreamController<void> _overrideController =
      StreamController.broadcast();

  @override
  Future<void> onSearchBarTap({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) async {
    showSearchDialog(context: context);
  }

  @override
  Future<void> onSourceExit({
    required BuildContext context,
    required WidgetRef ref,
  }) async {}

  @override
  BaseSourcePage buildLaunchPage({MediaItem? item}) {
    throw UnsupportedError('Lyrics source does not launch any page');
  }

  @override
  Future<void> prepareResources() async {
    NowPlaying.instance.start();
  }

  @override
  List<Widget> getActions({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    return [
      buildSearchButton(context: context, ref: ref, appModel: appModel),
    ];
  }

  @override
  BasePage buildHistoryPage({MediaItem? item}) {
    return const ReaderLyricsPage();
  }

  /// Get lyrics
  Future<String?> getLyrics(JidoujishoLyricsParameters parameters) async {
    String artist = Uri.encodeComponent(parameters.artist.trim());
    String title = Uri.encodeComponent(parameters.title.trim());

    String searchUrl =
        'https://www.google.com/search?q=$title+-+$artist+lyrics';

    late String? lyrics;
    bool webViewBusy = true;

    HeadlessInAppWebView webView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(searchUrl),
        ),
        onLoadStop: (controller, uri) async {
          dom.Document document = parser.parse(await controller.getHtml());

          List<dom.Element> elements = document.querySelectorAll(
              '[data-attrid="kc:/music/recording_cluster:lyrics"]');

          if (elements.isEmpty) {
            lyrics = null;
          } else {
            lyrics = elements.first.innerHtml
                .replaceAll(RegExp('<[^>]*>|&[^;]+;'), '\n')
                .replaceAll('\n\n\n', '\n')
                .trim();
          }

          webViewBusy = false;
        });

    await webView.run();

    while (webViewBusy) {
      await Future.delayed(const Duration(milliseconds: 100), () {});
    }

    return lyrics;
  }

  /// Get permissions to get the current playing media.
  Future<bool> requestPermissions() {
    return NowPlaying.instance.requestPermissions(force: true);
  }

  /// Whether or not artist and title are non-null and override the current media.
  bool get isOverride => _overrideArtist != null && _overrideTitle != null;

  /// Menu bar action.
  Widget buildSearchButton(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) {
    String setMediaLabel = appModel.translate('set_media');

    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: setMediaLabel,
        enabledColor: isOverride ? Colors.red : null,
        icon: Icons.audio_file,
        onTap: () {
          showSearchDialog(context: context);
        },
      ),
    );
  }

  /// Dialog for menu action.
  void showSearchDialog({required BuildContext context}) async {
    if (isOverride) {
      clearOverrideTitleAndAuthor();
      mediaType.refreshTab();
      _overrideController.add(null);
    } else {
      await showDialog(
        context: context,
        builder: (context) => LyricsDialogPage(
          title: NowPlaying.instance.track.title ?? '',
          artist: NowPlaying.instance.track.artist ?? '',
          onSearch: (title, artist) {
            if (artist.trim().isEmpty || title.trim().isEmpty) {
              return;
            }
            
            Navigator.pop(context);
            setOverrideTitleAndArtist(
              title: title,
              artist: artist,
            );

            mediaType.refreshTab();
            _overrideController.add(null);
          },
        ),
      );
    }
  }
}

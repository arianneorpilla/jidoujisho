import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
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
    return [];
  }

  @override
  Future<void> onSearchBarTap({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) async {}

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
          lyrics =  elements.first.innerHtml.replaceAll(RegExp('<[^>]*>|&[^;]+;'), '\n').replaceAll('\n\n\n', '\n').trim();
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
}

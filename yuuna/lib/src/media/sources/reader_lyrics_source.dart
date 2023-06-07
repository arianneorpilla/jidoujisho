import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/pages/implementations/lyrics_dialog_page.dart';
import 'package:yuuna/utils.dart';

/// A global [Provider] for getting lyrics from Google.
final lyricsProvider =
    FutureProvider.family<JidoujishoLyrics, JidoujishoLyricsParameters>(
        (ref, track) {
  return ReaderLyricsSource.instance.getLyrics(track);
});

/// A global [Provider] for getting lyrics from Google.
final lyricsPermissionsProvider = FutureProvider<bool>((ref) {
  return ReaderLyricsSource.instance.requestPermissions();
});

/// A global [Provider] for listening to track changes.
final lyricsStreamProvider = StreamProvider<NowPlayingTrack>((ref) {
  return NowPlaying.instance.stream;
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
              'fetched from Google and Uta-Net.',
          icon: Icons.queue_music,
          implementsSearch: false,
          implementsHistory: false,
        );

  /// Get the singleton instance of this media type.
  static ReaderLyricsSource get instance => _instance;

  static final ReaderLyricsSource _instance =
      ReaderLyricsSource._privateConstructor();

  /// Used for manual search.
  String? get overrideTitle => _overrideTitle;
  String? _overrideTitle;

  /// Used for manual search.
  String? get overrideArtist => _overrideArtist;
  String? _overrideArtist;

  /// Manual search action.
  void setOverrideTitleAndArtist({
    required String title,
    String? artist,
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
  Future<void> prepareResources() async {
    NowPlaying.instance.start();
  }

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
    required AppModel appModel,
    required WidgetRef ref,
  }) async {}

  @override
  BaseSourcePage buildLaunchPage({
    MediaItem? item,
  }) {
    throw UnsupportedError('Lyrics source does not launch any page');
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
  Future<JidoujishoLyrics> getLyrics(
    JidoujishoLyricsParameters parameters,
  ) async {
    String userAgent =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36';
    String artist = Uri.encodeComponent(parameters.artist.trim());
    String title = Uri.encodeComponent(parameters.title.trim());

    late String searchUrl;
    if (artist.isEmpty) {
      searchUrl = 'https://www.google.com/search?q=$title+lyrics';
    } else {
      searchUrl = 'https://www.google.com/search?q=$title+-+$artist+lyrics';
    }

    String? text;
    bool webViewBusy = true;

    HeadlessInAppWebView webView = HeadlessInAppWebView(
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          userAgent: userAgent,
        ),
        android: AndroidInAppWebViewOptions(
          blockNetworkImage: true,
        ),
      ),
      initialUrlRequest: URLRequest(
        url: Uri.parse(searchUrl),
      ),
      onLoadStop: (controller, uri) async {
        text = await controller.evaluateJavascript(source: '''
[...document.getElementsByClassName('ujudUb')].map((e) => {
    return e.innerText;                                                   
}).join('\\n\\n');
''');

        if (text != null && text!.trim().isEmpty) {
          text = null;
        }

        webViewBusy = false;
      },
    );

    await webView.run();

    while (webViewBusy) {
      await Future.delayed(const Duration(milliseconds: 100), () {});
    }

    if (parameters.artist.endsWith(' - Topic') && text == null) {
      return getLyrics(
        JidoujishoLyricsParameters(
          artist: parameters.artist.replaceAll(' - Topic', ''),
          title: parameters.title,
        ),
      );
    }

    if (artist.isNotEmpty && text == null) {
      String? firstResultUrl;
      bool googleWebViewBusy = true;

      HeadlessInAppWebView googleWebView = HeadlessInAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            userAgent: userAgent,
          ),
          android: AndroidInAppWebViewOptions(
            blockNetworkImage: true,
          ),
        ),
        initialUrlRequest: URLRequest(
          url: Uri.parse(
              'https://google.com/search?q=$artist+$title+歌詞+site:uta-net.com/song'),
        ),
        onLoadStop: (controller, uri) async {
          firstResultUrl = await controller.evaluateJavascript(
              source:
                  'document.querySelector(".yuRUbf:nth-of-type(1) > a").href');

          googleWebViewBusy = false;
        },
      );

      await googleWebView.run();

      while (googleWebViewBusy) {
        await Future.delayed(const Duration(milliseconds: 100), () {});
      }

      if (firstResultUrl != null) {
        bool utanetWebViewBusy = true;
        HeadlessInAppWebView utanetWebView = HeadlessInAppWebView(
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              userAgent: userAgent,
            ),
            android: AndroidInAppWebViewOptions(
              blockNetworkImage: true,
            ),
          ),
          initialUrlRequest: URLRequest(
            url: Uri.parse(firstResultUrl!),
          ),
          onLoadStop: (controller, uri) async {
            text = await controller.evaluateJavascript(source: '''
[...document.getElementsByTagName('h2')].map((e) => e.remove());
var kashi = document.getElementsByClassName('row kashi')[0];
kashi.children[0].children[0].innerText;
''');

            if (text != null && text!.trim().isEmpty) {
              text = null;
            }

            utanetWebViewBusy = false;
          },
        );

        await utanetWebView.run();

        while (utanetWebViewBusy) {
          await Future.delayed(const Duration(milliseconds: 100), () {});
        }
      }
    }

    /// Try again, but without an artist. This will probably be wrong. But it's
    /// better to have tried and gotten a good result sometimes than for this
    /// to always fail just because the artist's name might make it difficult.
    if (artist.isNotEmpty && text == null) {
      return getLyrics(
        JidoujishoLyricsParameters(
          artist: '',
          title: parameters.title,
        ),
      );
    }

    return JidoujishoLyrics(
      includesArtist: artist.isNotEmpty,
      text: text,
    );
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
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.set_media,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A media source that allows browsing the web.
class ReaderBrowserSource extends ReaderMediaSource with ChangeNotifier {
  /// Define this media source.
  ReaderBrowserSource._privateConstructor()
      : super(
          uniqueKey: 'reader_browser',
          sourceName: 'Browser',
          description:
              'Navigate websites with a browser which allows searching and mining selected text.',
          icon: Icons.language,
          implementsSearch: false,
          implementsHistory: false,
        );

  /// Get the singleton instance of this media type.
  static ReaderBrowserSource get instance => _instance;

  static final ReaderBrowserSource _instance =
      ReaderBrowserSource._privateConstructor();

  @override
  double get aspectRatio => 257 / 364;

  @override
  Future<void> onSearchBarTap({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) async {
    openLinkAction(
      context: context,
      ref: ref,
      appModel: appModel,
    );
  }

  @override
  Future<void> onSourceExit({
    required AppModel appModel,
    required WidgetRef ref,
  }) async {
    changeNotifier.notifyListeners();
  }

  /// For updating the history page.
  final ChangeNotifier changeNotifier = ChangeNotifier();

  @override
  BaseSourcePage buildLaunchPage({
    MediaItem? item,
  }) {
    return BrowserSourcePage(item: item);
  }

  @override
  BasePage buildHistoryPage({MediaItem? item}) {
    return const BrowserHistoryPage();
  }

  @override
  List<Widget> getActions({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    return [
      buildOpenLinkButton(context: context, ref: ref, appModel: appModel),
    ];
  }

  /// Helper to generate a media item with parameters.
  MediaItem generateMediaItem(BrowserBookmark bookmark, {String? base64Image}) {
    return MediaItem(
      mediaIdentifier: bookmark.url,
      title: bookmark.name,
      mediaTypeIdentifier: mediaType.uniqueKey,
      mediaSourceIdentifier: uniqueKey,
      base64Image: base64Image,
      position: 0,
      duration: 0,
      canDelete: true,
      canEdit: true,
    );
  }

  /// Open address bar dialog.
  void openLinkAction(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) async {
    await showDialog(
      context: context,
      builder: (context) => BrowserDialogPage(
        text: lastAddress,
        onBrowse: (url) {
          MediaItem item = generateMediaItem(
            BrowserBookmark(
              name: '',
              url: url,
            ),
          );

          appModel.openMedia(
            item: item,
            mediaSource: this,
            ref: ref,
          );
        },
      ),
    );
  }

  /// Menu bar action.
  Widget buildOpenLinkButton(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.browse,
        icon: Icons.launch,
        onTap: () => openLinkAction(
          context: context,
          ref: ref,
          appModel: appModel,
        ),
      ),
    );
  }

  /// Set the last used server address.
  Future<void> setLastAddress(String address) async {
    await setPreference<String>(key: 'last_address', value: address);
  }

  /// Get the last used server address.
  String get lastAddress =>
      getPreference<String>(key: 'last_address', defaultValue: '');

  /// Set the cached favicon URL.
  Future<void> setCachedFaviconUrl(String url, String faviconUrl) async {
    await setPreference<String>(key: 'favicon_url/$url', value: faviconUrl);
  }

  /// Get the cached favicon URL.
  String? getCachedFaviconUrl(String url) {
    return getPreference<String?>(key: 'favicon_url/$url', defaultValue: null);
  }
}

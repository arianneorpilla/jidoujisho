import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subtitle/subtitle.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:path/path.dart' as path;
import 'package:collection/collection.dart';

/// A media source that allows the user to read manga processed by Mokuro.
class ReaderMokuroSource extends ReaderMediaSource {
  /// Define this media source.
  ReaderMokuroSource._privateConstructor()
      : super(
          uniqueKey: 'reader_mokuro',
          sourceName: 'Mokuro',
          description:
              'Read manga volumes pre-processed as a single HTML file via Mokuro.',
          icon: Icons.dashboard_outlined,
          implementsSearch: false,
          implementsHistory: true,
          overridesAutoImage: true,
        );

  /// Get the singleton instance of this media type.
  static ReaderMokuroSource get instance => _instance;

  static final ReaderMokuroSource _instance =
      ReaderMokuroSource._privateConstructor();

  @override
  double get aspectRatio => 257 / 364;

  /// Generate a media item given required parameters.
  MediaItem generateMediaItem({
    required String title,
    required String imageUrl,
    required String url,
    required int pageCount,
  }) {
    return MediaItem(
      mediaIdentifier: url,
      imageUrl: imageUrl,
      title: title,
      position: 0,
      duration: pageCount,
      mediaTypeIdentifier: mediaType.uniqueKey,
      mediaSourceIdentifier: uniqueKey,
      canDelete: true,
      canEdit: true,
    );
  }

  @override
  Future<void> onSearchBarTap({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) async {
    showDialog(
      context: context,
      builder: (context) => const MokuroCatalogDialogPage(),
    );
  }

  @override
  BaseSourcePage buildLaunchPage({
    MediaItem? item,
  }) {
    return MokuroCatalogBrowsePage(item: item, catalog: null);
  }

  @override
  BasePage buildHistoryPage({MediaItem? item}) {
    return const ReaderMokuroHistoryPage();
  }

  @override
  List<Widget> getActions({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    return [
      buildTweaksButton(context: context, ref: ref, appModel: appModel),
      buildCatalogButton(context: context, ref: ref, appModel: appModel),
      buildOpenLinkButton(context: context, ref: ref, appModel: appModel),
      buildPickFileButton(context: context, ref: ref, appModel: appModel),
    ];
  }

  /// Tweaks bar action.
  Widget buildTweaksButton(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.tweaks,
        icon: Icons.tune,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const MokuroSettingsDialogPage(),
          );
        },
      ),
    );
  }

  /// Menu bar action.
  Widget buildCatalogButton(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.catalogs,
        icon: Icons.collections_bookmark,
        onTap: () async {
          showDialog(
            context: context,
            builder: (context) => const MokuroCatalogDialogPage(),
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
        tooltip: t.open_url,
        icon: Icons.add_link,
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) => MokuroLinkDialogPage(
              onRead: (url) async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MokuroCatalogBrowsePage(
                      item: null,
                      catalog: MokuroCatalog(
                        name: '',
                        url: url.toString(),
                        order: -1,
                      ),
                    ),
                  ),
                );

                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }

  /// Menu bar action.
  Widget buildPickFileButton(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.pick_file,
        icon: Icons.upload_file,
        onTap: () async {
          launchFilePicker(
            context: context,
            ref: ref,
            appModel: appModel,
          );
        },
      ),
    );
  }

  /// Launches a file picker and opens a media
  void launchFilePicker(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) async {
    List<Directory> rootDirectories =
        await appModel.getFilePickerDirectoriesForMediaType(mediaType);

    List<String> usedFiles = appModel
        .getMediaSourceHistory(mediaSource: this)
        .map((item) => item.mediaIdentifier)
        .map((e) => e.replaceAll('file://', ''))
        .toList();

    Iterable<String>? filePaths = await FilesystemPicker.open(
      allowedExtensions: ['.html'],
      context: context,
      rootDirectories: rootDirectories,
      fsType: FilesystemType.file,
      title: '',
      pickText: t.dialog_select,
      cancelText: t.dialog_cancel,
      themeData: Theme.of(context),
      folderIconColor: Theme.of(context).colorScheme.primary,
      usedFiles: usedFiles,
      currentActiveFile: appModel.currentMediaItem?.mediaIdentifier,
    );

    if (filePaths == null || filePaths.isEmpty) {
      return;
    }

    String filePath = filePaths.first;

    appModel.setLastPickedDirectory(
      type: ReaderMediaType.instance,
      directory: Directory(path.dirname(filePath)),
    );

    HeadlessInAppWebView webView = HeadlessInAppWebView(
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
        ),
      ),
      initialUrlRequest: URLRequest(
        url: Uri.parse('file://$filePath'),
      ),
      onLoadStop: (controller, url) async {
        MediaItem? item = await generateMediaItemFromWebView(
          appModel: appModel,
          controller: controller,
        );
        if (item == null) {
          Fluttertoast.showToast(msg: t.invalid_mokuro_file);
        } else {
          appModel.openMedia(
            context: context,
            item: item,
            ref: ref,
            mediaSource: this,
          );
        }
      },
    );

    await webView.run();
  }

  /// Generate a media item given a WebView.
  Future<MediaItem?> generateMediaItemFromWebView({
    required AppModel appModel,
    required InAppWebViewController controller,
  }) async {
    String title = await controller.getTitle() ?? '';
    Uri url = (await controller.getUrl())!.removeFragment();

    MediaItem? item = appModel
        .getMediaTypeHistory(mediaType: mediaType)
        .firstWhereOrNull((item) => item.mediaIdentifier == url.toString());
    if (item != null) {
      return item;
    }

    if (title.endsWith('| mokuro')) {
      title = title.replaceAll('| mokuro', '');
    }

    bool isMokuroPage = await controller.evaluateJavascript(
        source:
            'document.body.getElementsByClassName("pageContainer").length != 0 && document.getElementById("popupAbout") != null;');
    if (!isMokuroPage) {
      return null;
    }

    int pageCount = await controller.evaluateJavascript(source: '''
document.body.getElementsByClassName('pageContainer').length
''');

    String relativeUrl = await controller.evaluateJavascript(source: '''
var bgImage = document.body.getElementsByClassName('pageContainer')[0].style.backgroundImage;
bgImage.substring(5, bgImage.length - 2);
''');

    String imageUrl = getImageUrl(
      relativeUrl: relativeUrl,
      mediaIdentifier: url.toString(),
    );

    return MediaItem(
      canDelete: true,
      canEdit: true,
      title: title,
      mediaIdentifier: url.toString(),
      position: 0,
      duration: pageCount,
      imageUrl: imageUrl,
      mediaTypeIdentifier: mediaType.uniqueKey,
      mediaSourceIdentifier: uniqueKey,
    );
  }

  /// Given a certain index, return the absolute URL of a Mokuro image.
  String getImageUrl({
    required String relativeUrl,
    required String mediaIdentifier,
  }) {
    return Uri.decodeFull(
        Uri.parse(mediaIdentifier).resolve(relativeUrl).toString());
  }

  /// Whether or not using the volume buttons in the Reader should turn the
  /// page.
  bool get volumePageTurningEnabled {
    return getPreference<bool>(
        key: 'volume_page_turning_enabled', defaultValue: true);
  }

  /// Toggles the volume page turning option.
  void toggleVolumePageTurningEnabled() async {
    await setPreference<bool>(
      key: 'volume_page_turning_enabled',
      value: !volumePageTurningEnabled,
    );
  }

  /// Controls which direction is up or down for volume button page turning.
  bool get volumePageTurningInverted {
    return getPreference<bool>(
        key: 'volume_page_turning_inverted', defaultValue: false);
  }

  /// Inverts the current volume button page turning direction preference.
  void toggleVolumePageTurningInverted() async {
    await setPreference<bool>(
      key: 'volume_page_turning_inverted',
      value: !volumePageTurningInverted,
    );
  }

  /// Whether or not to add to extend the webpage beyond the navigation bar.
  /// This may be helpful for devices that don't have difficulty accessing the
  /// top bar (i.e. don't have a teardrop notch).
  bool get extendPageBeyondNavigationBar {
    return getPreference<bool>(
        key: 'extend_page_beyond_navbar', defaultValue: false);
  }

  /// Toggles the extend navbar option.
  void toggleExtendPageBeyondNavigationBar() async {
    await setPreference<bool>(
      key: 'extend_page_beyond_navbar',
      value: !extendPageBeyondNavigationBar,
    );
  }

  /// Whether the reader will highlight words on tap.
  bool get highlightOnTap {
    return getPreference<bool>(
      key: 'highlight_on_tap',
      defaultValue: true,
    );
  }

  /// Toggles whether the reader will highlight words on tap.
  void toggleHighlightOnTap() async {
    await setPreference<bool>(
      key: 'highlight_on_tap',
      value: !highlightOnTap,
    );
  }

  /// Whether the reader will inject dark theme.
  bool get useDarkTheme {
    return getPreference<bool>(
      key: 'use_dark_theme',
      defaultValue: false,
    );
  }

  /// Toggles whether to inject dark mode.
  void toggleUseDarkTheme() async {
    await setPreference<bool>(
      key: 'use_dark_theme',
      value: !useDarkTheme,
    );
  }

  /// If this source is non-null, this will be used as the initial function
  /// for the image field over the auto enhancement. Extra durations can be
  /// invoked and defined when initially opening the creator, to call attention
  /// to multiple durations to be used for image generation.
  @override
  Future<List<NetworkToFileImage>> generateImages({
    required AppModel appModel,
    required MediaItem item,
    List<Subtitle>? subtitles,
    SubtitleOptions? options,
    String? data,
  }) async {
    List<NetworkToFileImage> imageFiles = [];
    Directory appDirDoc = await getApplicationSupportDirectory();
    String mokuroPreviewPath = '${appDirDoc.path}/mokuroImagePreview';
    Directory mokuroPreviewDir = Directory(mokuroPreviewPath);
    if (mokuroPreviewDir.existsSync()) {
      mokuroPreviewDir.deleteSync(recursive: true);
    }
    mokuroPreviewDir.createSync();

    String timestamp = DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
    Directory imageDir = Directory('$mokuroPreviewPath/$timestamp');
    imageDir.createSync();

    File file = appModel.getPreviewImageFile(imageDir, 0);

    if (data != null) {
      if (item.mediaIdentifier.startsWith('file://')) {
        String absolutePath = Uri.decodeFull(
            Uri.parse(item.mediaIdentifier.replaceFirst('file://', ''))
                .resolve(data)
                .toString());

        File originalFile = File(absolutePath);
        originalFile.copySync(file.path);

        imageFiles.add(NetworkToFileImage(file: file));
      } else {
        String absolutePath = Uri.decodeFull(
            Uri.parse(item.mediaIdentifier).resolve(data).toString());

        File networkFile =
            await DefaultCacheManager().getSingleFile(absolutePath);
        networkFile.copySync(file.path);

        imageFiles.add(
          NetworkToFileImage(
            url: data,
            file: file,
          ),
        );
      }
    }

    return imageFiles;
  }
}

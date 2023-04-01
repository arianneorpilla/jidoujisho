import 'dart:convert';
import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:path/path.dart' as path;
import 'package:collection/collection.dart';

/// A global [Provider] for generating payloads for Mokuro media items.
final mokuroPayloadProvider =
    FutureProvider.family<MokuroPayload, String>((ref, url) {
  return ReaderMokuroSource.instance.generatePayload(url);
});

/// A media source that allows the user to read manga processed by Mokuro.
class ReaderMokuroSource extends ReaderMediaSource {
  /// Define this media source.
  ReaderMokuroSource._privateConstructor()
      : super(
          uniqueKey: 'reader_mokuro',
          sourceName: 'Mokuro',
          description:
              'Read manga volmes pre-processed as a single HTML file via Mokuro.',
          icon: Icons.dashboard_outlined,
          implementsSearch: false,
          implementsHistory: true,
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
    return ReaderMokuroSourcePage(item: item);
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
      buildCatalogButton(context: context, ref: ref, appModel: appModel),
      buildOpenLinkButton(context: context, ref: ref, appModel: appModel),
      buildPickFileButton(context: context, ref: ref, appModel: appModel),
    ];
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
                HeadlessInAppWebView webView = HeadlessInAppWebView(
                  initialUrlRequest: URLRequest(url: url),
                  onLoadStop: (controller, url) async {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    MediaItem? item = await generateMediaItemFromWebView(
                      appModel: appModel,
                      controller: controller,
                    );
                    if (item == null) {
                      Fluttertoast.showToast(msg: t.invalid_mokuro_file);
                      return;
                    } else {
                      appModel.openMedia(
                        item: item,
                        context: context,
                        ref: ref,
                        mediaSource: this,
                      );
                    }
                  },
                );

                await webView.run();
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

    Clipboard.setData(ClipboardData(text: filePath));

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
            item: item,
            context: context,
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

  /// From a URL from a [MediaItem], yields the payload to be used containing
  /// all image details of a Mokuro HTML file.
  Future<MokuroPayload> generatePayload(String mediaIdentifier) async {
    bool webViewBusy = true;

    late InAppWebViewController _controller;

    HeadlessInAppWebView webView = HeadlessInAppWebView(
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
        ),
      ),
      initialUrlRequest: URLRequest(url: Uri.parse(mediaIdentifier)),
      onWebViewCreated: (controller) {
        _controller = controller;
      },
      onLoadError: (_, __, ___, ____) {
        throw Exception('Load error occured');
      },
      onLoadHttpError: (_, __, ___, ____) {
        throw Exception('Load error occured');
      },
      onLoadStop: (controller, url) async {
        webViewBusy = false;
      },
    );

    await webView.run();
    while (webViewBusy) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    String containersDataJson =
        await _controller.evaluateJavascript(source: payloadJs);
    List<Map<String, dynamic>> containersData =
        List<Map<String, dynamic>>.from(jsonDecode(containersDataJson));

    List<MokuroImage> images = containersData.map((containerData) {
      String relativeUrl = containerData['relativeUrl'];
      double height = double.parse(containerData['height'].toString());
      double width = double.parse(containerData['width'].toString());
      List<Map<String, dynamic>> blocksData =
          List<Map<String, dynamic>>.from(containerData['blocks']);

      List<MokuroBlock> blocks = blocksData.map((blockData) {
        double height = double.parse(blockData['height'].toString());
        double width = double.parse(blockData['width'].toString());
        double left = double.parse(blockData['left'].toString());
        double top = double.parse(blockData['top'].toString());
        int zIndex = double.parse(blockData['z'].toString()).toInt();
        double fontSize = double.parse(blockData['fontSize'].toString());
        bool isVertical = blockData['isVertical'];
        List<String> lines = List<String>.from(blockData['lines']);

        return MokuroBlock(
          isVertical: isVertical,
          lines: lines,
          fontSize: fontSize,
          zIndex: zIndex,
          rectangle: Rect.fromLTWH(left, top, width * 1.3, height * 1.3),
        );
      }).toList();

      /// Higher z-index is priority to tap first.
      blocks.sort((a, b) => a.zIndex.compareTo(b.zIndex));

      String url = getImageUrl(
        relativeUrl: relativeUrl,
        mediaIdentifier: mediaIdentifier,
      );
      Size size = Size(width, height);

      return MokuroImage(
        url: url,
        size: size,
        blocks: blocks,
      );
    }).toList();

    return MokuroPayload(images: images);
  }

  /// Used for getting payload data.
  static String payloadJs = '''
JSON.stringify([...document.body.getElementsByClassName('pageContainer')].map((g) => {
  const backgroundImage = g.style.backgroundImage;
  const relativeUrl = backgroundImage.substring(5, backgroundImage.length - 2);

  return {
    'relativeUrl': relativeUrl,
    'height': parseFloat(g.style.height),
    'width': parseFloat(g.style.width),
    'blocks': [...g.getElementsByClassName('textBox')].map((e) => {
      return {
        'height': parseFloat(e.style.height),
        'width': parseFloat(e.style.width),
        'left': parseFloat(e.style.left),
        'top': parseFloat(e.style.top),
        'fontSize': parseFloat(e.style.fontSize),
        'isVertical': e.style.writingMode.startsWith('vertical'),
        'z': parseFloat(e.style.zIndex),
        'lines': [...e.getElementsByTagName('p')].map((f) => f.textContent.trim()),
      }
    }),
  }
}));
''';

  /// Get the color of the background in the reader.
  Color get backgroundColor {
    int red = getPreference(
      key: 'bg_red',
      defaultValue: Colors.black.withOpacity(0).red,
    );
    int green = getPreference(
      key: 'bg_green',
      defaultValue: Colors.black.withOpacity(0).green,
    );
    int blue = getPreference(
      key: 'bg_blue',
      defaultValue: Colors.black.withOpacity(0).blue,
    );

    return Color.fromRGBO(red, green, blue, 1);
  }

  /// Set the color of the background in the reader.
  void setBackgroundColor(Color color) {
    setPreference(key: 'bg_red', value: color.red);
    setPreference(key: 'bg_green', value: color.green);
    setPreference(key: 'bg_blue', value: color.blue);
  }

  /// Get whether or not the reader is RTL or LTR.
  bool get rightToLeft {
    return getPreference(key: 'right_to_left', defaultValue: true);
  }

  /// Toggle right to left mode.
  void toggleRightToLeft() {
    setPreference(key: 'right_to_left', value: !rightToLeft);
  }
}

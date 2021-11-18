import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'dart:async';

import 'package:chisa/media/media_sources/reader_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/pages/reader_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class ReaderTtuMediaSource extends ReaderMediaSource {
  ReaderTtuMediaSource()
      : super(
          sourceName: "ッツ Ebook Reader",
          icon: Icons.chrome_reader_mode_outlined,
        );

  @override
  String getHistoryCaption(MediaHistoryItem item) {
    return item.title;
  }

  @override
  String getHistorySubcaption(MediaHistoryItem item) {
    return item.author;
  }

  @override
  Future<ImageProvider<Object>> getHistoryThumbnail(
      MediaHistoryItem item) async {
    if (item.extra["ttu-thumbnail"] == null) {
      return MemoryImage(kTransparentImage);
    }

    UriData data = Uri.parse(item.thumbnailPath).data!;
    return MemoryImage(data.contentAsBytes());
  }

  @override
  URLRequest getInitialURLRequest(ReaderLaunchParams params) {
    return URLRequest(url: Uri.parse(params.mediaHistoryItem.key));
  }

  @override
  bool get noSearchAction => true;

  @override
  Future<void> onSearchBarTap(BuildContext context) async {
    AppModel appModel = Provider.of<AppModel>(context);

    MediaHistoryItem item = MediaHistoryItem(
      key: "https://ttu-ebook.web.app/",
      mediaTypePrefs: MediaType.reader.prefsDirectory(),
      sourceName: sourceName,
      currentProgress: 0,
      completeProgress: 0,
      extra: {},
    );

    ReaderLaunchParams params = ReaderLaunchParams.network(
      appModel: appModel,
      mediaSource: this,
      mediaHistoryItem: item,
    );

    await launchMediaPage(context, params);
  }

  @override
  ReaderLaunchParams getLaunchParams(AppModel appModel, MediaHistoryItem item) {
    return ReaderLaunchParams.network(
      mediaHistoryItem: item,
      mediaSource: this,
      appModel: appModel,
    );
  }

  @override
  FutureOr<List<MediaHistoryItem>?> getSearchMediaHistoryItems({
    required BuildContext context,
    required String searchTerm,
    required int pageKey,
  }) {
    return null;
  }

  @override
  Future<void> onConsoleMessage(InAppWebViewController webViewController,
      String consoleMessage, ReaderPageState readerPageState) {
    // TODO: implement onConsoleMessage
    throw UnimplementedError();
  }

  @override
  Future<void> onLoadStop(InAppWebViewController webViewController, Uri url,
      ReaderMediaSource readerMediaSource) {
    // TODO: implement onLoadStop
    throw UnimplementedError();
  }

  @override
  Future<void> onTitleChanged(
      InAppWebViewController webViewController, String title) {
    // TODO: implement onTitleChanged
    throw UnimplementedError();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/reader_page.dart';
import 'package:chisa/util/time_format.dart';

abstract class ReaderMediaSource extends MediaSource {
  ReaderMediaSource({
    required String sourceName,
    required IconData icon,
  }) : super(
          sourceName: sourceName,
          icon: icon,
          mediaType: MediaType.reader,
        );

  /// A [ReaderMediaSource] must be able to construct launch parameters from
  /// its media history items.
  ReaderLaunchParams getLaunchParams(AppModel appModel, MediaHistoryItem item);

  /// Push the navigator page to the media page pertaining to this media type.
  Future<void> launchMediaPage(
    BuildContext context,
    ReaderLaunchParams params, {
    bool pushReplacement = false,
  }) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);
    appModel.isInSource = true;

    if (pushReplacement) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => ReaderPage(params: params),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ReaderPage(params: params),
        ),
      );
    }

    appModel.isInSource = false;
  }

  @override
  Widget buildMediaHistoryItem({
    required BuildContext context,
    required MediaHistory history,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    bool isHistory = false,
  }) {
    AppModel appModel = Provider.of<AppModel>(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await launchMediaPage(context, getLaunchParams(appModel, item));
          homeRefreshCallback();
          searchRefreshCallback();
        },
        onLongPress: () async {
          AppModel appModel = Provider.of<AppModel>(context, listen: false);
          MediaHistory history = mediaType.getMediaHistory(appModel);

          List<Widget> actions = [];

          if (isHistory) {
            actions.add(TextButton(
              child: Text(
                appModel.translate("dialog_remove"),
                style: TextStyle(
                  color: Theme.of(context).focusColor,
                ),
              ),
              onPressed: () async {
                await history.removeItem(item.key);

                Navigator.pop(context);
                homeRefreshCallback();
                searchRefreshCallback();
              },
            ));
          }

          actions.addAll(
            getExtraHistoryActions(
              context: context,
              item: item,
              homeRefreshCallback: homeRefreshCallback,
              searchRefreshCallback: searchRefreshCallback,
              isHistory: isHistory,
            ),
          );

          actions.add(
            TextButton(
              child: Text(
                appModel.translate("dialog_play"),
                style: const TextStyle(),
              ),
              onPressed: () async {
                Navigator.pop(context);
                launchMediaPage(context, getLaunchParams(appModel, item));
                homeRefreshCallback();
                searchRefreshCallback();
              },
            ),
          );

          HapticFeedback.vibrate();
          ImageProvider<Object> image = await getHistoryThumbnail(item);
          await showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                getHistoryCaption(item),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              content: AspectRatio(
                aspectRatio: 16 / 9,
                child: FadeInImage(
                  image: image,
                  placeholder: MemoryImage(kTransparentImage),
                ),
              ),
              actions: actions,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 180,
                child: buildMediaHistoryThumbnail(
                  context: context,
                  item: item,
                  homeRefreshCallback: homeRefreshCallback,
                  searchRefreshCallback: searchRefreshCallback,
                  isHistory: isHistory,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: buildMediaHistoryMetadata(
                  context: context,
                  item: item,
                  homeRefreshCallback: homeRefreshCallback,
                  searchRefreshCallback: searchRefreshCallback,
                  isHistory: isHistory,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildMediaHistoryMetadata({
    required BuildContext context,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    bool isHistory = false,
  }) {
    Widget? extraMetadata = getHistoryExtraMetadata(
      context: context,
      item: item,
      homeRefreshCallback: homeRefreshCallback,
      searchRefreshCallback: searchRefreshCallback,
      isHistory: isHistory,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getHistoryCaption(item),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        const SizedBox(height: 8),
        Text(
          getHistorySubcaption(item),
          style: TextStyle(
            color: Theme.of(context).unselectedWidgetColor,
            fontSize: 12,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        const SizedBox(height: 2),
        if (isHistory)
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Icon(
              icon,
              color: Theme.of(context).unselectedWidgetColor,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              item.sourceName,
              style: TextStyle(
                color: Theme.of(context).unselectedWidgetColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ]),
        if (extraMetadata != null) extraMetadata
      ],
    );
  }

  @override
  Widget buildMediaHistoryThumbnail({
    required BuildContext context,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function()? searchRefreshCallback,
    bool isHistory = false,
  }) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          color: Colors.black,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: FutureBuilder<ImageProvider<Object>>(
              future: getHistoryThumbnail(item),
              builder: (BuildContext context,
                  AsyncSnapshot<ImageProvider> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return Image(image: MemoryImage(kTransparentImage));
                }

                ImageProvider<Object> thumbnail = snapshot.data!;

                return FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: thumbnail,
                  fit: BoxFit.fitWidth,
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 4.0,
          bottom: 6.0,
          child: Container(
            height: 20,
            color: Colors.black.withOpacity(0.8),
            alignment: Alignment.center,
            child: Text(
              getDurationText(Duration(seconds: item.completeProgress)),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        if (isHistory)
          Positioned(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: LinearProgressIndicator(
                value: item.currentProgress / item.completeProgress,
                backgroundColor: Colors.white.withOpacity(0.6),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                minHeight: 2,
              ),
            ),
          ),
      ],
    );
  }

  @override
  List<Widget> getExtraHistoryActions({
    required BuildContext context,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    bool isHistory = false,
  }) {
    return [];
  }

  @override
  Widget getDisplayLayout({
    required AppModel appModel,
    required BuildContext context,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    required ScrollController scrollController,
    required PagingController<int, MediaHistoryItem> pagingController,
  }) {
    AppModel appModel = Provider.of<AppModel>(context);
    MediaHistory mediaHistory = MediaHistory(
      appModel: appModel,
      prefsDirectory: mediaType.prefsDirectory(),
    );

    return PagedListView<int, MediaHistoryItem>(
      scrollController: scrollController,
      pagingController: pagingController,
      addAutomaticKeepAlives: true,
      key: UniqueKey(),
      builderDelegate: PagedChildBuilderDelegate<MediaHistoryItem>(
          itemBuilder: (context, item, index) {
        return buildMediaHistoryItem(
          context: context,
          history: mediaHistory,
          item: item,
          homeRefreshCallback: homeRefreshCallback,
          searchRefreshCallback: searchRefreshCallback,
        );
      }),
    );
  }

  /// From a [MediaHistoryItem], get an alias for an alternative caption to
  /// show for the item.
  String getHistoryCaptionAlias(MediaHistoryItem item);

  /// From a [MediaHistoryItem], get an alias for an alternative thumbnail to
  /// show for the item.
  Future<ImageProvider<Object>> getHistoryThumbnailAlias(MediaHistoryItem item);

  /// Define a custom options for the [InAppWebView] at startup of a
  /// [ReaderPage].
  URLRequest getInitialURLRequest(ReaderLaunchParams params);

  /// Define a custom options for the [InAppWebView] in the [ReaderPage] w
  /// when shown.
  InAppWebViewGroupOptions getInAppWebViewOptions(ReaderLaunchParams params) {
    return InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ),
    );
  }

  /// Define a custom menu for a source for the [InAppWebView] in the
  /// [ReaderPage] when shown.
  ContextMenu? getCustomContextMenu(ReaderPageState readerPageState) {
    return null;
  }

  /// Define a custom console message action to the [InAppWebView] in the
  /// [ReaderPage] when shown.
  Future<void> onConsoleMessage(
    InAppWebViewController webViewController,
    String consoleMessage,
    ReaderPageState readerPageState,
  ) async {}

  /// Define a custom load complete action for the [InAppWebView] in the
  /// [ReaderPage] when shown.
  Future<void> onLoadStop(
    InAppWebViewController webViewController,
    Uri url,
    ReaderMediaSource readerMediaSource,
  ) async {}

  /// Define a custom action for when the page title changes for the
  /// [InAppWebView] in the [ReaderPage] when shown.
  Future<void> onTitleChanged(
    InAppWebViewController webViewController,
    String title,
  ) async {}
}

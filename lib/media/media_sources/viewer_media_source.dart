import 'dart:io';

import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/viewer_page.dart';
import 'package:chisa/util/time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:collection/collection.dart';

enum ChapterProgressState {
  unstarted,
  viewed,
  finished,
}

abstract class ViewerMediaSource extends MediaSource {
  ViewerMediaSource({
    required String sourceName,
    required IconData icon,
  }) : super(
          sourceName: sourceName,
          icon: icon,
          mediaType: MediaType.viewer,
        );

  /// A [PlayerMediaSource] must be able to construct launch parameters from
  /// its media history items.
  ViewerLaunchParams getLaunchParams(AppModel appModel, MediaHistoryItem item);

  /// Push the navigator page to the media page pertaining to this media type.
  Future<void> launchMediaPage(
    BuildContext context,
    ViewerLaunchParams params, {
    bool pushReplacement = false,
  }) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);
    appModel.isInSource = true;

    if (pushReplacement) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => ViewerPage(params: params),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ViewerPage(params: params),
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

  String getHistoryCaptionAlias(MediaHistoryItem item) {
    return item.alias;
  }

  Future<ImageProvider<Object>?> getHistoryThumbnailAlias(
      MediaHistoryItem item) async {
    return FileImage(File(item.thumbnailPath));
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
            child: FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: getHistoryThumbnail(item),
              fit: BoxFit.fitWidth,
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

  /// A unique button for a [MediaSource] that appears on the menu of the
  /// [ViewerPage] when an item from the source is shown.
  Widget? buildSourceButton(BuildContext context, ViewerPageState page) {
    return null;
  }

  /// Get the name of the last chapter read pertaining to a [MediaHistoryItem].
  String? getLastReadChapterName(MediaHistoryItem item) {
    return item.extra["lastChapterRead"];
  }

  /// Get the name of the last chapter read pertaining to a [MediaHistoryItem].
  MediaHistoryItem setLastReadChapterName(
      MediaHistoryItem item, String chapter) {
    item.extra["lastChapterRead"] = chapter;
    return item;
  }

  /// Get the last chapter read pertaining to a [MediaHistoryItem] and a given
  /// list of [Chapter].
  String? getLastReadChapter(MediaHistoryItem item, List<String> chapters) {
    String? lastChapterName = item.extra["lastChapterRead"];
    if (lastChapterName == null) {
      return null;
    }

    return chapters.firstWhereOrNull((chapter) => chapter == lastChapterName);
  }

  /// Get the chapter before the last read chapter pertaining to a
  /// [MediaHistoryItem]  and a given list of [Chapter].
  String? getPreviousChapter(MediaHistoryItem item, List<String> chapters) {
    String? lastChapterRead = getLastReadChapterName(item);
    if (lastChapterRead == null) {
      return null;
    }
    if (chapters.isEmpty || chapters.length == 1) {
      return null;
    }

    for (int i = 0; i < chapters.length; i++) {
      if (chapters[i] == lastChapterRead) {
        if (i == 0) {
          return null;
        } else {
          return chapters[i - 1];
        }
      }
    }
  }

  /// Get the chapter after the last read chapter pertaining to a
  /// [MediaHistoryItem]  and a given list of [Chapter].
  String? getNextChapter(MediaHistoryItem item, List<String> chapters) {
    String? lastChapterRead = getLastReadChapterName(item);
    if (lastChapterRead == null) {
      return null;
    }
    if (chapters.isEmpty || chapters.length == 1) {
      return null;
    }

    for (int i = 0; i < chapters.length; i++) {
      if (chapters[i] == lastChapterRead) {
        if (i == chapters.length - 1) {
          return null;
        } else {
          return chapters[i + 1];
        }
      }
    }
  }

  ChapterProgressState getChapterProgress(
    MediaHistoryItem item,
    String chapter,
  ) {
    int? pageTotal = getChapterPageTotal(item, chapter);
    if (pageTotal == null) {
      return ChapterProgressState.unstarted;
    }

    int pageProgress = getChapterPageProgress(item, chapter) ?? 0;

    if (pageTotal == pageProgress) {
      return ChapterProgressState.finished;
    } else {
      return ChapterProgressState.viewed;
    }
  }

  int? getChapterPageProgress(
    MediaHistoryItem item,
    String chapter,
  ) {
    return item.extra["$chapter/pageProgress"];
  }

  MediaHistoryItem setChapterPageProgress(
    MediaHistoryItem item,
    String chapter,
    int pageProgress,
  ) {
    item.extra["$chapter/pageProgress"] = pageProgress;
    return item;
  }

  int? getChapterPageTotal(
    MediaHistoryItem item,
    String chapter,
  ) {
    return item.extra["$chapter/pageTotal"];
  }

  MediaHistoryItem setChapterPageTotal(
    MediaHistoryItem item,
    String chapter,
    int pageTotal,
  ) {
    item.extra["$chapter/pageTotal"] = pageTotal;
    return item;
  }

  /// Get all chapters given a [MediaHistoryItem].
  List<String> getChapters(MediaHistoryItem item);

  /// Given a [Chapter] from a [MediaHistoryItem], return a list of
  /// [ImageProvider<Object>] representing the chapter contents.
  Future<List<ImageProvider<Object>>> getChapterImages(
    MediaHistoryItem item,
    String chapter,
  );
}

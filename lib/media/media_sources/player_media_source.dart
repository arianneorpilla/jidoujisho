import 'dart:async';

import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';

import 'package:chisa/util/subtitle_utils.dart';
import 'package:chisa/util/time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/pages/player_page.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

abstract class PlayerMediaSource extends MediaSource {
  PlayerMediaSource({
    required String sourceName,
    required IconData icon,
  }) : super(
          sourceName: sourceName,
          icon: icon,
          mediaType: MediaType.player,
        );

  /// A [PlayerMediaSource] must be able to construct launch parameters from
  /// its media history items.
  PlayerLaunchParams getLaunchParams(AppModel appModel, MediaHistoryItem item);

  /// Push the navigator page to the media page pertaining to this media type.
  Future<void> launchMediaPage(
    BuildContext context,
    PlayerLaunchParams params, {
    bool pushReplacement = false,
  }) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);
    appModel.isInSource = true;

    if (pushReplacement) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => PlayerPage(params: params),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PlayerPage(params: params),
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
                appModel.translate('dialog_remove'),
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
                appModel.translate('dialog_play'),
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
          ImageProvider<Object> image = getHistoryThumbnail(item);
          await showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              title: Text(
                getHistoryCaption(item),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          icon,
                          color: Theme.of(context).unselectedWidgetColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.sourceName,
                          style: TextStyle(
                            color: Theme.of(context).unselectedWidgetColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image(
                        image: image,
                      ),
                    ),
                  ],
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

  /// A button that shows on the player menu particular to the media source.
  Widget? buildSourceButton(BuildContext context, PlayerPageState page);

  FutureOr<List<SubtitleItem>> provideSubtitles(PlayerLaunchParams params);

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

  /// A source can define extra actions that appears when you long press
  /// on a history item in the Player screen.
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
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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

  FutureOr<String> getNetworkStreamUrl(PlayerLaunchParams params);

  FutureOr<String?> getAudioStreamUrl(PlayerLaunchParams params) {
    return null;
  }

  /// Particular to YouTube export... For some reason it needs a specific
  /// quality to export to FFMPEG...
  FutureOr<String>? getExportVideoDataSource(PlayerLaunchParams params) {
    return null;
  }

  /// Particular to YouTube export... For some reason it needs a specific
  /// quality to export to FFMPEG...
  FutureOr<String>? getExportAudioDataSource(PlayerLaunchParams params) {
    return null;
  }
}

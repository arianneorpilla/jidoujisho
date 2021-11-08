import 'dart:async';

import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/media_source_action_button.dart';

import 'package:chisa/util/subtitle_utils.dart';
import 'package:chisa/util/time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/pages/player_page.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wakelock/wakelock.dart';

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

    await Wakelock.enable();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (pushReplacement) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => PlayerPage(params: params),
        ),
      );

      await Wakelock.enable();
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PlayerPage(params: params),
        ),
      );
    }

    await Wakelock.disable();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    appModel.isInSource = false;
  }

  FutureOr<List<SubtitleItem>> provideSubtitles(PlayerLaunchParams params);

  /// A button that shows on the player menu particular to the media source.
  Widget? buildSourceButton(BuildContext context, PlayerPageState page);

  @override
  Widget buildMediaHistoryItem({
    required BuildContext context,
    required MediaHistory history,
    required MediaHistoryItem item,
    required Function() refreshCallback,
  }) {
    AppModel appModel = Provider.of<AppModel>(context);

    return InkWell(
      onTap: () async {
        await launchMediaPage(context, getLaunchParams(appModel, item));
        refreshCallback();
      },
      onLongPress: () async {
        List<Widget> actions = [];
        actions.add(
          TextButton(
            child: Text(
              appModel.translate("dialog_remove"),
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onPressed: () async {
              await history.removeItem(item.key);

              Navigator.pop(context);
              refreshCallback();
            },
          ),
        );

        actions.addAll(getExtraHistoryActions(item, refreshCallback));

        actions.add(
          TextButton(
            child: Text(
              appModel.translate("dialog_play"),
              style: const TextStyle(),
            ),
            onPressed: () async {
              Navigator.pop(context);
              launchMediaPage(context, getLaunchParams(appModel, item));
              refreshCallback();
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
            buildMediaHistoryThumbnail(context, item),
            const SizedBox(width: 8),
            Expanded(
              child: buildMediaHistoryMetadata(context, item),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildMediaHistoryMetadata(
    BuildContext context,
    MediaHistoryItem item,
  ) {
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
        getHistoryExtraMetadata(item),
      ],
    );
  }

  @override
  Widget getHistoryExtraMetadata(MediaHistoryItem item) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildMediaHistoryThumbnail(
    BuildContext context,
    MediaHistoryItem item,
  ) {
    double scaleWidth = MediaQuery.of(context).size.shortestSide * 0.4;

    return Container(
      width: scaleWidth,
      height: (scaleWidth) / 16 * 9,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FutureBuilder<ImageProvider<Object>>(
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
                  fit: BoxFit.contain,
                );
              }),
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
      ),
    );
  }

  /// A source can define extra actions that appears when you long press
  /// on a history item in the Player screen.
  @override
  List<MediaSourceActionButton> getExtraHistoryActions(
    MediaHistoryItem item,
    Function()? refreshCallback,
  ) {
    return [];
  }

  @override
  Widget getDisplayLayout({
    required AppModel appModel,
    required BuildContext context,
    required Function() refreshCallback,
    required ScrollController scrollController,
    required List<MediaHistoryItem> items,
  }) {
    AppModel appModel = Provider.of<AppModel>(context);
    MediaHistory mediaHistory = MediaHistory(
      appModel: appModel,
      prefsDirectory: mediaType.prefsDirectory(),
    );

    return ListView.builder(
      controller: scrollController,
      addAutomaticKeepAlives: true,
      key: UniqueKey(),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return buildMediaHistoryItem(
          context: context,
          history: mediaHistory,
          item: items[index],
          refreshCallback: refreshCallback,
        );
      },
    );
  }

  FutureOr<String> getNetworkStreamUrl(PlayerLaunchParams params);
}

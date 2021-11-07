import 'dart:async';

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
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wakelock/wakelock.dart';

abstract class PlayerMediaSource extends MediaSource {
  PlayerMediaSource({
    required String sourceName,
    required IconData icon,
    required bool searchSupport,
    String? searchLabel,
    Future<void> Function(String, BuildContext)? searchAction,
  }) : super(
          sourceName: sourceName,
          icon: icon,
          mediaType: MediaType.player,
          searchSupport: searchSupport,
          searchLabel: searchLabel,
          searchAction: searchAction,
        );

  /// A [PlayerMediaSource] must be able to construct launch parameters from
  /// its media history items.
  PlayerLaunchParams getLaunchParams(MediaHistoryItem item);

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
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

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

  Widget buildMediaHistoryItem({
    required BuildContext context,
    required MediaHistoryItem item,
    Widget? metadataWidget,
    Function()? onTap,
    Function()? onLongPress,
  }) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            buildMediaHistoryThumbnail(context, item),
            const SizedBox(width: 12),
            Expanded(
              child: metadataWidget ?? buildMediaHistoryMetadata(context, item),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMediaHistoryMetadata(
    BuildContext context,
    MediaHistoryItem item,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getCaption(item),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        const SizedBox(height: 8),
        Text(
          getSubcaption(item),
          style: TextStyle(
            color: Theme.of(context).unselectedWidgetColor,
            fontSize: 12,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).unselectedWidgetColor,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              sourceName,
              style: TextStyle(
                color: Theme.of(context).unselectedWidgetColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMediaHistoryThumbnail(
    BuildContext context,
    MediaHistoryItem item,
  ) {
    double scaleWidth = MediaQuery.of(context).size.width * 0.4;

    return Container(
      width: scaleWidth,
      height: (scaleWidth) / 16 * 9,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FutureBuilder<ImageProvider<Object>>(
              future: getThumbnail(item),
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
  List<Widget> getExtraHistoryActions(
    MediaHistoryItem item, {
    Function()? callback,
  }) {
    return [];
  }

  FutureOr<String> getNetworkStreamUrl(PlayerLaunchParams params);
}

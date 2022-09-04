import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A media source that allows the user to stream video from a URL.
class PlayerNetworkStreamSource extends PlayerMediaSource {
  /// Define this media source.
  PlayerNetworkStreamSource._privateConstructor()
      : super(
          uniqueKey: 'player_network_stream',
          sourceName: 'Network Stream',
          description: 'Stream videos from a direct URL.',
          icon: Icons.podcasts,
          implementsSearch: false,
          implementsHistory: false,
        );

  /// Get the singleton instance of this media type.
  static PlayerNetworkStreamSource get instance => _instance;

  static final PlayerNetworkStreamSource _instance =
      PlayerNetworkStreamSource._privateConstructor();

  @override
  BaseSourcePage buildLaunchPage({MediaItem? item}) {
    return PlayerSourcePage(
      item: item,
      source: this,
      useHistory: false,
    );
  }

  /// Produce media item from URL.
  MediaItem getMediaItemFromUrl(String url) {
    return MediaItem(
      title: url,
      mediaIdentifier: url,
      mediaSourceIdentifier: uniqueKey,
      mediaTypeIdentifier: mediaType.uniqueKey,
      position: 0,
      duration: 0,
      canEdit: false,
      canDelete: false,
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
      builder: (context) => NetworkStreamDialogPage(
        onPlay: (url) {
          Navigator.pop(context);

          MediaItem item = getMediaItemFromUrl(url);

          appModel.openMedia(
            context: context,
            ref: ref,
            mediaSource: this,
            item: item,
          );
        },
      ),
    );
  }

  @override
  Future<VlcPlayerController> preparePlayerController({
    required AppModel appModel,
    required WidgetRef ref,
    required MediaItem item,
  }) async {
    String dataSource = item.mediaIdentifier;
    int startTime = item.position;

    List<String> advancedParams = ['--start-time=$startTime'];
    List<String> audioParams = [
      '--sub-track=99999',
    ];

    return VlcPlayerController.network(
      dataSource,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions(advancedParams),
        audio: VlcAudioOptions(audioParams),
      ),
    );
  }

  @override
  Future<List<SubtitleItem>> prepareSubtitles({
    required AppModel appModel,
    required WidgetRef ref,
    required MediaItem item,
  }) async {
    return [];
  }
}

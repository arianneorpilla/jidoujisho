import 'dart:async';

import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A source for the [PlayerMediaType], which handles primarily video-based
/// media.
abstract class PlayerMediaSource extends MediaSource {
  /// Initialise a media source.
  PlayerMediaSource({
    required super.uniqueKey,
    required super.sourceName,
    required super.description,
    required super.icon,
    required super.implementsSearch,
  }) : super(
          mediaType: PlayerMediaType.instance,
        );

  /// The body widget to show in the tab when this source's media type and this
  /// source is selected.
  @override
  BaseHistoryPage buildHistoryPage({MediaItem? item}) {
    return const HistoryPlayerPage();
  }

  /// Get the player controller to be used when a media item is loaded up,
  Future<VlcPlayerController> preparePlayerController(MediaItem item) async {
    throw UnimplementedError();
  }

  /// Get the player controller to be used when a media item is loaded up,
  Future<List<SubtitleItem>> prepareSubtitles(MediaItem item) async {
    throw UnimplementedError();
  }

  /// Prepare a payload including a controller and subtitles.
  Future<PlayerPayload> preparePayload(MediaItem item) async {
    VlcPlayerController controller = await preparePlayerController(item);
    List<SubtitleItem> subtitleItems = await prepareSubtitles(item);

    return PlayerPayload(
      controller: controller,
      subtitleItems: subtitleItems,
    );
  }
}

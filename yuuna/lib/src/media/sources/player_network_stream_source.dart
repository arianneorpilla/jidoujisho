import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

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
          canDeleteHistory: true,
          canOverrideDisplayValues: false,
        );

  /// Get the singleton instance of this media type.
  static PlayerNetworkStreamSource get instance => _instance;

  static final PlayerNetworkStreamSource _instance =
      PlayerNetworkStreamSource._privateConstructor();

  @override
  BaseSourcePage buildLaunchPage({MediaItem? item}) {
    return const PlaceholderSourcePage();
  }
}

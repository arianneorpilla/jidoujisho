import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// A media source that allows the user to watch videos in their local device
/// storage.
class PlayerLocalMediaSource extends PlayerMediaSource {
  /// Define this media source.
  PlayerLocalMediaSource._privateConstructor()
      : super(
          uniqueKey: 'player_local_media',
          sourceName: 'Local Media',
          description: 'Play videos sourced from local device storage.',
          icon: Icons.storage,
          implementsSearch: false,
        );

  /// Get the singleton instance of this media type.
  static PlayerLocalMediaSource get instance => _instance;

  static final PlayerLocalMediaSource _instance =
      PlayerLocalMediaSource._privateConstructor();

  @override
  BaseSourcePage buildLaunchPage({MediaItem? item}) {
    return const PlaceholderSourcePage();
  }
}

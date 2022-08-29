import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// A media source that allows the user to stream a selected video from YouTube.
class PlayerYoutubeSource extends PlayerMediaSource {
  /// Define this media source.
  PlayerYoutubeSource._privateConstructor()
      : super(
          uniqueKey: 'player_youtube',
          sourceName: 'YouTube',
          description: 'Select and watch videos from YouTube.',
          icon: Icons.smart_display,
          implementsSearch: false,
           implementsHistory: true,
        );

  /// Get the singleton instance of this media type.
  static PlayerYoutubeSource get instance => _instance;

  static final PlayerYoutubeSource _instance =
      PlayerYoutubeSource._privateConstructor();

  @override
  BaseSourcePage buildLaunchPage({MediaItem? item}) {
    return const PlaceholderSourcePage();
  }
}

import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:yuuna/utils.dart';

/// A class that bundles together necessary entities for using the player.
class PlayerPayload {
  /// Initialise a payload.
  const PlayerPayload({
    required this.controller,
    required this.subtitleItems,
  });

  /// Contains information on the media to be played.
  final VlcPlayerController controller;

  /// Contains subtitles to be included during media playback.
  final List<SubtitleItem> subtitleItems;
}

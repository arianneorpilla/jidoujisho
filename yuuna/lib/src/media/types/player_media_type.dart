import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';

/// Media type that encapsulates videos or music.
class PlayerMediaType extends MediaType {
  /// Initialise this media type.
  PlayerMediaType()
      : super(
          uniqueKey: 'player_media_type',
          icon: Icons.video_library,
        );

  @override
  Widget get home => Container();
}

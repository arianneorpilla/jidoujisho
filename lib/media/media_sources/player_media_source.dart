import 'dart:io';

import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_history_items/default_media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/media/media_types/player_media_type.dart';
import 'package:flutter/material.dart';

abstract class PlayerMediaSource extends MediaSource {
  PlayerMediaSource({
    required String sourceName,
    required IconData icon,
    required bool searchSupport,
    VoidCallback? searchAction,
  }) : super(
          sourceName: sourceName,
          icon: icon,
          mediaType: PlayerMediaType(),
          searchSupport: searchSupport,
          searchAction: searchAction,
        );

  /// A [PlayerMediaSource] must be able to construct launch parameters from
  /// its media history items.
  PlayerLaunchParams getLaunchParams(DefaultMediaHistoryItem item);

  /// Push the navigator page to the media page pertaining to this media type.
  Future<void> launchMediaPage(
      BuildContext context, PlayerLaunchParams params) async {}

  @override
  Widget? getButton(BuildContext context) {
    return null;
  }
}

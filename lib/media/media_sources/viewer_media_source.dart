import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:flutter/material.dart';

abstract class ViewerMediaSource extends MediaSource {
  ViewerMediaSource({
    required String sourceName,
    required IconData icon,
  }) : super(
          sourceName: sourceName,
          icon: icon,
          mediaType: MediaType.viewer,
        );

  /// A [PlayerMediaSource] must be able to construct launch parameters from
  /// its media history items.
  ViewerLaunchParams getLaunchParams(MediaHistoryItem item);

  /// Push the navigator page to the media page pertaining to this media type.
  Future<void> launchMediaPage(
      BuildContext context, ViewerLaunchParams params) async {}

  @override
  Widget? getButton(BuildContext context, Function() refreshCallback) {
    return null;
  }
}

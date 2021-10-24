import 'package:chisa/media/media_history_items/default_media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/media/media_types/reader_media_type.dart';
import 'package:flutter/material.dart';

abstract class ReaderMediaSource extends MediaSource {
  ReaderMediaSource({
    required String sourceName,
    required IconData icon,
    required bool searchSupport,
    String? searchLabel,
    Future<void> Function()? searchAction,
  }) : super(
          sourceName: sourceName,
          icon: icon,
          mediaType: ReaderMediaType(),
          searchSupport: searchSupport,
          searchLabel: searchLabel,
          searchAction: searchAction,
        );

  /// A [PlayerMediaSource] must be able to construct launch parameters from
  /// its media history items.
  ReaderLaunchParams getLaunchParams(DefaultMediaHistoryItem item);

  /// Push the navigator page to the media page pertaining to this media type.
  Future<void> launchMediaPage(
      BuildContext context, ReaderLaunchParams params) async {}

  @override
  Widget? getButton(BuildContext context) {
    return null;
  }
}

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/pages/viewer_page.dart';
import 'package:chisa/util/comic.dart';
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

  /// A unique button for a [MediaSource] that appears on the menu of the
  /// [ViewerPage] when an item from the source is shown.
  Widget? buildSourceButton(BuildContext context, ViewerPageState page) {
    return null;
  }

  /// From a [MediaHistoryItem], get an alias for an alternative caption to
  /// show for the item.
  String getHistoryCaptionAlias(MediaHistoryItem item);

  /// From a [MediaHistoryItem], get an alias for an alternative thumbnail to
  /// show for the item.
  Future<ImageProvider<Object>> getHistoryThumbnailAlias(MediaHistoryItem item);

  /// Get the  name of the last chapter read pertaining to
  /// the [MediaHistoryItem].
  String getLastChapterRead();

  /// Get all chapters given a [MediaHistoryItem].
  List<Chapter> getChapters();
}

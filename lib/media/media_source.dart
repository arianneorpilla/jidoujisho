import 'dart:async';

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/media_source_action_button.dart';
import 'package:flutter/material.dart';

import 'media_histories/media_history.dart';

/// A source for a [MediaType] that will appear on the list of sources when
/// set as active. Handles sourcing and delivery of arguments such that the
/// [MediaType] is able to execute and launch with the proper arguments.
abstract class MediaSource {
  MediaSource({
    required this.sourceName,
    required this.mediaType,
    required this.icon,
  });

  /// The name for this that will appear under the media type's source picker.
  final String sourceName;

  /// Which media type this source pertains to.
  final MediaType mediaType;

  final IconData icon;

  bool isShown(AppModel appModel) {
    return appModel.getMediaSourceShown(this);
  }

  /// The unique identifier that is passed to the source parameter
  String getIdentifier() {
    return "${mediaType.prefsDirectory()}/$sourceName";
  }

  /// From a [MediaHistoryItem], generate the thumbnail of this item that will
  /// show up in the home screen.
  Future<ImageProvider> getHistoryThumbnail(MediaHistoryItem item);

  /// From a [MediaHistoryItem], get a caption of the metadata to display.
  String getHistoryCaption(MediaHistoryItem item);

  /// From a [MediaHistoryItem], get a subcaption of the metadata to display.
  String getHistorySubcaption(MediaHistoryItem item);

  /// A list of [Widget] to show in the [MediaSourceSearchBar] when this source
  /// is active in its media type tab. This will be the leading actions in the
  /// search bar.
  List<MediaSourceActionButton> getSearchBarActions(
    BuildContext context,
    Function() refreshCallback,
  );

  /// If true, [onSearchBarTap] should be executed when tapping on the search
  /// bar.
  bool noSearchAction = false;

  /// If this is not null, this action is executed when the user taps on the
  /// search bar. Sources that do not have a search action should have this
  /// defined.
  Future<void> onSearchBarTap(BuildContext context) {
    throw UnimplementedError();
  }

  /// This returns a list of [MediaHistoryItem], and is performed to search
  /// the media source for items. If [onTap] is true, this can remain null as
  /// no search function actually occurs
  FutureOr<List<MediaHistoryItem>>? getSearchMediaHistoryItems(
      String searchTerm);

  /// Given a search term, this source may give search suggestions. If the
  /// empty list is returned, then search history will be shown instead.
  Future<List<String>> generateSearchSuggestions(String searchTerm) {
    return Future.value([]);
  }

  /// Get how this media source displays its items - this will probably be
  /// a [ListView] or a [GridView].
  Widget getDisplayLayout({
    required AppModel appModel,
    required BuildContext context,
    required Function() refreshCallback,
    required ScrollController scrollController,
    required List<MediaHistoryItem> items,
  });

  Widget buildMediaHistoryItem({
    required BuildContext context,
    required MediaHistory history,
    required MediaHistoryItem item,
    required Function() refreshCallback,
    bool isHistory = false,
  });

  Widget buildMediaHistoryMetadata(
    BuildContext context,
    MediaHistoryItem item, {
    bool isHistory = false,
  });

  Widget getHistoryExtraMetadata(BuildContext context, MediaHistoryItem item);

  Widget buildMediaHistoryThumbnail(
    BuildContext context,
    MediaHistoryItem item, {
    bool isHistory = false,
  });

  /// A source can define extra actions that appears when you long press
  /// on a history item in the Player screen.
  List<Widget> getExtraHistoryActions(
      BuildContext context, MediaHistoryItem item, Function()? refreshCallback,
      {bool isHistory = false});

  /// Number in milliseconds of how long it should take for the search bar to
  /// respond to query changes. For expensive operations, the debounce should
  /// probably remain the default value. Otherwise, if search suggestions can
  /// be generated efficiently, this can be 0.
  int getSearchDebounceDelay = 500;
}

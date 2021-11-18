import 'dart:async';

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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

  /// An icon that shows in the media source selection screen and when active
  /// on the search bar of its source media tab.
  final IconData icon;

  /// A unique identifier that represents the media source's name along with
  /// its media type. Useful for storing entries in shared preferences.
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
  List<Widget> getSearchBarActions(
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
  FutureOr<List<MediaHistoryItem>?> getSearchMediaHistoryItems({
    required BuildContext context,
    required String searchTerm,
    required int pageKey,
  });

  /// Given a search term, this source may give search suggestions. If the
  /// empty list is returned, then search history will be shown instead.
  Future<List<String>> generateSearchSuggestions(String searchTerm) {
    return Future.value([]);
  }

  /// Get how this media source displays its items when active under the search
  /// bar - this will probably be a [ListView] or a [GridView].
  Widget getDisplayLayout({
    required AppModel appModel,
    required BuildContext context,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    required ScrollController scrollController,
    required PagingController<int, MediaHistoryItem> pagingController,
  });

  /// Builds a widget to represent the [MediaHistoryItem]. Clicking on this
  /// item should start the media, and it should generally have a thumbnail and
  /// metadata describing the item.
  Widget buildMediaHistoryItem({
    required BuildContext context,
    required MediaHistory history,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    bool isHistory = false,
  });

  /// A helper function called within [buildMediaHistoryItem] to show the
  /// metadata of a [MediaHistoryItem].
  Widget buildMediaHistoryMetadata({
    required BuildContext context,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    bool isHistory = false,
  });

  /// Extra metadata that can optionally be defined. This is typically added
  /// to a list within [buildMediaHistoryMetadata] if non-null. If null, no
  /// widget should be appended to the list.
  Widget? getHistoryExtraMetadata({
    required BuildContext context,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    bool isHistory = false,
  }) {
    return null;
  }

  /// Thumbnail which represents a [MediaHistoryItem] when shown in history or
  /// in search.
  Widget buildMediaHistoryThumbnail({
    required BuildContext context,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    bool isHistory = false,
  });

  /// A [MediaSource] can define extra actions that appears when you long press
  /// on a history item in the Player screen.
  List<Widget> getExtraHistoryActions({
    required BuildContext context,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    bool isHistory = false,
  }) {
    return [];
  }

  /// Number in milliseconds of how long it should take for the search bar to
  /// respond to query changes. For expensive operations, the debounce should
  /// probably remain the default value. Otherwise, if search suggestions can
  /// be generated efficiently, this can be 0.
  int getSearchDebounceDelay = 500;

  int getSearchPageSize = 20;
}

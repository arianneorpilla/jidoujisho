import 'package:chisa/media/media_history.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:flutter/material.dart';

import 'package:chisa/media/media_history_item.dart';

abstract class MediaType {
  MediaType({
    required this.mediaTypeName,
    required this.mediaTypeIcon,
  });

  /// The default localisation name of this media type for preferencing
  /// purposes.
  late String mediaTypeName;

  /// The icon that shows on the bottom navigation bar.
  late IconData mediaTypeIcon;

  /// Given a [Uri], pointing to a file, a directory or a link, return a value
  /// for whether or not it is appropriate to the media type.
  ///
  /// For example, the Reader should support EPUB files, while the Player
  /// should only support video files.
  bool isUriSupported(Uri uri);

  /// Given a [Uri], create a new history item with the appropriate uri,
  /// initial progress and name.
  MediaHistoryItem getNewHistoryItem(Uri uri);

  /// Some screens might merge their histories. For example, viewing videos
  /// from another media type that uses a streaming service might decide to add
  /// its history to the "Player" screen. This can be called to redirect
  /// action to that other media type.
  MediaType? getFallbackMediaType(MediaHistoryItem mediaHistoryItem);

  /// The widget that is shown when the bottom navigation bar item from
  /// [getHomeNavigationBarItem] is active in the home page.
  ///
  /// For example, in the case of the Reader, this is a history of books to
  /// pick from. For the player, this shows the playback history.
  MediaHomePage getHomeBody(BuildContext context);

  /// A bottom navigation bar item that represents the media type in the home
  /// screen.
  ///
  /// For example, in the case of the Reader, this is a bottom navigation bar
  /// item with a book icon and labelled as "Reader". For the player, this
  /// is a nav bar item with a video icon and labelled as "Player".
  BottomNavigationBarItem getHomeTab(BuildContext context);

  /// Given a [MediaHistoryItem], launch the appropriate page for the media
  /// type, returning to the appropriate progress marker if given.
  ///
  /// For example, if progress is 54, in the Player, the player page should
  /// resume at 54 seconds.
  ///
  /// This function should perform necessary checking for whether or not
  /// the [MediaHistoryItem]'s given [Uri] is supported, and if not,
  /// [getFallbackMediaType] may point it to the appropriate media type,
  /// which will then handle its own [launchMediaPage] function.
  void launchMediaPageFromHistory(
      BuildContext context, MediaHistoryItem mediaHistoryItem);

  /// Given a [Uri], launch the appropriate page for the media
  /// type with progress zero.
  ///
  /// This function should perform necessary checking for whether or not
  /// the [MediaHistoryItem]'s given [Uri] is supported, and if not,
  /// [getFallbackMediaType] may point it to the appropriate media type,
  /// which will then handle its own [launchMediaPage] function.
  void launchMediaPageFromUri(BuildContext context, Uri uri);

  /// Get the media history for this certain media type.
  MediaHistory getMediaHistory(BuildContext context);
}

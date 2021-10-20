import 'package:chisa/media/media_history.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:flutter/material.dart';

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

  /// Get the media history for this certain media type.
  MediaHistory getMediaHistory(BuildContext context);

  /// The explicit file types this media source allows for file picking.
  List<String> getAllowedExtensions();
}

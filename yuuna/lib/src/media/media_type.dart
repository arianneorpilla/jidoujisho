import 'package:flutter/widgets.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

/// A type of media that is significantly distinguishable from other media such
/// that it is deserving of its own core functionality when viewing media items.
/// A [MediaType] has its own history and home tab.
abstract class MediaType with ChangeNotifier {
  /// Initialise this media type with the predetermined and hardset values.
  MediaType({
    required this.uniqueKey,
    required this.icon,
    required this.outlinedIcon,
  });

  /// A unique name that allows distinguishing this type from others,
  /// particularly for the purposes of differentiating between persistent
  /// settings keys. This does not differ when the user's app language changes.
  final String uniqueKey;

  /// An icon that will represent this media type in its home tab.
  final IconData icon;

  /// An icon that represents this media type when unselected in its home tab.
  final IconData outlinedIcon;

  /// The body that will be shown when this media type's tab is the current
  /// selected home tab.
  Widget get home;

  /// The controller to be used for this media type's home tab when it has
  /// enough media items to display that require the tab to be scrollable.
  ScrollController scrollController = ScrollController();

  /// The floating search bar controller for this media type's tab page.
  final FloatingSearchBarController floatingSearchBarController =
      FloatingSearchBarController();

  /// Used to notify the media type tab to refresh.
  final ChangeNotifier tabRefreshNotifier = ChangeNotifier();

  /// Use this to refresh a media type's tab page on the main menu.
  void refreshTab() {
    tabRefreshNotifier.notifyListeners();
  }

  @override
  operator ==(Object other) =>
      other is MediaType && other.uniqueKey == uniqueKey;

  @override
  int get hashCode => uniqueKey.hashCode;
}

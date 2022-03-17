import 'package:flutter/widgets.dart';

/// A type of media that is significantly distinguishable from other media such
/// that it is deserving of its own core functionality when viewing media items.
/// A [MediaType] has its own history and home tab.
abstract class MediaType {
  /// Initialise this media type with the predetermined and hardset values.
  const MediaType({
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
  StatelessWidget get home;

  @override
  operator ==(Object other) =>
      other is MediaType && other.uniqueKey == uniqueKey;

  @override
  int get hashCode => uniqueKey.hashCode;
}

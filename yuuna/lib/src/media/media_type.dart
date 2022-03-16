import 'package:flutter/widgets.dart';

/// A type of media that is significantly distinguishable from other media such
/// that it is deserving of its own core functionality when viewing media items.
/// A [MediaType] has its own history and home tab.
abstract class MediaType {
  /// Initialise this media type with the predetermined and hardset values.
  const MediaType({
    required this.uniqueKey,
    required this.icon,
  });

  /// A unique name that allows distinguishing this type from others,
  /// particularly for the purposes of differentiating between persistent
  /// settings keys. This does not differ when the user's app language changes.
  final String uniqueKey;

  /// An icon that will represent this media type in its home tab.
  final IconData icon;

  /// The body that will be shown when this media type's tab is the current
  /// selected home tab.
  Widget get home;
}

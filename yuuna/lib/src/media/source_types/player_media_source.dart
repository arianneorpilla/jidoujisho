import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// A source for the [PlayerMediaType], which handles primarily video-based
/// media.
abstract class PlayerMediaSource extends MediaSource {
  /// Initialise a media source.
  PlayerMediaSource({
    required super.uniqueKey,
    required super.sourceName,
    required super.description,
    required super.icon,
    required super.implementsSearch,
  }) : super(
          mediaType: PlayerMediaType.instance,
        );

  /// The body widget to show in the tab when this source's media type and this
  /// source is selected.
  @override
  BaseHistoryPage buildHistoryWidget({MediaItem? item}) {
    return const HistoryPlayerPage();
  }
}

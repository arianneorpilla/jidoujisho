import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// A source for the [ViewerMediaType], which handles primarily image-based
/// media.
abstract class ViewerMediaSource extends MediaSource {
  /// Initialise a media source.
  ViewerMediaSource({
    required super.uniqueKey,
    required super.sourceName,
    required super.description,
    required super.icon,
    required super.implementsSearch,
  }) : super(
          mediaType: ViewerMediaType.instance,
        );

  /// The body widget to show in the tab when this source's media type and this
  /// source is selected.
  @override
  BaseHistoryPage buildHistoryWidget({MediaItem? item}) {
    return const HistoryViewerPage();
  }
}

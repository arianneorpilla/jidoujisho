import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// A source for the [ReaderMediaType], which handles primarily text-based
/// media.
abstract class ReaderMediaSource extends MediaSource {
  /// Initialise a media source.
  ReaderMediaSource({
    required super.uniqueKey,
    required super.sourceName,
    required super.description,
    required super.icon,
    required super.implementsSearch,
    required super.implementsHistory,
  }) : super(
          mediaType: ReaderMediaType.instance,
        );

  @override
  double get aspectRatio => 176 / 250;

  /// The body widget to show in the tab when this source's media type and this
  /// source is selected.
  @override
  BasePage buildHistoryPage({MediaItem? item}) {
    return const HistoryReaderPage();
  }
}

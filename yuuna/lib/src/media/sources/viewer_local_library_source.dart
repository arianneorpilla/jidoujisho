import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// A media source that allows the user to read from on-device downloaded
/// manga stored in a Tachiyomi-compatible file structure and use optical
/// character recognition features.
class ViewerMangaReaderSource extends ViewerMediaSource {
  /// Define this media source.
  ViewerMangaReaderSource._privateConstructor()
      : super(
          uniqueKey: 'viewer_manga_reader',
          sourceName: 'Manga Reader',
          description: 'Read on-device manga chapters stored in a'
              ' Tachiyomi-compatible folder structure.',
          icon: Icons.photo_album,
          implementsSearch: false,
        );

  /// Get the singleton instance of this media type.
  static ViewerMangaReaderSource get instance => _instance;

  static final ViewerMangaReaderSource _instance =
      ViewerMangaReaderSource._privateConstructor();

  @override
  BaseSourcePage buildLaunchWidget({MediaItem? item}) {
    return const PlaceholderSourcePage();
  }
}

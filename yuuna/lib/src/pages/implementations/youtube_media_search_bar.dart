import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// The search bar used for the [YoutubeMediaSearchBar].
class YoutubeMediaSearchBar extends BaseMediaSearchBar {
  /// Create an instance of this bar.
  const YoutubeMediaSearchBar({super.key});

  @override
  BaseMediaSearchBarState<YoutubeMediaSearchBar> createState() =>
      _YoutubeMediaSearchBar();
}

/// State for [YoutubeMediaSearchBar].
class _YoutubeMediaSearchBar
    extends BaseMediaSearchBarState<YoutubeMediaSearchBar> {
  @override
  MediaSource get mediaSource => PlayerYoutubeSource.instance;

  @override
  MediaType get mediaType => PlayerMediaType.instance;

  @override
  Duration get searchDelay => const Duration(seconds: 2);

  /// Shows when there are proper search results returned.
  @override
  Widget buildResultList() {
    return VideoResultsPage(
      title: mediaType.floatingSearchBarController.query,
      pagingController: pagingController!,
      showAppBar: false,
    );
  }
}

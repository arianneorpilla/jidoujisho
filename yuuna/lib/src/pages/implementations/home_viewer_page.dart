import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// The body content for the Viewer tab in the main menu.
class HomeViewerPage extends BaseTabPage {
  /// Create an instance of this page.
  const HomeViewerPage({Key? key}) : super(key: key);

  @override
  BaseTabPageState<BaseTabPage> createState() => _HomeViewerPageState();
}

class _HomeViewerPageState<T extends BaseTabPage> extends BaseTabPageState {
  @override
  MediaType get mediaType => ViewerMediaType.instance;

  @override
  bool get shouldPlaceholderBeShown => true;
}

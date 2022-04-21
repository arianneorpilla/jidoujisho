import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// The body content for the Player tab in the main menu.
class HomePlayerPage extends BaseTabPage {
  /// Create an instance of this page.
  const HomePlayerPage({Key? key}) : super(key: key);

  @override
  BaseTabPageState<BaseTabPage> createState() => _HomePlayerPageState();
}

class _HomePlayerPageState<T extends BaseTabPage> extends BaseTabPageState {
  @override
  MediaType get mediaType => PlayerMediaType.instance;

  @override
  bool get shouldPlaceholderBeShown => true;
}

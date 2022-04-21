import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// The body content for the Dictionary tab in the main menu.
class HomeDictionaryPage extends BaseTabPage {
  /// Create an instance of this page.
  const HomeDictionaryPage({Key? key}) : super(key: key);

  @override
  BaseTabPageState<BaseTabPage> createState() => _HomeDictionaryPageState();
}

class _HomeDictionaryPageState<T extends BaseTabPage> extends BaseTabPageState {
  @override
  MediaType get mediaType => DictionaryMediaType.instance;

  @override
  bool get shouldPlaceholderBeShown => true;
}

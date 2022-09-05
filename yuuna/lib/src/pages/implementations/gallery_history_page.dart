import 'package:flutter/material.dart';
import 'package:yuuna/pages.dart';

/// The media page used for unimplemented sources.
class GalleryHistoryPage extends BasePage {
  /// Create an instance of this page.
  const GalleryHistoryPage({
    super.key,
  });

  @override
  BasePageState createState() => _GalleryHistoryPageState();
}

class _GalleryHistoryPageState extends BasePageState {
  String get unimplementedSource => appModel.translate('unimplemented_source');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}

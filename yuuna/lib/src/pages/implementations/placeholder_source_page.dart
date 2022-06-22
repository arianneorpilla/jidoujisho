import 'package:flutter/material.dart';
import 'package:yuuna/src/pages/base_source_page.dart';
import 'package:yuuna/utils.dart';

/// The media page used for unimplemented sources.
class PlaceholderSourcePage extends BaseSourcePage {
  /// Create an instance of this page.
  const PlaceholderSourcePage({
    super.item,
    super.key,
  });

  @override
  BaseSourcePageState createState() => _PlaceholderSourcePage();
}

class _PlaceholderSourcePage extends BaseSourcePageState {
  String get unimplementedSource => appModel.translate('unimplemented_source');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: Center(
          child: buildPlaceholder(),
        ),
      ),
    );
  }

  Widget buildPlaceholder() {
    return JidoujishoPlaceholderMessage(
      icon: Icons.construction,
      message: unimplementedSource,
    );
  }
}

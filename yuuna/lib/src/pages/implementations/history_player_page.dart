import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// A default page for a [PlayerMediaSource]'s tab body content when selected
/// as a source in the main menu.
class HistoryPlayerPage extends BaseHistoryPage {
  /// Create an instance of this tab page.
  const HistoryPlayerPage({
    super.key,
  });

  @override
  BaseHistoryPageState<BaseHistoryPage> createState() =>
      _HistoryPlayerPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class _HistoryPlayerPageState<T extends BaseHistoryPage>
    extends BaseHistoryPageState {
  /// This variable is true when the [buildPlaceholder] should be shown.
  /// For example, if a certain media type does not have any media items to
  /// show in its history.
  @override
  bool get shouldPlaceholderBeShown => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (shouldPlaceholderBeShown) {
      return buildPlaceholder();
    } else {
      return buildHistory();
    }
  }

  /// This is shown as the body when [shouldPlaceholderBeShown] is false.
  @override
  Widget buildHistory() {
    return Container();
  }
}

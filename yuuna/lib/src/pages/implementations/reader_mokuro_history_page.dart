import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A page for [ReaderMokuroSource]'s tab body content when selected as a source
/// in the main menu.
class ReaderMokuroHistoryPage extends HistoryReaderPage {
  /// Create an instance of this tab page.
  const ReaderMokuroHistoryPage({
    super.key,
  });

  @override
  BaseHistoryPageState<BaseHistoryPage> createState() =>
      _ReaderMokuroHistoryPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class _ReaderMokuroHistoryPageState<T extends HistoryReaderPage>
    extends HistoryReaderPageState {
  @override
  MediaType get mediaType => mediaSource.mediaType;

  @override
  ReaderMokuroSource get mediaSource => ReaderMokuroSource.instance;

  @override
  void initState() {
    super.initState();
    mediaType.tabRefreshNotifier.addListener(refresh);
  }

  @override
  void dispose() {
    mediaType.tabRefreshNotifier.removeListener(refresh);
    super.dispose();
  }

  /// Refresh the page and respond to history changes.
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<MediaItem> items = appModel
        .getMediaSourceHistory(mediaSource: mediaSource)
        .reversed
        .toList();

    if (items.isEmpty) {
      return buildPlaceholder();
    } else {
      return buildHistory(items);
    }
  }

  /// This is shown as the body when [shouldPlaceholderBeShown] is true.
  @override
  Widget buildPlaceholder() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: mediaSource.icon,
        message: t.info_empty_home_tab,
      ),
    );
  }
}

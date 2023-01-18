import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A page for [ReaderTtuSource]'s tab body content when selected as a source
/// in the main menu.
class ReaderTtuSourceHistoryPage extends HistoryReaderPage {
  /// Create an instance of this tab page.
  const ReaderTtuSourceHistoryPage({
    super.key,
  });

  @override
  BaseHistoryPageState<BaseHistoryPage> createState() =>
      _ReaderTtuSourceHistoryPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class _ReaderTtuSourceHistoryPageState<T extends HistoryReaderPage>
    extends HistoryReaderPageState {
  /// The message to be shown in the placeholder that displays when
  /// [shouldPlaceholderBeShown] is true. This should be a localised message.
  @override
  String get placeholderMessage => appModel.translate('ttu_no_books_added');

  @override
  MediaType get mediaType => mediaSource.mediaType;

  @override
  ReaderTtuSource get mediaSource => ReaderTtuSource.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<LocalAssetsServer> server =
        ref.watch(ttuServerProvider(appModel.targetLanguage));

    return server.when(
      data: buildData,
      loading: buildLoading,
      error: (error, stack) => buildError(
        error: error,
        stack: stack,
        refresh: () {
          ref.refresh(ttuServerProvider(appModel.targetLanguage));
        },
      ),
    );
  }

  Widget buildData(LocalAssetsServer server) {
    AsyncValue<List<MediaItem>> books =
        ref.watch(ttuBooksProvider(appModel.targetLanguage));

    return books.when(
      data: buildBody,
      error: (error, stack) => buildError(
        error: error,
        stack: stack,
        refresh: () {
          ref.refresh(ttuBooksProvider(appModel.targetLanguage));
        },
      ),
      loading: buildLoading,
    );
  }

  Widget buildBody(List<MediaItem> books) {
    if (books.isEmpty) {
      return buildPlaceholder();
    } else {
      return buildHistory(books);
    }
  }

  /// This is shown as the body when [shouldPlaceholderBeShown] is true.
  @override
  Widget buildPlaceholder() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: mediaSource.icon,
        message: placeholderMessage,
      ),
    );
  }
}

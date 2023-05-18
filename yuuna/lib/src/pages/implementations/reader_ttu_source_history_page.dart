import 'dart:async';
import 'dart:io';

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
  @override
  MediaType get mediaType => mediaSource.mediaType;

  @override
  ReaderTtuSource get mediaSource => ReaderTtuSource.instance;

  final ValueNotifier<int> _tryAgainCountdownNotifier = ValueNotifier(0);
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    AsyncValue<LocalAssetsServer> server =
        ref.watch(ttuServerProvider(appModel.targetLanguage));

    return server.when(
        data: buildData,
        loading: buildLoading,
        error: (error, stack) {
          if (_tryAgainCountdownNotifier.value == 0) {
            _tryAgainCountdownNotifier.value = 5;
          }

          if (error is SocketException) {
            _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
              _tryAgainCountdownNotifier.value -= 1;
              if (_tryAgainCountdownNotifier.value <= 0) {
                ref.invalidate(ttuServerProvider(appModel.targetLanguage));
                _timer?.cancel();
                _timer = null;
              }
            });

            return Center(
              child: ValueListenableBuilder<int>(
                valueListenable: _tryAgainCountdownNotifier,
                builder: (_, __, ___) => JidoujishoPlaceholderMessage(
                  icon: Icons.lan,
                  message: '${t.server_port_in_use}\n${t.retrying_in.seconds(
                    n: _tryAgainCountdownNotifier.value,
                  )}',
                ),
              ),
            );
          }

          return buildError(
            error: error,
            stack: stack,
            refresh: () {
              ref.invalidate(ttuServerProvider(appModel.targetLanguage));
            },
          );
        });
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
          ref.invalidate(ttuBooksProvider(appModel.targetLanguage));
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
        message: t.ttu_no_books_added,
      ),
    );
  }
}

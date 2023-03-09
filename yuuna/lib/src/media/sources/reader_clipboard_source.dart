import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A global [Provider] for getting lyrics from Google.
final clipboardProvider = StateProvider<String>((ref) => '');

/// A media source that allows the user to paste and select text.
class ReaderClipboardSource extends ReaderMediaSource {
  /// Define this media source.
  ReaderClipboardSource._privateConstructor()
      : super(
          uniqueKey: 'reader_clipboard',
          sourceName: 'Clipboard',
          description:
              'Allows text pasted from the clipboard to be displayed as '
              'selectable text.',
          icon: Icons.paste,
          implementsSearch: false,
          implementsHistory: false,
        );

  /// Get the singleton instance of this media type.
  static ReaderClipboardSource get instance => _instance;

  static final ReaderClipboardSource _instance =
      ReaderClipboardSource._privateConstructor();

  @override
  Future<void> onSearchBarTap({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) async {}

  @override
  BaseSourcePage buildLaunchPage({MediaItem? item}) {
    throw UnsupportedError('Clipboard source does not launch any page');
  }

  @override
  List<Widget> getActions({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    return [
      buildPasteButton(context: context, ref: ref, appModel: appModel),
    ];
  }

  /// Menu bar action.
  Widget buildPasteButton(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel}) {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.paste,
        icon: Icons.note_alt_outlined,
        onTap: () async {
          ClipboardData? data = await Clipboard.getData('text/plain');
          ref.watch(clipboardProvider.notifier).state = data?.text ?? '';
        },
      ),
    );
  }

  @override
  BasePage buildHistoryPage({MediaItem? item}) {
    return const ReaderClipboardPage();
  }
}

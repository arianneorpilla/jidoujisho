import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A global [Provider] for serving a local ッツ Ebook Reader.
final ttuProvider = FutureProvider<LocalAssetsServer>((ref) {
  return ReaderTtuSource.instance.serveLocalAssets();
});

/// A media source that allows the user to read from ッツ Ebook Reader.
class ReaderTtuSource extends ReaderMediaSource {
  /// Define this media source.
  ReaderTtuSource._privateConstructor()
      : super(
          uniqueKey: 'reader_ttu',
          sourceName: 'ッツ Ebook Reader',
          description: 'Read EPUBs and mine sentences via an embedded web '
              ' reader.',
          icon: Icons.chrome_reader_mode_outlined,
          implementsSearch: false,
        );

  /// Get the singleton instance of this media type.
  static ReaderTtuSource get instance => _instance;

  /// This port should ideally not conflict but should remain the same for
  /// caching purposes.
  static int get port => 55635;

  static final ReaderTtuSource _instance =
      ReaderTtuSource._privateConstructor();

  /// For serving the reader assets locally.
  Future<LocalAssetsServer> serveLocalAssets() async {
    final server = LocalAssetsServer(
      address: InternetAddress.loopbackIPv4,
      port: port,
      assetsBasePath: 'assets/ttu-ebook-reader',
      logger: const DebugLogger(),
    );

    await server.serve();

    return server;
  }

  @override
  BaseSourcePage buildLaunchWidget({MediaItem? item}) {
    return ReaderTtuSourcePage();
  }

  @override
  List<Widget> getActions({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    return [
      buildClearButton(
        context: context,
        ref: ref,
        appModel: appModel,
      ),
      buildLaunchButton(
        context: context,
        ref: ref,
        appModel: appModel,
      )
    ];
  }

  /// Allows user to clear all the browser data used for TTU.
  Widget buildClearButton({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    String tooltip = appModel.translate('clear_browser_title');

    return FloatingSearchBarAction(
      showIfOpened: true,
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: tooltip,
        icon: Icons.delete_sweep,
        onTap: () {
          showClearDataDialog(context: context, ref: ref, appModel: appModel);
        },
      ),
    );
  }

  /// Allows user to clear all the browser data used for TTU.
  Future<void> showClearDataDialog({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) async {
    String title = appModel.translate('clear_browser_title');
    String description = appModel.translate('clear_browser_description');
    String dialogClearLabel = appModel.translate('dialog_clear');
    String dialogCloseLabel = appModel.translate('dialog_close');

    Widget alertDialog = AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: <Widget>[
        TextButton(
          child: Text(
            dialogClearLabel,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          onPressed: () async {
            await appModel.clearBrowserData();

            Navigator.pop(context);
            mediaType.refreshTab();
          },
        ),
        TextButton(
          child: Text(dialogCloseLabel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }
}

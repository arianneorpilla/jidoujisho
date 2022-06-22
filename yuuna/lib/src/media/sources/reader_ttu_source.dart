import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
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
final ttuServerProvider = FutureProvider<LocalAssetsServer>((ref) {
  return ReaderTtuSource.instance.serveLocalAssets();
});

/// A global [Provider] for getting ッツ Ebook Reader books from IndexedDB.
final ttuBooksProvider = FutureProvider<List<MediaItem>>((ref) {
  LocalAssetsServer server = ref.watch(ttuServerProvider).value!;
  return ReaderTtuSource.instance.getBooksHistory(server: server);
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

  @override
  Future<void> onSourceExit({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    ref.refresh(ttuBooksProvider);
  }

  /// Get the URL for a running server.
  Uri getInitialUrl({required LocalAssetsServer server}) {
    String address = server.address.address;
    int port = server.boundPort!;

    return Uri.parse('http://$address:$port');
  }

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
  BaseSourcePage buildLaunchPage({MediaItem? item}) {
    return const ReaderTtuSourcePage();
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
            ref.refresh(ttuBooksProvider);
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

  @override
  BaseHistoryPage buildHistoryPage({MediaItem? item}) {
    return const ReaderTtuSourceHistoryPage();
  }

  /// Fetch JSON for all books in IndexedDB.
  Future<List<MediaItem>> getBooksHistory({
    required LocalAssetsServer server,
  }) async {
    List<MediaItem>? items;
    HeadlessInAppWebView webView = HeadlessInAppWebView(
        initialUrlRequest:
            URLRequest(url: Uri.parse('http://localhost:${server.boundPort}/')),
        onLoadStop: (controller, url) async {
          controller.evaluateJavascript(source: getHistoryJs);
        },
        onConsoleMessage: (controller, message) {
          late Map<String, dynamic> messageJson;
          messageJson = jsonDecode(message.message);

          if (messageJson['messageType'] != null) {
            try {
              items = getItemsFromJson(messageJson);
            } catch (error, stack) {
              items = [];
              debugPrint('$error');
              debugPrint('$stack');
            }
          } else {
            debugPrint(message.message);
          }
        });

    await webView.run();
    while (items == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return items!;
  }

  List<MediaItem> getItemsFromJson(Map<String, dynamic> json) {
    List<dynamic> bookmark = jsonDecode(json['bookmark']);
    List<dynamic> data = jsonDecode(json['data']);

    List<MediaItem> items = data.mapIndexed((index, datum) {
      int position = 0;
      int duration = 1;

      Map<String, dynamic>? bookmarkDatum =
          bookmark.firstWhereOrNull((e) => e['dataId'] == datum['id']);

      if (bookmarkDatum != null) {
        position = bookmarkDatum['exploredCharCount'] as int;
        double progress = double.parse(bookmarkDatum['progress'].toString());
        if (progress == 0) {
          duration = 1;
        } else {
          duration = position ~/ progress;
        }
      }

      return MediaItem(
        uniqueKey: datum['id'].toString(),
        title: datum['title'] as String? ?? '',
        base64Image: datum['coverImage'],
        mediaTypeIdentifier: ReaderTtuSource.instance.mediaType.uniqueKey,
        mediaSourceIdentifier: ReaderTtuSource.instance.uniqueKey,
        position: position,
        duration: duration,
      );
    }).toList();

    return items;
  }

  /// Used to fetch JSON for all books in IndexedDB.
  static const String getHistoryJs = '''
var bookmarkJson = JSON.stringify([]);
var dataJson = JSON.stringify([]);
var lastItemJson = JSON.stringify([]);

var blobToBase64 = function(blob) {
	return new Promise(resolve => {
		let reader = new FileReader();
		reader.onload = function() {
			let dataUrl = reader.result;
			resolve(dataUrl);
		};
		reader.readAsDataURL(blob);
	});
}

function getAllFromIDBStore(storeName) {
  return new Promise(
    function(resolve, reject) {
      var dbRequest = indexedDB.open("books");

      dbRequest.onerror = function(event) {
        reject(Error("Error opening DB"));
      };

      dbRequest.onupgradeneeded = function(event) {
        reject(Error('Not found'));
      };

      dbRequest.onsuccess = function(event) {
        var database = event.target.result;

        try {
          var transaction = database.transaction([storeName]);
          var objectStore;
          try {
            objectStore = transaction.objectStore(storeName);
          } catch (e) {
            objectStore = database.createObjectStore(storeName);
          }

          var objectRequest = objectStore.getAll();

          objectRequest.onerror = function(event) {
            reject(Error('Error getting objects'));
          };

          objectRequest.onerror = function(event) {
            reject(Error('Error getting objects'));
          };

          objectRequest.onsuccess = function(event) {
            if (objectRequest.result) resolve(objectRequest.result);
            else reject(Error('Objects not found'));
          }; 
        } catch (e) {
          reject(Error('Error getting objects'));
        }
      };
    }
  );
}

async function getTtuData() {
  try {
    items = await getAllFromIDBStore("data");
    await Promise.all(items.map(async (item) => {
      item["coverImage"] = await blobToBase64(item["coverImage"]);
    }));
    
    dataJson = JSON.stringify(items);
  } catch (e) {
    dataJson = JSON.stringify([]);
  }

  try {
    bookmarkJson = JSON.stringify(await getAllFromIDBStore("bookmark"));
  } catch (e) {
    bookmarkJson = JSON.stringify([]);
  }
  
  try {
    lastItemJson = JSON.stringify(await getAllFromIDBStore("lastItem"));
  } catch (e) {
    lastItemJson = JSON.stringify([]);
  }

  console.log(JSON.stringify({messageType: "history", lastItem: lastItemJson, bookmark: bookmarkJson, data: dataJson}));
}

try {
  getTtuData();
} catch (e) {
  console.log(JSON.stringify({messageType: "history", lastItem: lastItemJson, bookmark: bookmarkJson, data: dataJson}));
}
''';
}

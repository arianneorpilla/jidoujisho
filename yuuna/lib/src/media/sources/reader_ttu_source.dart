import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';

/// A global [Provider] for serving a local ッツ Ebook Reader.
final ttuServerProvider = FutureProvider<LocalAssetsServer>((ref) {
  return ReaderTtuSource.instance.serveLocalAssets();
});

/// A global [Provider] for getting ッツ Ebook Reader books from IndexedDB.
final ttuBooksProvider = FutureProvider<List<MediaItem>>((ref) {
  return ReaderTtuSource.instance.getBooksHistory();
});

/// A media source that allows the user to read from ッツ Ebook Reader.
class ReaderTtuSource extends ReaderMediaSource {
  /// Define this media source.
  ReaderTtuSource._privateConstructor()
      : super(
          uniqueKey: 'reader_ttu',
          sourceName: 'ッツ Ebook Reader',
          description: 'Read EPUBs and mine sentences via an embedded web'
              ' reader.',
          icon: Icons.chrome_reader_mode_outlined,
          implementsSearch: false,
        );

  /// Get the singleton instance of this media type.
  static ReaderTtuSource get instance => _instance;

  /// This port should ideally not conflict but should remain the same for
  /// caching purposes.
  static int get port => 52059;

  static final ReaderTtuSource _instance =
      ReaderTtuSource._privateConstructor();

  @override
  Future<void> onSourceExit({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    ref.refresh(ttuBooksProvider);
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
    return ReaderTtuSourcePage(item: item);
  }

  @override
  List<Widget> getActions({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
  }) {
    return [
      buildLaunchButton(
        context: context,
        ref: ref,
        appModel: appModel,
      )
    ];
  }

  @override
  BaseHistoryPage buildHistoryPage({MediaItem? item}) {
    return const ReaderTtuSourceHistoryPage();
  }

  /// Fetch JSON for all books in IndexedDB.
  Future<List<MediaItem>> getBooksHistory() async {
    if (getPreference(key: 'firstTime', defaultValue: true)) {
      return [];
    }

    List<MediaItem>? items;
    HeadlessInAppWebView webView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse('http://localhost:$port/')),
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
      },
    );

    try {
      await webView.run();
      while (items == null) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } finally {
      await webView.dispose();
    }

    return items!;
  }

  /// Fetch the list of history items given JSON from IndexedDB.
  List<MediaItem> getItemsFromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> bookmarks =
        List<Map<String, dynamic>>.from(jsonDecode(json['bookmark']));
    List<Map<String, dynamic>> datas =
        List<Map<String, dynamic>>.from(jsonDecode(json['data']));
    Map<int, Map<String, dynamic>> bookmarksById =
        Map<int, Map<String, dynamic>>.fromEntries(
            bookmarks.map((e) => MapEntry(e['dataId'] as int, e)));

    List<MediaItem> items = datas.mapIndexed((index, data) {
      int position = 0;
      int duration = 1;

      Map<String, dynamic>? bookmark = bookmarksById[data['id']];

      if (bookmark != null) {
        position = bookmark['exploredCharCount'] as int;
        double progress = double.parse(bookmark['progress'].toString());
        if (progress == 0) {
          duration = 1;
        } else {
          duration = position ~/ progress;
        }
      }

      String id = data['id'].toString();
      String title = data['title'] as String? ?? ' ';
      String? base64Image;
      try {
        Uri.parse(data['coverImage']);
        base64Image = data['coverImage'];
      } catch (e) {
        base64Image = null;
      }

      return MediaItem(
        mediaIdentifier: 'http://localhost:$port/b.html?id=$id&?title=$title',
        title: title,
        base64Image: base64Image,
        mediaTypeIdentifier: ReaderTtuSource.instance.mediaType.uniqueKey,
        mediaSourceIdentifier: ReaderTtuSource.instance.uniqueKey,
        position: position,
        duration: duration,
        canDelete: false,
        canEdit: true,
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
          var transaction = database.transaction([storeName], 'readwrite');
          var objectStore;
          try {
            objectStore = transaction.objectStore(storeName);
          } catch (e) {
            reject(Error('Error getting objects'));
          }

          var objectRequest = objectStore.getAll();

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
      try {
        item["coverImage"] = await blobToBase64(item["coverImage"]);
      } catch (e) {}
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

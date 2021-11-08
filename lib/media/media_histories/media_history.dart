import 'dart:convert';
import 'dart:io';

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/models/app_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaHistory {
  MediaHistory({
    required this.appModel,
    required this.prefsDirectory,
    this.maxItemCount = 30,
  });

  /// A directory name for where this media's history should be stored in
  /// [SharedPreferences].
  final String prefsDirectory;

  /// A maximum number of items to keep in history.
  final int maxItemCount;

  /// An instance of SharedPreferences.
  final AppModel appModel;

  /// Add the media history item to the latest end of history. If history
  /// is too huge and exceeds [maxItemCount], get rid of the oldest items
  /// first and end up with a list with [maxItemCount] number of elements.
  ///
  /// If a [MediaHistoryItem] with a conflicting key exists, delete the
  /// existing item and push the new item to the latest end of history.
  Future<void> addItem(MediaHistoryItem item) async {
    List<MediaHistoryItem> history = getItems();

    history.removeWhere((historyItem) => item.key == historyItem.key);
    history.add(item);

    if (history.length >= maxItemCount) {
      history = history.sublist(history.length - maxItemCount);
    }

    appModel.sharedPreferences
        .setString("resumeMediaHistoryItem", item.toJson());
    await setItems(history);
  }

  /// Remove a given media history item with a given unique identifier.
  /// If the key identifier does not exist, do nothing.
  Future<void> removeItem(String key) async {
    List<MediaHistoryItem> history = getItems();

    List<MediaHistoryItem> itemsToRemove =
        history.where((historyItem) => key == historyItem.key).toList();
    for (MediaHistoryItem historyItem in itemsToRemove) {
      File thumbnailFile = File(historyItem.thumbnailPath);
      if (thumbnailFile.existsSync()) {
        thumbnailFile.deleteSync();
      }

      history.remove(historyItem);
    }

    await setItems(history);
  }

  /// Given a list of [MediaHistoryItem], serialise all with [toJson] and
  /// update the appropriate [prefsDirectory] in [SharedPreferences] with
  /// the serialised list of [MediaHistoryItem] in JSON format.
  Future<void> setItems(List<MediaHistoryItem> items) async {
    List<String> serialisedItems = [];
    for (MediaHistoryItem item in items) {
      serialisedItems.add(
        item.toJson(),
      );
    }

    await appModel.sharedPreferences.setString(
      prefsDirectory,
      jsonEncode(serialisedItems),
    );
  }

  /// Get the serialised history in [prefsDirectory] of [SharedPreferences]
  /// and deserialise each [MediaHistoryItem] and return the list.
  List<MediaHistoryItem> getItems() {
    String jsonList =
        appModel.sharedPreferences.getString(prefsDirectory) ?? '[]';

    List<dynamic> serialisedItems = (jsonDecode(jsonList) as List<dynamic>);

    List<MediaHistoryItem> history = [];
    for (var serialisedItem in serialisedItems) {
      MediaHistoryItem entry = MediaHistoryItem.fromJson(serialisedItem);
      history.add(entry);
    }

    return history;
  }
}

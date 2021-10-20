import 'dart:convert';

import 'package:chisa/media/media_history.dart';
import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_history_items/default_media_history_item.dart';

class DefaultMediaHistory extends MediaHistory {
  DefaultMediaHistory({
    required sharedPreferences,
    required prefsDirectory,
    maxItemCount = 30,
  }) : super(
          sharedPreferences,
          prefsDirectory,
          maxItemCount,
        );

  @override
  Future<void> addItem(MediaHistoryItem item) async {
    List<MediaHistoryItem> history = getItems();

    history.removeWhere((historyItem) => item.key == historyItem.key);
    history.add(item);

    if (history.length >= maxItemCount) {
      history = history.sublist(history.length - maxItemCount);
    }

    await setItems(history);
  }

  @override
  Future<void> removeItem(String key) async {
    List<MediaHistoryItem> history = getItems();

    history.removeWhere((historyItem) => key == historyItem.key);
    await setItems(history);
  }

  @override
  List<MediaHistoryItem> getItems() {
    String jsonList = sharedPreferences.getString(prefsDirectory) ?? '[]';

    List<dynamic> serialisedItems = (jsonDecode(jsonList) as List<dynamic>);

    List<MediaHistoryItem> history = [];
    for (var serialisedItem in serialisedItems) {
      DefaultMediaHistoryItem entry =
          DefaultMediaHistoryItem.fromJson(serialisedItem);
      history.add(entry);
    }

    return history;
  }

  @override
  Future<void> setItems(List<MediaHistoryItem> items) async {
    List<String> serialisedItems = [];
    for (MediaHistoryItem item in items) {
      serialisedItems.add(
        item.toJson(),
      );
    }

    await sharedPreferences.setString(
      prefsDirectory,
      jsonEncode(serialisedItems),
    );
  }
}

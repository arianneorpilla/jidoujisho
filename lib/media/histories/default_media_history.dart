import 'dart:convert';

import 'package:daijidoujisho/media/media_history.dart';
import 'package:daijidoujisho/media/media_history_item.dart';
import 'package:daijidoujisho/media/history_items/default_media_history_item.dart';

class DefaultMediaHistory extends MediaHistory {
  DefaultMediaHistory({
    prefsDirectory,
    maxItemCount,
    sharedPreferences,
  }) : super(
          prefsDirectory,
          maxItemCount,
          sharedPreferences,
        );

  @override
  Future<void> addMediaHistoryItem(MediaHistoryItem item) async {
    List<MediaHistoryItem> history = getMediaHistory();

    history.removeWhere((historyItem) => item.uri == historyItem.uri);
    history.add(item);

    if (history.length >= maxItemCount) {
      history = history.sublist(history.length - maxItemCount);
    }

    await setMediaHistory(history);
  }

  @override
  Future<void> removeMediaHistoryItem(Uri uri) async {
    List<MediaHistoryItem> history = getMediaHistory();

    history.removeWhere((historyItem) => uri == historyItem.uri);
    await setMediaHistory(history);
  }

  @override
  List<MediaHistoryItem> getMediaHistory() {
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
  Future<void> setMediaHistory(List<MediaHistoryItem> items) async {
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

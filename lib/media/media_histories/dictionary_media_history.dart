import 'dart:convert';

import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/dictionary_media_history_item.dart';

class DictionaryMediaHistory extends MediaHistory {
  DictionaryMediaHistory({
    required appModel,
    required prefsDirectory,
    maxItemCount = 50,
  }) : super(
          appModel: appModel,
          prefsDirectory: prefsDirectory,
        );

  Future<void> addDictionaryItem(DictionaryMediaHistoryItem item) async {
    List<DictionaryMediaHistoryItem> history = getDictionaryItems();

    history.removeWhere((historyItem) =>
        historyItem.sourceName == item.sourceName &&
        historyItem.title == item.title);
    history.add(item);

    if (history.length >= maxItemCount) {
      history = history.sublist(history.length - maxItemCount);
    }

    await setItems(history);
  }

  Future<void> removeDictionaryItem(
      String originalSearchTerm, String dictionaryName) async {
    List<DictionaryMediaHistoryItem> history = getDictionaryItems();

    history.removeWhere((historyItem) =>
        historyItem.sourceName == dictionaryName &&
        historyItem.title == originalSearchTerm);
    await setItems(history);
  }

  List<DictionaryMediaHistoryItem> getDictionaryItems() {
    String jsonList =
        appModel.sharedPreferences.getString(prefsDirectory) ?? '[]';

    List<dynamic> serialisedItems = (jsonDecode(jsonList) as List<dynamic>);

    List<DictionaryMediaHistoryItem> history = [];
    for (var serialisedItem in serialisedItems) {
      DictionaryMediaHistoryItem entry =
          DictionaryMediaHistoryItem.fromJson(serialisedItem);
      history.add(entry);
    }

    return history;
  }

  Future<void> setDictionaryItems(
      List<DictionaryMediaHistoryItem> items) async {
    List<String> serialisedItems = [];
    for (DictionaryMediaHistoryItem item in items) {
      serialisedItems.add(
        item.toJson(),
      );
    }

    await appModel.sharedPreferences.setString(
      prefsDirectory,
      jsonEncode(serialisedItems),
    );
  }
}

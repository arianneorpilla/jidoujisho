import 'dart:convert';

import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/dictionary_media_history_item.dart';

class DictionaryMediaHistory extends MediaHistory {
  DictionaryMediaHistory({
    required appModel,
    required prefsDirectory,
    maxItemCount = 100,
  }) : super(
          appModel: appModel,
          prefsDirectory: prefsDirectory,
          maxItemCount: maxItemCount,
        );

  Future<void> addDictionaryItem(DictionaryMediaHistoryItem item) async {
    List<String> keys = getKeys();

    keys.removeWhere((historyKey) => item.key == historyKey);
    keys.add(item.key);

    if (keys.length >= maxItemCount) {
      keys = keys.sublist(keys.length - maxItemCount);

      for (int i = 0; i < keys.length - maxItemCount; i++) {
        keys.remove(keys[i]);
        await appModel.sharedPreferences
            .remove('$prefsDirectory/values/${keys[i]}');
      }
    }

    await appModel.sharedPreferences
        .setString('$prefsDirectory/values/${item.key}', item.toJson());
    await setKeys(keys);
  }

  Future<void> removeDictionaryItem(DictionaryMediaHistoryItem item) async {
    await appModel.sharedPreferences
        .remove('$prefsDirectory/values/${item.key}');
    List<String> keys = getKeys();
    keys.removeWhere((historyKey) => item.key == historyKey);
    await setKeys(keys);
  }

  Future<void> clearAllDictionaryItems() async {
    await setKeys([]);
    List<String> valuesToDelete = appModel.sharedPreferences
        .getKeys()
        .where((key) => key.startsWith('$prefsDirectory/values/'))
        .toList();

    for (String valueToDelete in valuesToDelete) {
      appModel.sharedPreferences.remove(valueToDelete);
    }
  }

  List<DictionaryMediaHistoryItem> getDictionaryItems() {
    List<String> keys = getKeys();
    List<DictionaryMediaHistoryItem> history = [];
    for (String key in keys) {
      String itemJson =
          appModel.sharedPreferences.getString('$prefsDirectory/values/$key')!;
      DictionaryMediaHistoryItem item =
          DictionaryMediaHistoryItem.fromJson(itemJson);
      history.add(item);
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

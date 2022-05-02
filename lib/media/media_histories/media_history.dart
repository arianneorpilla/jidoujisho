import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/models/app_model.dart';

class MediaHistory {
  MediaHistory({
    required this.appModel,
    required this.prefsDirectory,
    this.maxItemCount = 100,
  });

  /// A directory name for where this media's history should be stored in
  /// a Hive [Box].
  final String prefsDirectory;

  /// A maximum number of items to keep in history.
  final int maxItemCount;

  final AppModel appModel;

  /// Add the media history item to the latest end of history. If history
  /// is too huge and exceeds [maxItemCount], get rid of the oldest items
  /// first and end up with a list with [maxItemCount] number of elements.
  ///
  /// If a [MediaHistoryItem] with a conflicting key exists, delete the
  /// existing item and push the new item to the latest end of history.
  Future<void> addItem(MediaHistoryItem item) async {
    List<String> keys = getKeys();

    keys.removeWhere((historyKey) => item.key == historyKey);
    keys.add(item.key);

    if (keys.length >= maxItemCount) {
      keys = keys.sublist(keys.length - maxItemCount);

      for (int i = 0; i < keys.length - maxItemCount; i++) {
        await appModel.sharedPreferences
            .remove('$prefsDirectory/values/${keys[i]}');
        keys.remove(keys[i]);
      }
    }

    await appModel.sharedPreferences
        .setString('$prefsDirectory/values/${item.key}', item.toJson());
    await appModel.sharedPreferences
        .setString('resumeMediaHistoryItem', item.toJson());
    await setKeys(keys);
  }

  /// Remove a given media history item with a given unique identifier.
  /// If the key identifier does not exist, do nothing.
  Future<void> removeItem(String key) async {
    await appModel.sharedPreferences.remove('$prefsDirectory/values/$key');
    List<String> keys = getKeys();
    keys.removeWhere((historyKey) => key == historyKey);
    await setKeys(keys);
  }

  /// Get the serialised history in [prefsDirectory] of a Hive [Box]
  /// and deserialise each [MediaHistoryItem] and return the list.
  Future<bool> setKeys(List<String> keys) async {
    return appModel.sharedPreferences
        .setStringList('$prefsDirectory/keys', keys);
  }

  /// Get the serialised history in [prefsDirectory] of a Hive [Box]
  /// and deserialise each [MediaHistoryItem] and return the list.
  List<String> getKeys() {
    return appModel.sharedPreferences.getStringList('$prefsDirectory/keys') ??
        [];
  }

  Future<void> clearAllItems() async {
    await setKeys([]);
    List<String> valuesToDelete = appModel.sharedPreferences
        .getKeys()
        .where((key) => key.startsWith('$prefsDirectory/values/'))
        .toList();

    for (String valueToDelete in valuesToDelete) {
      appModel.sharedPreferences.remove(valueToDelete);
    }
  }

  /// Get the serialised history in [prefsDirectory] of a Hive [Box]
  /// and deserialise each [MediaHistoryItem] and return the list.
  List<MediaHistoryItem> getItems() {
    List<String> keys = getKeys();
    List<MediaHistoryItem> history = [];
    for (String key in keys) {
      String itemJson =
          appModel.sharedPreferences.getString('$prefsDirectory/values/$key')!;
      MediaHistoryItem item = MediaHistoryItem.fromJson(itemJson);
      history.add(item);
    }

    return history;
  }
}

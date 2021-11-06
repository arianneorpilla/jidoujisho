import 'dart:convert';

import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_type.dart';

class DictionaryMediaHistoryItem extends MediaHistoryItem {
  DictionaryMediaHistoryItem({
    required String key,
    required String name,
    required String sourceName,
    required String mediaTypePrefs,
    required int currentProgress,
    required int completeProgress,
    required this.contextItem,
    required Map<String, dynamic> extra,
  }) : super(
          key: key,
          name: name,
          sourceName: sourceName,
          mediaTypePrefs: MediaType.dictionary.prefsDirectory(),
          currentProgress: currentProgress,
          completeProgress: completeProgress,
          extra: extra,
        );

  final MediaHistoryItem? contextItem;

  factory DictionaryMediaHistoryItem.fromDictionarySearchResult(
      DictionarySearchResult result,
      {int currentProgress = 0}) {
    return DictionaryMediaHistoryItem(
      key: result.toJson(),
      name: result.originalSearchTerm,
      sourceName: result.dictionaryName,
      mediaTypePrefs: MediaType.dictionary.prefsDirectory(),
      currentProgress: currentProgress,
      completeProgress: result.entries.length - 1,
      contextItem: result.mediaHistoryItem,
      extra: {},
    );
  }

  factory DictionaryMediaHistoryItem.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);

    String key = map["key"] ?? "";
    String name = map["name"] ?? "";
    String sourceName = map["sourceName"] ?? "";
    String mediaTypePrefs = map["mediaTypePrefs"] ?? "";
    int currentProgress = int.tryParse(map["currentProgress"] ?? "") ?? 0;
    int completeProgress = int.tryParse(map["completeProgress"] ?? "") ?? 0;
    Map<String, dynamic> extra = jsonDecode(map["extra"] ?? "{}");

    MediaHistoryItem? contextItem;
    String? itemJson = map["contextItem"];
    if (itemJson != null && itemJson.isNotEmpty) {
      contextItem = MediaHistoryItem.fromJson(itemJson);
    }

    return DictionaryMediaHistoryItem(
      key: key,
      name: name,
      sourceName: sourceName,
      mediaTypePrefs: mediaTypePrefs,
      currentProgress: currentProgress,
      completeProgress: completeProgress,
      contextItem: contextItem,
      extra: extra,
    );
  }

  @override
  String toJson() {
    Map<String, String> map = {
      "key": key,
      "name": name,
      "sourceName": sourceName,
      "mediaTypePrefs": mediaTypePrefs,
      "currentProgress": currentProgress.toString(),
      "completeProgress": completeProgress.toString(),
      "thumbnailPath": thumbnailPath,
      "extra": jsonEncode(extra),
    };

    if (contextItem != null) {
      map["contextItem"] = contextItem!.toJson();
    }

    return jsonEncode(map);
  }
}

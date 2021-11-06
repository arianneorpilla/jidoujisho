import 'dart:convert';

import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_type.dart';

class DictionaryMediaHistoryItem extends MediaHistoryItem {
  DictionaryMediaHistoryItem({
    required String key,
    required String name,
    required String source,
    required int currentProgress,
    required int completeProgress,
    required this.contextItem,
    required Map<String, dynamic> extra,
  }) : super(
          key: key,
          name: name,
          source: source,
          mediaType: MediaType.dictionary.prefsDirectory(),
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
      name: "",
      source: "",
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
    String source = map["source"] ?? "";
    int currentProgress = int.tryParse(map["currentProgress"] ?? "") ?? 0;
    int completeProgress = int.tryParse(map["completeProgress"] ?? "") ?? 0;
    Map<String, dynamic> extra = jsonDecode(map["extra"] ?? "{}");

    MediaHistoryItem? contextItem;
    String? itemJson = map["contextItem"];
    if (itemJson != null) {
      contextItem = MediaHistoryItem.fromJson(json);
    }

    return DictionaryMediaHistoryItem(
      key: key,
      name: name,
      source: source,
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
      "source": source,
      "currentProgress": currentProgress.toString(),
      "completeProgress": completeProgress.toString(),
      "thumbnailPath": thumbnailPath,
      "extra": jsonEncode(extra),
      "contextItem": contextItem?.toJson() ?? "",
    };

    return jsonEncode(map);
  }
}

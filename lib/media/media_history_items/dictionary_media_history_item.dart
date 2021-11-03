import 'dart:convert';

import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/media/media_history_items/default_media_history_item.dart';

class DictionaryMediaHistoryItem extends DefaultMediaHistoryItem {
  DictionaryMediaHistoryItem({
    required String key,
    required String name,
    required String source,
    required int currentProgress,
    required int completeProgress,
    required Map<String, dynamic> extra,
  }) : super(
          key: key,
          name: name,
          source: source,
          currentProgress: currentProgress,
          completeProgress: completeProgress,
          extra: extra,
        );

  factory DictionaryMediaHistoryItem.fromDictionarySearchResult(
      DictionarySearchResult result,
      {int currentProgress = 0}) {
    return DictionaryMediaHistoryItem(
      key: result.toJson(),
      name: "",
      source: "",
      currentProgress: currentProgress,
      completeProgress: result.entries.length - 1,
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

    return DictionaryMediaHistoryItem(
      key: key,
      name: name,
      source: source,
      currentProgress: currentProgress,
      completeProgress: completeProgress,
      extra: extra,
    );
  }
}

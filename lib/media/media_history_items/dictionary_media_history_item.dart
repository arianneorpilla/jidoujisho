import 'dart:convert';

import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/media/media_history_items/default_media_history_item.dart';

class DictionaryMediaHistoryItem extends DefaultMediaHistoryItem {
  DictionaryMediaHistoryItem({
    required String key,
    required String name,
    required String resource,
    required int progress,
    required Map<String, dynamic> extra,
  }) : super(
          key: key,
          name: name,
          resource: resource,
          progress: progress,
          extra: extra,
        );

  factory DictionaryMediaHistoryItem.fromDictionarySearchResult(
      DictionarySearchResult result,
      {int progress = 0}) {
    return DictionaryMediaHistoryItem(
      key: result.toJson(),
      name: "",
      resource: "",
      progress: progress,
      extra: {},
    );
  }

  factory DictionaryMediaHistoryItem.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);

    String key = map["key"] ?? "";
    String name = map["name"] ?? "";
    String resource = map["resource"] ?? "";
    int progress = int.tryParse(map["progress"] ?? "") ?? 0;
    Map<String, dynamic> extra = jsonDecode(map["extra"] ?? "{}");

    return DictionaryMediaHistoryItem(
      key: key,
      name: name,
      resource: resource,
      progress: progress,
      extra: extra,
    );
  }
}

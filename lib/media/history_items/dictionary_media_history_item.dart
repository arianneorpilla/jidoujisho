import 'dart:convert';

import 'package:chisa/dictionary/dictionary_search_results.dart';
import 'package:chisa/media/history_items/default_media_history_item.dart';

class DictionaryMediaHistoryItem extends DefaultMediaHistoryItem {
  DictionaryMediaHistoryItem({
    required String key,
    required String name,
    required Uri resourceUri,
    required int progress,
    required Map<String, dynamic> extra,
  }) : super(
          key: key,
          name: name,
          resourceUri: resourceUri,
          progress: progress,
          extra: extra,
        );

  factory DictionaryMediaHistoryItem.fromDictionarySearchResult(
      DictionarySearchResult result,
      {int progress = 0}) {
    return DictionaryMediaHistoryItem(
      key: result.toJson(),
      name: "",
      resourceUri: Uri.dataFromString(""),
      progress: progress,
      extra: {},
    );
  }

  factory DictionaryMediaHistoryItem.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);

    String key = map["key"] ?? "";
    String name = map["name"] ?? "";
    Uri resourceUri = Uri.dataFromString(map["uri"] ?? "");
    int progress = int.tryParse(map["progress"] ?? "") ?? 0;
    Map<String, dynamic> extra = jsonDecode(map["extra"] ?? "{}");

    return DictionaryMediaHistoryItem(
      key: key,
      name: name,
      resourceUri: resourceUri,
      progress: progress,
      extra: extra,
    );
  }
}

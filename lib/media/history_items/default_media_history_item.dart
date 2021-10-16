import 'dart:convert';

import 'package:chisa/media/media_history_item.dart';

class DefaultMediaHistoryItem extends MediaHistoryItem {
  DefaultMediaHistoryItem({
    uri,
    name,
    resourceUri,
    progress,
    extra,
  }) : super(
          uri: uri,
          name: name,
          resourceUri: resourceUri,
          progress: progress,
          extra: extra,
        );

  factory DefaultMediaHistoryItem.fromJson(String json) {
    Map<String, String> map = jsonDecode(json);

    Uri uri = Uri.dataFromString(map["uri"] ?? "");
    String name = map["name"] ?? "";
    Uri resourceUri = Uri.dataFromString(map["uri"] ?? "");
    int progress = int.tryParse(map["progress"] ?? "") ?? 0;
    Map<String, String> extra = jsonDecode(map["extra"] ?? "{}");

    return DefaultMediaHistoryItem(
      uri: uri,
      name: name,
      resourceUri: resourceUri,
      progress: progress,
      extra: extra,
    );
  }
}

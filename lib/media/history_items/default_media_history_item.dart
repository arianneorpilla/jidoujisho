import 'dart:convert';

import 'package:chisa/media/media_history_item.dart';

class DefaultMediaHistoryItem extends MediaHistoryItem {
  DefaultMediaHistoryItem({
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

  factory DefaultMediaHistoryItem.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);

    String key = map["key"] ?? "";
    String name = map["name"] ?? "";
    Uri resourceUri = Uri.dataFromString(map["uri"] ?? "");
    int progress = int.tryParse(map["progress"] ?? "") ?? 0;
    Map<String, dynamic> extra = jsonDecode(map["extra"] ?? "{}");

    return DefaultMediaHistoryItem(
      key: key,
      name: name,
      resourceUri: resourceUri,
      progress: progress,
      extra: extra,
    );
  }

  // @override
  // String toJson() {
  //   Map<String, String> map = {
  //     "uri": uri.toString(),
  //     "name": name,
  //     "resourceUri": resourceUri.toString(),
  //     "progress": progress.toString(),
  //     "extra": jsonEncode(extra)
  //   };

  //   return jsonEncode(map);
  // }
}

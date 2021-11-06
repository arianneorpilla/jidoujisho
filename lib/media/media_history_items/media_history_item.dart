import 'dart:convert';

class MediaHistoryItem {
  MediaHistoryItem({
    required this.key,
    required this.name,
    required this.source,
    required this.mediaType,
    required this.currentProgress,
    required this.completeProgress,
    required this.extra,
    this.thumbnailPath = "",
  });

  /// The unique identifier of this item. If the same item exists in history,
  /// then the item is replaced with a newer item in the addition operation.
  String key;

  /// The name of this item. Typically, this could be the name of a video
  /// or a book.
  String name;

  /// The media source where this item is from. All media sources have a
  /// unique identifier that takes the format of [mediaTypeName/sourceName].
  ///
  /// This is used to generate resources that the media item may require for
  /// preview purposes. For example, for a local media item to display its
  /// screenshot, the player page will need to invoke a function pertaining
  /// to the media source in order to generate its thumbnail.
  String source;
  String mediaType;

  /// A path pointing to a file, storing a temporary thumbnail. This is deleted
  /// when an item is disposed.
  String thumbnailPath;

  /// Progress of this item persisted for resuming purposes.
  ///
  /// For dictionary media history items, this is the scroll position.
  /// For video media history items, this is the seconds elapsed.
  int currentProgress;

  /// The progress of this item when the history item is completed. Stored for
  /// division and progress tracking purposes.
  int completeProgress;

  /// Extra parameters are provided should a media history item require it.
  Map<String, dynamic> extra;

  factory MediaHistoryItem.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);

    String key = map["key"] ?? "";
    String name = map["name"] ?? "";
    String source = map["source"] ?? "";
    String mediaType = map["mediaType"] ?? "";
    int currentProgress = int.tryParse(map["currentProgress"] ?? "") ?? 0;
    int completeProgress = int.tryParse(map["completeProgress"] ?? "") ?? 0;
    String thumbnailPath = map["thumbnailPath"] ?? "";
    Map<String, dynamic> extra = jsonDecode(map["extra"] ?? "{}");

    return MediaHistoryItem(
      key: key,
      name: name,
      mediaType: mediaType,
      source: source,
      currentProgress: currentProgress,
      completeProgress: completeProgress,
      thumbnailPath: thumbnailPath,
      extra: extra,
    );
  }

  String toJson() {
    Map<String, String> map = {
      "key": key,
      "name": name,
      "source": source,
      "currentProgress": currentProgress.toString(),
      "completeProgress": completeProgress.toString(),
      "thumbnailPath": thumbnailPath,
      "extra": jsonEncode(extra),
    };

    return jsonEncode(map);
  }
}

import 'dart:convert';

import 'package:chisa/media/media_history_item.dart';

class DefaultMediaHistoryItem extends MediaHistoryItem {
  DefaultMediaHistoryItem({
    /// The unique identifier of this item. If the same item exists in history,
    /// then the item is replaced with a newer item in the addition operation.
    required String key,

    /// The name of this item. Typically, this could be the name of a video
    /// or a book.
    required String name,

    /// The media source where this item is from. All media sources have a
    /// unique identifier that takes the format of [mediaTypeName/sourceName].
    ///
    /// This is used to generate resources that the media item may require for
    /// preview purposes. For example, for a local media item to display its
    /// screenshot, the player page will need to invoke a function pertaining
    /// to the media source in order to generate its thumbnail.
    required String source,

    /// Progress of this item persisted for resuming purposes.
    ///
    /// For dictionary media history items, this is the scroll position.
    /// For video media history items, this is the seconds elapsed.
    required int currentProgress,

    /// A path pointing to a file, storing a temporary thumbnail. This is deleted
    /// when an item is disposed.
    String thumbnailPath = "",

    /// The progress of this item when the history item is completed. Stored for
    /// division and progress tracking purposes.
    required int completeProgress,

    /// Extra parameters are provided should a media history item require it.
    required Map<String, dynamic> extra,
  }) : super(
          key: key,
          name: name,
          source: source,
          currentProgress: currentProgress,
          completeProgress: completeProgress,
          thumbnailPath: thumbnailPath,
          extra: extra,
        );

  factory DefaultMediaHistoryItem.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);

    String key = map["key"] ?? "";
    String name = map["name"] ?? "";
    String source = map["source"] ?? "";
    int currentProgress = int.tryParse(map["currentProgress"] ?? "") ?? 0;
    int completeProgress = int.tryParse(map["completeProgress"] ?? "") ?? 0;
    String thumbnailPath = map["thumbnailPath"] ?? "";
    Map<String, dynamic> extra = jsonDecode(map["extra"] ?? "{}");

    return DefaultMediaHistoryItem(
      key: key,
      name: name,
      source: source,
      currentProgress: currentProgress,
      completeProgress: completeProgress,
      thumbnailPath: thumbnailPath,
      extra: extra,
    );
  }
}

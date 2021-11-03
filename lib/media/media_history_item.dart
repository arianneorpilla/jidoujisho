import 'dart:convert';

abstract class MediaHistoryItem {
  MediaHistoryItem({
    required this.key,
    required this.name,
    required this.source,
    required this.currentProgress,
    required this.completeProgress,
    this.thumbnailPath = "",
    required this.extra,
  });

  /// The unique identifier of this item. If the same item exists in history,
  /// then the item is replaced with a newer item in the addition operation.
  String key;

  /// The name of this item. Typically, this could be the name of a video
  /// or a book.
  String name;

  /// The [sourceName] of the media source this item is from.
  ///
  /// This is used to generate resources that the media item may require for
  /// preview purposes. For example, for a local media item to display its
  /// screenshot, the player page will need to invoke a function pertaining
  /// to the media source in order to generate its thumbnail.
  String source;

  /// Progress of this item persisted for resuming purposes.
  ///
  /// For dictionary media history items, this is the scroll position.
  /// For video media history items, this is the seconds elapsed.
  int currentProgress;

  /// The progress of this item when the history item is completed. Stored for
  /// division and progress tracking purposes.
  int completeProgress;

  /// A path pointing to a file, storing a temporary thumbnail. This is deleted
  /// when an item is disposed.
  String thumbnailPath;

  /// Extra parameters are provided should a media history item require it.
  Map<String, dynamic> extra;

  /// Return the serialised JSON form of this [MediaHistoryItem]. See
  /// [MediaHistory] for how this is used.
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

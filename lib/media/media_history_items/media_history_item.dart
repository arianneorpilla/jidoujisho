import 'dart:convert';

class MediaHistoryItem {
  MediaHistoryItem({
    required this.key,
    required this.sourceName,
    required this.mediaTypePrefs,
    required this.currentProgress,
    required this.completeProgress,
    required this.extra,
    this.title = '',
    this.author = '',
    this.alias = '',
    this.thumbnailPath = '',
  });

  /// The unique identifier of this item. If the same item exists in history,
  /// then the item is replaced with a newer item in the addition operation.
  String key;

  /// The name of this item. Typically, this could be the name of a video
  /// or a book.
  String title;

  /// This field is a convenience field as it may be common to store this
  /// detail. For a web video, this could be the channel where the video is
  /// from. For a book, it is the author.
  String author;

  /// An alternative title for the name, for a reader or viewer item.
  String alias;

  /// The media source where this item is from. All media sources have a
  /// unique identifier that takes the format of [mediaTypeName/sourceName].
  ///
  /// This is used to generate resources that the media item may require for
  /// preview purposes. For example, for a local media item to display its
  /// screenshot, the player page will need to invoke a function pertaining
  /// to the media source in order to generate its thumbnail.
  String sourceName;
  String mediaTypePrefs;

  /// A path pointing to a file, storing a temporary thumbnail. This is deleted
  /// when an item is disposed! Paths that cannot be deleted should be placed
  /// in the [extra] parameter instead as source-specific metadata!
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

    String key = map['key'] ?? '';
    String title = map['title'] ?? '';
    String author = map['author'] ?? '';
    String alias = map['alias'] ?? '';
    String sourceName = map['sourceName'] ?? '';
    String mediaTypePrefs = map['mediaTypePrefs'] ?? '';
    int currentProgress = int.tryParse(map['currentProgress'] ?? '') ?? 0;
    int completeProgress = int.tryParse(map['completeProgress'] ?? '') ?? 0;
    String thumbnailPath = map['thumbnailPath'] ?? '';
    Map<String, dynamic> extra = jsonDecode(map['extra'] ?? '{}');

    return MediaHistoryItem(
      key: key,
      title: title,
      author: author,
      alias: alias,
      mediaTypePrefs: mediaTypePrefs,
      sourceName: sourceName,
      currentProgress: currentProgress,
      completeProgress: completeProgress,
      thumbnailPath: thumbnailPath,
      extra: extra,
    );
  }

  String toJson() {
    Map<String, String> map = {
      'key': key,
      'title': title,
      'author': author,
      'alias': alias,
      'sourceName': sourceName,
      'mediaTypePrefs': mediaTypePrefs,
      'currentProgress': currentProgress.toString(),
      'completeProgress': completeProgress.toString(),
      'thumbnailPath': thumbnailPath,
      'extra': jsonEncode(extra),
    };

    return jsonEncode(map);
  }
}

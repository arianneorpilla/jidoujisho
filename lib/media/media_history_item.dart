import 'dart:convert';

abstract class MediaHistoryItem {
  MediaHistoryItem({
    required this.uri,
    required this.name,
    required this.resourceUri,
    required this.progress,
    required this.extra,
  });

  /// The [Uri] pertaining to the item. For example, for Player video playback
  /// history, this is a uri to the video file. This could be a website link
  /// for a custom streaming service media type.
  late Uri uri;

  /// The name to be given for display for the history item. This could be the
  /// name of a video file or the name of a book.
  late String name;

  /// A progress parameter. For the Reader, this could be the scroll position
  /// to scroll to. For the Player, this could be the number of seconds to seek
  /// to when resuming playback.
  late int progress;

  /// The [Uri] pertaining to a preview resource, e.g. a thumbnail or cover
  /// art for a book.
  late Uri resourceUri;

  /// Extra details that may be necessary should a media type need to be
  /// extended to find its use. For example, the Viewer may find storing the
  /// individual chapters progress necessary.
  late Map<String, String> extra;

  /// Return the serialised JSON form of this [MediaHistoryItem]. See
  /// [MediaHistory] for how this is used.
  String toJson() {
    Map<String, String> map = {
      "uri": uri.toString(),
      "name": name,
      "resourceUri": resourceUri.toString(),
      "progress": progress.toString(),
      "extra": jsonEncode(extra),
    };

    return jsonEncode(map);
  }
}

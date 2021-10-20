import 'dart:convert';

abstract class MediaHistoryItem {
  MediaHistoryItem({
    required this.key,
    required this.name,
    required this.resource,
    required this.progress,
    required this.extra,
  });

  /// A key unique identifier for the item. For example, for Player video
  /// playback history, this is a uri to the video file, which should be
  /// unique in a filesystem. This could be a website link for a custom
  /// streaming service media type, or even the data itself in [String] form.
  late String key;

  /// The name to be given for display for the history item. This could be the
  /// name of a video file or the name of a book.
  late String name;

  /// A progress parameter. For the Reader, this could be the scroll position
  /// to scroll to. For the Player, this could be the number of seconds to seek
  /// to when resuming playback.
  late int progress;

  /// The [Uri] pertaining to a preview resource, e.g. a thumbnail or cover
  /// art for a book.
  late String resource;

  /// Extra details that may be necessary should a media type need to be
  /// extended to find its use. For example, the Viewer may find storing the
  /// individual chapters progress necessary.
  late Map<String, dynamic> extra;

  /// Return the serialised JSON form of this [MediaHistoryItem]. See
  /// [MediaHistory] for how this is used.
  String toJson() {
    Map<String, String> map = {
      "key": key,
      "name": name,
      "resource": resource,
      "progress": progress.toString(),
      "extra": jsonEncode(extra),
    };

    return jsonEncode(map);
  }
}

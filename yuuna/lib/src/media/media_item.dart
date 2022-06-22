import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pretty_json/pretty_json.dart';
part 'media_item.g.dart';

/// An item representable in media history from which a media source may
/// start playback with. This entity does not have any progress information,
/// such as duration or number of chapters and individual progress of those
/// items. That extra information is handled as extra arguments used alongside
/// the [MediaItem], and not included within it. This design is done to reduce
/// the number and complexity of CRUD operations, as including all data in this
/// entity is impractical to include when persisting a progress update.
@JsonSerializable()
@Collection()
class MediaItem {
  /// Initialise a media item with certain details.
  MediaItem({
    required this.uniqueKey,
    required this.title,
    required this.sourceIdentifier,
    this.id,
    this.author,
    this.sourceMetadata,
    this.position,
    this.duration,
  });

  /// Create an instance of this class from a serialized format.
  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);

  /// Convert this into a serialized format.
  Map<String, dynamic> toJson() => _$MediaItemToJson(this);

  /// A unique identifier for the purposes of database storage.
  @Id()
  int? id;

  /// The unique identifier of this item. Using this variable alone, a media
  /// source must be able to functionally process how to display the media.
  /// If the same item exists in history, then the item is replaced with a
  /// newer item in the addition operation. This key is also used to identify
  /// resources such as thumbnails in the cache.
  String uniqueKey;

  /// The name of this item. Typically, this could be the name of a video
  /// or a book.
  String title;

  /// The media source where this item is from.
  String sourceIdentifier;

  /// This field is a convenience field as it may be common to store this
  /// detail. For a web video, this could be the channel where the video is
  /// from. For a book, it is the author.
  String? author;

  /// This field may be used to store additional details that the source may
  /// require to get more details on this item.
  String? sourceMetadata;

  /// The current progress of the media in the time this context was made.
  /// This could be the seconds of a playing video or the page number of a
  /// book or comic.
  final int? position;

  /// The media's full duration, used to be able to tell the completion of
  /// this media context relative to the position.
  final int? duration;

  @override
  operator ==(Object other) =>
      other is MediaItem && other.uniqueKey == uniqueKey;

  @override
  int get hashCode => toJson().hashCode;

  @override
  String toString() => prettyJson(toJson());
}

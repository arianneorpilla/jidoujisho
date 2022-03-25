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
    this.references,
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

  /// The media source where this item is from. All media sources have a
  /// unique identifier that takes the format of [media/type/source] or
  /// [enhancement/field/key].
  /// This is used to generate resources that the media item may require for
  /// preview purposes. For example, for a local media item to display its
  /// screenshot, the player page will need to invoke a function pertaining
  /// to the media source in order to generate its thumbnail.
  String sourceIdentifier;

  /// This field is a convenience field as it may be common to store this
  /// detail. For a web video, this could be the channel where the video is
  /// from. For a book, it is the author.
  String? author;

  /// This field may be used to store additional details that the source may
  /// require to get more details on this item.
  String? sourceMetadata;

  /// This field can be used to store the database identifiers of a
  /// dictionary entry, allowing a dictionary search result bundling multiple
  /// entries to be stored as a single media item in media history.
  List<int>? references;

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

  /// The category from which this media item is from, enhancement or media.
  String get identifierCategory => sourceIdentifier.split('/')[0];

  /// The media type or field from the source identifier.
  String get identifierType => sourceIdentifier.split('/')[1];

  /// The media source or the enhancement unique key from the source identifier.
  String get identifierKey => sourceIdentifier.split('/')[2];

  /// If this media item was from an enhancement.
  bool get fromEnhancement => identifierCategory == 'enhancement';

  /// If this media item was from media.
  bool get fromMedia => identifierCategory == 'enhancement';
}

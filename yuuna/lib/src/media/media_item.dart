import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
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
    required this.mediaIdentifier,
    required this.title,
    required this.mediaTypeIdentifier,
    required this.mediaSourceIdentifier,
    required this.position,
    required this.duration,
    required this.canDelete,
    required this.canEdit,
    this.id,
    this.extraUrl,
    this.extra,
    this.base64Image,
    this.imageUrl,
    this.audioUrl,
    this.author,
    this.authorIdentifier,
    this.sourceMetadata,
  });

  /// Create an instance of this class from a serialized format.
  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);

  /// Convert this into a serialized format.
  Map<String, dynamic> toJson() => _$MediaItemToJson(this);

  /// A unique identifier for the purposes of database storage.
  Id? id;

  /// A unique identifier for the purposes of database storage.
  @Index(unique: true, replace: true)
  String get uniqueKey => '$mediaSourceIdentifier/$mediaIdentifier';

  /// The media identifier of this item. Using this variable alone, a media
  /// source must be able to functionally process how to display the media.
  /// If the same item exists in history, then the item is replaced with a
  /// newer item in the addition operation. This key is also used to identify
  /// resources such as thumbnails in the cache.
  @Index()
  String mediaIdentifier;

  /// The name of this item. Typically, this could be the name of a video
  /// or a book.
  String title;

  /// The media type where this item is from.
  @Index(type: IndexType.hash)
  String mediaTypeIdentifier;

  /// The media source where this item is from.
  @Index(type: IndexType.hash)
  String mediaSourceIdentifier;

  /// If [imageUrl] is null and this is not null, this will be used as the
  /// preview image.
  String? base64Image;

  /// This will be attempted for use as the preview image if not null,
  /// otherwise [base64Image] will be attempted.
  String? imageUrl;

  /// Used to override the audio to be played for the media.
  String? audioUrl;

  /// This field is a convenience field as it may be common to store this
  /// detail. For a web video, this could be the channel where the video is
  /// from. For a book, it is the author.
  String? author;

  /// Used to provide any extra URL information.
  String? extraUrl;

  /// This field is a convenience field for metadata information.
  String? extra;

  /// This field is for future-proofing, and can be used to store an identifier
  /// for an author, for example, a YouTube channel.
  String? authorIdentifier;

  /// This field may be used to store additional details that the source may
  /// require to get more details on this item.
  String? sourceMetadata;

  /// The current progress of the media in the time this context was made.
  /// This could be the seconds of a playing video or the page number of a
  /// book or comic.
  int position;

  /// The media's full duration, used to be able to tell the completion of
  /// this media context relative to the position.
  int duration;

  /// Whether or not this [MediaItem] can be deleted.
  final bool canDelete;

  /// Whether or not this [MediaItem] allows overriding the display title and
  /// thumbnail.
  final bool canEdit;

  @override
  operator ==(Object other) =>
      other is MediaItem && other.uniqueKey == uniqueKey;

  @override
  int get hashCode => toJson().hashCode;

  @override
  String toString() {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(this);
  }

  /// Get the [MediaType] from a [MediaItem] from its serialised identifier.
  MediaType getMediaType({required AppModel appModel}) {
    return appModel.mediaTypes[mediaTypeIdentifier]!;
  }

  /// Get the [MediaSource] from a [MediaItem] from its serialised identifier.
  MediaSource getMediaSource({required AppModel appModel}) {
    MediaType mediaType = getMediaType(appModel: appModel);
    return appModel.mediaSources[mediaType]![mediaSourceIdentifier]!;
  }

  /// Creates a deep copy of this mapping but with the given variables replaced
  /// with the new values.
  MediaItem copyWith({
    int? id,
    String? mediaIdentifier,
    String? title,
    String? mediaSourceIdentifier,
    String? mediaTypeIdentifier,
    String? base64Image,
    String? imageUrl,
    String? audioUrl,
    String? author,
    String? sourceMetadata,
    int? position,
    int? duration,
    bool? canDelete,
    bool? canEdit,
  }) {
    return MediaItem(
      id: id ?? this.id,
      mediaIdentifier: mediaIdentifier ?? this.mediaIdentifier,
      title: title ?? this.title,
      mediaSourceIdentifier:
          mediaSourceIdentifier ?? this.mediaSourceIdentifier,
      mediaTypeIdentifier: mediaTypeIdentifier ?? this.mediaTypeIdentifier,
      base64Image: base64Image ?? this.base64Image,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      author: author ?? this.author,
      sourceMetadata: sourceMetadata ?? this.sourceMetadata,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      canDelete: canDelete ?? this.canDelete,
      canEdit: canEdit ?? this.canEdit,
    );
  }
}

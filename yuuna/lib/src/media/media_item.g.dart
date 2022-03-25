// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) => MediaItem(
      uniqueKey: json['uniqueKey'] as String,
      title: json['title'] as String,
      sourceIdentifier: json['sourceIdentifier'] as String,
      id: json['id'] as int?,
      author: json['author'] as String?,
      sourceMetadata: json['sourceMetadata'] as String?,
      references:
          (json['references'] as List<dynamic>?)?.map((e) => e as int).toList(),
      position: json['position'] as int?,
      duration: json['duration'] as int?,
    );

Map<String, dynamic> _$MediaItemToJson(MediaItem instance) => <String, dynamic>{
      'id': instance.id,
      'uniqueKey': instance.uniqueKey,
      'title': instance.title,
      'sourceIdentifier': instance.sourceIdentifier,
      'author': instance.author,
      'sourceMetadata': instance.sourceMetadata,
      'references': instance.references,
      'position': instance.position,
      'duration': instance.duration,
    };

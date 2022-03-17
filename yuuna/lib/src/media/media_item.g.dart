// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) => MediaItem(
      uniqueKey: json['uniqueKey'] as String,
      title: json['title'] as String,
      sourceId: json['sourceId'] as String,
      id: json['id'] as int?,
      author: json['author'] as String?,
      sourceMetadata: json['sourceMetadata'] as String?,
      references:
          (json['references'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );

Map<String, dynamic> _$MediaItemToJson(MediaItem instance) => <String, dynamic>{
      'id': instance.id,
      'uniqueKey': instance.uniqueKey,
      'title': instance.title,
      'sourceId': instance.sourceId,
      'author': instance.author,
      'sourceMetadata': instance.sourceMetadata,
      'references': instance.references,
    };

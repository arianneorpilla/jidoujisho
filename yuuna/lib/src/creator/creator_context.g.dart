// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatorContext _$CreatorContextFromJson(Map<String, dynamic> json) =>
    CreatorContext(
      sentence: json['sentence'] as String?,
      word: json['word'] as String?,
      reading: json['reading'] as String?,
      meaning: json['meaning'] as String?,
      extra: json['extra'] as String?,
      imageSeed: json['imageSeed'] == null
          ? null
          : MediaItem.fromJson(json['imageSeed'] as Map<String, dynamic>),
      imageSearch: json['imageSearch'] as String?,
      imageSuggestions: (json['imageSuggestions'] as List<dynamic>?)
          ?.map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      audioSeed: json['audioSeed'] == null
          ? null
          : MediaItem.fromJson(json['audioSeed'] as Map<String, dynamic>),
      audioSearch: json['audioSearch'] as String?,
      context: json['context'] == null
          ? null
          : MediaItem.fromJson(json['context'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreatorContextToJson(CreatorContext instance) =>
    <String, dynamic>{
      'sentence': instance.sentence,
      'word': instance.word,
      'reading': instance.reading,
      'meaning': instance.meaning,
      'extra': instance.extra,
      'imageSeed': instance.imageSeed,
      'imageSuggestions': instance.imageSuggestions,
      'audioSeed': instance.audioSeed,
      'imageSearch': instance.imageSearch,
      'audioSearch': instance.audioSearch,
      'context': instance.context,
    };

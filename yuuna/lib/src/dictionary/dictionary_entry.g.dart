// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictionaryEntry _$DictionaryEntryFromJson(Map<String, dynamic> json) =>
    DictionaryEntry(
      word: json['word'] as String?,
      dictionaryName: json['dictionaryName'] as String?,
      id: json['id'] as int?,
      reading: json['reading'] as String?,
      meaning: json['meaning'] as String?,
      extra: json['extra'] as String?,
      meanings: (json['meanings'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      meaningTags: (json['meaningTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      wordTags: (json['wordTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      popularity: json['popularity'] as int?,
      sequence: json['sequence'] as int?,
    );

Map<String, dynamic> _$DictionaryEntryToJson(DictionaryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'word': instance.word,
      'reading': instance.reading,
      'meaning': instance.meaning,
      'extra': instance.extra,
      'meanings': instance.meanings,
      'meaningTags': instance.meaningTags,
      'wordTags': instance.wordTags,
      'popularity': instance.popularity,
      'sequence': instance.sequence,
      'dictionaryName': instance.dictionaryName,
    };

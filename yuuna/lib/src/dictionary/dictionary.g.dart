// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dictionary _$DictionaryFromJson(Map<String, dynamic> json) => Dictionary(
      dictionaryName: json['dictionaryName'] as String,
      formatName: json['formatName'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    )..id = json['id'] as int?;

Map<String, dynamic> _$DictionaryToJson(Dictionary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dictionaryName': instance.dictionaryName,
      'formatName': instance.formatName,
      'metadata': instance.metadata,
    };

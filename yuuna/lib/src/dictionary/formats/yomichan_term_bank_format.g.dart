// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yomichan_term_bank_format.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YomichanTag _$YomichanTagFromJson(Map<String, dynamic> json) => YomichanTag(
      name: json['name'] as String,
      category: json['category'] as String,
      sortingOrder: json['sortingOrder'] as int,
      notes: json['notes'] as String,
      popularity: (json['popularity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$YomichanTagToJson(YomichanTag instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'sortingOrder': instance.sortingOrder,
      'notes': instance.notes,
      'popularity': instance.popularity,
    };

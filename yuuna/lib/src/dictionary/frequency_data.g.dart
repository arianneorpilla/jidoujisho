// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frequency_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FrequencyData _$FrequencyDataFromJson(Map<String, dynamic> json) =>
    FrequencyData(
      value: (json['value'] as num).toDouble(),
      displayValue: json['displayValue'] as String,
      reading: json['reading'] as String?,
    );

Map<String, dynamic> _$FrequencyDataToJson(FrequencyData instance) =>
    <String, dynamic>{
      'value': instance.value,
      'displayValue': instance.displayValue,
      'reading': instance.reading,
    };

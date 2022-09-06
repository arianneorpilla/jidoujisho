// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pitch_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PitchData _$PitchDataFromJson(Map<String, dynamic> json) => PitchData(
      reading: json['reading'] as String,
      downstep: json['downstep'] as int,
    );

Map<String, dynamic> _$PitchDataToJson(PitchData instance) => <String, dynamic>{
      'reading': instance.reading,
      'downstep': instance.downstep,
    };

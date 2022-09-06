import 'package:json_annotation/json_annotation.dart';

part 'pitch_data.g.dart';

/// A base class representing a generic implementation of a dictionary entry.
/// Not all variables need to be defined in an entry. This class is heavily
/// based on the Yomichan's term bank schema, though it does not completely
/// parallel its feature set. The intent is to allow compatibility for most
/// cases when importing data using that schema.
@JsonSerializable()
class PitchData {
  /// Initialise a dictionary entry with given details of a certain word.
  PitchData({
    required this.reading,
    required this.downstep,
  });

  /// Create an instance of this class from a serialized format.
  factory PitchData.fromJson(Map<String, dynamic> json) =>
      _$PitchDataFromJson(json);

  /// Convert this into a serialized format.
  Map<String, dynamic> toJson() => _$PitchDataToJson(this);

  /// The pronunciation of the word represented by this dictionary entry.
  final String reading;

  /// The downstep for this term's reading.
  final int downstep;
}

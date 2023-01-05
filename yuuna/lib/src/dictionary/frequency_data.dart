import 'package:json_annotation/json_annotation.dart';

part 'frequency_data.g.dart';

/// A base class representing a generic implementation of a dictionary entry.
/// Not all variables need to be defined in an entry. This class is heavily
/// based on the Yomichan's term bank schema, though it does not completely
/// parallel its feature set. The intent is to allow compatibility for most
/// cases when importing data using that schema.
@JsonSerializable()
class FrequencyData {
  /// Initialise a dictionary entry with given details of a certain word.
  FrequencyData({
    required this.value,
    required this.displayValue,
    this.reading,
  });

  /// Create an instance of this class from a serialized format.
  factory FrequencyData.fromJson(Map<String, dynamic> json) =>
      _$FrequencyDataFromJson(json);

  /// Convert this into a serialized format.
  Map<String, dynamic> toJson() => _$FrequencyDataToJson(this);

  /// Frequency value.
  final double value;

  /// Value to show as text.
  final String displayValue;

  /// The pronunciation of the word represented by this dictionary entry.
  final String? reading;
}

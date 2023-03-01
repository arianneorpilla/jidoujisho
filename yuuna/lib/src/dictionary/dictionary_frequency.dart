import 'package:yuuna/dictionary.dart';
import 'package:isar/isar.dart';

part 'dictionary_frequency.g.dart';

/// A database entity that that represents supplementary frequency data for a
/// certain search key.
@Collection()
class DictionaryFrequency {
  /// Frequency data contains a numerical and text value.
  DictionaryFrequency({
    required this.value,
    required this.displayValue,
    this.id,
  });

  /// Identifier for database purposes.
  Id? id;

  /// Numerical representation of the frequency information.
  final double value;

  /// Text representation of the frequency information.
  final String displayValue;

  /// This object belongs to a certain heading.
  final IsarLink<DictionaryHeading> heading = IsarLink<DictionaryHeading>();

  /// This object belongs to a dictionary.
  final IsarLink<Dictionary> dictionary = IsarLink<Dictionary>();

  @override
  bool operator ==(Object other) => other is DictionaryPitch && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

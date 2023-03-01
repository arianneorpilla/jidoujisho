import 'package:yuuna/dictionary.dart';
import 'package:isar/isar.dart';

part 'dictionary_pitch.g.dart';

/// A database entity that that represents supplementary pitch accent data for
/// a certain search key.
@Collection()
class DictionaryPitch {
  /// Pitch data contains a downstep value, and pertains to a certain search
  /// key and a dictionary.
  DictionaryPitch({
    required this.downstep,
    this.id,
  });

  /// Identifier for database purposes.
  Id? id;

  /// Number that represents the index of the morae where the downstep occurs.
  final int downstep;

  /// This object pertains to a certain heading.
  final IsarLink<DictionaryHeading> heading = IsarLink<DictionaryHeading>();

  /// This object belongs to a dictionary.
  final IsarLink<Dictionary> dictionary = IsarLink<Dictionary>();

  @override
  bool operator ==(Object other) => other is DictionaryPitch && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

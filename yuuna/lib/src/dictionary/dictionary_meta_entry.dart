import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/utils.dart';

part 'dictionary_meta_entry.g.dart';

/// A base class representing a generic implementation of a dictionary meta
/// entry. Not all variables need to be defined in an entry. This class is
/// heavily based on the Yomichan's term meta bank schema, though it does not
/// completely parallel its feature set. The intent is to allow compatibility
/// for most cases when importing data using that schema.
@JsonSerializable()
@Collection()
class DictionaryMetaEntry {
  /// Initialise a dictionary entry with given details of a certain word.
  DictionaryMetaEntry({
    required this.dictionaryName,
    required this.term,
    this.pitches,
    this.frequency,
    this.id,
  });

  /// Create an instance of this class from a serialized format.
  factory DictionaryMetaEntry.fromJson(Map<String, dynamic> json) =>
      _$DictionaryMetaEntryFromJson(json);

  /// Convert this into a serialized format.
  Map<String, dynamic> toJson() => _$DictionaryMetaEntryToJson(this);

  /// A unique identifier for the purposes of database storage.
  Id? id;

  /// The word or phrase represented by this dictionary entry.
  @Index(type: IndexType.hash, caseSensitive: false)
  final String term;

  /// Length of the term.
  @Index(composite: [CompositeIndex('term')])
  int get termLength => term.length;

  /// The dictionary from which this entry was imported from. This is used for
  /// database query purposes.
  @Index(type: IndexType.hash)
  final String dictionaryName;

  /// The frequency of this term.
  @ignore
  FrequencyData? frequency;

  /// List of pitch accent downsteps for this term's reading.
  @ignore
  List<PitchData>? pitches;

  /// Serializes [pitches].
  String? get pitchesIsar => PitchDataConverter.toIsar(pitches);
  set pitchesIsar(String? object) =>
      pitches = PitchDataConverter.fromIsar(object);

  /// Serializes [frequency].
  String? get frequencyIsar => FrequencyDataConverter.toIsar(frequency);
  set frequencyIsar(String? object) =>
      frequency = FrequencyDataConverter.fromIsar(object);

  @override
  operator ==(Object other) => other is DictionaryMetaEntry && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

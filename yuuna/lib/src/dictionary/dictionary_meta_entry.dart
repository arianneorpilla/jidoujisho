import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/utils.dart';

part 'dictionary_meta_entry.g.dart';

/// A base class representing a generic implementation of a dictionary entry.
/// Not all variables need to be defined in an entry. This class is heavily
/// based on the Yomichan's term meta bank schema, though it does not
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
  @Id()
  int? id;

  /// The word or phrase represented by this dictionary entry.
  @Index()
  final String term;

  @Index()

  /// Length of the term.
  @Index(composite: [CompositeIndex('term')])
  int get termLength => term.length;

  /// The dictionary from which this entry was imported from. This is used for
  /// database query purposes.
  @Index()
  final String dictionaryName;

  /// The frequency of this term.
  @Index()
  final String? frequency;

  /// List of pitch accent downsteps for this term's reading.
  @PitchDataConverter()
  final List<PitchData>? pitches;
}

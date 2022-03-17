import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pretty_json/pretty_json.dart';
part 'dictionary_entry.g.dart';

/// A base class representing a generic implementation of a dictionary entry.
/// Not all variables need to be defined in an entry. This class is heavily
/// based on the Yomichan's term bank schema, though it does not completely
/// parallel its feature set. The intent is to allow compatibility for most
/// cases when importing data using that schema.
@JsonSerializable()
@Collection()
class DictionaryEntry {
  /// Initialise a dictionary entry with given details of a certain word.
  DictionaryEntry({
    required this.word,
    required this.dictionaryName,
    this.id,
    this.reading,
    this.meaning,
    this.extra,
    this.meanings,
    this.meaningTags,
    this.wordTags,
    this.popularity,
    this.sequence,
  });

  /// Create an instance of this class from a serialized format.
  factory DictionaryEntry.fromJson(Map<String, dynamic> json) =>
      _$DictionaryEntryFromJson(json);

  /// Convert this into a serialized format.
  Map<String, dynamic> toJson() => _$DictionaryEntryToJson(this);

  /// A unique identifier for the purposes of database storage.
  @Id()
  int? id;

  /// The word represented by this dictionary entry.
  final String? word;

  /// The pronunciation of the word represented by this dictionary entry.
  final String? reading;

  /// A simple text representation of the definition of the word represented
  /// by this dictionary entry. More complex structures that may contain plural
  /// definitions should use [meanings] instead.
  final String? meaning;

  /// A bonus field for storing any additional kind of information. For example,
  /// if there are any grammar rules related to this term.
  final String? extra;

  /// If this term has multiple definition entries, they can be stored here
  /// rather than [meaning], which should be used for the singular case instead.
  final List<String>? meanings;

  /// Tags that are used to indicate a certain trait to the definitions of
  /// this word.
  final List<String>? meaningTags;

  /// Tags that are used to indicate a certain trait to this particular word.
  final List<String>? wordTags;

  /// A value that can be used to sort entries when performing a database
  /// search.
  final int? popularity;

  /// A value that can be used to group similar entries with the same value
  /// together.
  final int? sequence;

  /// The dictionary from which this entry was imported from. This is used for
  /// database query purposes.
  final String? dictionaryName;

  @override
  operator ==(Object other) =>
      other is DictionaryEntry && other.toJson() == toJson();

  @override
  int get hashCode => toJson().hashCode;

  @override
  String toString() => prettyJson(toJson());
}

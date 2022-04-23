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
    required this.meanings,
    this.id,
    this.reading,
    this.extra,
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
  @Index()
  final String word;

  /// The dictionary from which this entry was imported from. This is used for
  /// database query purposes.
  @Index()
  final String dictionaryName;

  /// The pronunciation of the word represented by this dictionary entry.
  @Index()
  final String? reading;

  /// A list of definitions for a word. If there is only a single [String] item,
  /// this should be a single item list.
  final List<String> meanings;

  /// A bonus field for storing any additional kind of information. For example,
  /// if there are any grammar rules related to this term.
  final String? extra;

  /// Tags that are used to indicate a certain trait to the definitions of
  /// this word.
  final List<String>? meaningTags;

  /// Tags that are used to indicate a certain trait to this particular word.
  final List<String>? wordTags;

  /// A value that can be used to sort entries when performing a database
  /// search.
  @Index()
  final double? popularity;

  /// A value that can be used to group similar entries with the same value
  /// together.
  @Index()
  final int? sequence;

  @override
  operator ==(Object other) =>
      other is DictionaryEntry && other.toJson() == toJson();

  @override
  int get hashCode => toJson().hashCode;

  @override
  String toString() => prettyJson(toJson());
}

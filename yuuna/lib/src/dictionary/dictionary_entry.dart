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
    this.reading = '',
    this.id,
    this.extra,
    this.meaningTags = const [],
    this.wordTags = const [],
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
  @Index(composite: [CompositeIndex('reading'), CompositeIndex('popularity')])
  final String word;

  /// The dictionary from which this entry was imported from. This is used for
  /// database query purposes.
  @Index()
  final String dictionaryName;

  /// The pronunciation of the word represented by this dictionary entry.
  @Index()
  final String reading;

  /// A list of definitions for a word. If there is only a single [String] item,
  /// this should be a single item list.
  final List<String> meanings;

  /// A bonus field for storing any additional kind of information. For example,
  /// if there are any grammar rules related to this term.
  final String? extra;

  /// Tags that are used to indicate a certain trait to the definitions of
  /// this word.
  final List<String> meaningTags;

  /// Tags that are used to indicate a certain trait to this particular word.
  final List<String> wordTags;

  /// A value that can be used to sort entries when performing a database
  /// search.
  @Index()
  final double? popularity;

  /// A value that can be used to group similar entries with the same value
  /// together.
  @Index()
  final int? sequence;

  /// The length of word is used as an index.
  @Index()
  int get wordLength => word.length;

  /// The length of reading is used as an index.
  @Index()
  int get readingLength => reading.length;

  /// Index for the first character of this word.
  @Index(composite: [
    CompositeIndex('wordSecondChar'),
    CompositeIndex('wordLength'),
  ])
  String? get wordFirstChar {
    if (word.isEmpty) {
      return null;
    } else {
      return word[0];
    }
  }

  /// Index for the second character of this word.
  String? get wordSecondChar {
    if (word.length < 2) {
      return null;
    } else {
      return word[1];
    }
  }

  /// Index for the first character of this word.
  @Index(composite: [
    CompositeIndex('readingSecondChar'),
    CompositeIndex('readingLength'),
  ])
  String? get readingFirstChar {
    if (reading.isEmpty) {
      return null;
    } else {
      return reading[0];
    }
  }

  /// Index for the second character of this word.
  String? get readingSecondChar {
    if (reading.length < 2) {
      return null;
    } else {
      return reading[1];
    }
  }

  @override
  operator ==(Object other) =>
      other is DictionaryEntry && other.toJson() == toJson();

  @override
  int get hashCode => toJson().hashCode;

  @override
  String toString() => prettyJson(toJson());
}

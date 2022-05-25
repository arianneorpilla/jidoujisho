import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/utils.dart';

part 'dictionary_term.g.dart';

/// A class for organising all parameters that fall under a unique
/// word-reading pair.
@JsonSerializable()
@Collection()
class DictionaryTerm {
  /// Initialise a dictionary term with the hardset values.
  DictionaryTerm({
    required this.term,
    required this.reading,
    required this.entries,
  });

  /// Create an instance of this class from a serialized format.
  factory DictionaryTerm.fromJson(Map<String, dynamic> json) =>
      _$DictionaryTermFromJson(json);

  /// Convert this into a serialized format.
  Map<String, dynamic> toJson() => _$DictionaryTermToJson(this);

  /// The headword of the dictionary term.
  final String term;

  /// Pronunciation of the term.
  final String reading;

  /// The dictionary entries found for the term-reading pair.
  @DictionaryEntriesConverter()
  final List<DictionaryEntry> entries;

  /// A unique identifier for the purposes of database storage.
  @Id()
  int? id;
}

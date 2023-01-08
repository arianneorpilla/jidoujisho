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
    this.entries = const [],
    this.metaEntries = const [],
    this.termTags = const [],
    this.meaningTagsGroups = const [],
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
  @ignore
  List<DictionaryEntry> entries;

  /// The dictionary meta entries found for the term-reading pair.
  @ignore
  List<DictionaryMetaEntry> metaEntries;

  /// The dictionary tags found for the specific term-reading pair.
  @ignore
  List<DictionaryTag> termTags;

  /// The dictionary tags found for each entry in [entries].
  @ignore
  List<List<DictionaryTag>> meaningTagsGroups;

  /// Serializes [entries].
  String get entriesIsar => DictionaryEntriesConverter.toIsar(entries);
  set entriesIsar(String object) =>
      entries = DictionaryEntriesConverter.fromIsar(object);

  /// Serializes [metaEntries].
  String get metaEntriesIsar =>
      DictionaryMetaEntriesConverter.toIsar(metaEntries);
  set metaEntriesIsar(String object) =>
      metaEntries = DictionaryMetaEntriesConverter.fromIsar(object);

  /// Serializes [termTags].
  String get termTagsIsar => DictionaryTagsConverter.toIsar(termTags);
  set termTagsIsar(String object) =>
      termTags = DictionaryTagsConverter.fromIsar(object);

  /// Serializes [meaningTagsGroups].
  String get meaningTagsGroupsIsar =>
      DictionaryTagsListConverter.toIsar(meaningTagsGroups);
  set meaningTagsGroupsIsar(String object) =>
      meaningTagsGroups = DictionaryTagsListConverter.fromIsar(object);

  @override
  operator ==(Object other) =>
      other is DictionaryTerm && reading == other.reading && term == other.term;

  @override
  int get hashCode => term.hashCode * reading.hashCode;

  /// A unique identifier for the purposes of database storage.
  Id? id;
}

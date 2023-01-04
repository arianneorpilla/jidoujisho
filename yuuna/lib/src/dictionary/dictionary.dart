import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yuuna/utils.dart';
part 'dictionary.g.dart';

/// A dictionary that can be imported into the application. Dictionary details
/// are stored in a database, while this separate class is used to encapsulate
/// and represent the metadata of the dictionary.
@JsonSerializable()
@Collection()
class Dictionary {
  /// Initialise a dictionary with details from import.
  Dictionary({
    required this.dictionaryName,
    required this.formatName,
    required this.order,
    required this.collapsed,
    required this.hidden,
    this.metadata,
  });

  /// Create an instance of this class from a serialized format.
  factory Dictionary.fromJson(Map<String, dynamic> json) =>
      _$DictionaryFromJson(json);

  /// Convert this into a serialized format.
  Map<String, dynamic> toJson() => _$DictionaryToJson(this);

  /// A unique identifier for the purposes of database storage.
  Id? id;

  /// The name of the dictionary. For example, this could be 'Merriam-Webster
  /// Dictionary' or '大辞林' or 'JMdict'.
  ///
  /// Dictionary names are meant to be unique, meaning two dictionaries of the
  /// same name should not be allowed to be added in the database.
  @Index(unique: true)
  final String dictionaryName;

  /// The format that the dictionary was sourced from.
  final String formatName;

  /// The order of this dictionary in terms of user sorting, relative to other
  /// dictionaries.
  @Index(unique: true)
  int order;

  /// Whether this dictionary is collapsed or not by default in search results.
  bool collapsed;

  /// Whether this dictionary is shown or not in search results.
  bool hidden;

  /// Any extra dictionary-specific information that this dictionary may
  /// decide to store for use at runtime.
  @ignore
  Map<String, dynamic>? metadata;

  /// Serializes [metadata].
  String get pitchesIsar => ImmutableStringMapConverter.toIsar(metadata!);
  set pitchesIsar(String object) =>
      metadata = ImmutableStringMapConverter.fromIsar(object);
}

import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/utils.dart';

part 'dictionary_result.g.dart';

/// A database entity for storing references to [DictionaryEntry] results that
/// are yielded from dictionary database searches.
@Collection()
@JsonSerializable()
class DictionaryResult {
  /// Define a search result with the given references to [DictionaryEntry]
  /// items.
  DictionaryResult({
    required this.searchTerm,
    this.mapping = const [],
    this.id,
  });

  /// A unique identifier for the purposes of database storage.
  @Id()
  final int? id;

  /// Original search term used to make the result.
  @Index(unique: true)
  late String searchTerm;

  /// A list of list of [DictionaryEntry] indexes sorted by [DictionaryPair].
  @DictionaryEntriesConverter()
  final List<List<DictionaryEntry>> mapping;
}

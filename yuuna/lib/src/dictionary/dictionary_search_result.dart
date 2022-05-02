import 'package:isar/isar.dart';
import 'package:yuuna/dictionary.dart';

part 'dictionary_search_result.g.dart';

/// A database entity for storing references to [DictionaryEntry] results that
/// are yielded from dictionary database searches.
@Collection()
class DictionarySearchResult {
  /// Define a search result with the given references to [DictionaryEntry]
  /// items.
  DictionarySearchResult({
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
  final List<List<int>> mapping;
}

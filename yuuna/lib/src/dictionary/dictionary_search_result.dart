import 'package:yuuna/dictionary.dart';
import 'package:isar/isar.dart';

part 'dictionary_search_result.g.dart';

/// A database entity for storing references to [DictionaryEntry] results that
/// are yielded from dictionary database searches.
@Collection()
@Collection(accessor: 'dictionarySearchHistory')
class DictionarySearchResult {
  /// Define a search result with the given references to [DictionaryEntry]
  /// items.
  DictionarySearchResult({
    this.searchTerm = '',
    this.bestLength = 0,
    this.scrollPosition = 0,
    this.headingIds = const [],
    this.id,
  });

  /// Identifier for database purposes.
  Id? id;

  /// Original search term used to make the result.
  @Index(unique: true)
  final String searchTerm;

  /// The best length found for the search term used for highlighting the
  /// selected word.
  final int bestLength;

  /// The current scroll position of the result in dictionary history.
  int scrollPosition;

  /// List of ids by order.
  final List<int> headingIds;

  /// A single result may have multiple headings in the result, which in turn
  /// contain multiple dictionary entries.
  final IsarLinks<DictionaryHeading> headings = IsarLinks<DictionaryHeading>();
}

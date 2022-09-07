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
    this.terms = const [],
    this.scrollIndex = 0,
    this.id,
  });

  /// A unique identifier for the purposes of database storage.
  @Id()
  int? id;

  /// An index that indicates which in the mapping is the last viewed and
  /// should be shown on the dashboard. Scrolling a result horizontally in the
  /// dictionary history will change and update this result in the database.
  int scrollIndex;

  /// Original search term used to make the result.
  @Index(unique: true)
  late String searchTerm;

  /// A list of list of [DictionaryEntry] indexes sorted by [DictionaryPair].
  @DictionaryTermsConverter()
  final List<DictionaryTerm> terms;
}

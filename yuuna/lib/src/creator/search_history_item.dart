import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_history_item.g.dart';

/// A collection of search history items given a certain name.
@JsonSerializable()
@Collection()
class SearchHistoryItem {
  /// Initialise a model mapping with the given parameters.
  SearchHistoryItem({
    required this.historyKey,
    required this.searchTerm,
    this.id,
  });

  /// The key representing the history type of this item.
  @Index()
  final String historyKey;

  /// The name of the model to use when exporting with this mapping.
  @Index()
  final String searchTerm;

  /// Enforces the uniqueness of a search term within its history type.
  @Index(unique: true)
  String get uniqueKey => '$historyKey/$searchTerm';

  /// A unique identifier for the purposes of database storage.
  @Id()
  int? id;
}

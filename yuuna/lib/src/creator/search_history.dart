import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_history.g.dart';

/// A collection of search history items given a certain name.
@JsonSerializable()
@Collection()
class SearchHistory {
  /// Initialise a model mapping with the given parameters.
  SearchHistory({
    required this.uniqueKey,
    required this.items,
    this.id,
  });

  /// The name of this mapping.
  @Index(unique: true)
  final String uniqueKey;

  /// The name of the model to use when exporting with this mapping.
  List<String> items;

  /// A unique identifier for the purposes of database storage.
  @Id()
  int? id;
}

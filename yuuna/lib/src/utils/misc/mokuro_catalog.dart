import 'package:isar/isar.dart';

part 'mokuro_catalog.g.dart';

/// Used to persist online catalogs of Mokuro manga.
@Collection()
class MokuroCatalog {
  /// Initialise this object.
  MokuroCatalog({
    required this.name,
    required this.url,
    required this.order,
    this.id,
  });

  /// Used for database purposes.
  Id? id;

  /// Name of the catalog.
  final String name;

  /// The URL pertaining to the catalog.
  @Index(unique: true, replace: true)
  final String url;

  /// The order of this dictionary in terms of user sorting, relative to other
  /// dictionaries.
  @Index(unique: true, replace: true)
  int order;

  @override
  bool operator ==(Object other) => other is MokuroCatalog && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

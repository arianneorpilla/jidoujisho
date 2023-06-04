import 'package:isar/isar.dart';

part 'browser_bookmark.g.dart';

/// Used to persist online catalogs of Mokuro manga.
@Collection()
class BrowserBookmark {
  /// Initialise this object.
  BrowserBookmark({
    required this.name,
    required this.url,
    this.id,
  });

  /// Used for database purposes.
  Id? id;

  /// Name of the catalog.
  final String name;

  /// The URL pertaining to the catalog.
  @Index(unique: true, replace: true)
  final String url;

  @override
  bool operator ==(Object other) => other is BrowserBookmark && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

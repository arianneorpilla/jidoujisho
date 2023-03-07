import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:yuuna/dictionary.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;

part 'dictionary.g.dart';

/// A dictionary that can be imported into the application, encapsulating its
/// metadata and current preferences.
@Collection()
@CopyWith()
class Dictionary {
  /// Initialise a dictionary with details determined from import.
  Dictionary({
    required this.name,
    required this.formatKey,
    required this.collapsed,
    required this.hidden,
    required this.order,
  });

  /// Function to generate a lookup ID for heading by its unique string key.
  static int hash({required String name}) {
    return fastHash(name);
  }

  /// Identifier for database purposes.
  Id get id => hash(name: name);

  /// The name of the dictionary. For example, this could be 'Merriam-Webster
  /// Dictionary' or '大辞林' or 'JMdict'.
  ///
  /// Dictionary names are meant to be unique, meaning two dictionaries of the
  /// same name should not be allowed to be added in the database.
  @Index(unique: true)
  final String name;

  /// The unique key for the format that the dictionary was sourced from.
  final String formatKey;

  /// The order of this dictionary in terms of user sorting, relative to other
  /// dictionaries.
  @Index()
  int order;

  /// Whether this dictionary is collapsed or not by default in search results.
  bool collapsed;

  /// Whether this dictionary is shown or not in search results.
  bool hidden;

  /// A dictionary may have multiple entries.
  @Backlink(to: 'dictionary')
  final IsarLinks<DictionaryEntry> entries = IsarLinks<DictionaryEntry>();

  /// A dictionary may have multiple tags.
  @Backlink(to: 'dictionary')
  final IsarLinks<DictionaryTag> tags = IsarLinks<DictionaryTag>();

  /// A dictionary may have multiple pitch entries.
  @Backlink(to: 'dictionary')
  final IsarLinks<DictionaryPitch> pitches = IsarLinks<DictionaryPitch>();

  /// A dictionary may have multiple frequency entries.
  @Backlink(to: 'dictionary')
  final IsarLinks<DictionaryFrequency> frequencies =
      IsarLinks<DictionaryFrequency>();

  /// Returns the resource path for within the applications documents directory.
  String getBasePath({required String appDirDocPath}) {
    return path.join(appDirDocPath, name);
  }

  /// Given an asset name, returns an appropriate path to place the asset
  /// within this dictionary's resource path.
  String getResourcePath({
    required String appDirDocPath,
    required String resourceBasename,
  }) {
    return path.join(
      getBasePath(appDirDocPath: appDirDocPath),
      resourceBasename,
    );
  }

  @override
  bool operator ==(Object other) => other is Dictionary && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

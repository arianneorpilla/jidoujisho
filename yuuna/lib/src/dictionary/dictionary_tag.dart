import 'dart:ui';

import 'package:yuuna/dictionary.dart';
import 'package:isar/isar.dart';

part 'dictionary_tag.g.dart';

/// A database entity for tags, heavily based on the Yomichan format.
@Collection()
class DictionaryTag {
  /// Initiates a tag with given parameters.
  DictionaryTag({
    required this.dictionaryId,
    required this.name,
    required this.category,
    required this.sortingOrder,
    required this.notes,
    required this.popularity,
  });

  /// Makes a tag for a dictionary.
  factory DictionaryTag.dictionary(Dictionary dictionary) {
    return DictionaryTag(
      dictionaryId: dictionary.id,
      name: dictionary.name,
      notes: '',
      sortingOrder: -100000000000,
      category: 'frequent',
      popularity: 0,
    );
  }

  /// Dictionary ID for hashing this tag.
  final int dictionaryId;

  /// Function to generate a lookup ID for heading by its unique string key.
  static int hash({required int dictionaryId, required String name}) {
    return fastHash('$dictionaryId/$name');
  }

  /// Identifier for database purposes.
  Id get isarId => hash(dictionaryId: dictionaryId, name: name);

  /// Display name for the tag.
  @Index()
  final String name;

  /// Category for the tag.
  final String category;

  /// Sorting order for the tag.
  final int sortingOrder;

  /// Notes for this tag.
  final String notes;

  /// Score used to determine popularity.
  /// Negative values are more rare and positive values are more frequent.
  /// This score is also used to sort search results.
  final double popularity;

  /// Get the color for this tag based on its category.
  @ignore
  Color get color {
    switch (category) {
      case 'name':
        return const Color(0xffd46a6a);
      case 'expression':
        return const Color(0xffff4d4d);
      case 'popular':
        return const Color(0xff550000);
      case 'partOfSpeech':
        return const Color(0xff565656);
      case 'archaism':
        return const Color(0xFF616161);
      case 'dictionary':
        return const Color(0xffa15151);
      case 'frequency':
        return const Color(0xffd46a6a);
      case 'frequent':
        return const Color(0xff801515);
    }

    return const Color(0xFF616161);
  }

  /// A value is yielded from a single key.
  final IsarLink<Dictionary> dictionary = IsarLink<Dictionary>();

  @override
  bool operator ==(Object other) =>
      other is DictionaryTag && isarId == other.isarId;

  @override
  int get hashCode => isarId.hashCode;
}

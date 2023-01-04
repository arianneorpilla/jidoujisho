import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'dictionary_tag.g.dart';

/// A helper class for tags that are present in Yomichan imported dictionary
/// entries.
@Collection()
class DictionaryTag {
  /// Define a tag with given parameters.
  DictionaryTag({
    required this.dictionaryName,
    required this.name,
    required this.category,
    required this.sortingOrder,
    required this.notes,
    required this.popularity,
    this.id,
  });

  /// The dictionary from which this entry was imported from. This is used for
  /// database query purposes.
  @Index()
  final String dictionaryName;

  /// Tag name.
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
  final double? popularity;

  /// The length of word is used as an index.
  @Index(unique: true)
  String get uniqueKey => '$dictionaryName/$name';

  /// A unique identifier for the purposes of database storage.
  Id? id;

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
        return Colors.grey.shade700;
      case 'dictionary':
        return const Color(0xffa15151);
      case 'frequency':
        return const Color(0xffd46a6a);
      case 'frequent':
        return const Color(0xff801515);
    }

    return Colors.grey.shade700;
  }
}

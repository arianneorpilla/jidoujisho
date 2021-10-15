import 'package:objectbox/objectbox.dart';

@Entity()
class DictionaryEntry {
  DictionaryEntry({
    this.id = 0,
    @Index() required this.headword,
    @Index() required this.reading,
    required this.meaning,
    required this.extra,
    required this.popularity,
  });

  /// ObjectBox identifier parameter.
  int id;

  /// The headword of the dictionary entry. For example, 見る.
  late String headword;

  /// The reading of the dictionary entry. For example, みる.
  late String reading;

  /// The meaning of the dictionary entry. For example, "to see".
  late String meaning;

  /// A [Map<String, String>] that has been serialised for database storage.
  /// This parameter is used to neatly reserve extra features for custom
  /// dictionary formats.
  late String extra;

  /// The popularity index of the dictionary entry for sorting purposes.
  late double popularity;
}

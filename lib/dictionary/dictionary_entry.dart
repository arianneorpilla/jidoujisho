import 'dart:convert';

import 'package:objectbox/objectbox.dart';

@Entity()
class DictionaryEntry {
  DictionaryEntry({
    this.id = 0,
    @Index() required this.word,
    @Index() required this.reading,
    required this.meaning,
    required this.extra,
    required this.popularity,
  });

  /// ObjectBox identifier parameter.
  int id;

  /// The word of the dictionary entry. For example, 見る.
  late String word;

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

  /// Get a serialised representation of the dictionary result for history
  /// and persistence purposes.
  String toJson() {
    Map<String, dynamic> map = {
      "word": word,
      "reading": reading,
      "meaning": meaning,
      "extra": extra,
      "popularity": popularity,
    };

    return jsonEncode(map);
  }

  /// Deserialise JSON and get a result from history as a result item.
  factory DictionaryEntry.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);

    return DictionaryEntry(
      word: map["word"],
      reading: map["reading"],
      meaning: map["meaning"],
      extra: map["extra"],
      popularity: map["popularity"],
    );
  }
}

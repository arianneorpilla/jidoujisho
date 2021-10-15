import 'dart:convert';

class DictionaryResultItem {
  DictionaryResultItem({
    required this.headword,
    required this.reading,
    required this.meaning,
    required this.extra,
  });

  /// The headword of the dictionary entry. For example, 見る.
  late String headword;

  /// The reading of the dictionary entry. For example, みる.
  late String reading;

  /// The meaning of the dictionary entry. For example, "to see".
  late String meaning;

  /// A map of parameters that will be used to construct dictionary result
  /// widgets.
  late Map<String, String> extra;

  /// Get a serialised representation of the dictionary result for history
  /// and persistence purposes.
  String toJson() {
    Map<String, String> map = {
      "headword": headword,
      "reading": reading,
      "meaning": meaning,
      "extra": jsonEncode(extra),
    };

    return jsonEncode(map);
  }

  /// Deserialise JSON and get a result from history as a result item.
  factory DictionaryResultItem.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);

    return DictionaryResultItem(
      headword: map["headword"],
      reading: map["reading"],
      meaning: map["meaning"],
      extra: jsonDecode(map["extra"]),
    );
  }
}

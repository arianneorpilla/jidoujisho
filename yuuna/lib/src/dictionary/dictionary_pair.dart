/// An entity used to separate dictionary entries.
class DictionaryPair {
  /// Make a word-reading pair for sorting purposes.
  const DictionaryPair({
    required this.word,
    required this.reading,
  });

  /// The word represented by this dictionary entry.
  final String word;

  /// The pronunciation of the word represented by this dictionary entry.
  final String reading;

  @override
  operator ==(Object other) =>
      other is DictionaryPair && other.word == word && other.reading == reading;

  @override
  int get hashCode => word.hashCode * reading.hashCode;

  @override
  String toString() => 'DictionaryPair($word, $reading)';
}

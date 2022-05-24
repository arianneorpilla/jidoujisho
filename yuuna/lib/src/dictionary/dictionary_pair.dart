/// An entity used to separate dictionary entries.
class DictionaryPair {
  /// Make a word-reading pair for sorting purposes.
  const DictionaryPair({
    required this.term,
    required this.reading,
  });

  /// The word or phrase represented by this dictionary entry.
  final String term;

  /// The pronunciation of the word represented by this dictionary entry.
  final String reading;

  @override
  operator ==(Object other) =>
      other is DictionaryPair && other.term == term && other.reading == reading;

  @override
  int get hashCode => term.hashCode * reading.hashCode;

  @override
  String toString() => 'DictionaryPair($term, $reading)';
}

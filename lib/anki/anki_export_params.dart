class AnkiExportParams {
  AnkiExportParams({
    required this.context,
    required this.headword,
    required this.pronunciation,
    required this.definition,
    required this.extra,
    required this.imageUri,
    required this.audioUri,
  });

  /// The written context of the sourced headword, i.e. an example sentence or
  /// scene dialogue.
  String context;

  /// The headword pertaining to the pronunciation and definition, the word
  /// to be memorised from the card.
  String headword;

  /// Pronunciation or reading. May be overriden with some characteristics such
  /// as pitch accent diagrams, by particular languages.
  String pronunciation;

  /// Definition or meaning. May be overriden with some characteristics such
  /// as having definition tags.
  String definition;

  /// Extra parameters from which a custom user script can be written to parse
  /// from the Anki end. A JSON map serialised as a single String to be
  /// exported. Intended for future proofing and developer customisation.
  String extra;

  /// A [Uri] to an image file to be copied to the Anki media collection.
  Uri imageUri;

  /// A [Uri] to an audio file to be copied to the Anki media collection.
  Uri audioUri;
}

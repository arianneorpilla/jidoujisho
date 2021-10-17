import 'dart:io';

class AnkiExportParams {
  AnkiExportParams({
    this.sentence = "",
    this.word = "",
    this.reading = "",
    this.meaning = "",
    this.extra = "",
    this.imageFile,
    this.audioFile,
  });

  /// The written context of the sourced word, i.e. an example sentence or
  /// scene dialogue.
  String sentence;

  /// The word pertaining to the reading and meaning, the word
  /// to be memorised from the card.
  String word;

  /// reading or reading. May be overriden with some characteristics such
  /// as pitch accent diagrams, by particular languages.
  String reading;

  /// Definition or meaning. May be overriden with some characteristics such
  /// as having meaning tags.
  String meaning;

  /// Extra parameters from which a custom user script can be written to parse
  /// from the Anki end. A JSON map serialised as a single String to be
  /// exported. Intended for future proofing and developer customisation.
  String extra;

  /// A [Uri] to an image file to be copied to the Anki media collection.
  File? imageFile;

  /// A [Uri] to an audio file to be copied to the Anki media collection.
  File? audioFile;
}

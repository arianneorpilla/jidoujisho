import 'dart:io';

import 'package:network_to_file_image/network_to_file_image.dart';

class AnkiExportParams {
  AnkiExportParams({
    this.sentence = "",
    this.word = "",
    this.reading = "",
    this.meaning = "",
    this.extra = "",
    this.imageFiles = const [],
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

  /// List of images to choose from. The first image is what is shown in the
  /// Creator. If there is no [imageFile], this field should be empty.
  List<NetworkToFileImage> imageFiles;

  /// A [Uri] to an image file to be copied to the Anki media collection.
  File? imageFile;

  /// A [Uri] to an audio file to be copied to the Anki media collection.
  File? audioFile;

  @override
  operator ==(Object other) =>
      other is AnkiExportParams &&
      other.sentence == sentence &&
      other.word == word &&
      other.reading == reading &&
      other.meaning == meaning &&
      other.extra == extra &&
      other.imageFiles == imageFiles &&
      other.imageFile == imageFile &&
      other.audioFile == audioFile;

  @override
  int get hashCode => {
        "sentence": sentence,
        "word": word,
        "reading": reading,
        "meaning": meaning,
        "extra": extra,
        "imageFiles": imageFiles.hashCode,
        "imageFile": imageFile.hashCode,
        "audioFile": audioFile.hashCode,
      }.hashCode;

  bool isEmpty() {
    return this == AnkiExportParams();
  }
}

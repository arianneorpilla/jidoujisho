import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';

class AnkiExportParams with ChangeNotifier {
  AnkiExportParams({
    this.sentence = '',
    this.word = '',
    this.reading = '',
    this.meaning = '',
    this.extra = '',
    this.imageSearch = '',
    this.audioSearch = '',
    this.imageFiles = const [],
    this.imageFile,
    this.audioFile,
    this.context = '',
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

  /// The content of the image search controller for the Creator.
  String imageSearch;

  /// The content of the audio search controller for the Creator.
  String audioSearch;

  /// A serialised [MediaHistoryItem] for app link return to context.
  String context;

  @override
  operator ==(Object other) =>
      other is AnkiExportParams &&
      other.sentence == sentence &&
      other.word == word &&
      other.reading == reading &&
      other.meaning == meaning &&
      other.extra == extra &&
      other.imageFiles.isEmpty &&
      other.imageFile == imageFile &&
      other.audioFile == audioFile;

  @override
  int get hashCode => {
        'sentence': sentence,
        'word': word,
        'reading': reading,
        'meaning': meaning,
        'extra': extra,
        'imageFiles': imageFiles.hashCode,
        'imageFile': imageFile.hashCode,
        'audioFile': audioFile.hashCode,
      }.hashCode;

  bool isEmpty() {
    return this == AnkiExportParams();
  }

  void setSentence(String newSentence) {
    sentence = newSentence;
    notifyListeners();
  }

  void setWord(String newWord) {
    word = newWord;
    notifyListeners();
  }

  void setReading(String newReading) {
    reading = newReading;
    notifyListeners();
  }

  void setMeaning(String newMeaning) {
    meaning = newMeaning;
    notifyListeners();
  }

  void setExtra(String newExtra) {
    extra = newExtra;
    notifyListeners();
  }

  void setImageSearch(String newImageSearch) {
    imageSearch = newImageSearch;
    notifyListeners();
  }

  void setAudioSearch(String newAudioSearch) {
    audioSearch = newAudioSearch;
    notifyListeners();
  }

  void setImageFiles(List<NetworkToFileImage> newImageFiles) {
    imageFiles = newImageFiles;
    notifyListeners();
  }

  void setAudioFile(File? newAudioFile) {
    audioFile = newAudioFile;
    notifyListeners();
  }

  void setImageFile(File? newImageFile) {
    imageFile = newImageFile;
    notifyListeners();
  }

  void setAllValues(AnkiExportParams params) {
    sentence = params.sentence;
    word = params.word;
    reading = params.reading;
    meaning = params.meaning;
    extra = params.extra;
    imageSearch = params.imageSearch;
    audioSearch = params.audioSearch;
    imageFiles = params.imageFiles;
    imageFile = params.imageFile;
    audioFile = params.audioFile;
    notifyListeners();
  }
}

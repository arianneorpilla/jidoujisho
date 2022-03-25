import 'dart:io';

import 'package:yuuna/media.dart';

/// Represents an entity exported from the creator model that can be used to
/// interface with export options.
class ExportDetails {
  /// Initialise an immutable context export with the final parameters.
  const ExportDetails({
    this.sentence,
    this.word,
    this.reading,
    this.meaning,
    this.extra,
    this.image,
    this.audio,
    this.context,
  });

  /// The written context of the sourced word, i.e. an example sentence or
  /// scene dialogue.
  final String? sentence;

  /// The word pertaining to the reading and meaning, the word
  /// to be memorised from the card.
  final String? word;

  /// Pronunciation or reading. May be overriden with some characteristics such
  /// as pitch accent diagrams, by particular languages.
  final String? reading;

  /// Definition or meaning. May be overriden with some characteristics such
  /// as having meaning tags.
  final String? meaning;

  /// Extra parameters from which a custom user script can be written to parse
  /// from the Anki end. A JSON map serialised as a single String to be
  /// exported. Intended for future proofing and developer customisation.
  final String? extra;

  /// A serialised [MediaItem] to allow return to context.
  final String? context;

  /// The image file to export.
  final File? image;

  /// The audio file to export.
  final File? audio;
}

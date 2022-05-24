import 'dart:io';

import 'package:yuuna/media.dart';
import 'package:equatable/equatable.dart';

/// Represents an entity exported from the creator model that can be used to
/// interface with export options.
class ExportDetails extends Equatable {
  /// Initialise an immutable context export with the final parameters.
  const ExportDetails({
    this.sentence = '',
    this.term = '',
    this.reading = '',
    this.meaning = '',
    this.extra = '',
    this.context = '',
    this.image,
    this.audio,
  });

  /// The written context of the sourced word, i.e. an example sentence or
  /// scene dialogue.
  final String? sentence;

  /// The word or phrase pertaining to the reading and meaning, the term
  /// to be memorised from the card.
  final String? term;

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

  /// Check if this export details is equivalent to the empty export details.
  bool get isExportable {
    return this != const ExportDetails();
  }

  @override
  List<Object?> get props => [
        sentence,
        term,
        reading,
        meaning,
        extra,
        context,
        image?.path,
        audio?.path
      ];

  @override
  bool? get stringify => true;
}

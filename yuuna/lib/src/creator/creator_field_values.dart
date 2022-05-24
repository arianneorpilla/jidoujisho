import 'dart:io';

import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yuuna/creator.dart';

/// A collection of values that can be used to mutate the current context of
/// the creator.
@JsonSerializable()
@Collection()
class CreatorFieldValues {
  /// Initialise an immutable collection of the final parameters.
  CreatorFieldValues({
    this.textValues = const {},
  });

  /// Creates a deep copy of this context but with the given fields replaced
  /// with the new values.
  CreatorFieldValues copyWith({
    Map<FieldNua, String>? textValues,
  }) {
    Map<FieldNua, String>? newTextValues;
    if (textValues != null) {
      newTextValues = {};
      newTextValues.addAll(textValues);
    }

    return CreatorFieldValues(textValues: newTextValues ?? this.textValues);
  }

  /// A map of text values to override for certain supplied key fields.
  final Map<FieldNua, String> textValues;

  /// List of images to export to Anki.
  Map<FieldNua, File> get imagesToExport => throw UnimplementedError();

  /// List of audio to export to Anki.
  Map<FieldNua, File> get audioToExport => throw UnimplementedError();

  /// Whether or not to allow the export button to be pressed.
  bool get isExportable {
    return textValues.isNotEmpty;
  }
}

import 'dart:io';

import 'package:yuuna/creator.dart';
import 'package:yuuna/src/models/app_model.dart';

/// A collection of values that can be used to mutate the current context of
/// the creator.
class CreatorFieldValues {
  /// Initialise an immutable collection of the final parameters.
  CreatorFieldValues({
    this.textValues = const {},
  });

  // factory CreatorFieldValues.fromDictionary({
  //   required String term,
  //   required String reading,
  //   required List<DictionaryEntry> entries,
  //   required List<DictionaryMetaEntry> metaEntries,
  // }) {}

  /// Creates a deep copy of this context but with the given fields replaced
  /// with the new values.
  CreatorFieldValues copyWith({
    Map<Field, String>? textValues,
  }) {
    Map<Field, String>? newTextValues;
    if (textValues != null) {
      newTextValues = {};
      newTextValues.addAll(textValues);
    }

    return CreatorFieldValues(textValues: newTextValues ?? this.textValues);
  }

  /// A map of text values to override for certain supplied key fields.
  final Map<Field, String> textValues;

  /// List of images to export to Anki.
  Map<Field, File> get imagesToExport {
    Map<Field, File> exportFiles = {};

    for (Field field in globalFields) {
      if (field is ImageExportField) {
        if (field.exportFile?.file != null) {
          exportFiles[field] = field.exportFile!.file!;
        }
      }
    }

    return exportFiles;
  }

  /// List of audio to export to Anki.
  Map<Field, File> get audioToExport {
    Map<Field, File> exportFiles = {};

    for (Field field in globalFields) {
      if (field is AudioExportField) {
        print(field.exportFile);
        if (field.exportFile != null) {
          exportFiles[field] = field.exportFile!;
        }
      }
    }

    return exportFiles;
  }

  /// Whether or not to allow the export button to be pressed.
  bool get isExportable {
    for (String value in textValues.values) {
      if (value.isNotEmpty) {
        return true;
      }
    }

    return false;
  }
}

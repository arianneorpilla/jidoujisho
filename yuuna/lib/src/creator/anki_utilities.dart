import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import 'package:path/path.dart' as path;
import 'package:yuuna/creator.dart';
import 'package:yuuna/utils.dart';

/// A general collection of static functions related to communicating with Anki
/// for card export and getting information on decks and models.
class AnkiUtilities {
  /// Used to communicate back and forth with Dart and native code.
  static const MethodChannel methodChannel =
      MethodChannel('app.lrorpilla.jidoujisho/anki');

  /// Get the file to be written to for image export.
  static Future<File> getImageExportFile() async {
    Directory jidoujishoDirectory =
        await JidoujishoCommon.getJidoujishoDirectory();

    String imagePath = path.join(jidoujishoDirectory.path, 'exportImage.jpg');
    return File(imagePath);
  }

  /// Get the file to be written to for audio export.
  static Future<File> getAudioExportFile() async {
    Directory jidoujishoDirectory =
        await JidoujishoCommon.getJidoujishoDirectory();

    String audioPath = path.join(jidoujishoDirectory.path, 'exportAudio.mp3');
    return File(audioPath);
  }

  /// Get a list of decks from the Anki background service that can be used
  /// for export.
  static Future<List<String>> getDecks() async {
    List<String> decks =
        List<String>.from(await methodChannel.invokeMethod('getDecks'));

    decks.sort((a, b) => a.compareTo(b));
    return decks;
  }

  /// Get a list of models from the Anki background service that can be used
  /// for export.
  static Future<List<String>> getModels() async {
    List<String> models =
        List<String>.from(await methodChannel.invokeMethod('getModels'));

    models.sort((a, b) => a.compareTo(b));
    return models;
  }

  /// Get a list of field names for a given [model] in Anki.
  static Future<List<String>> getModelFields(String model) async {
    List<String> fields =
        List<String>.from(await methodChannel.invokeMethod('getModels', model));

    return fields;
  }

  /// Add a note with certain [details] and a [mapping] of fields to a model
  /// to a given [deck].
  static Future<void> addNote({
    required ExportDetails details,
    required AnkiMapping mapping,
    required String deck,
  }) async {
    String timestamp =
        intl.DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
    String preferredName = 'jidoujisho-$timestamp';

    String? imageFileName;
    String? audioFileName;

    if (details.image != null) {
      imageFileName = await addFileToMedia(
        exportFile: details.image!,
        preferredName: preferredName,
        mimeType: 'image',
      );
    }

    if (details.audio != null) {
      audioFileName = await addFileToMedia(
        exportFile: details.audio!,
        preferredName: preferredName,
        mimeType: 'audio',
      );
    }

    String model = mapping.model;
    List<String> fields = getCardFields(
      details: details,
      mapping: mapping,
      imageFileName: imageFileName,
      audioFileName: audioFileName,
    );

    try {
      return await methodChannel.invokeMethod(
        'addNote',
        <String, dynamic>{
          'deck': deck,
          'model': model,
          'fields': fields,
        },
      );
    } on PlatformException {
      debugPrint('Failed to add note for [$preferredName]');
      rethrow;
    } finally {
      debugPrint('Added note for [$preferredName] to Anki media');
    }
  }

  /// Add a file to Anki media. [mimeType] can be 'image' or 'audio'.
  /// [preferredName] is used as a prefix to the file when exported to the
  /// media store. Returns the name of the file once successfully added to
  /// Anki media.
  static Future<String> addFileToMedia({
    required File exportFile,
    required String preferredName,
    required String mimeType,
  }) async {
    late File destinationFile;
    if (mimeType == 'image') {
      destinationFile = await getImageExportFile();
    } else if (mimeType == 'audio') {
      destinationFile = await getAudioExportFile();
    } else {
      throw Exception('Invalid mime type, must be image or audio');
    }

    String destinationPath = destinationFile.path;
    exportFile.copySync(destinationPath);

    String uriPath = 'file:///${destinationFile.uri}';

    try {
      return await methodChannel.invokeMethod(
        'addFileToMedia',
        <String, String>{
          'uriPath': uriPath,
          'preferredName': preferredName,
          'mimeType': mimeType,
        },
      );
    } on PlatformException {
      debugPrint('Failed to add [$mimeType] to Anki media');
      rethrow;
    } finally {
      debugPrint('Added $mimeType for [$preferredName] to Anki media');
    }
  }

  /// Returns the list that will be passed to the Anki card creation API to
  /// fill a card's fields. The contents of the list will correspond to the
  /// order of the [mapping] provided, with each field in the list replaced
  /// with the corresponding [details] or in the case of the image and audio
  /// fields, the file names.
  static List<String> getCardFields({
    required ExportDetails details,
    required AnkiMapping mapping,
    required String? imageFileName,
    required String? audioFileName,
  }) {
    List<String> fields = mapping.fields.map<String>((field) {
      switch (field) {
        case Field.sentence:
          return details.sentence ?? '';
        case Field.word:
          return details.word ?? '';
        case Field.reading:
          return details.reading ?? '';
        case Field.meaning:
          return details.meaning ?? '';
        case Field.extra:
          return details.extra ?? '';
        case Field.context:
          return details.context ?? '';
        case Field.image:
          return imageFileName ?? '';
        case Field.audio:
          return audioFileName ?? '';
      }
    }).toList();

    return fields;
  }
}

import 'dart:async';
import 'dart:io';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:chisa/util/export_paths.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerEnhancement extends AnkiExportEnhancement {
  ImagePickerEnhancement({
    required AppModel appModel,
  }) : super(
          appModel: appModel,
          enhancementName: "Image Picker",
          enhancementDescription:
              "Upload your own image to use in the Creator.",
          enhancementIcon: Icons.file_upload,
          enhancementField: AnkiExportField.image,
        );

  @override
  Future<AnkiExportParams> enhanceParams({
    required BuildContext context,
    required AppModel appModel,
    required AnkiExportParams params,
    required bool autoMode,
    required CreatorPageState state,
  }) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return params;
    }

    String imagePath = getPreviewImagePath();
    File imageFile = File(imagePath);
    if (imageFile.existsSync()) {
      imageFile.deleteSync();
    }

    await pickedFile.saveTo(imagePath);

    String temporaryDirectoryPath = (await getTemporaryDirectory()).path;

    String temporaryFileName =
        "jidoujisho-" + DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
    File croppedImageFile = File('$temporaryDirectoryPath/$temporaryFileName');

    croppedImageFile.createSync();
    croppedImageFile.writeAsBytesSync(await pickedFile.readAsBytes());
    params.imageFile = croppedImageFile;
    params.imageFiles = [NetworkToFileImage(file: File(getPreviewImagePath()))];

    state.notifyImageNotSearching();

    return params;
  }
}

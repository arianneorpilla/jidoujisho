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
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CameraImageEnhancement extends AnkiExportEnhancement {
  CameraImageEnhancement({
    required AppModel appModel,
  }) : super(
          appModel: appModel,
          enhancementName: "Camera",
          enhancementDescription:
              "Upload your own image to use in the Creator.",
          enhancementIcon: Icons.add_a_photo,
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
    ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.camera);

    if (file == null) {
      return params;
    }

    Directory appDirDoc = await getApplicationDocumentsDirectory();
    int mills = DateTime.now().millisecondsSinceEpoch;
    String ext = p.extension(file.path);
    String cameraImagePath = "${appDirDoc.path}/camera/$mills$ext";
    File tempFile = File(cameraImagePath);

    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }

    imageCache?.clear();

    Directory("${appDirDoc.path}/camera/").createSync();
    await file.saveTo(cameraImagePath);
    File(cameraImagePath).copySync(getPreviewImagePath());

    params.imageFile = File(cameraImagePath);
    params.imageFiles = [NetworkToFileImage(file: File(getPreviewImagePath()))];

    state.notifyImageNotSearching();

    return params;
  }
}

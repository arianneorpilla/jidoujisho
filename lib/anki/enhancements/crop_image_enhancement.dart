import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:chisa/util/export_paths.dart';
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';

class CropImageEnhancement extends AnkiExportEnhancement {
  CropImageEnhancement({
    required AppModel appModel,
  }) : super(
          appModel: appModel,
          enhancementName: "Crop Image",
          enhancementDescription: "Crop the current selected image.",
          enhancementIcon: Icons.crop,
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
    if (params.imageFile == null) {
      return params;
    }

    CropController cropController = CropController();

    if (await showCropDialog(
        context, cropController, FileImage(params.imageFile!), state)) {
      ui.Image croppedImage = await cropController.croppedBitmap();
      ByteData? data =
          await croppedImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List bytes = data!.buffer.asUint8List();

      String temporaryDirectoryPath = (await getTemporaryDirectory()).path;

      String temporaryFileName =
          "jidoujisho-" + DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
      File croppedImageFile =
          File('$temporaryDirectoryPath/$temporaryFileName');

      croppedImageFile.createSync();
      croppedImageFile.writeAsBytesSync(bytes);
      params.imageFile = croppedImageFile;
      params.imageFiles = [
        NetworkToFileImage(file: File(getPreviewImagePath()))
      ];
    }

    return params;
  }

  Future<bool> showCropDialog(
    BuildContext context,
    CropController cropController,
    ImageProvider image,
    CreatorPageState state,
  ) async {
    ScrollController scrollController = ScrollController();

    return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 10),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              content: RawScrollbar(
                thumbColor: (appModel.getIsDarkMode())
                    ? Colors.grey[700]
                    : Colors.grey[400],
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Center(
                    child: CropImage(
                      controller: cropController,
                      image: Image(image: image),
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(appModel.translate("dialog_set")),
                  onPressed: () async {
                    state.notifyImageNotSearching();
                    return Navigator.pop(context, true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

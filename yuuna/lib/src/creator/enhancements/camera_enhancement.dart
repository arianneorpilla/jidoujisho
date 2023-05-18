import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';

/// An enhancement that can be used to take a picture to set a new image.
class CameraEnhancement extends ImageEnhancement {
  /// Initialise this enhancement with the hardset parameters.
  CameraEnhancement()
      : super(
          uniqueKey: key,
          label: 'Camera',
          description: 'Take a new photo to use as the new image.',
          icon: Icons.camera_alt,
          field: ImageField.instance,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'camera';

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    ImageExportField imageField = field as ImageExportField;
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile == null) {
      return;
    }

    Directory appDirDoc = await getApplicationSupportDirectory();
    String cameraImagePath = '${appDirDoc.path}/camera';
    Directory cameraImageDir = Directory(cameraImagePath);
    if (cameraImageDir.existsSync()) {
      cameraImageDir.deleteSync(recursive: true);
    }
    cameraImageDir.createSync(recursive: true);

    String timestamp = DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
    Directory imageDir = Directory('$cameraImagePath/$timestamp');
    String imagePath = '${imageDir.path}/image';
    imageDir.createSync(recursive: true);

    await pickedFile.saveTo(imagePath);
    File pickedImage = File(imagePath);

    await imageField.setImages(
      cause: cause,
      appModel: appModel,
      creatorModel: creatorModel,
      newAutoCannotOverride: false,
      generateImages: () async {
        List<NetworkToFileImage> images = [
          NetworkToFileImage(file: pickedImage),
        ];

        return images;
      },
    );
  }

  @override
  Future<List<NetworkToFileImage>> fetchImages({
    required AppModel appModel,
    String? searchTerm,
  }) async {
    throw UnimplementedError();
  }
}

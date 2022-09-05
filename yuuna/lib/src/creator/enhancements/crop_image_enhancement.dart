import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';

/// An enhancement that can be used to crop the current image.
class CropImageEnhancement extends ImageEnhancement {
  /// Initialise this enhancement with the hardset parameters.
  CropImageEnhancement()
      : super(
          uniqueKey: key,
          label: 'Crop Image',
          description: 'Crop the current selected image.',
          icon: Icons.crop,
          field: ImageField.instance,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'crop_image';

  /// Holds the cropped image.
  File? _croppedImage;

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    _croppedImage = null;

    ImageExportField imageField = field as ImageExportField;
    String? searchTerm;

    File? imageFile = imageField.exportFile?.file;
    if (imageFile == null) {
      return;
    }

    _croppedImage = await showDialog<File?>(
      context: context,
      builder: (context) => CropImageDialogPage(
        imageFile: imageFile,
      ),
    );

    await imageField.setImages(
      cause: cause,
      appModel: appModel,
      creatorModel: creatorModel,
      newAutoCannotOverride: false,
      searchTerm: searchTerm,
      generateImages: () async {
        return fetchImages(
          appModel: appModel,
          context: context,
        );
      },
    );
  }

  @override
  Future<List<NetworkToFileImage>> fetchImages({
    required AppModel appModel,
    required BuildContext context,
    String? searchTerm,
  }) async {
    List<NetworkToFileImage> images = [
      NetworkToFileImage(file: _croppedImage),
    ];

    return images;
  }
}

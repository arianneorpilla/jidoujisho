import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';

/// The content of the dialog when using the crop image enhancement.
class CropImageDialogPage extends BasePage {
  /// Create an instance of this page.
  const CropImageDialogPage({
    required this.imageFile,
    super.key,
  });

  /// Initial file.
  final File imageFile;

  @override
  BasePageState createState() => _CropImageDialogPageState();
}

class _CropImageDialogPageState extends BasePageState<CropImageDialogPage> {
  String get dialogCropLabel => appModel.translate('dialog_crop');
  String get dialogCancelLabel => appModel.translate('dialog_cancel');

  final CropController _controller = CropController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: Spacing.of(context).insets.all.normal,
      actionsPadding: Spacing.of(context).insets.horizontal.normal,
      content: buildContent(),
      actions: actions,
    );
  }

  List<Widget> get actions => [
        buildCancelButton(),
        buildCropButton(),
      ];

  Widget buildContent() {
    return Center(
      child: CropImage(
        controller: _controller,
        image: Image(image: FileImage(widget.imageFile)),
      ),
    );
  }

  Widget buildCropButton() {
    return TextButton(
      child: Text(
        dialogCropLabel,
      ),
      onPressed: executeCrop,
    );
  }

  Widget buildCancelButton() {
    return TextButton(
      child: Text(
        dialogCancelLabel,
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  void executeCrop() async {
    Directory appDirDoc = await getApplicationSupportDirectory();
    String cropImagePath = '${appDirDoc.path}/crop';
    Directory cropImageDir = Directory(cropImagePath);
    if (cropImageDir.existsSync()) {
      cropImageDir.deleteSync(recursive: true);
    }
    cropImageDir.createSync(recursive: true);

    String timestamp = DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
    Directory imageDir = Directory('$cropImagePath/$timestamp');
    ui.Image croppedImage = await _controller.croppedBitmap();
    ByteData? data =
        await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List bytes = data!.buffer.asUint8List();

    String imagePath = '${imageDir.path}/cropped';
    File imageFile = File(imagePath);
    imageFile.createSync(recursive: true);
    imageFile.writeAsBytesSync(bytes);

    Navigator.pop(context, imageFile);
  }
}

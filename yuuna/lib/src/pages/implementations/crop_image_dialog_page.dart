import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The content of the dialog when using the crop image enhancement.
class CropImageDialogPage extends BasePage {
  /// Create an instance of this page.
  const CropImageDialogPage({
    required this.imageFile,
    required this.onCrop,
    super.key,
  });

  /// Initial file.
  final File imageFile;

  /// On crop action.
  final Function(File) onCrop;

  @override
  BasePageState createState() => _CropImageDialogPageState();
}

class _CropImageDialogPageState extends BasePageState<CropImageDialogPage> {
  final CropController _controller = CropController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: Spacing.of(context).insets.all.normal,
      actionsPadding: Spacing.of(context).insets.horizontal.normal,
      content: SizedBox(
        width: double.maxFinite,
        child: buildContent(),
      ),
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
          minimumImageSize: 25,
          gridColor: Theme.of(context).unselectedWidgetColor,
          controller: _controller,
          image: Image(image: FileImage(widget.imageFile))),
    );
  }

  Widget buildCropButton() {
    return TextButton(
      onPressed: executeCrop,
      child: Text(t.dialog_crop),
    );
  }

  Widget buildCancelButton() {
    return TextButton(
      child: Text(t.dialog_cancel),
      onPressed: () => Navigator.pop(context),
    );
  }

  void executeCrop() async {
    final navigator = Navigator.of(context);
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

    widget.onCrop(imageFile);
    navigator.pop();
  }
}

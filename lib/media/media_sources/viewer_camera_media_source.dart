import 'dart:io';

import 'package:camera/camera.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'dart:async';

import 'package:chisa/media/media_sources/viewer_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/viewer_page.dart';
import 'package:chisa/util/media_source_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

class ViewerCameraMediaSource extends ViewerMediaSource {
  ViewerCameraMediaSource()
      : super(
          sourceName: "Camera",
          icon: Icons.camera,
        );

  List<CameraDescription>? cameras;
  String cameraImagePath = "";

  @override
  Future<List<ImageProvider<Object>>> getChapterImages(
    MediaHistoryItem item,
    String chapter,
  ) async {
    File tempFile = File(cameraImagePath);

    return Future.value([FileImage(tempFile)]);
  }

  Directory getItemDirectory(MediaHistoryItem item) {
    return Directory(item.key);
  }

  @override
  Future<List<String>> getChapters(MediaHistoryItem item) async {
    return Future.value(["Camera Roll"]);
  }

  @override
  String getHistoryCaption(MediaHistoryItem item) {
    throw UnsupportedError("Invalid for camera source");
  }

  @override
  String getHistorySubcaption(MediaHistoryItem item) {
    throw UnsupportedError("Invalid for camera source");
  }

  @override
  ImageProvider<Object> getHistoryThumbnail(MediaHistoryItem item) {
    throw UnsupportedError("Invalid for camera source");
  }

  @override
  FutureOr<List<MediaHistoryItem>?> getSearchMediaHistoryItems({
    required BuildContext context,
    required String searchTerm,
    required int pageKey,
  }) {
    return null;
  }

  Future<void> showCameraScreen(
    BuildContext context,
    ImageSource source, {
    bool pushFillerScreen = false,
  }) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    if (pushFillerScreen) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => Container(color: Colors.black),
        ),
      );
    }

    ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: source);

    Directory appDirDoc = await getApplicationDocumentsDirectory();
    int mills = DateTime.now().millisecondsSinceEpoch;
    if (file != null) {
      String ext = p.extension(file.path);
      cameraImagePath = "${appDirDoc.path}/camera/$mills$ext";
      File tempFile = File(cameraImagePath);

      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }

      imageCache?.clear();

      Directory("${appDirDoc.path}/camera/").createSync();
      await file.saveTo(cameraImagePath);

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      await launchMediaPage(
        context,
        ViewerLaunchParams(
          appModel: appModel,
          mediaSource: this,
          chapters: ["Camera Roll"],
          chapterName: "Camera Roll",
          canOpenHistory: false,
          hideSlider: true,
          pushReplacement: true,
          mediaHistoryItem: MediaHistoryItem(
            key: cameraImagePath,
            sourceName: sourceName,
            currentProgress: 1,
            completeProgress: 1,
            extra: {"chapters": "Camera Roll"},
            mediaTypePrefs: mediaType.prefsDirectory(),
          ),
        ),
      );
    } else {
      if (pushFillerScreen) {
        Navigator.pop(context);
      }
    }
  }

  @override
  List<MediaSourceActionButton> getSearchBarActions(
    BuildContext context,
    Function() refreshCallback,
  ) {
    return [
      MediaSourceActionButton(
        context: context,
        source: this,
        refreshCallback: refreshCallback,
        showIfClosed: true,
        showIfOpened: false,
        icon: Icons.photo_rounded,
        onPressed: () async {
          await showCameraScreen(
            context,
            ImageSource.gallery,
            pushFillerScreen: true,
          );
          refreshCallback();
        },
      ),
      MediaSourceActionButton(
        context: context,
        source: this,
        refreshCallback: refreshCallback,
        showIfClosed: true,
        showIfOpened: false,
        icon: Icons.camera_alt,
        onPressed: () async {
          await showCameraScreen(
            context,
            ImageSource.camera,
            pushFillerScreen: true,
          );
          refreshCallback();
        },
      ),
    ];
  }

  @override
  Widget? buildSourceButton(BuildContext context, ViewerPageState page) {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    return Row(
      children: [
        IconButton(
          color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
          icon: const Icon(Icons.photo_rounded),
          onPressed: () async {
            await showCameraScreen(context, ImageSource.gallery);
          },
        ),
        IconButton(
          color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
          icon: const Icon(Icons.camera_alt),
          onPressed: () async {
            await showCameraScreen(context, ImageSource.camera);
          },
        ),
      ],
    );
  }

  @override
  Future<void> onSearchBarTap(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Container(color: Colors.black),
      ),
    );
    await showCameraScreen(
      context,
      ImageSource.camera,
      pushFillerScreen: true,
    );
  }

  @override
  bool get noSearchAction => true;

  @override
  bool get saveHistoryItem => false;
}

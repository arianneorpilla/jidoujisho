import 'dart:io';

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'dart:async';

import 'package:chisa/media/media_sources/viewer_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/util/media_source_action_button.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:collection/collection.dart';

class ViewerLocalMediaSource extends ViewerMediaSource {
  ViewerLocalMediaSource()
      : super(
          sourceName: "Local Source",
          icon: Icons.photo_album,
        );

  @override
  ViewerLaunchParams getLaunchParams(AppModel appModel, MediaHistoryItem item) {
    return ViewerLaunchParams(
      appModel: appModel,
      mediaSource: this,
      mediaHistoryItem: item,
      saveHistoryItem: true,
    );
  }

  @override
  Future<List<ImageProvider<Object>>> getChapterImages(
    MediaHistoryItem item,
    String chapter,
  ) {
    Directory directory =
        Directory(p.join(getItemDirectory(item).path, chapter));
    List<FileSystemEntity> entities = directory.listSync();

    List<String> extensions = mediaType.getAllowedExtensions();

    List<File> files = [];
    for (FileSystemEntity entity in entities) {
      if (entity is File) {
        if (extensions.contains(p.extension(entity.path))) {
          files.add(entity);
        }
      }
    }

    files.sort((a, b) => p
        .basenameWithoutExtension(a.path)
        .compareTo(p.basenameWithoutExtension(b.path)));

    List<ImageProvider<Object>> images = [];

    for (File file in files) {
      images.add(FileImage(file));
    }

    return Future.value(images);
  }

  Directory getItemDirectory(MediaHistoryItem item) {
    return Directory(item.key);
  }

  @override
  List<String> getChapters(MediaHistoryItem item) {
    Directory directory = getItemDirectory(item);
    List<FileSystemEntity> entities = directory.listSync();

    List<Directory> directories = [];
    for (FileSystemEntity entity in entities) {
      if (entity is Directory) {
        directories.add(entity);
      }
    }

    directories.sort((a, b) => p
        .basenameWithoutExtension(a.path)
        .compareTo(p.basenameWithoutExtension(b.path)));
    List<String> chapters = [];

    for (Directory directory in directories) {
      chapters.add(p.basenameWithoutExtension(directory.path));
    }

    return chapters;
  }

  @override
  String getHistoryCaption(MediaHistoryItem item) {
    return item.title;
  }

  @override
  String getHistorySubcaption(MediaHistoryItem item) {
    return item.author;
  }

  @override
  Future<ImageProvider<Object>> getHistoryThumbnail(
      MediaHistoryItem item) async {
    File? coverFile = getCoverFile(item.key);

    if (coverFile == null) {
      return MemoryImage(kTransparentImage);
    }

    return FileImage(coverFile);
  }

  File? getCoverFile(String directoryPath) {
    Directory directory = Directory(directoryPath);
    List<FileSystemEntity> entities = directory.listSync(recursive: true);

    List<String> extensions = mediaType.getAllowedExtensions();

    for (FileSystemEntity entity in entities) {
      if (entity is File) {
        if (p.basenameWithoutExtension(entity.path) == "cover") {
          if (extensions.contains(p.extension(entity.path))) {
            return entity;
          }
        }
      }
    }

    return null;
  }

  @override
  FutureOr<List<MediaHistoryItem>?> getSearchMediaHistoryItems({
    required BuildContext context,
    required String searchTerm,
    required int pageKey,
  }) {
    return null;
  }

  Future<void> showFilePicker(BuildContext context,
      {bool pushReplacement = false}) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    Iterable<String>? filePaths = await FilesystemPicker.open(
      title: "",
      pickText: appModel.translate("dialog_select"),
      cancelText: appModel.translate("dialog_return"),
      context: context,
      rootDirectories: await appModel.getMediaTypeDirectories(mediaType),
      fsType: FilesystemType.folder,
      multiSelect: false,
      folderIconColor: Colors.red,
      themeData: Theme.of(context),
    );

    if (filePaths == null || filePaths.isEmpty) {
      return;
    }

    String filePath = filePaths.first;

    appModel.setLastPickedDirectory(mediaType, Directory(p.dirname(filePath)));

    MediaHistoryItem? historyItem = mediaType
        .getMediaHistory(appModel)
        .getItems()
        .firstWhereOrNull((item) => item.key == filePath);

    MediaHistoryItem item;
    if (historyItem != null) {
      item = MediaHistoryItem.fromJson(historyItem.toJson());
    } else {
      item = MediaHistoryItem(
        key: filePath,
        title: p.basenameWithoutExtension(filePath),
        mediaTypePrefs: mediaType.prefsDirectory(),
        sourceName: sourceName,
        currentProgress: 0,
        completeProgress: 0,
        thumbnailPath: getCoverFile(filePath)?.path ?? "",
        extra: {},
      );
    }

    ViewerLaunchParams params = getLaunchParams(appModel, item);
    await launchMediaPage(
      context,
      params,
      pushReplacement: pushReplacement,
    );
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
        icon: Icons.perm_media,
        onPressed: () async {
          await showFilePicker(context);
          refreshCallback();
        },
      )
    ];
  }

  @override
  Future<void> onSearchBarTap(BuildContext context) async {
    await showFilePicker(context);
  }

  @override
  bool get noSearchAction => true;
}

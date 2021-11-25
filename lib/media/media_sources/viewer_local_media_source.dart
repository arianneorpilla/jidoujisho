import 'dart:io';

import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'dart:async';

import 'package:chisa/media/media_sources/viewer_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
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
  Future<List<String>> getChapters(MediaHistoryItem item) async {
    Directory directory = getItemDirectory(item);
    if (!directory.existsSync()) {
      return [];
    }

    List<FileSystemEntity> entities = directory.listSync();

    List<Directory> directories = [];
    for (FileSystemEntity entity in entities) {
      if (entity is Directory) {
        directories.add(entity);
      }
    }

    directories
        .sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
    List<String> chapters = [];

    for (Directory directory in directories) {
      chapters.add(p.basename(directory.path));
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
  ImageProvider<Object> getHistoryThumbnail(MediaHistoryItem item) {
    File? coverFile = getCoverFile(item.key);

    if (coverFile == null || !coverFile.existsSync()) {
      return MemoryImage(kTransparentImage);
    }

    return FileImage(coverFile);
  }

  File? getCoverFile(String directoryPath) {
    Directory directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      return null;
    }

    List<FileSystemEntity> entities = directory.listSync(recursive: true);
    entities.sort((a, b) => a.path.compareTo(b.path));

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

    for (FileSystemEntity entity in entities) {
      if (entity is File) {
        if (extensions.contains(p.extension(entity.path))) {
          return entity;
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

  Future<void> showFilePicker(
    BuildContext context, {
    bool pushReplacement = false,
  }) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    Iterable<String>? filePaths = await FilesystemPicker.open(
      title: "",
      pickText: appModel.translate("dialog_select"),
      cancelText: appModel.translate("dialog_return"),
      context: context,
      rootDirectories: await appModel.getMediaTypeDirectories(mediaType),
      fsType: FilesystemType.folder,
      multiSelect: true,
      folderIconColor: Colors.red,
      themeData: Theme.of(context),
    );

    if (filePaths == null || filePaths.isEmpty) {
      return;
    }

    List<String> paths = filePaths.toList();
    for (String path in paths) {
      appModel.setLastPickedDirectory(mediaType, Directory(p.dirname(path)));

      MediaHistory history = mediaType.getMediaHistory(appModel);

      MediaHistoryItem? historyItem =
          history.getItems().firstWhereOrNull((item) => item.key == path);

      MediaHistoryItem item;
      if (historyItem != null) {
        item = MediaHistoryItem.fromJson(historyItem.toJson());
      } else {
        item = MediaHistoryItem(
          key: path,
          title: p.basenameWithoutExtension(path),
          mediaTypePrefs: mediaType.prefsDirectory(),
          sourceName: sourceName,
          currentProgress: 0,
          completeProgress: 0,
          extra: {},
        );
      }

      try {
        List<String> chapters = await getCachedChapters(item);
        getCoverFile(item.key);
        if (chapters.isEmpty) {
          continue;
        }

        item.extra["chapters"] = chapters;

        history.addItem(item);
      } catch (e) {
        continue;
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
        icon: Icons.my_library_add,
        onPressed: () async {
          await showFilePicker(context);
          refreshCallback();
        },
      ),
    ];
  }

  @override
  Future<void> onSearchBarTap(BuildContext context) async {
    await showFilePicker(context);
  }

  @override
  bool get noSearchAction => true;
}

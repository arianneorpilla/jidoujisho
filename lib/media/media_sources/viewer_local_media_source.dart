import 'dart:io';

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'dart:async';

import 'package:chisa/media/media_sources/viewer_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:transparent_image/transparent_image.dart';

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
    File? coverFile = getCoverFile(item);

    if (coverFile == null) {
      return MemoryImage(kTransparentImage);
    }

    return FileImage(coverFile);
  }

  File? getCoverFile(MediaHistoryItem item) {
    Directory directory = getItemDirectory(item);
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

  // TODO: tap action
  @override
  bool get noSearchAction => true;
}

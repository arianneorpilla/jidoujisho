import 'dart:async';
import 'dart:io';

import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_history_items/default_media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/player_page.dart';
import 'package:chisa/util/bottom_sheet_dialog.dart';
import 'package:chisa/util/media_type_button.dart';
import 'package:chisa/util/subtitle_utils.dart';
import 'package:chisa/util/time_format.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class PlayerLocalMediaSource extends PlayerMediaSource {
  PlayerLocalMediaSource()
      : super(
          sourceName: "Local Media",
          icon: Icons.video_library,
          searchSupport: false,
        );

  @override
  PlayerLaunchParams getLaunchParams(MediaHistoryItem item) {
    return PlayerLaunchParams.file(
      videoFile: File(item.key),
      mediaSource: this,
      mediaHistoryItem: item,
      saveHistoryItem: true,
    );
  }

  @override
  Widget? getButton(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    return MediaTypeButton(
      label: appModel.translate("player_pick_video"),
      icon: Icons.upload_file,
      onTap: () async {
        showFilePicker(context);
      },
    );
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
      fsType: FilesystemType.file,
      multiSelect: false,
      folderIconColor: Colors.red,
    );

    if (filePaths == null || filePaths.isEmpty) {
      return;
    }

    String filePath = filePaths.first;

    appModel.setLastPickedDirectory(mediaType, Directory(p.dirname(filePath)));

    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory thumbsDir = Directory(appDocDir.path + "/thumbs");
    if (!thumbsDir.existsSync()) {
      thumbsDir.createSync(recursive: true);
    }

    String thumbnailPath =
        "${thumbsDir.path}${p.withoutExtension(filePath)}.jpg";
    File thumbnailFile = File(thumbnailPath);
    thumbnailFile.createSync(recursive: true);

    await generateThumbnail(filePath, thumbnailPath);

    MediaHistoryItem? historyItem = appModel
        .getMediaHistory(mediaType)
        .getItems()
        .firstWhereOrNull((item) => item.key == filePath);

    DefaultMediaHistoryItem item;
    if (historyItem != null) {
      item = DefaultMediaHistoryItem.fromJson(historyItem.toJson());
    } else {
      item = DefaultMediaHistoryItem(
        key: filePath,
        name: p.basenameWithoutExtension(filePath),
        source: sourceName,
        currentProgress: 0,
        completeProgress: 0,
        thumbnailPath: thumbnailPath,
        extra: {},
      );
    }

    PlayerLaunchParams params = getLaunchParams(item);
    launchMediaPage(
      context,
      params,
      pushReplacement: pushReplacement,
    );
  }

  @override
  FutureOr<List<SubtitleItem>> provideSubtitles(
      PlayerLaunchParams params) async {
    List<SubtitleItem> items = [];

    File videoFile = params.videoFile!;
    Directory directory = Directory(p.dirname(videoFile.path));

    List<FileSystemEntity> entityList = directory.listSync();

    String videoFileBasename = p.basenameWithoutExtension(videoFile.path);

    List<FileSystemEntity> matchingEntities = entityList.where((entity) {
      return entity is File &&
          p.basename(entity.path).startsWith(videoFileBasename) &&
          videoFile.path != entity.path;
    }).toList();

    for (FileSystemEntity file in matchingEntities) {
      if (file is File) {
        String metadata =
            p.basename(file.path).replaceAll(videoFileBasename, "");
        SubtitleItem? item = await prepareSubtitleControllerFromFile(
          file: file,
          metadata: metadata,
          type: SubtitleItemType.externalSubtitle,
        );
        items.add(item);
      }
    }

    return items;
  }

  Future<void> generateThumbnail(String inputPath, String targetPath) async {
    String timestamp = getTimestampFromDuration(const Duration(seconds: 5));

    String command =
        "-ss $timestamp -y -i \"$inputPath\" -frames:v 1 -q:v 2 \"$targetPath\"";

    await FFmpegKit.executeAsync(command, (session) async {});
  }

  @override
  Future<ImageProvider> getThumbnail(MediaHistoryItem item) async {
    return FileImage(File(item.thumbnailPath));
  }

  @override
  String getCaption(MediaHistoryItem item) {
    return item.name;
  }

  @override
  String getSubcaption(MediaHistoryItem item) {
    return item.key;
  }

  @override
  Widget? buildSourceButton(BuildContext context, PlayerPageState page) {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    return IconButton(
      color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
      icon: const Icon(Icons.perm_media),
      onPressed: () async {
        page.dialogSmartPause();
        await showFilePicker(
          context,
          pushReplacement: true,
        );
        page.dialogSmartResume();
      },
    );
  }
}

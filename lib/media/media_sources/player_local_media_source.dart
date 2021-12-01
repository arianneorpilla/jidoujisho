import 'dart:async';
import 'dart:io';

import 'package:chisa/util/busy_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

import 'package:collection/collection.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/player_page.dart';
import 'package:chisa/util/media_source_action_button.dart';
import 'package:chisa/util/subtitle_utils.dart';
import 'package:chisa/util/time_format.dart';

class PlayerLocalMediaSource extends PlayerMediaSource {
  PlayerLocalMediaSource()
      : super(
          sourceName: "Local Media",
          icon: Icons.storage,
        );

  @override
  PlayerLaunchParams getLaunchParams(AppModel appModel, MediaHistoryItem item) {
    return PlayerLaunchParams.file(
      appModel: appModel,
      videoFile: File(item.key),
      mediaSource: this,
      mediaHistoryItem: item,
      saveHistoryItem: true,
    );
  }

  Future<void> pickFileAndShow(
    BuildContext context, {
    bool pushReplacement = false,
  }) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    Iterable<String>? filePaths = await FilesystemPicker.open(
      title: "",
      pickText: appModel.translate("dialog_select"),
      cancelText: appModel.translate("dialog_cancel"),
      context: context,
      rootDirectories: await appModel.getMediaTypeDirectories(mediaType),
      fsType: FilesystemType.file,
      multiSelect: false,
      folderIconColor: Colors.red,
      themeData: Theme.of(context),
    );

    if (filePaths == null || filePaths.isEmpty) {
      return;
    }

    await showFileFromPath(
      context,
      filePaths.first,
      pushReplacement: pushReplacement,
    );
  }

  Future<void> showFileFromPath(
    BuildContext context,
    String filePath, {
    bool pushReplacement = false,
  }) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

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
        thumbnailPath: thumbnailPath,
        extra: {},
      );
    }

    PlayerLaunchParams params = getLaunchParams(appModel, item);
    await launchMediaPage(
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
    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

    String command =
        "-ss $timestamp -y -i \"$inputPath\" -frames:v 1 -q:v 2 \"$targetPath\"";

    await _flutterFFmpeg.execute(command);
  }

  @override
  ImageProvider<Object> getHistoryThumbnail(MediaHistoryItem item) {
    return FileImage(File(item.thumbnailPath));
  }

  @override
  String getHistoryCaption(MediaHistoryItem item) {
    String videoName = item.title;
    return videoName;
  }

  @override
  String getHistorySubcaption(MediaHistoryItem item) {
    String videoPath = item.key;
    return videoPath;
  }

  @override
  Widget? buildSourceButton(BuildContext context, PlayerPageState page) {
    return Material(
      color: Colors.transparent,
      child: BusyIconButton(
        icon: const Icon(Icons.perm_media),
        iconSize: 20,
        onPressed: () async {
          page.dialogSmartPause();
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          await pickFileAndShow(
            context,
            pushReplacement: true,
          );
          await SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.immersiveSticky);
          page.dialogSmartResume();
        },
      ),
    );
  }

  @override
  FutureOr<String> getNetworkStreamUrl(PlayerLaunchParams params) {
    throw UnsupportedError(
        "Local media source does not support network stream");
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
          await pickFileAndShow(context);
          refreshCallback();
        },
      )
    ];
  }

  @override
  bool get noSearchAction => true;

  @override
  Future<void> onSearchBarTap(BuildContext context) async {
    await pickFileAndShow(context);
  }

  @override
  FutureOr<List<MediaHistoryItem>?> getSearchMediaHistoryItems({
    required BuildContext context,
    required String searchTerm,
    required int pageKey,
  }) {
    throw UnsupportedError("Local media does not support search");
  }
}

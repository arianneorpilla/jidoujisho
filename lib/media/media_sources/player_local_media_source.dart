import 'dart:async';
import 'dart:io';

import 'package:chisa/media/media_history_items/default_media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/media_type_button.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:subtitle/subtitle.dart';

class PlayerLocalMediaSource extends PlayerMediaSource {
  PlayerLocalMediaSource()
      : super(
          sourceName: "Local Media",
          icon: Icons.video_library,
          searchSupport: false,
        );

  @override
  PlayerLaunchParams getLaunchParams(DefaultMediaHistoryItem item) {
    return PlayerLaunchParams.file(
      videoFile: File(item.key),
      mediaSource: this,
      mediaHistoryItem: item,
    );
  }

  @override
  Widget? getButton(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    return MediaTypeButton(
      label: appModel.translate("player_pick_video"),
      icon: Icons.upload_file,
      onTap: () async {
        Iterable<String>? filePaths = await FilesystemPicker.open(
          title: appModel.translate("player_pick_video"),
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

        appModel.setLastPickedDirectory(
            mediaType, Directory(p.dirname(filePath)));

        DefaultMediaHistoryItem item = DefaultMediaHistoryItem(
          key: filePath,
          name: p.basenameWithoutExtension(filePath),
          resource: "",
          progress: 0,
          extra: {},
        );

        PlayerLaunchParams params = getLaunchParams(item);
        launchMediaPage(context, params);
      },
    );
  }

  @override
  FutureOr<List<SubtitleController>> provideSubtitles(
      PlayerLaunchParams params) {
    List<SubtitleController> controllers = [];

    File videoFile = params.videoFile!;

    String srtPath = p.withoutExtension(videoFile.path) + ".srt";
    String assPath = p.withoutExtension(videoFile.path) + ".ass";

    File srtFile = File(srtPath);
    File assFile = File(assPath);

    // First priority is an existing SRT file.
    if (srtFile.existsSync()) {
      SubtitleController controller =
          SubtitleController(provider: SubtitleProvider.fromFile(srtFile));
      controllers.add(controller);
    }

    return controllers;
  }
}

import 'dart:io';

import 'package:chisa/media/media_history_items/default_media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

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
    return null;
  }

  Future<void> pickVideoAndLaunch(BuildContext context) async {
    AppModel appModel = Provider.of<AppModel>(context);

    String? videoFilePath = await FilesystemPicker.open(
      title: appModel.translate("player_pick_video"),
      context: context,
      rootDirectory: appModel.getLastPickedDirectory(mediaType),
      allowedExtensions: mediaType.getAllowedExtensions(),
      fsType: FilesystemType.file,
      pickText: appModel.translate("player_pick_video"),
      folderIconColor: Colors.teal,
    );

    if (videoFilePath != null) {
      appModel.setLastPickedDirectory(
          mediaType, Directory(p.dirname(videoFilePath)));

      DefaultMediaHistoryItem item = DefaultMediaHistoryItem(
        key: videoFilePath,
        name: p.basenameWithoutExtension(videoFilePath),
        resource: "",
        progress: 0,
        extra: {},
      );

      PlayerLaunchParams params = getLaunchParams(item);
      launchMediaPage(context, params);
    }
  }
}

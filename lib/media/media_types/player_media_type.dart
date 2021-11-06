import 'dart:io';

import 'package:chisa/media/media_histories/default_media_history.dart';
import 'package:chisa/media/media_history.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:chisa/pages/player_home_page.dart';
import 'package:flutter/material.dart';

import 'package:chisa/media/media_type.dart';
import 'package:provider/provider.dart';

class PlayerMediaType extends MediaType {
  PlayerMediaType()
      : super(
          mediaTypeName: "Player",
          mediaTypeIcon: Icons.video_library,
        );

  @override
  MediaHomePage getHomeBody(BuildContext context) {
    return PlayerHomePage(mediaType: this);
  }

  @override
  BottomNavigationBarItem getHomeTab(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);
    return BottomNavigationBarItem(
      label: appModel.translate("player_media_type"),
      icon: Icon(mediaTypeIcon),
    );
  }

  @override
  MediaHistory getMediaHistory(AppModel appModel) {
    return DefaultMediaHistory(
      sharedPreferences: appModel.sharedPreferences,
      prefsDirectory: mediaTypeName,
    );
  }

  @override
  List<String> getAllowedExtensions() {
    return const [
      ".3gp",
      ".aaf",
      ".asf",
      ".avchd",
      ".avi",
      ".drc",
      ".flv",
      ".m2v",
      ".m4p",
      ".m4v",
      ".mkv",
      ".mng",
      ".mov",
      ".mp2",
      ".mp4",
      ".mpe",
      ".mpeg",
      ".mpg",
      ".mpv",
      ".mxf",
      ".nsv",
      ".ogg",
      ".ogv",
      ".ogm",
      ".qt",
      ".rm",
      ".rmvb",
      ".roq",
      ".srt",
      ".svi",
      ".vob",
      ".webm",
      ".wmv",
      ".yuv"
    ];
  }
}

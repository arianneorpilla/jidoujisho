import 'dart:io';

import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/media/histories/default_media_history.dart';
import 'package:chisa/media/media_history.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:chisa/pages/player_home_page.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:provider/provider.dart';

class PlayerMediaType extends MediaType {
  PlayerMediaType()
      : super(
          mediaTypeName: "Player",
          mediaTypeIcon: Icons.video_library,
        );

  @override
  MediaType? getFallbackMediaType(MediaHistoryItem mediaHistoryItem) {
    return null;
  }

  @override
  MediaHomePage getHomeBody(BuildContext context) {
    return PlayerHomePage(mediaType: this);
  }

  @override
  BottomNavigationBarItem getHomeTab(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);
    return BottomNavigationBarItem(
      label: AppLocalizations.getLocalizedValue(
          appModel.getAppLanguageName(), "player_media_type"),
      icon: Icon(mediaTypeIcon),
    );
  }

  @override
  MediaHistoryItem getNewHistoryItem(Uri uri) {
    // TODO: implement getNewHistoryItem
    throw UnimplementedError();
  }

  @override
  bool isUriSupported(Uri uri) {
    File file;

    try {
      file = File.fromUri(uri);
    } on UnsupportedError {
      return false;
    }

    String mimeType = lookupMimeType(file.path) ?? "";
    return mimeType.startsWith("video/");
  }

  @override
  void launchMediaPageFromHistory(
      BuildContext context, MediaHistoryItem mediaHistoryItem) {
    // TODO: implement launchMediaPageFromHistory
  }

  @override
  void launchMediaPageFromUri(BuildContext context, Uri uri) {
    // TODO: implement launchMediaPageFromUri
  }

  @override
  MediaHistory getMediaHistory(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);
    return DefaultMediaHistory(
      sharedPreferences: appModel.sharedPreferences,
      prefsDirectory: mediaTypeName,
    );
  }
}

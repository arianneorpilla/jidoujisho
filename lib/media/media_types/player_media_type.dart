import 'dart:io';

import 'package:chisachan/language/app_localizations.dart';
import 'package:chisachan/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import 'package:chisachan/media/media_history_item.dart';
import 'package:chisachan/media/media_type.dart';
import 'package:provider/provider.dart';

class PlayerMediaType extends MediaType {
  PlayerMediaType()
      : super(
          mediaTypeName: "Player",
        );

  @override
  MediaType? getFallbackMediaType(MediaHistoryItem mediaHistoryItem) {
    return null;
  }

  @override
  Widget getHomeBody(BuildContext context) {
    return Container(color: Colors.red);
  }

  @override
  BottomNavigationBarItem getHomeTab(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);
    return BottomNavigationBarItem(
      label: AppLocalizations.getLocalizedValue(
          appModel.getAppLanguage(), "player_media_type"),
      icon: const Icon(Icons.video_library),
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
}

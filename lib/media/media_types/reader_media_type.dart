import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/media/histories/default_media_history.dart';
import 'package:chisa/media/media_history.dart';
import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:chisa/pages/reader_home_page.dart';
import 'package:chisa/pages/reader_page.dart';

class ReaderMediaType extends MediaType {
  ReaderMediaType()
      : super(
          mediaTypeName: "Reader",
          mediaTypeIcon: Icons.library_books,
        );

  @override
  MediaType? getFallbackMediaType(MediaHistoryItem mediaHistoryItem) {
    return null;
  }

  @override
  MediaHomePage getHomeBody(BuildContext context) {
    return ReaderHomePage(mediaType: this);
  }

  @override
  BottomNavigationBarItem getHomeTab(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    return BottomNavigationBarItem(
      label: AppLocalizations.getLocalizedValue(
          appModel.getAppLanguageName(), "reader_media_type"),
      icon: Icon(mediaTypeIcon),
    );
  }

  @override
  MediaHistoryItem getNewHistoryItem(Uri uri) {
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

    return lookupMimeType(file.path) == "application/epub+zip";
  }

  @override
  void launchMediaPageFromHistory(
      BuildContext context, MediaHistoryItem mediaHistoryItem) {
    // TODO: implement launchMediaPage
  }

  @override
  void launchMediaPageFromUri(BuildContext context, Uri uri) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderPage(
          mediaType: this,
          uri: uri,
        ),
      ),
    );
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

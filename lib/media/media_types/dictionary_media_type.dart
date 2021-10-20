import 'dart:io';

import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/pages/dictionary_home_page.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import 'package:chisa/media/media_histories/default_media_history.dart';
import 'package:chisa/media/media_history.dart';
import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';

class DictionaryMediaType extends MediaType {
  DictionaryMediaType()
      : super(
          mediaTypeName: "Dictionary",
          mediaTypeIcon: Icons.auto_stories,
        );

  @override
  MediaType? getFallbackMediaType(MediaHistoryItem mediaHistoryItem) {
    return null;
  }

  @override
  MediaHomePage getHomeBody(BuildContext context) {
    return DictionaryHomePage(mediaType: this);
  }

  @override
  MediaHistory getMediaHistory(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);
    return DefaultMediaHistory(
      sharedPreferences: appModel.sharedPreferences,
      prefsDirectory: mediaTypeName,
    );
  }

  Future<Uri> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File epubFile = File(result.files.single.path!);
      if (isUriSupported(epubFile.uri)) {
        return epubFile.uri;
      } else {
        throw Exception("Uri is not supported.");
      }
    } else {
      throw Exception("No file picked.");
    }
  }

  @override
  BottomNavigationBarItem getHomeTab(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    return BottomNavigationBarItem(
      label: appModel.translate("dictionary_media_type"),
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
  void launchMediaPage(BuildContext context, MediaLaunchParams params) {}

  @override
  List<String> getAllowedExtensions() {
    throw UnsupportedError("Operation invalid for dictionary media type.");
  }
}

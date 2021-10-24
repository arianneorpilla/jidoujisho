import 'dart:io';

import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/pages/dictionary_home_page.dart';
import 'package:chisa/pages/media_home_page.dart';
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

  @override
  BottomNavigationBarItem getHomeTab(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    return BottomNavigationBarItem(
      label: appModel.translate("dictionary_media_type"),
      icon: Icon(mediaTypeIcon),
    );
  }

  @override
  List<String> getAllowedExtensions() {
    throw UnsupportedError("Operation invalid for dictionary media type.");
  }
}

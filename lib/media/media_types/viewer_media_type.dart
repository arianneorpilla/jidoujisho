import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chisa/media/media_histories/default_media_history.dart';
import 'package:chisa/media/media_history.dart';
import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:chisa/pages/reader_home_page.dart';

class ViewerMediaType extends MediaType {
  ViewerMediaType()
      : super(
          mediaTypeName: "Viewer",
          mediaTypeIcon: Icons.photo_library,
        );

  @override
  MediaHomePage getHomeBody(BuildContext context) {
    return ReaderHomePage(mediaType: this);
  }

  @override
  BottomNavigationBarItem getHomeTab(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    return BottomNavigationBarItem(
      label: appModel.translate("reader_media_type"),
      icon: Icon(mediaTypeIcon),
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

  @override
  List<String> getAllowedExtensions() {
    return const [
      ".jpg",
      ".jpeg",
      ".png",
    ];
  }
}

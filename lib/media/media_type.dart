import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/dictionary_home_page.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:chisa/pages/player_home_page.dart';
import 'package:chisa/pages/reader_home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MediaType {
  player,
  reader,
  viewer,
  dictionary,
}

extension MediaTypeParameters on MediaType {
  IconData icon() {
    switch (this) {
      case MediaType.player:
        return Icons.video_library;
      case MediaType.reader:
        return Icons.library_books;
      case MediaType.viewer:
        return Icons.photo_library;
      case MediaType.dictionary:
        return Icons.auto_stories;
    }
  }

  String prefsDirectory() {
    switch (this) {
      case MediaType.player:
        return "player_media_type";
      case MediaType.reader:
        return "reader_media_type";
      case MediaType.viewer:
        return "viewer_media_type";
      case MediaType.dictionary:
        return "dictionary_media_type";
    }
  }

  MediaHomePage getHomeBody() {
    switch (this) {
      case MediaType.player:
        return PlayerHomePage(mediaType: this);
      case MediaType.reader:
        return ReaderHomePage(mediaType: this);
      case MediaType.viewer:
        throw UnimplementedError();
      case MediaType.dictionary:
        return DictionaryHomePage(mediaType: this);
    }
  }

  BottomNavigationBarItem getHomeTab(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);
    return BottomNavigationBarItem(
      label: appModel.translate(prefsDirectory()),
      icon: Icon(icon()),
    );
  }

  MediaHistory getMediaHistory(AppModel appModel) {
    return MediaHistory(
      sharedPreferences: appModel.sharedPreferences,
      prefsDirectory: prefsDirectory(),
    );
  }

  List<String> getAllowedExtensions() {
    switch (this) {
      case MediaType.player:
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
      case MediaType.reader:
        return const [
          ".epub",
        ];
      case MediaType.viewer:
        return const [
          ".jpg",
          ".jpeg",
          ".png",
        ];
      case MediaType.dictionary:
        throw UnsupportedError("Operation invalid for dictionary media type.");
    }
  }
}

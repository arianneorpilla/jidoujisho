import 'dart:io';

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/models/app_model.dart';

class MediaLaunchParams {}

enum MediaLaunchMode {
  file,
  network,
}

class PlayerLaunchParams {
  PlayerLaunchParams.file({
    required this.appModel,
    required this.videoFile,
    this.networkPath,
    this.audioPath,
    required this.mediaSource,
    required this.mediaHistoryItem,
    required this.saveHistoryItem,
  });

  PlayerLaunchParams.network({
    required this.appModel,
    this.videoFile,
    required this.networkPath,
    this.audioPath,
    required this.mediaSource,
    required this.mediaHistoryItem,
    required this.saveHistoryItem,
  });

  final AppModel appModel;
  final File? videoFile;
  final String? networkPath;
  final String? audioPath;
  final PlayerMediaSource mediaSource;
  final MediaHistoryItem mediaHistoryItem;
  final bool saveHistoryItem;

  MediaLaunchMode getMode() {
    if (videoFile != null) {
      return MediaLaunchMode.file;
    } else {
      return MediaLaunchMode.network;
    }
  }
}

class ReaderLaunchParams {
  ReaderLaunchParams.file({
    required this.appModel,
    required this.bookFile,
    required this.mediaSource,
    required this.mediaHistoryItem,
  });

  ReaderLaunchParams.network({
    required this.appModel,
    this.bookFile,
    required this.mediaSource,
    required this.mediaHistoryItem,
  });

  final AppModel appModel;
  final File? bookFile;
  final MediaSource mediaSource;
  final MediaHistoryItem mediaHistoryItem;
}

class ViewerLaunchParams {
  ViewerLaunchParams({
    required this.appModel,
    required this.mediaSource,
    required this.mediaHistoryItem,
  });

  final AppModel appModel;
  final MediaSource mediaSource;
  final MediaHistoryItem mediaHistoryItem;
}

import 'dart:io';

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_sources/reader_media_source.dart';
import 'package:chisa/media/media_sources/viewer_media_source.dart';
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
    required this.mediaSource,
    required this.mediaHistoryItem,
    required this.saveHistoryItem,
    this.networkPath,
    this.audioPath,
  });

  PlayerLaunchParams.network({
    required this.appModel,
    required this.networkPath,
    required this.mediaSource,
    required this.mediaHistoryItem,
    required this.saveHistoryItem,
    this.videoFile,
    this.audioPath,
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
    required this.saveHistoryItem,
  });

  ReaderLaunchParams.network({
    required this.appModel,
    required this.mediaSource,
    required this.mediaHistoryItem,
    required this.saveHistoryItem,
    this.bookFile,
  });

  final AppModel appModel;
  final File? bookFile;
  final ReaderMediaSource mediaSource;
  final MediaHistoryItem mediaHistoryItem;
  final bool saveHistoryItem;
}

class ViewerLaunchParams {
  ViewerLaunchParams({
    required this.appModel,
    required this.mediaSource,
    required this.mediaHistoryItem,
    required this.chapters,
    this.canOpenHistory = true,
    this.hideSlider = false,
    this.chapterName,
    this.fromStart = false,
    this.fromEnd = false,
    this.pushReplacement = false,
  });

  final AppModel appModel;
  final ViewerMediaSource mediaSource;
  final MediaHistoryItem mediaHistoryItem;
  final List<String> chapters;
  final String? chapterName;
  final bool fromStart;
  final bool fromEnd;
  final bool canOpenHistory;
  final bool hideSlider;
  final bool pushReplacement;
}

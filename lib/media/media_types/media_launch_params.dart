import 'dart:io';

import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_source.dart';

class MediaLaunchParams {}

enum MediaLaunchMode {
  file,
  network,
}

class PlayerLaunchParams {
  PlayerLaunchParams.file({
    required this.videoFile,
    this.networkUri,
    required this.mediaSource,
    required this.mediaHistoryItem,
  });

  PlayerLaunchParams.network({
    this.videoFile,
    required this.networkUri,
    required this.mediaSource,
    required this.mediaHistoryItem,
  });

  final File? videoFile;
  final Uri? networkUri;
  final MediaSource mediaSource;
  final MediaHistoryItem mediaHistoryItem;

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
    this.bookFile,
    required this.mediaSource,
    required this.mediaHistoryItem,
  });

  ReaderLaunchParams.network({
    this.bookFile,
    required this.mediaSource,
    required this.mediaHistoryItem,
  });

  final File? bookFile;
  final MediaSource mediaSource;
  final MediaHistoryItem mediaHistoryItem;
}

class ViewerLaunchParams {
  ViewerLaunchParams.file({
    required this.imageFiles,
    required this.mediaSource,
    required this.mediaHistoryItem,
  });

  final List<Uri> imageFiles;
  final MediaSource mediaSource;
  final MediaHistoryItem mediaHistoryItem;
}

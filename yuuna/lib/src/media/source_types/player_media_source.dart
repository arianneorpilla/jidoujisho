import 'dart:async';
import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:intl/intl.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subtitle/subtitle.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A source for the [PlayerMediaType], which handles primarily video-based
/// media.
abstract class PlayerMediaSource extends MediaSource {
  /// Initialise a media source.
  PlayerMediaSource({
    required super.uniqueKey,
    required super.sourceName,
    required super.description,
    required super.icon,
    required super.implementsSearch,
    required super.implementsHistory,
  }) : super(
          mediaType: PlayerMediaType.instance,
          overridesAutoAudio: true,
          overridesAutoImage: true,
        );

  /// The body widget to show in the tab when this source's media type and this
  /// source is selected.
  @override
  BasePage buildHistoryPage({MediaItem? item}) {
    return const HistoryPlayerPage();
  }

  /// Get the player controller to be used when a media item is loaded up,
  Future<VlcPlayerController> preparePlayerController({
    required AppModel appModel,
    required MediaItem item,
    String? audioUrl,
  }) async {
    throw UnimplementedError();
  }

  /// Get the player controller to be used when a media item is loaded up,
  Future<List<SubtitleItem>> prepareSubtitles(MediaItem item) async {
    throw UnimplementedError();
  }

  /// If this source is non-null, this will be used as the initial function
  /// for the image field over the auto enhancement. Extra durations can be
  /// invoked and defined when initially opening the creator, to call attention
  /// to multiple durations to be used for image generation.
  @override
  Future<List<NetworkToFileImage>> generateImages({
    required AppModel appModel,
    required MediaItem item,
    required List<Subtitle>? subtitles,
    required SubtitleOptions options,
  }) async {
    if (subtitles == null && appModel.currentSubtitle.value != null) {
      subtitles ??= [appModel.currentSubtitle.value!];
    }
    List<NetworkToFileImage> imageFiles = [];
    Directory appDirDoc = await getApplicationSupportDirectory();
    String playerPreviewPath = '${appDirDoc.path}/playerImagePreview';
    Directory playerPreviewDir = Directory(playerPreviewPath);
    if (playerPreviewDir.existsSync()) {
      playerPreviewDir.deleteSync(recursive: true);
    }
    playerPreviewDir.createSync();

    String timestamp = DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
    Directory imageDir = Directory('$playerPreviewPath/$timestamp');
    imageDir.createSync();

    for (int index = 0; index < subtitles!.length; index++) {
      Subtitle subtitle = subtitles[index];
      File imageFile = appModel.getPreviewImageFile(imageDir, index);

      String outputPath = imageFile.path;
      if (imageFile.existsSync()) {
        imageFile.deleteSync();
      }

      int msStart = subtitle.start.inMilliseconds;
      int msEnd = subtitle.end.inMilliseconds;
      int msMean = ((msStart + msEnd) / 2).floor();
      Duration currentTime = Duration(milliseconds: msMean);

      VlcPlayerController playerController = appModel.currentPlayerController!;
      if (subtitles.length == 1) {
        currentTime = Duration(
            milliseconds: playerController.value.position.inMilliseconds);
      }

      String timestamp = JidoujishoTimeFormat.getFfmpegTimestamp(currentTime);
      String inputPath = item.mediaIdentifier;
      String command =
          '-ss $timestamp -y -i "$inputPath" -frames:v 1 -q:v 2 "$outputPath"';

      final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
      await _flutterFFmpeg.execute(command);

      while (!imageFile.existsSync()) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      NetworkToFileImage networkToFileImage =
          NetworkToFileImage(file: imageFile);

      imageFiles.add(networkToFileImage);
    }

    return imageFiles;
  }

  /// If this source is non-null, this will be used as the initial function
  /// for the audio field over the auto enhancement.
  @override
  Future<File?>? generateAudio({
    required AppModel appModel,
    required MediaItem item,
    required List<Subtitle>? subtitles,
    required SubtitleOptions options,
  }) async {
    Directory appDirDoc = await getApplicationSupportDirectory();
    String playerPreviewPath = '${appDirDoc.path}/playerAudioPreview';
    Directory playerPreviewDir = Directory(playerPreviewPath);
    if (playerPreviewDir.existsSync()) {
      playerPreviewDir.deleteSync(recursive: true);
    }
    playerPreviewDir.createSync();

    String timestamp = DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
    Directory imageDir = Directory('$playerPreviewPath/$timestamp');
    imageDir.createSync();

    File audioFile = appModel.getAudioPreviewFile(playerPreviewDir);
    String outputPath = audioFile.path;
    if (audioFile.existsSync()) {
      audioFile.deleteSync();
    }

    String timeStart = '';
    String timeEnd = '';

    VlcPlayerController playerController = appModel.currentPlayerController!;
    Map<int, String> embeddedTracks = await playerController.getAudioTracks();

    int audioIndex = await playerController.getAudioTrack() ?? 0;
    for (int i = 0; i < embeddedTracks.length; i++) {
      MapEntry<int, String> entry = embeddedTracks.entries.elementAt(i);
      if (audioIndex == entry.key) {
        audioIndex = i;
      }
    }

    if (item.audioUrl != null) {
      audioIndex = 0;
    }

    Duration allowance = Duration(milliseconds: options.audioAllowance);
    Duration delay = Duration(milliseconds: options.subtitleDelay);

    if (subtitles == null && appModel.currentSubtitle.value != null) {
      subtitles ??= [appModel.currentSubtitle.value!];
    }
    Duration adjustedStart = subtitles!.first.start - delay - allowance;
    Duration adjustedEnd = subtitles.last.end - delay + allowance;
    timeStart = JidoujishoTimeFormat.getFfmpegTimestamp(adjustedStart);
    timeEnd = JidoujishoTimeFormat.getFfmpegTimestamp(adjustedEnd);

    String inputPath = item.mediaIdentifier;
    String? altInputPath = item.audioUrl;
    if (altInputPath != null) {
      inputPath = altInputPath;
    }

    String command =
        '-ss $timeStart -to $timeEnd -y -i "$inputPath" -map 0:a:$audioIndex "$outputPath"';

    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
    await _flutterFFmpeg.execute(command);

    return audioFile;
  }
}

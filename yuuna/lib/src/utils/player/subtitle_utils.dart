import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subtitle/subtitle.dart';
import 'package:path/path.dart' as path;
import 'package:yuuna/language.dart';

/// Differentiates different types of [SubtitleItem].
enum SubtitleItemType {
  /// Subtitles from a file.
  externalSubtitle,

  /// Subtitle from a video.
  embeddedSubtitle,

  /// Represents an item that contains no subtitles.
  noneSubtitle,

  /// Subtitle from a separate web document.
  webSubtitle,
}

/// Represents subtitles that can be used in the player.
class SubtitleItem {
  /// Initialise an item.
  SubtitleItem({
    required this.controller,
    required this.type,
    this.source,
    this.metadata,
    this.index,
  });

  /// The controller that contains the content of the subtitle.
  SubtitleController controller;

  /// The type of the subtitle, embedded, external, etc.
  SubtitleItemType type;

  /// Used to identify the source of a subtitle. This could be a filename.
  String? source;

  /// Used to possibly identify the content of a subtitle.
  String? metadata;

  /// Used to possibly identify the order of a subtitle.
  int? index;
}

/// A class for calling subtitle utility functions.
class SubtitleUtils {
  /// Fetches a subtitle from a subtitle file.
  static Future<SubtitleItem> subtitlesFromFile({
    required File file,
    required SubtitleItemType type,
    String? source,
    String? metadata,
    int? index,
  }) async {
    String fileExtension = path.extension(file.path).toLowerCase();

    if (!file.existsSync()) {
      return SubtitleItem(
        controller: SubtitleController(
          provider: SubtitleProvider.fromFile(
            file,
          ),
        ),
        metadata: metadata,
        source: source,
        type: type,
        index: index,
      );
    }

    switch (fileExtension) {
      case '.srt':
        return SubtitleItem(
          controller: SubtitleController(
            provider: SubtitleProvider.fromString(
              data: file.readAsStringSync(),
              type: SubtitleType.srt,
            ),
          ),
          metadata: metadata,
          type: type,
          index: index,
        );
      case '.ass':
      case '.ssa':
        return SubtitleItem(
          controller: SubtitleController(
            provider: SubtitleProvider.fromString(
              data: await convertAssSubtitles(file.path),
              type: SubtitleType.srt,
            ),
          ),
          metadata: metadata,
          type: type,
          index: index,
        );
    }

    return SubtitleItem(
      controller: SubtitleController(
        provider: SubtitleProvider.fromFile(
          file,
        ),
      ),
      metadata: metadata,
      type: type,
      index: index,
    );
  }

  /// Gets a list of subtitles from a video file.
  static Future<SubtitleItem?> targetSubtitleFromVideo({
    required File file,
    required Language language,
    required Function(SubtitleItem) onItemComplete,
  }) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory subsDir = Directory('${appDocDir.path}/targetSubtitles');
    if (!subsDir.existsSync()) {
      subsDir.createSync(recursive: true);
    }

    String inputPath = file.path;

    String threeLanguageCode = language.threeLetterCode;
    String outputPath = '${subsDir.path}/extractSrt.srt';
    String command =
        '-loglevel quiet -i "$inputPath" -map 0:m:language:$threeLanguageCode -map -0:a -map -0:v "$outputPath"';

    File outputFile = File(outputPath);

    if (outputFile.existsSync()) {
      outputFile.deleteSync();
    }

    final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();

    await flutterFFmpeg.execute(command);

    await Future.delayed(const Duration(seconds: 1));

    if (outputFile.existsSync()) {
      SubtitleItem item = await subtitlesFromFile(
        file: outputFile,
        type: SubtitleItemType.embeddedSubtitle,
      );
      onItemComplete(item);
      return item;
    } else {
      return null;
    }
  }

  /// Gets a list of subtitles from a video file.
  static Future<List<SubtitleItem>> subtitlesFromVideo({
    required File file,
    required int embeddedTrackCount,
    required Function(SubtitleItem) onItemComplete,
  }) async {
    List<File> outputFiles = [];
    List<SubtitleItem> items = [];

    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory subsDir = Directory('${appDocDir.path}/subtitles');
    if (!subsDir.existsSync()) {
      subsDir.createSync(recursive: true);
    }

    String inputPath = file.path;

    for (int i = 0; i < embeddedTrackCount - 1; i++) {
      String outputPath = '${subsDir.path}/extractSrt$i.srt';
      String command =
          '-loglevel quiet -i "$inputPath" -map 0:s:$i "$outputPath"';

      File outputFile = File(outputPath);

      if (outputFile.existsSync()) {
        outputFile.deleteSync();
      }

      final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();
      final FlutterFFmpegConfig flutterFFmpegConfig = FlutterFFmpegConfig();

      await flutterFFmpeg.execute(command);
      String output = await flutterFFmpegConfig.getLastCommandOutput();
      if (output.contains("Stream map '0:s:$i' matches no streams.")) {
        break;
      }

      await Future.delayed(const Duration(seconds: 1));

      SubtitleItem item = await subtitlesFromFile(
        file: outputFile,
        type: SubtitleItemType.embeddedSubtitle,
        index: i,
      );

      onItemComplete(item);
      outputFiles.add(outputFile);
      items.add(item);
    }

    return items;
  }

  /// Converts ASS subtitles to SRT and returns the data.
  static Future<String> convertAssSubtitles(String inputPath) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory subsDir = Directory('${appDocDir.path}/subtitles');
    if (!subsDir.existsSync()) {
      subsDir.createSync(recursive: true);
    }

    String outputPath = '${subsDir.path}/assSubtitles.srt';
    File targetFile = File(outputPath);

    if (targetFile.existsSync()) {
      targetFile.deleteSync();
    }

    String command = '-i "$inputPath" "$outputPath"';

    final FlutterFFmpeg flutterFFmpeg = FlutterFFmpeg();

    await flutterFFmpeg.execute(command);

    return targetFile.readAsStringSync();
  }
}

import 'dart:io';

import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subtitle/subtitle.dart';
import 'package:path/path.dart' as p;

enum SubtitleItemType {
  externalSubtitle,
  embeddedSubtitle,
  noneSubtitle,
  webSubtitle,
}

class SubtitleItem {
  SubtitleItem({
    required this.controller,
    required this.type,
    this.metadata,
    this.index,
  });

  SubtitleController controller;
  SubtitleItemType type;
  String? metadata;
  int? index;
}

Future<SubtitleItem> prepareSubtitleControllerFromFile({
  required File file,
  required SubtitleItemType type,
  String? metadata,
  int? index,
}) async {
  String fileExtension = p.extension(file.path).toLowerCase();

  if (!file.existsSync()) {
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

  switch (fileExtension) {
    case ".srt":
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
    case ".ass":
    case ".ssa":
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

Future<List<SubtitleItem>> prepareSubtitleControllersFromVideo(
  File file,
  int embeddedTrackCount,
) async {
  List<File> outputFiles = [];

  Directory appDocDir = await getApplicationDocumentsDirectory();
  Directory subsDir = Directory(appDocDir.path + "/subtitles");
  if (!subsDir.existsSync()) {
    subsDir.createSync(recursive: true);
  }

  String inputPath = file.path;

  for (int i = 0; i < embeddedTrackCount - 1; i++) {
    String outputPath = "${subsDir.path}/extractSrt$i.srt";
    String command =
        "-loglevel verbose -i \"$inputPath\" -map 0:s:$i \"$outputPath\"";

    File outputFile = File(outputPath);

    if (outputFile.existsSync()) {
      outputFile.deleteSync();
    }

    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
    final FlutterFFmpegConfig _flutterFFmpegConfig = new FlutterFFmpegConfig();

    await _flutterFFmpeg.execute(command);
    String output = await _flutterFFmpegConfig.getLastCommandOutput();
    if (output.contains("Stream map '0:s:$i' matches no streams.")) {
      break;
    }

    await Future.delayed(const Duration(seconds: 1));

    outputFiles.add(outputFile);
  }

  List<SubtitleItem> items = [];
  for (int i = 0; i < outputFiles.length; i++) {
    File outputFile = outputFiles[i];

    SubtitleItem item = await prepareSubtitleControllerFromFile(
      file: outputFile,
      type: SubtitleItemType.embeddedSubtitle,
      index: i,
    );

    items.add(item);
  }

  return items;
}

Future<String> convertAssSubtitles(String inputPath) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  Directory subsDir = Directory(appDocDir.path + "/subtitles");
  if (!subsDir.existsSync()) {
    subsDir.createSync(recursive: true);
  }

  String outputPath = "${subsDir.path}/assSubtitles.srt";
  File targetFile = File(outputPath);

  String command = "-i \"$inputPath\" \"$outputPath\"";

  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  final FlutterFFmpegConfig _flutterFFmpegConfig = new FlutterFFmpegConfig();

  await _flutterFFmpeg.execute(command);

  return targetFile.readAsStringSync();
}

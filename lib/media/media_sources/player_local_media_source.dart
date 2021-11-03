import 'dart:async';
import 'dart:io';

import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_history_items/default_media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/media_type_button.dart';
import 'package:chisa/util/time_format.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:subtitle/subtitle.dart';

class PlayerLocalMediaSource extends PlayerMediaSource {
  PlayerLocalMediaSource()
      : super(
          sourceName: "Local Media",
          icon: Icons.video_library,
          searchSupport: false,
        );

  @override
  PlayerLaunchParams getLaunchParams(MediaHistoryItem item) {
    return PlayerLaunchParams.file(
      videoFile: File(item.key),
      mediaSource: this,
      mediaHistoryItem: item,
    );
  }

  @override
  Widget? getButton(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);

    return MediaTypeButton(
      label: appModel.translate("player_pick_video"),
      icon: Icons.upload_file,
      onTap: () async {
        Iterable<String>? filePaths = await FilesystemPicker.open(
          title: "",
          pickText: appModel.translate("dialog_select"),
          cancelText: appModel.translate("dialog_return"),
          context: context,
          rootDirectories: await appModel.getMediaTypeDirectories(mediaType),
          fsType: FilesystemType.file,
          multiSelect: false,
          folderIconColor: Colors.red,
        );

        if (filePaths == null || filePaths.isEmpty) {
          return;
        }

        String filePath = filePaths.first;

        appModel.setLastPickedDirectory(
            mediaType, Directory(p.dirname(filePath)));

        Directory appDocDir = await getApplicationDocumentsDirectory();
        Directory thumbsDir = Directory(appDocDir.path + "/thumbs");
        if (!thumbsDir.existsSync()) {
          thumbsDir.createSync(recursive: true);
        }

        String thumbnailPath =
            "${thumbsDir.path}${p.withoutExtension(filePath)}.jpg";
        File thumbnailFile = File(thumbnailPath);
        thumbnailFile.createSync(recursive: true);

        await generateThumbnail(filePath, thumbnailPath);

        DefaultMediaHistoryItem item = DefaultMediaHistoryItem(
          key: filePath,
          name: p.basenameWithoutExtension(filePath),
          source: sourceName,
          currentProgress: 0,
          completeProgress: 0,
          thumbnailPath: thumbnailPath,
          extra: {},
        );

        PlayerLaunchParams params = getLaunchParams(item);
        launchMediaPage(context, params);
      },
    );
  }

  @override
  FutureOr<List<SubtitleController>> provideSubtitles(
      PlayerLaunchParams params) async {
    List<SubtitleController> controllers = [];

    File videoFile = params.videoFile!;

    String srtPath = p.withoutExtension(videoFile.path) + ".srt";
    String assPath = p.withoutExtension(videoFile.path) + ".ass";

    File srtFile = File(srtPath);
    File assFile = File(assPath);

    // First priority is an existing SRT file.
    if (srtFile.existsSync()) {
      SubtitleController controller = SubtitleController(
        provider: SubtitleProvider.fromString(
          data: srtFile.readAsStringSync(),
          type: SubtitleType.srt,
        ),
      );
      controllers.add(controller);
    }
    if (assFile.existsSync()) {
      SubtitleController controller = SubtitleController(
        provider: SubtitleProvider.fromString(
          data: await convertAssSubtitles(assFile.path),
          type: SubtitleType.srt,
        ),
      );
      controllers.add(controller);
    }

    return controllers;
  }

  Future<void> generateThumbnail(String inputPath, String targetPath) async {
    String timestamp = getTimestampFromDuration(const Duration(seconds: 5));

    String command =
        "-ss $timestamp -y -i \"$inputPath\" -frames:v 1 -q:v 2 \"$targetPath\"";

    await FFmpegKit.executeAsync(command, (session) async {});
  }

  Future<String> convertAssSubtitles(String inputPath) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory subsDir = Directory(appDocDir.path + "/subtitles");
    if (!subsDir.existsSync()) {
      subsDir.createSync(recursive: true);
    }

    String targetPath = "${subsDir.path}/assSubtitles.srt";
    File targetFile = File(targetPath);

    String command = "-i \"$inputPath\" \"$targetPath\"";

    await FFmpegKit.executeAsync(command, (session) async {
      debugPrint(await session.getOutput());
    });

    return sanitizeSubtitleArtifacts(targetFile.readAsStringSync());
  }

  String sanitizeSubtitleArtifacts(String unsanitizedContent) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    String sanitizedContent = unsanitizedContent.replaceAll(exp, '');
    sanitizedContent = sanitizedContent.replaceAll(
        RegExp(r'{(.*?)}', caseSensitive: false), '');

    sanitizedContent = sanitizedContent.replaceAll("<br>", "\n");
    sanitizedContent = sanitizedContent.replaceAll('&amp;', '&');
    sanitizedContent = sanitizedContent.replaceAll('&apos;', '\'');
    sanitizedContent = sanitizedContent.replaceAll('&#39;', '\'');
    sanitizedContent = sanitizedContent.replaceAll('&quot;', '\"');
    sanitizedContent = sanitizedContent.replaceAll('&amp;', '');
    sanitizedContent = sanitizedContent.replaceAll('\r', '\n');
    sanitizedContent = sanitizedContent.replaceAll('\\n', '\n');
    sanitizedContent = sanitizedContent.replaceAll('​', '');

    return sanitizedContent;
  }

  @override
  Future<ImageProvider> getThumbnail(MediaHistoryItem item) async {
    return FileImage(File(item.thumbnailPath));
  }

  @override
  String getCaption(MediaHistoryItem item) {
    return item.name;
  }

  @override
  String getSubcaption(MediaHistoryItem item) {
    return item.key;
  }
}

import 'dart:io';

import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/return_from_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uri_to_file/uri_to_file.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> textShareIntentAction(BuildContext context, String text) async {
  AppModel appModel = Provider.of<AppModel>(context, listen: false);
  appModel.killOnExit = true;

  // If a context link, let the other case handle this.
  if (text.startsWith('https://jidoujisho.context/')) {
    await returnFromAppLink(context, text);

    return;
  }

  // If a valid video ID or YouTube URL, play the video.
  String? videoId = VideoId.parseVideoId(text);
  if (videoId != null) {
    PlayerMediaSource source = appModel.getMediaSourceFromName(
        MediaType.player, 'YouTube') as PlayerMediaSource;
    YoutubeExplode yt = YoutubeExplode();
    Video video = await yt.videos.get(videoId);
    MediaHistoryItem item = MediaHistoryItem(
      key: video.url,
      title: video.title,
      author: video.author,
      sourceName: source.sourceName,
      mediaTypePrefs: source.mediaType.prefsDirectory(),
      currentProgress: 0,
      completeProgress: video.duration?.inSeconds ?? 0,
      extra: {'thumbnail': video.thumbnails.mediumResUrl},
    );
    await returnFromContext(context, item);
  } else if (text.startsWith('http://') || text.startsWith('https://')) {
    PlayerMediaSource source = appModel.getMediaSourceFromName(
        MediaType.player, 'Network Stream') as PlayerMediaSource;
    MediaHistoryItem item = MediaHistoryItem(
      key: text,
      title: '',
      author: '',
      sourceName: source.sourceName,
      mediaTypePrefs: source.mediaType.prefsDirectory(),
      currentProgress: 0,
      completeProgress: 0,
      extra: {},
    );
    await returnFromContext(context, item);
  } else if (text.startsWith('content://') || (File(text).existsSync())) {
    try {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => Container(
            color: Colors.black,
            child: Center(
              child: SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation(Theme.of(context).focusColor),
                ),
              ),
            ),
          ),
        ),
      );

      File file = await toFile(text);

      PlayerMediaSource source = appModel.getMediaSourceFromName(
          MediaType.player, 'Local Media') as PlayerMediaSource;
      MediaHistoryItem item = MediaHistoryItem(
        key: file.path,
        title: '',
        author: '',
        sourceName: source.sourceName,
        mediaTypePrefs: source.mediaType.prefsDirectory(),
        currentProgress: 0,
        completeProgress: 0,
        extra: {},
      );

      PlayerLaunchParams params = PlayerLaunchParams.file(
        appModel: appModel,
        videoFile: File(item.key),
        mediaSource: source,
        mediaHistoryItem: item,
        saveHistoryItem: false,
      );
      source.launchMediaPage(context, params, pushReplacement: true);
    } catch (e) {
      debugPrint('$e');
    }
  } else {
    await navigateToCreator(
      context: context,
      appModel: appModel,
      initialParams: AnkiExportParams(sentence: text),
      popOnExport: true,
    );
    await SystemNavigator.pop();
  }
}

import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/return_from_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> textShareIntentAction(BuildContext context, String text) async {
  AppModel appModel = Provider.of<AppModel>(context, listen: false);

  // If a context link, let the other case handle this.
  if (text.startsWith("https://jidoujisho.context/")) {
    await returnFromAppLink(context, text);
    await SystemNavigator.pop();
    return;
  }
  // If a valid video ID or YouTube URL, play the video.
  String? videoId = VideoId.parseVideoId(text);
  if (videoId != null) {
    PlayerMediaSource source = appModel.getMediaSourceFromName(
        MediaType.player, "YouTube") as PlayerMediaSource;
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
      extra: {"thumbnail": video.thumbnails.mediumResUrl},
    );
    await returnFromContext(context, item);
    await SystemNavigator.pop();
  } else if (text.startsWith("http://") || text.startsWith("https://")) {
    PlayerMediaSource source = appModel.getMediaSourceFromName(
        MediaType.player, "Network Stream") as PlayerMediaSource;
    MediaHistoryItem item = MediaHistoryItem(
      key: text,
      title: "",
      author: "",
      sourceName: source.sourceName,
      mediaTypePrefs: source.mediaType.prefsDirectory(),
      currentProgress: 0,
      completeProgress: 0,
      extra: {},
    );
    await returnFromContext(context, item);
    await SystemNavigator.pop();
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

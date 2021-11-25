import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_sources/reader_media_source.dart';
import 'package:chisa/media/media_sources/viewer_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> returnFromContext(
    BuildContext context, MediaHistoryItem item) async {
  AppModel appModel = Provider.of<AppModel>(context, listen: false);

  MediaType mediaType = MediaType.values
      .firstWhere((type) => type.prefsDirectory() == item.mediaTypePrefs);
  switch (mediaType) {
    case MediaType.player:
      PlayerMediaSource source = appModel.getMediaSourceFromName(
          mediaType, item.sourceName) as PlayerMediaSource;
      await source.launchMediaPage(
          context, source.getLaunchParams(appModel, item));
      break;
    case MediaType.reader:
      ReaderMediaSource source = appModel.getMediaSourceFromName(
          mediaType, item.sourceName) as ReaderMediaSource;
      await source.launchMediaPage(
          context, source.getLaunchParams(appModel, item));
      break;
    case MediaType.viewer:
      ViewerMediaSource source = appModel.getMediaSourceFromName(
          mediaType, item.sourceName) as ViewerMediaSource;
      await source.launchMediaPage(
        context,
        ViewerLaunchParams(
          mediaHistoryItem: item,
          appModel: appModel,
          chapters: await source.getCachedChapters(item),
          mediaSource: source,
        ),
      );
      break;
    default:
      throw UnimplementedError();
  }
}

Future<void> returnFromAppLink(BuildContext context, String link) async {
  String encodedJson = link.replaceFirst("https://jidoujisho.context/", "");
  String mediaHistoryJson = Uri.decodeFull(encodedJson);

  MediaHistoryItem item = MediaHistoryItem.fromJson(mediaHistoryJson);
  await returnFromContext(context, item);
}

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> returnFromContext(
    BuildContext context, MediaHistoryItem item) async {
  AppModel appModel = Provider.of<AppModel>(context);

  MediaType mediaType = MediaType.values
      .firstWhere((type) => type.prefsDirectory() == item.mediaTypePrefs);
  switch (mediaType) {
    case MediaType.player:
      PlayerMediaSource source = appModel.getMediaSourceFromName(
          mediaType, item.sourceName) as PlayerMediaSource;
      await source.launchMediaPage(
          context, source.getLaunchParams(appModel, item));
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

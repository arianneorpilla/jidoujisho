import 'dart:async';

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/player_page.dart';
import 'package:chisa/util/subtitle_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlayerNetworkStreamSource extends PlayerMediaSource {
  PlayerNetworkStreamSource()
      : super(
          sourceName: 'Network Stream',
          icon: Icons.podcasts,
        );

  @override
  PlayerLaunchParams getLaunchParams(AppModel appModel, MediaHistoryItem item) {
    return PlayerLaunchParams.network(
      appModel: appModel,
      networkPath: item.key,
      mediaSource: this,
      mediaHistoryItem: item,
      saveHistoryItem: false,
    );
  }

  MediaHistoryItem getItemFromUrl(Video video) {
    return MediaHistoryItem(
      key: video.url,
      title: video.title,
      author: video.author,
      sourceName: sourceName,
      mediaTypePrefs: mediaType.prefsDirectory(),
      currentProgress: 0,
      completeProgress: video.duration?.inSeconds ?? 0,
      extra: {},
    );
  }

  @override
  FutureOr<String> getNetworkStreamUrl(PlayerLaunchParams params) async {
    String url = params.mediaHistoryItem.key;
    return url;
  }

  @override
  FutureOr<String?> getAudioStreamUrl(PlayerLaunchParams params) async {
    return null;
  }

  @override
  String getHistoryCaption(MediaHistoryItem item) {
    return item.title;
  }

  @override
  String getHistorySubcaption(MediaHistoryItem item) {
    return item.key;
  }

  @override
  ImageProvider<Object> getHistoryThumbnail(MediaHistoryItem item) {
    String thumbnailUrl = item.extra['thumbnail']!;
    return NetworkImage(thumbnailUrl);
  }

  @override
  FutureOr<List<MediaHistoryItem>?> getSearchMediaHistoryItems({
    required BuildContext context,
    required String searchTerm,
    required int pageKey,
  }) async {
    return null;
  }

  @override
  Future<List<String>> generateSearchSuggestions(String searchTerm) async {
    return [];
  }

  @override
  int get getSearchDebounceDelay => 0;

  @override
  FutureOr<List<SubtitleItem>> provideSubtitles(
      PlayerLaunchParams params) async {
    return [];
  }

  @override
  List<Widget> getSearchBarActions(
    BuildContext context,
    Function() refreshCallback,
  ) {
    return [];
  }

  @override
  Widget? buildSourceButton(BuildContext context, PlayerPageState page) {
    return null;
  }

  @override
  bool get isDirectTextEntry => true;

  @override
  Future<void> onDirectTextEntrySubmit(
    BuildContext context,
    String query,
  ) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);
    MediaHistoryItem item = MediaHistoryItem(
      key: query,
      title: '',
      author: '',
      sourceName: sourceName,
      mediaTypePrefs: mediaType.prefsDirectory(),
      currentProgress: 0,
      completeProgress: 0,
      extra: {},
    );

    await launchMediaPage(context, getLaunchParams(appModel, item));
  }
}

import 'dart:async';
import 'dart:io';

import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/player_page.dart';
import 'package:chisa/util/media_type_button.dart';
import 'package:chisa/util/subtitle_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlayerYouTubeSource extends PlayerMediaSource {
  PlayerYouTubeSource()
      : super(
          sourceName: "YouTube",
          icon: Icons.smart_display,
          searchSupport: true,
          searchLabel: "YouTube",
          searchAction: searchYouTube,
        );

  static YoutubeExplode yt = YoutubeExplode();

  static Future<void> searchYouTube(
    String searchTerm,
    BuildContext context,
  ) async {
    if (searchTerm.trim().isEmpty) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => buildTrendingVideos(searchTerm, context),
      ),
    );
  }

  static Widget buildTrendingVideos(String searchTerm, BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          searchTerm,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Container(color: Colors.red),
    );
  }

  @override
  PlayerLaunchParams getLaunchParams(MediaHistoryItem item) {
    return PlayerLaunchParams.network(
      networkPath: item.key,
      mediaSource: this,
      mediaHistoryItem: item,
      saveHistoryItem: true,
    );
  }

  @override
  Widget? getButton(BuildContext context, Function() refreshCallback) {
    AppModel appModel = Provider.of<AppModel>(context);

    return MediaTypeButton(
      label: appModel.translate("youtube_trending"),
      icon: Icons.whatshot,
      onTap: () async {
        await showTrendingVideos();
        refreshCallback();
      },
    );
  }

  Future<void> showTrendingVideos() async {}

  @override
  FutureOr<List<SubtitleItem>> provideSubtitles(
      PlayerLaunchParams params) async {
    return [];
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

  @override
  Widget? buildSourceButton(BuildContext context, PlayerPageState page) {
    return null;
  }

  @override
  FutureOr<String> getNetworkStreamUrl(PlayerLaunchParams params) {
    // TODO: implement getNetworkStreamUrl
    throw UnimplementedError();
  }
}

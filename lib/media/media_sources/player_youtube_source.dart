import 'dart:async';

import 'package:chisa/language/language.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/player_page.dart';
import 'package:chisa/util/media_source_action_button.dart';
import 'package:chisa/util/subtitle_utils.dart';
import 'package:chisa/util/youtube_subtitles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subtitle/subtitle.dart';
import 'package:xml2json/xml2json.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

enum YouTubeVideoQuality {
  sd_144,
  sd_240,
  sd_360,
  sd_480,
  sd_720,
  hd_1080,
  hd_1440,
  hd_2160,
}

class PlayerYouTubeSource extends PlayerMediaSource {
  PlayerYouTubeSource()
      : super(
          sourceName: "YouTube",
          icon: Icons.smart_display,
        );

  static YoutubeExplode yt = YoutubeExplode();

  Map<String, Video> videoStore = {};
  Map<String, StreamManifest> manifestStore = {};
  SharedPreferences? sharedPreferences;

  @override
  PlayerLaunchParams getLaunchParams(AppModel appModel, MediaHistoryItem item) {
    return PlayerLaunchParams.network(
      appModel: appModel,
      networkPath: item.key,
      mediaSource: this,
      mediaHistoryItem: item,
      saveHistoryItem: true,
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
  Widget? buildSourceButton(BuildContext context, PlayerPageState page) {
    return null;
  }

  @override
  FutureOr<String> getNetworkStreamUrl(PlayerLaunchParams params) async {
    String url = params.mediaHistoryItem.key;
    Video video = await yt.videos.get(url);
    StreamManifest manifest =
        await yt.videos.streamsClient.getManifest(video.id);
    manifestStore[url] = manifest;

    sharedPreferences ??= await SharedPreferences.getInstance();
    int lastPreferredQuality =
        sharedPreferences!.getInt("lastPreferredQuality") ??
            YouTubeVideoQuality.sd_480.index;

    return manifest.muxed.withHighestBitrate().url.toString();
  }

  @override
  String getHistoryCaption(MediaHistoryItem item) {
    return item.title;
  }

  @override
  String getHistorySubcaption(MediaHistoryItem item) {
    return item.author;
  }

  @override
  Future<ImageProvider<Object>> getHistoryThumbnail(
      MediaHistoryItem item) async {
    if (videoStore[item.key] == null) {
      Video video = await yt.videos.get(item.key);
      videoStore[item.key] = video;
    }

    Video video = videoStore[item.key]!;
    String thumbnailUrl = video.thumbnails.mediumResUrl;
    return NetworkImage(thumbnailUrl);
  }

  @override
  FutureOr<List<MediaHistoryItem>>? getSearchMediaHistoryItems(
      String searchTerm) async {
    SearchList searchResults = await yt.search.getVideos(searchTerm);

    List<MediaHistoryItem> items = [];
    List<Video> videos = [];

    for (Video video in searchResults) {
      videos.add(video);
      videoStore[video.url] = video;
      items.add(getItemFromUrl(video));
    }

    return items;
  }

  @override
  List<MediaSourceActionButton> getSearchBarActions(
      BuildContext context, Function() refreshCallback) {
    return [];
  }

  @override
  Future<List<String>> generateSearchSuggestions(String searchTerm) {
    return yt.search.getQuerySuggestions(searchTerm);
  }

  @override
  int get getSearchDebounceDelay => 0;

  @override
  FutureOr<List<SubtitleItem>> provideSubtitles(
      PlayerLaunchParams params) async {
    String videoId = VideoId.fromString(params.mediaHistoryItem.key).toString();
    ClosedCaptionManifest manifest =
        await yt.videos.closedCaptions.getManifest(videoId);

    List<String> languageCodes = [];
    List<Future<String>> futures = [];

    for (ClosedCaptionTrackInfo trackInfo in manifest.tracks) {
      String languageCode = trackInfo.language.code;
      languageCodes.add(languageCode);
    }

    languageCodes = languageCodes.toSet().toList();

    for (int i = 0; i < languageCodes.length; i++) {
      String languageCode = languageCodes[i];
      futures.add(http.read(Uri.parse(
          "https://www.youtube.com/api/timedtext?lang=$languageCode&v=$videoId")));
    }

    List<SubtitleItem> items = [];
    List<String> xmls = await Future.wait(futures);
    for (int i = 0; i < languageCodes.length; i++) {
      String languageCode = languageCodes[i];

      try {
        String srt = timedTextToSRT(xmls[i]);
        String sanitizedSrt = sanitizeSubtitleArtifacts(srt);
        items.add(
          SubtitleItem(
            controller: SubtitleController(
              provider: SubtitleProvider.fromString(
                data: sanitizedSrt,
                type: SubtitleType.srt,
              ),
            ),
            metadata: "YouTube - [$languageCode]",
            type: SubtitleItemType.webSubtitle,
          ),
        );
      } catch (e) {
        debugPrint(
            "$languageCode failed to convert from xml to srt for $videoId");
      }
    }

    SubtitleItem priorityItem;
    int priorityIndex = languageCodes
        .indexOf(params.appModel.getCurrentLanguage().languageCode);

    if (priorityIndex != -1) {
      priorityItem = items[priorityIndex];
      items.remove(priorityItem);
      List<SubtitleItem> newItems = [];
      newItems.add(priorityItem);
      newItems.addAll(items);
      items = newItems;
    }

    return items;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path/path.dart' as path;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/util.dart';
import 'package:jidoujisho/youtube.dart';

List<String> getChannelList() {
  String prefsChannels = gSharedPrefs.getString('subscribedChannels') ?? '[]';
  List<String> channelIDs =
      (jsonDecode(prefsChannels) as List<dynamic>).cast<String>();

  return channelIDs;
}

Future<void> addNewChannel(String videoURL) async {
  YoutubeExplode yt = YoutubeExplode();

  String channelID = (await yt.channels.getByVideo(videoURL)).id.value;
  String prefsChannels = gSharedPrefs.getString('subscribedChannels') ?? '[]';
  List<String> channelIDs =
      (jsonDecode(prefsChannels) as List<dynamic>).cast<String>();

  gChannelCache = AsyncMemoizer();
  setChannelCache([]);
  if (!channelIDs.contains(channelID)) {
    channelIDs.add(channelID);
  }

  await gSharedPrefs.setString('subscribedChannels', jsonEncode(channelIDs));
}

Future<void> addNewChannelFromID(String channelID) async {
  String prefsChannels = gSharedPrefs.getString('subscribedChannels') ?? '[]';
  List<String> channelIDs =
      (jsonDecode(prefsChannels) as List<dynamic>).cast<String>();

  gChannelCache = AsyncMemoizer();
  setChannelCache([]);
  if (!channelIDs.contains(channelID)) {
    channelIDs.add(channelID);
  }

  await gSharedPrefs.setString('subscribedChannels', jsonEncode(channelIDs));
}

Future<void> removeChannel(String channelID) async {
  String prefsChannels = gSharedPrefs.getString('subscribedChannels') ?? '[]';
  List<String> channelIDs =
      (jsonDecode(prefsChannels) as List<dynamic>).cast<String>();

  gChannelCache = AsyncMemoizer();
  setChannelCache([]);
  channelIDs.remove(channelID);
  await gSharedPrefs.setString('subscribedChannels', jsonEncode(channelIDs));
}

Future<void> setChannelList(List<String> channelIDs) async {
  await gSharedPrefs.setString('subscribedChannels', jsonEncode(channelIDs));
}

bool isChannelInList(String channelID) {
  return getChannelList().contains(channelID);
}

Map<String, dynamic> channelToMap(Channel channel) {
  return {
    "id": channel.id.value,
    "title": channel.title,
    "logoUrl": channel.logoUrl,
  };
}

Channel mapToChannel(Map<String, dynamic> map) {
  ChannelId id = ChannelId.fromString(map['id']);
  String title = map['title'];
  String logoUrl = map['logoUrl'];

  return Channel(id, title, logoUrl);
}

Future<void> setChannelCache(List<Channel> channels) async {
  List<Map<String, dynamic>> maps = [];
  channels.forEach((channel) {
    maps.add(channelToMap(channel));
  });

  await gSharedPrefs.setString('channelCache', jsonEncode(maps));
}

List<Channel> getChannelCache() {
  String prefsChannelCache = gSharedPrefs.getString('channelCache') ?? '[]';
  List<dynamic> maps = (jsonDecode(prefsChannelCache) as List<dynamic>);

  List<Channel> channels = [];
  maps.forEach((map) {
    Channel channel = mapToChannel(map);
    channels.add(channel);
  });

  return channels;
}

Future<void> setTrendingChannelCache(List<Channel> channels) async {
  List<Map<String, dynamic>> maps = [];
  channels.forEach((channel) {
    maps.add(channelToMap(channel));
  });

  await gSharedPrefs.setString('trendingChannelCache', jsonEncode(maps));
}

List<Channel> getTrendingChannelCache() {
  String prefsChannelCache =
      gSharedPrefs.getString('trendingChannelCache') ?? '[]';
  List<dynamic> maps = (jsonDecode(prefsChannelCache) as List<dynamic>);

  List<Channel> channels = [];
  maps.forEach((map) {
    Channel channel = mapToChannel(map);
    channels.add(channel);
  });

  return channels;
}

Map<String, dynamic> videoToMap(Video video) {
  return {
    "id": video.id.toString() ?? "",
    "title": video.title ?? "",
    "author": video.author ?? "",
    "channelId": video.channelId.toString() ?? "",
    "description": video.description ?? "",
    "duration": video.duration.inMilliseconds ?? 0,
    "thumbnails": video.thumbnails.mediumResUrl,
  };
}

Video mapToVideo(Map<String, dynamic> map) {
  VideoId id = VideoId.fromString(map['id']);
  String title = map['title'];
  String author = map['author'];
  ChannelId channelId = ChannelId.fromString(map['channelId']);
  DateTime uploadDate = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime publishDate = DateTime.fromMillisecondsSinceEpoch(0);
  String description = map['description'];
  Duration duration = Duration(milliseconds: map['duration']);
  ThumbnailSet thumbnails = ThumbnailSet(map['id']);

  return Video(
    id,
    title,
    author,
    channelId,
    uploadDate,
    publishDate,
    description,
    duration,
    thumbnails,
    [],
    Engagement(0, 0, 0),
    false,
  );
}

Future<void> setTrendingVideosCache(List<Video> videos) async {
  List<Map<String, dynamic>> maps = [];
  videos.forEach((video) {
    maps.add(videoToMap(video));
  });

  await gSharedPrefs.setString('trendingVideosCache', jsonEncode(maps));
}

List<Video> getTrendingVideosCache() {
  String prefsChannelCache =
      gSharedPrefs.getString('trendingVideosCache') ?? '[]';
  List<dynamic> maps = (jsonDecode(prefsChannelCache) as List<dynamic>);

  List<Video> videos = [];
  maps.forEach((map) {
    Video video = mapToVideo(map);
    videos.add(video);
  });

  return videos;
}

List<String> getSearchHistory() {
  String prefsHistory = gSharedPrefs.getString('searchHistory') ?? '[]';
  List<String> history =
      (jsonDecode(prefsHistory) as List<dynamic>).cast<String>();

  return history;
}

Future<void> addSearchHistory(String term) async {
  List<String> history = getSearchHistory();

  if (history.contains(term.trim())) {
    history.remove(term.trim());
  }
  if (term.trim() != "") {
    history.add(term.trim());
  }

  if (history.length >= 14) {
    history = history.sublist(history.length - 14);
  }

  await gSharedPrefs.setString('searchHistory', jsonEncode(history));
}

Future<void> removeSearchHistory(String term) async {
  List<String> history = getSearchHistory();

  history.remove(term);
  await gSharedPrefs.setString('searchHistory', jsonEncode(history));
}

Future<void> setAnkiDroidDirectory(Directory directory) async {
  await gSharedPrefs.setString('ankiDroidDirectory', directory.path);
}

Directory getAnkiDroidDirectory() {
  String directoryPath = gSharedPrefs.getString('ankiDroidDirectory') ??
      'storage/emulated/0/AnkiDroid';
  Directory directory = Directory(directoryPath);

  return directory;
}

Future<void> setTermBankDirectory(Directory directory) async {
  await gSharedPrefs.setString('termBankDirectory', directory.path);
}

Directory getTermBankDirectory() {
  String directoryPath = gSharedPrefs.getString('termBankDirectory') ??
      'storage/emulated/0/jidoujisho';
  Directory directory = Directory(directoryPath);

  return directory;
}

Future<void> setLastDeck(String selectedDeck) async {
  await gSharedPrefs.setString("lastDeck", selectedDeck);
}

String getLastDeck() {
  String lastDeck = gSharedPrefs.getString('lastDeck') ?? 'Default';

  return lastDeck;
}

Future<void> setPreferredQuality(int preferredQualityIndex) async {
  await gSharedPrefs.setInt("preferredQuality", preferredQualityIndex);
}

int getPreferredQuality() {
  return gSharedPrefs.getInt("preferredQuality") ?? 0;
}

Future<void> setLastMenuSeen(int lastMenuSeen) async {
  await gSharedPrefs.setInt("lastMenuSeen", lastMenuSeen);
}

int getLastMenuSeen() {
  return gSharedPrefs.getInt("lastMenuSeen") ?? 0;
}

Future<void> setTrendingExpiration() async {
  await gSharedPrefs.setInt(
      "trendingExpiration",
      DateTime.now().millisecondsSinceEpoch +
          Duration(hours: 3).inMilliseconds);
}

int getTrendingExpiration() {
  return gSharedPrefs.getInt("trendingExpiration") ?? 0;
}

bool isTrendingExpired() {
  return getTrendingExpiration() < DateTime.now().millisecondsSinceEpoch;
}

Future<void> toggleSelectMode() async {
  await gSharedPrefs.setBool("selectMode", !getSelectMode());
}

bool getSelectMode() {
  if (!gIsTapToSelectSupported) {
    return true;
  }

  return gSharedPrefs.getBool("selectMode") ?? false;
}

Future<void> useMonolingual() async {
  await setCurrentDictionary('Sora Dictionary API');
}

Future<void> useBilingual() async {
  await setCurrentDictionary('Jisho.org API');
}

Future<void> toggleFocusMode() async {
  await gSharedPrefs.setBool("focusMode", !getFocusMode());
}

bool getFocusMode() {
  return gSharedPrefs.getBool("focusMode") ?? false;
}

Future<void> toggleLatinFilterMode() async {
  await gSharedPrefs.setBool("latinFilterMode", !getLatinFilterMode());
}

bool getLatinFilterMode() {
  return gSharedPrefs.getBool("latinFilterMode") ?? false;
}

bool getLastSetMediaType() {
  return gSharedPrefs.getBool("lastSetMediaType") ?? false;
}

Future setLastSetVideo() async {
  await gSharedPrefs.setBool("lastSetMediaType", false);
}

Future setLastSetBook() async {
  await gSharedPrefs.setBool("lastSetMediaType", true);
}

bool isLastSetBook() {
  return (getLastSetMediaType() == true);
}

bool isLastSetVideo() {
  return (getLastSetMediaType() == false);
}

Future<void> toggleListeningComprehensionMode() async {
  await gSharedPrefs.setBool(
      "listeningComprehensionMode", !getListeningComprehensionMode());
}

bool getListeningComprehensionMode() {
  return gSharedPrefs.getBool("listeningComprehensionMode") ?? false;
}

bool getResumeAvailable() {
  String lastPlayedPath = getLastPlayedPath();
  return lastPlayedPath != "-1";
}

String getLastPlayedPath() {
  return gSharedPrefs.getString("lastPlayedPath") ??
      getVideoHistoryPosition().last.url;
}

int getLastPlayedPosition() {
  return gSharedPrefs.getInt("lastPlayedPosition") ??
      getVideoHistoryPosition().last.position;
}

Future<void> setScopedStorageDontShow() async {
  await gSharedPrefs.setBool("scopedStorageDontShow", true);
}

bool getScopedStorageDontShow() {
  return gSharedPrefs.getBool("scopedStorageDontShow") ?? false;
}

Future<void> setAudioAllowance(int ms) async {
  await gSharedPrefs.setInt("audioAllowance", ms);
}

int getAudioAllowance() {
  return gSharedPrefs.getInt("audioAllowance") ?? 0;
}

Future<void> setFontSize(double px) async {
  await gSharedPrefs.setDouble("fontSize", px);
}

double getFontSize() {
  return gSharedPrefs.getDouble("fontSize") ?? 24;
}

Future<void> setSubtitleDelay(int ms) async {
  await gSharedPrefs.setInt("subtitleDelay", ms);
}

int getSubtitleDelay() {
  return gSharedPrefs.getInt("subtitleDelay") ?? 0;
}

Future<void> setHasClosedCaptions(String videoID, bool hasCaptions) async {
  await gSharedPrefs.setBool("hasCC_$videoID", hasCaptions);
}

bool getHasClosedCaptions(String videoID) {
  return gSharedPrefs.getBool("hasCC_$videoID");
}

void maintainTrendingCache() {
  if (isTrendingExpired()) {
    setTrendingVideosCache([]);
    setTrendingChannelCache([]);
    print("INVALIDATING TRENDING CACHE");
  }
}

void maintainClosedCaptions() {
  if (gSharedPrefs.getKeys().length < 5100) {
    return;
  }

  int ccCount = 0;
  gSharedPrefs.getKeys().forEach((key) {
    if (key.startsWith("hasCC")) {
      ccCount += 1;
    }
  });

  if (ccCount > 5000) {
    gSharedPrefs.getKeys().forEach((key) {
      if (key.startsWith("hasCC")) {
        gSharedPrefs.remove(key);
      }
    });
  }
}

BlurWidgetOptions getBlurWidgetOptions() {
  double width = gSharedPrefs.getDouble("blurWidgetWidth") ?? 200;
  double height = gSharedPrefs.getDouble("blurWidgetHeight") ?? 200;
  double left = gSharedPrefs.getDouble("blurWidgetLeft") ?? -1;
  double top = gSharedPrefs.getDouble("blurWidthTop") ?? -1;

  int colorRed =
      gSharedPrefs.getInt("blurWidgetRed") ?? Colors.black.withOpacity(0.5).red;
  int colorGreen = gSharedPrefs.getInt("blurWidgetGreen") ??
      Colors.black.withOpacity(0.5).green;
  int colorBlue = gSharedPrefs.getInt("blurWidgetBlue") ??
      Colors.black.withOpacity(0.5).blue;
  double colorOpacity = gSharedPrefs.getDouble("blurWidgetOpacity") ??
      Colors.black.withOpacity(0.5).opacity;

  Color color = Color.fromRGBO(colorRed, colorGreen, colorBlue, colorOpacity);

  double blurRadius = gSharedPrefs.getDouble("blurWidgetBlurRadius") ?? 5;
  bool visible = gSharedPrefs.getBool("blurWidgetVisible") ?? false;

  return BlurWidgetOptions(
      width, height, left, top, color, blurRadius, visible);
}

Future setBlurWidgetOptions(BlurWidgetOptions blurWidgetOptions) async {
  await gSharedPrefs.setDouble("blurWidgetWidth", blurWidgetOptions.width);
  await gSharedPrefs.setDouble("blurWidgetHeight", blurWidgetOptions.height);
  await gSharedPrefs.setDouble("blurWidgetLeft", blurWidgetOptions.left);
  await gSharedPrefs.setDouble("blurWidthTop", blurWidgetOptions.top);

  await gSharedPrefs.setInt("blurWidgetRed", blurWidgetOptions.color.red);
  await gSharedPrefs.setInt("blurWidgetGreen", blurWidgetOptions.color.green);
  await gSharedPrefs.setInt("blurWidgetBlue", blurWidgetOptions.color.blue);
  await gSharedPrefs.setDouble(
      "blurWidgetOpacity", blurWidgetOptions.color.opacity);

  await gSharedPrefs.setDouble(
      "blurWidgetBlurRadius", blurWidgetOptions.blurRadius);
  await gSharedPrefs.setBool("blurWidgetVisible", blurWidgetOptions.visible);
}

List<HistoryItem> getVideoHistory() {
  String prefsVideoHistory =
      gSharedPrefs.getString('videoHistoryPrefs') ?? '[]';
  List<dynamic> history = (jsonDecode(prefsVideoHistory) as List<dynamic>);

  List<HistoryItem> histories = [];
  history.forEach((entry) {
    HistoryItem videoHistory = HistoryItem.fromMap(entry);
    histories.add(videoHistory);
  });

  return histories;
}

Future<void> setVideoHistory(List<HistoryItem> videoHistories) async {
  List<Map<String, dynamic>> maps = [];
  videoHistories.forEach((entry) {
    maps.add(entry.toMap());
  });

  await gSharedPrefs.setString('videoHistoryPrefs', jsonEncode(maps));
}

Future<void> addVideoHistory(HistoryItem videoHistory, bool addPosition) async {
  List<HistoryItem> videoHistories = getVideoHistory();

  if (videoHistory.thumbnail == null) {
    File videoFile = File(videoHistory.url);
    String photoFileNameDir = "$gAppDirPath/" +
        path.basenameWithoutExtension(videoFile.path) +
        ".jpg";
    File photoFile = File(photoFileNameDir);
    if (photoFile.existsSync()) {
      photoFile.deleteSync();
    }

    String formatted = getTimestampFromDuration(Duration(seconds: 5));

    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

    String inputPath = videoHistory.url;
    String exportPath = "\"$photoFileNameDir\"";

    String command =
        "-loglevel quiet -ss $formatted -y -i \"$inputPath\" -frames:v 1 -q:v 2 $exportPath";

    await _flutterFFmpeg.execute(command);

    videoHistory.thumbnail = photoFileNameDir;
  }

  videoHistories.removeWhere((entry) => entry.url == videoHistory.url);
  videoHistories.add(videoHistory);

  if (videoHistories.length >= 20) {
    videoHistories.sublist(0, videoHistories.length - 20).forEach((entry) {
      if (!entry.thumbnail.startsWith("http")) {
        File photoFile = File(entry.thumbnail);
        if (photoFile.existsSync()) {
          photoFile.deleteSync();
        }
      }
    });
    videoHistories = videoHistories.sublist(videoHistories.length - 20);
  }

  if (addPosition) {
    await addVideoHistoryPosition(
      HistoryItemPosition(
        videoHistory.url,
        0,
      ),
    );
  }

  await setVideoHistory(videoHistories);
}

Future<void> removeVideoHistory(HistoryItem videoHistory) async {
  List<HistoryItem> videoHistories = getVideoHistory();
  List<HistoryItemPosition> videoHistoryPositions = getVideoHistoryPosition();

  videoHistories.removeWhere((entry) => entry.url == videoHistory.url);
  videoHistoryPositions.removeWhere((entry) => entry.url == videoHistory.url);
  if (!videoHistory.thumbnail.startsWith("http")) {
    File photoFile = File(videoHistory.thumbnail);
    if (photoFile.existsSync()) {
      photoFile.deleteSync();
    }
  }

  await setVideoHistory(videoHistories);
  await setVideoHistoryPosition(videoHistoryPositions);
}

List<HistoryItemPosition> getVideoHistoryPosition() {
  String prefsVideoHistory =
      gSharedPrefs.getString('videoHistoryPositionPrefs') ?? '[]';
  List<dynamic> history = (jsonDecode(prefsVideoHistory) as List<dynamic>);

  List<HistoryItemPosition> histories = [];
  history.forEach((entry) {
    HistoryItemPosition videoHistory = HistoryItemPosition.fromMap(entry);
    histories.add(videoHistory);
  });

  return histories;
}

Future<void> setVideoHistoryPosition(
    List<HistoryItemPosition> videoHistories) async {
  List<Map<String, dynamic>> maps = [];
  videoHistories.forEach((entry) {
    maps.add(entry.toMap());
  });

  await gSharedPrefs.setString('videoHistoryPositionPrefs', jsonEncode(maps));
}

Future<void> addVideoHistoryPosition(HistoryItemPosition videoHistory) async {
  List<HistoryItemPosition> videoHistories = getVideoHistoryPosition();

  videoHistories.removeWhere((entry) => entry.url == videoHistory.url);
  videoHistories.add(videoHistory);

  if (videoHistories.length >= 20) {
    videoHistories = videoHistories.sublist(videoHistories.length - 20);
  }

  await setVideoHistoryPosition(videoHistories);
}

Future<void> removeVideoHistoryPosition(
    HistoryItemPosition videoHistory) async {
  List<HistoryItemPosition> videoHistories = getVideoHistoryPosition();

  videoHistories.removeWhere((entry) => entry.url == videoHistory.url);
  await setVideoHistoryPosition(videoHistories);
}

List<DictionaryHistoryEntry> getDictionaryHistory() {
  String prefsDictionary =
      gSharedPrefs.getString('dictionaryEntriesYomi') ?? '[]';

  List<dynamic> history = (jsonDecode(prefsDictionary) as List<dynamic>);

  List<DictionaryHistoryEntry> entries = [];
  history.forEach((map) {
    DictionaryHistoryEntry entry = DictionaryHistoryEntry.fromMap(map);
    entries.add(entry);
  });

  return entries;
}

Future<void> setDictionaryHistory(
    List<DictionaryHistoryEntry> dictionaryEntries) async {
  List<Map<String, dynamic>> maps = [];
  dictionaryEntries.forEach((entry) {
    maps.add(entry.toMap());
  });

  await gSharedPrefs.setString('dictionaryEntriesYomi', jsonEncode(maps));
}

Future<void> addDictionaryEntryToHistory(
    DictionaryHistoryEntry dictionaryHistoryEntry) async {
  List<DictionaryHistoryEntry> dictionaryHistoryEntries =
      getDictionaryHistory();

  try {
    DictionaryHistoryEntry sameContext = dictionaryHistoryEntries.firstWhere(
      (entry) => entry == dictionaryHistoryEntry,
    );
    if (dictionaryHistoryEntries != null) {
      dictionaryHistoryEntry.contextDataSource = sameContext.contextDataSource;
      dictionaryHistoryEntry.contextPosition = sameContext.contextPosition;
    }
  } catch (e) {
    print(e);
  }

  dictionaryHistoryEntries
      .removeWhere((entry) => dictionaryHistoryEntry == entry);
  dictionaryHistoryEntries.add(dictionaryHistoryEntry);

  if (dictionaryHistoryEntries.length >= 50) {
    dictionaryHistoryEntries =
        dictionaryHistoryEntries.sublist(dictionaryHistoryEntries.length - 50);
  }

  await setDictionaryHistory(dictionaryHistoryEntries);
}

Future<void> updateDictionaryHistorySwipeIndex(
    DictionaryHistoryEntry toChange, int swipeIndex) async {
  List<DictionaryHistoryEntry> history = getDictionaryHistory();
  history.firstWhere((entry) => entry == toChange).swipeIndex = swipeIndex;

  setDictionaryHistory(history);
}

Future<void> removeDictionaryEntryFromHistory(
    DictionaryHistoryEntry dictionaryHistoryEntry) async {
  List<DictionaryHistoryEntry> dictionaryHistoryEntries =
      getDictionaryHistory();

  dictionaryHistoryEntries
      .removeWhere((entry) => dictionaryHistoryEntry == entry);

  await setDictionaryHistory(dictionaryHistoryEntries);
}

YouTubeQualityOption getPreferredYouTubeQuality(
    List<YouTubeQualityOption> qualities) {
  switch (getPreferredQuality()) {
    case 1:
      return qualities.first;
    case 2:
      return qualities.firstWhere((quality) => quality.muxed) ??
          qualities.first;
    case 3:
      return qualities.lastWhere((quality) => quality.muxed) ?? qualities.last;
    case 4:
      return qualities.last;
    default:
      String lastPlayedQuality = gSharedPrefs.getString("lastPlayedQuality");

      if (lastPlayedQuality != null) {
        for (YouTubeQualityOption quality in qualities) {
          // If we find the quality they last played, we return that.
          if (quality.videoResolution == lastPlayedQuality) {
            return quality;
          }
        }
        // In this case, we know that they have set a quality that doesn't exist,
        // maybe it's a low quality video -- so we take the best quality.
        return qualities.lastWhere((element) => element.muxed) ??
            qualities.last;
      } else {
        // We don't know if we could abuse their mobile data,
        // let's try the average.
        return qualities.firstWhere((element) =>
                element.videoResolution == "360p" || element.muxed) ??
            qualities.first;
      }
  }
}

List<HistoryItem> getBookHistory() {
  String prefsBookHistory = gSharedPrefs.getString('bookHistoryPrefs') ?? '[]';
  List<dynamic> history = (jsonDecode(prefsBookHistory) as List<dynamic>);

  List<HistoryItem> histories = [];
  history.forEach((entry) {
    HistoryItem bookHistory = HistoryItem.fromMap(entry);
    histories.add(bookHistory);
  });

  return histories;
}

Future<void> setBookHistory(List<HistoryItem> bookHistories) async {
  List<Map<String, dynamic>> maps = [];
  bookHistories.forEach((entry) {
    maps.add(entry.toMap());
  });

  await gSharedPrefs.setString('bookHistoryPrefs', jsonEncode(maps));
}

Future<void> addBookHistory(HistoryItem bookHistory) async {
  List<HistoryItem> bookHistories = getBookHistory();

  if (bookHistory.thumbnail == null) {
    File bookFile = File(bookHistory.url);
    String photoFileNameDir =
        "$gAppDirPath/" + path.basenameWithoutExtension(bookFile.path) + ".jpg";
    File photoFile = File(photoFileNameDir);
    if (photoFile.existsSync()) {
      photoFile.deleteSync();
    }

    String formatted = getTimestampFromDuration(Duration(seconds: 5));

    final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

    String inputPath = bookHistory.url;
    String exportPath = "\"$photoFileNameDir\"";

    String command =
        "-loglevel quiet -ss $formatted -y -i \"$inputPath\" -frames:v 1 -q:v 2 $exportPath";

    await _flutterFFmpeg.execute(command);

    bookHistory.thumbnail = photoFileNameDir;
  }

  bookHistories.removeWhere((entry) => entry.url == bookHistory.url);
  bookHistories.add(bookHistory);

  if (bookHistories.length >= 20) {
    bookHistories.sublist(0, bookHistories.length - 20).forEach((entry) {
      if (!entry.thumbnail.startsWith("http")) {
        File photoFile = File(entry.thumbnail);
        if (photoFile.existsSync()) {
          photoFile.deleteSync();
        }
      }
    });
    bookHistories = bookHistories.sublist(bookHistories.length - 20);
  }

  await setBookHistory(bookHistories);
}

Future<void> removeBookHistory(HistoryItem bookHistory) async {
  List<HistoryItem> bookHistories = getBookHistory();
  List<HistoryItemPosition> bookHistoryPositions = getBookHistoryPosition();

  bookHistories.removeWhere((entry) => entry.url == bookHistory.url);
  bookHistoryPositions.removeWhere((entry) => entry.url == bookHistory.url);
  if (!bookHistory.thumbnail.startsWith("http")) {
    File photoFile = File(bookHistory.thumbnail);
    if (photoFile.existsSync()) {
      photoFile.deleteSync();
    }
  }

  await setBookHistory(bookHistories);
  await setBookHistoryPosition(bookHistoryPositions);
}

List<HistoryItemPosition> getBookHistoryPosition() {
  String prefsBookHistory =
      gSharedPrefs.getString('bookHistoryPositionPrefs') ?? '[]';
  List<dynamic> history = (jsonDecode(prefsBookHistory) as List<dynamic>);

  List<HistoryItemPosition> histories = [];
  history.forEach((entry) {
    HistoryItemPosition bookHistory = HistoryItemPosition.fromMap(entry);
    histories.add(bookHistory);
  });

  return histories;
}

Future<void> setBookHistoryPosition(
    List<HistoryItemPosition> bookHistories) async {
  List<Map<String, dynamic>> maps = [];
  bookHistories.forEach((entry) {
    maps.add(entry.toMap());
  });

  await gSharedPrefs.setString('bookHistoryPositionPrefs', jsonEncode(maps));
}

Future<void> addBookHistoryPosition(HistoryItemPosition bookHistory) async {
  List<HistoryItemPosition> bookHistories = getBookHistoryPosition();

  bookHistories.removeWhere((entry) => entry.url == bookHistory.url);
  bookHistories.add(bookHistory);

  if (bookHistories.length >= 20) {
    bookHistories = bookHistories.sublist(bookHistories.length - 20);
  }

  await setBookHistoryPosition(bookHistories);
}

Future<void> removeBookHistoryPosition(HistoryItemPosition bookHistory) async {
  List<HistoryItemPosition> bookHistories = getBookHistoryPosition();

  bookHistories.removeWhere((entry) => entry.url == bookHistory.url);
  await setBookHistoryPosition(bookHistories);
}

List<String> getDictionariesName() {
  return gSharedPrefs.getStringList('dictionarySources') ?? [];
}

Future<void> setDictionariesName(List<String> customDictionaries) async {
  await gSharedPrefs.setStringList('dictionarySources', customDictionaries);
}

Future<void> addDictionaryName(String customDictionary) async {
  List<String> customDictionaries = getDictionariesName();
  customDictionaries.add(customDictionary);
  await setDictionariesName(customDictionaries);
}

Future<void> removeDictionaryName(String customDictionary) async {
  List<String> customDictionaries = getDictionariesName();
  customDictionaries.remove(customDictionary);
  await setDictionariesName(customDictionaries);
}

Future<void> setCurrentDictionary(String newCurrentDictionary) async {
  gActiveDictionary.value = newCurrentDictionary;
  await gSharedPrefs.setString("currentCustomDictionary", newCurrentDictionary);
}

String getCurrentDictionary() {
  String customDictionary =
      gSharedPrefs.getString('currentCustomDictionary') ?? 'Jisho.org API';
  return customDictionary;
}

bool isCustomDictionary() {
  return !(gReservedDictionaryNames.contains(getCurrentDictionary()));
}

Future<void> setNextDictionary() async {
  List<String> allDictionaries =
      getDictionariesName() + gReservedDictionaryNames;
  int currentIndex = allDictionaries.indexOf(getCurrentDictionary());

  if (currentIndex + 1 > allDictionaries.length - 1) {
    await setCurrentDictionary(allDictionaries[0]);
  } else {
    await setCurrentDictionary(allDictionaries[currentIndex + 1]);
  }
}

Future<void> setPrevDictionary() async {
  List<String> allDictionaries =
      getDictionariesName() + gReservedDictionaryNames;
  int currentIndex = allDictionaries.indexOf(getCurrentDictionary());

  if (currentIndex - 1 < 0) {
    await setCurrentDictionary(allDictionaries[allDictionaries.length - 1]);
  } else {
    await setCurrentDictionary(allDictionaries[currentIndex - 1]);
  }
}

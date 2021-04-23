import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_youtube_dl/youtube_dl.dart';
import 'package:http/http.dart' as http;
import 'package:jidoujisho/preferences.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shell/shell.dart';
import 'package:xml2json/xml2json.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/util.dart';

class YouTubeQualityOption {
  final String videoURL;
  final String videoResolution;
  final bool muxed;

  YouTubeQualityOption({
    this.videoURL,
    this.videoResolution,
    this.muxed,
  });
}

class YouTubeMux {
  final String title;
  final String channel;
  final String thumbnailURL;
  final List<YouTubeQualityOption> videoQualities;
  final String videoURL;
  final String audioURL;
  final String audioMetadata;

  YouTubeMux({
    this.title,
    this.channel,
    this.thumbnailURL,
    this.videoQualities,
    this.videoURL,
    this.audioURL,
    this.audioMetadata,
  });
}

String timedTextToSRT(String timedText) {
  final Xml2Json xml2Json = Xml2Json();

  xml2Json.parse(timedText);
  var jsonString = xml2Json.toBadgerfish();
  var data = jsonDecode(jsonString);

  List<dynamic> lines = (data["transcript"]["text"]);

  String convertedLines = "";
  int lineCount = 0;

  lines.forEach((line) {
    String convertedLine = timedLineToSRT(line, lineCount++);
    convertedLines = convertedLines + convertedLine;
  });

  return convertedLines;
}

String timedLineToSRT(Map<String, dynamic> line, int lineCount) {
  double start = double.parse(line["\@start"]);
  double duration = double.parse(line["\@dur"]);
  String text = line["\$"] ?? "";

  String startTime = formatTimeString(start);
  String endTime = formatTimeString(start + duration);
  String lineNumber = lineCount.toString();

  String srtLine = "$lineNumber\n$startTime --> $endTime\n$text\n\n";

  return srtLine;
}

Future<YouTubeMux> getPlayerYouTubeInfo(String webURL) async {
  var videoID = YoutubePlayer.convertUrlToId(webURL);

  if (videoID != null) {
    YoutubeExplode yt = YoutubeExplode();
    Video video = await yt.videos.get(videoID);
    String title = video.title;
    String channel = video.author;
    String thumbnailURL = video.thumbnails.highResUrl;

    StreamManifest streamManifest =
        await yt.videos.streamsClient.getManifest(webURL);

    List<YouTubeQualityOption> videoQualities = [];
    List<String> videoResolutions = [];

    for (var stream in streamManifest.muxed.sortByBitrate()) {
      String resolutionLabel = stream.videoQualityLabel;
      if (!stream.videoQualityLabel.contains("p")) {
        resolutionLabel = stream.videoQualityLabel + "p";
      }
      if (stream.videoQualityLabel.contains("p60")) {
        resolutionLabel = stream.videoQualityLabel.replaceAll("p60", "p");
      }

      if (!videoResolutions.contains(resolutionLabel)) {
        videoQualities.add(
          YouTubeQualityOption(
            videoURL: stream.url.toString(),
            videoResolution: resolutionLabel,
            muxed: true,
          ),
        );
        videoResolutions.add(resolutionLabel);
      }
    }

    for (var stream in streamManifest.videoOnly.sortByBitrate()) {
      String resolutionLabel = stream.videoQualityLabel;
      if (!stream.videoQualityLabel.contains("p")) {
        resolutionLabel = stream.videoQualityLabel + "p";
      }
      if (stream.videoQualityLabel.contains("p60")) {
        resolutionLabel = stream.videoQualityLabel.replaceAll("p60", "p");
      }

      if (!videoResolutions.contains(resolutionLabel)) {
        videoQualities.add(
          YouTubeQualityOption(
            videoURL: stream.url.toString(),
            videoResolution: resolutionLabel,
            muxed: false,
          ),
        );
        videoResolutions.add(resolutionLabel);
      }
    }

    videoQualities.sort((a, b) {
      int aHeight = int.parse(
          a.videoResolution.substring(0, a.videoResolution.length - 1));
      int bHeight = int.parse(
          b.videoResolution.substring(0, b.videoResolution.length - 1));

      return aHeight.compareTo(bHeight);
    });

    AudioStreamInfo streamAudioInfo =
        streamManifest.audioOnly.sortByBitrate().last;
    String audioURL = streamAudioInfo.url.toString();
    String audioMetadata =
        "[${streamAudioInfo.container.name}] - [${streamAudioInfo.bitrate.kiloBitsPerSecond.floor()} Kbps]";

    return YouTubeMux(
      title: title,
      channel: channel,
      videoQualities: videoQualities,
      audioURL: audioURL,
      audioMetadata: audioMetadata,
      thumbnailURL: thumbnailURL,
      videoURL: webURL,
    );
  } else {
    return null;
  }
}

Future<List<Video>> searchYouTubeVideos(String searchQuery) async {
  YoutubeExplode yt = YoutubeExplode();
  SearchList searchResults = await yt.search.getVideos(searchQuery);

  List<Video> videos = [];
  for (Video video in searchResults) {
    videos.add(video);
  }

  return videos;
}

Future<List<Video>> getLatestChannelVideos(String channelID) async {
  YoutubeExplode yt = YoutubeExplode();
  List<Video> searchResults = await yt.channels.getUploads(channelID).toList();

  return searchResults;
}

Future<List<Video>> searchYouTubeTrendingVideos() {
  YoutubeExplode yt = YoutubeExplode();
  return yt.playlists.getVideos("PLuXL6NS58Dyx-wTr5o7NiC7CZRbMA91DC").toList();
}

FutureOr<List<Channel>> getSubscribedChannels() async {
  if (getChannelCache().isNotEmpty) {
    return getChannelCache();
  }

  List<String> channelIDs = getChannelList();
  YoutubeExplode yt = YoutubeExplode();

  List<Future<Channel>> futureChannels = [];
  channelIDs.forEach(
      (channelID) async => {futureChannels.add(yt.channels.get(channelID))});

  List<Channel> channels = await Future.wait(futureChannels);
  channels
      .sort(((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase())));

  setChannelCache(channels);

  return channels;
}

Future<bool> checkYouTubeClosedCaptionAvailable(String videoID) async {
  String httpSubs = await http.read(
      Uri.parse("https://www.youtube.com/api/timedtext?lang=ja&v=" + videoID));
  return (httpSubs.isNotEmpty);
}

FutureOr<String> getPublishMetadata(Video result) async {
  String videoPublishTime =
      result.uploadDate == null ? "" : getTimeAgoFormatted(result.uploadDate);
  String videoViewCount = getViewCountFormatted(result.engagement.viewCount);
  String videoDetails = "$videoPublishTime · $videoViewCount views";

  if (result.uploadDate != null) {
    return videoDetails;
  } else {
    YoutubeExplode yt = YoutubeExplode();
    Video video = await yt.videos.get(result.id);

    String videoPublishTime =
        video.uploadDate == null ? "" : getTimeAgoFormatted(video.uploadDate);
    String videoViewCount = getViewCountFormatted(video.engagement.viewCount);
    String videoDetails = "$videoPublishTime · $videoViewCount views";

    return videoDetails;
  }
}

Future<void> installYouTubeDLDependencies() async {
  await YoutubeDL.init(null);
}

Future<String> requestAutoGeneratedSubtitles(
  String url,
  ValueNotifier<String> clipboard,
  ValueNotifier<int> subtrack,
) async {
  File autogenSubFile = File('$gAppDirPath/jidoujisho-autogenSubtitles');
  File vttFile = (Directory("$gAppDirPath").listSync().firstWhere(
    (fileEntity) => path
        .basename(fileEntity.path)
        .startsWith("jidoujisho-autogenSubtitles"),
    orElse: () {
      return null;
    },
  )) as File;
  if (vttFile != null) {
    vttFile.deleteSync();
  }

  var dir = await getApplicationSupportDirectory();
  var bin = await YoutubeDL.getLibraryDirectory();
  var shell = new Shell();

  shell.navigate(bin.path);
  shell.environment['LD_LIBRARY_PATH'] =
      path.join(dir.path, 'python', 'usr', 'lib');
  shell.environment['SSL_CERT_FILE'] =
      path.join(dir.path, 'python', 'usr', 'etc', 'tls', 'cert.pem');
  shell.environment['PYTHONHOME'] = path.join(dir.path, 'python', 'usr');

  List<String> pparam = [];

  pparam.insert(0, autogenSubFile.path);
  pparam.insert(0, '-o');
  pparam.insert(0, '--verbose');
  pparam.insert(0, 'ja');
  pparam.insert(0, '--sub-lang');
  pparam.insert(0, url);
  pparam.insert(0, '--skip-download');
  pparam.insert(0, '--write-auto-sub');

  pparam.insert(
      0, path.join(dir.path, 'python', 'usr', 'youtube_dl', '__main__.py'));
  pparam.add('--cache-dir');
  pparam.add(path.join(dir.path, 'python', 'usr', 'bin', '.cache'));
  print(pparam);

  var echo = await shell.start('./libpython3.so', pparam);
  var stdout = await echo.stdout.readAsString();
  print(stdout);
  var stderr = await echo.stderr.readAsString();
  print(stderr);
  print("Finished execution");

  vttFile = (Directory("$gAppDirPath").listSync().firstWhere(
      (fileEntity) => path
          .basename(fileEntity.path)
          .startsWith("jidoujisho-autogenSubtitles"), orElse: () {
    clipboard.value = "&<&>autogenbad&<&>";
    subtrack.value = -51;
    return null;
  })) as File;

  return vttFile.readAsStringSync();
}

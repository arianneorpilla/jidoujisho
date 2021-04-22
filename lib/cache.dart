import 'package:async/async.dart';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/youtube.dart';

fetchTrendingCache() {
  return gTrendingCache.runOnce(() async {
    return searchYouTubeTrendingVideos();
  });
}

fetchChannelCache() {
  return gChannelCache.runOnce(() async {
    return getSubscribedChannels();
  });
}

fetchSearchCache(String searchQuery) {
  if (gSearchCache[searchQuery] == null) {
    gSearchCache[searchQuery] = AsyncMemoizer();
  }
  return gSearchCache[searchQuery].runOnce(() async {
    return searchYouTubeVideos(searchQuery);
  });
}

fetchChannelVideoCache(String channelID) {
  if (gChannelVideoCache[channelID] == null) {
    gChannelVideoCache[channelID] = AsyncMemoizer();
  }
  return gChannelVideoCache[channelID].runOnce(() async {
    return getLatestChannelVideos(channelID);
  });
}

fetchCaptioningCache(String videoID) {
  if (gCaptioningCache[videoID] == null) {
    gCaptioningCache[videoID] = AsyncMemoizer();
  }
  return gCaptioningCache[videoID].runOnce(() async {
    return checkYouTubeClosedCaptionAvailable(videoID);
  });
}

fetchMetadataCache(String videoID, Video video) {
  if (gMetadataCache[videoID] == null) {
    gMetadataCache[videoID] = AsyncMemoizer();
  }
  return gMetadataCache[videoID].runOnce(() async {
    return getPublishMetadata(video);
  });
}

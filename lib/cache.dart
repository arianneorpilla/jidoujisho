import 'package:async/async.dart';
import 'package:jidoujisho/dictionary.dart';

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

fetchChannelVideoCache(String channelID) {
  if (gChannelVideoCache[channelID] == null) {
    gChannelVideoCache[channelID] = [];
  }
  return gChannelVideoCache[channelID];
}

fetchSearchCache(String searchQuery) {
  if (gSearchCache[searchQuery] == null) {
    gSearchCache[searchQuery] = AsyncMemoizer();
  }
  return gSearchCache[searchQuery].runOnce(() async {
    return searchYouTubeVideos(searchQuery);
  });
}

fetchBilingualSearchCache({
  String searchTerm,
  String contextDataSource = "-1",
  int contextPosition = -1,
}) {
  if (gBilingualSearchCache[searchTerm] == null) {
    gBilingualSearchCache[searchTerm] = AsyncMemoizer();
  }

  gBilingualSearchCache[searchTerm].runOnce(() async {
    return getWordDetails(
      searchTerm: searchTerm,
      contextDataSource: contextDataSource,
      contextPosition: contextPosition,
    );
  });

  return gBilingualSearchCache[searchTerm].future;
}

fetchMonolingualSearchCache({
  String searchTerm,
  bool recursive,
  String contextDataSource = "-1",
  int contextPosition = -1,
}) {
  if (gMonolingualSearchCache[searchTerm] == null) {
    gMonolingualSearchCache[searchTerm] = AsyncMemoizer();
  }

  gMonolingualSearchCache[searchTerm].runOnce(() async {
    return getMonolingualWordDetails(
      searchTerm: searchTerm,
      recursive: recursive,
      contextDataSource: contextDataSource,
      contextPosition: contextPosition,
    );
  });

  return gMonolingualSearchCache[searchTerm].future;
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

import 'dart:convert';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:path/path.dart' as path;
import 'package:ve_dart/ve_dart.dart';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/youtube.dart';

fetchTrendingCache() {
  return gTrendingCache.runOnce(() async {
    List<Video> trendingVideos = await searchYouTubeTrendingVideos();
    await fetchTrendingChannelCache(trendingVideos);
    return trendingVideos;
  });
}

fetchChannelCache() {
  return gChannelCache.runOnce(() async {
    List<Channel> channels;
    try {
      if (getChannelCache().isNotEmpty) {
        return getChannelCache();
      }
      List<String> channelIDs = getChannelList();
      String channelsMessage = jsonEncode(channelIDs);
      channels = await compute(getSubscribedChannels, channelsMessage);
      if (channels != null && channels.isNotEmpty) {
        setChannelCache(channels);
      }
    } catch (e) {
      print(e);
    }
    return channels;
  });
}

fetchTrendingChannelCache(List<Video> trendingVideos) {
  return gTrendingChannelCache.runOnce(() async {
    List<Channel> trendingChannels;
    try {
      if (getTrendingChannelCache().isNotEmpty) {
        return getTrendingChannelCache();
      }
      trendingChannels = await compute(getTrendingChannels, trendingVideos);
      if (trendingChannels != null && trendingChannels.isNotEmpty) {
        setTrendingChannelCache(trendingChannels);
      }
    } catch (e) {
      print(e);
    }
    return trendingChannels;
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

String generateFallbackTerm(String searchTerm) {
  String fallbackTerm;
  List<Word> words = parseVe(gMecabTagger, searchTerm);

  if (words == null && words.isNotEmpty) {
    fallbackTerm = searchTerm;
  } else {
    if (words.first.lemma != null && words.first.lemma != words.first.word) {
      fallbackTerm = words.first.lemma;
    } else {
      fallbackTerm = words.first.word;
    }
  }

  return fallbackTerm;
}

fetchCustomDictionarySearchCache({
  String dictionaryName,
  String searchTerm,
  String contextDataSource = "-1",
  int contextPosition = -1,
}) {
  if (gCustomDictionarySearchCache[dictionaryName] == null) {
    gCustomDictionarySearchCache[dictionaryName] = {};
  }

  if (gCustomDictionarySearchCache[dictionaryName][searchTerm] == null) {
    gCustomDictionarySearchCache[dictionaryName][searchTerm] = AsyncMemoizer();
  }

  gCustomDictionarySearchCache[dictionaryName][searchTerm].runOnce(() async {
    ByteData storeReference =
        gCustomDictionaryStores[getCurrentDictionary()].reference;

    CustomWordDetailsParams params = CustomWordDetailsParams(
      searchTerm: searchTerm,
      contextDataSource: contextDataSource,
      contextPosition: contextPosition,
      originalSearchTerm: searchTerm,
      fallbackTerm: generateFallbackTerm(searchTerm),
      entryStoreReference: storeReference,
      tagStoreReference: gTagStore.reference,
      allStoreReferences: getAllStoreReferences(),
    );

    try {
      DictionaryHistoryEntry results =
          await compute(getCustomWordDetails, params);

      if (results != null) {
        return results;
      } else {
        KanaKit kanaKit = KanaKit();
        if (kanaKit.isRomaji(searchTerm)) {
          String recursiveSearchTerm = kanaKit.toHiragana(searchTerm);
          params = CustomWordDetailsParams(
            searchTerm: recursiveSearchTerm,
            contextDataSource: contextDataSource,
            contextPosition: contextPosition,
            originalSearchTerm: searchTerm,
            fallbackTerm: generateFallbackTerm(recursiveSearchTerm),
            entryStoreReference: storeReference,
            tagStoreReference: gTagStore.reference,
            allStoreReferences: getAllStoreReferences(),
          );
          DictionaryHistoryEntry results =
              await compute(getCustomWordDetails, params);

          if (results != null) {
            return results;
          } else {
            recursiveSearchTerm = kanaKit.toKatakana(searchTerm);
            params = CustomWordDetailsParams(
              searchTerm: recursiveSearchTerm,
              contextDataSource: contextDataSource,
              contextPosition: contextPosition,
              originalSearchTerm: searchTerm,
              fallbackTerm: generateFallbackTerm(recursiveSearchTerm),
              entryStoreReference: storeReference,
              tagStoreReference: gTagStore.reference,
              allStoreReferences: getAllStoreReferences(),
            );
            results = await compute(getCustomWordDetails, params);
            if (results != null) {
              return results;
            }
          }
        } else if (kanaKit.isHiragana(searchTerm)) {
          String recursiveSearchTerm = kanaKit.toKatakana(searchTerm);
          params = CustomWordDetailsParams(
            searchTerm: recursiveSearchTerm,
            contextDataSource: contextDataSource,
            contextPosition: contextPosition,
            originalSearchTerm: searchTerm,
            fallbackTerm: generateFallbackTerm(recursiveSearchTerm),
            entryStoreReference: storeReference,
            tagStoreReference: gTagStore.reference,
            allStoreReferences: getAllStoreReferences(),
          );
          results = await compute(getCustomWordDetails, params);
          if (results != null) {
            return results;
          }
        } else if (kanaKit.isKatakana(searchTerm)) {
          String recursiveSearchTerm = kanaKit.toHiragana(searchTerm);
          params = CustomWordDetailsParams(
            searchTerm: recursiveSearchTerm,
            contextDataSource: contextDataSource,
            contextPosition: contextPosition,
            originalSearchTerm: searchTerm,
            fallbackTerm: generateFallbackTerm(recursiveSearchTerm),
            entryStoreReference: storeReference,
            tagStoreReference: gTagStore.reference,
            allStoreReferences: getAllStoreReferences(),
          );
          results = await compute(getCustomWordDetails, params);
          if (results != null) {
            return results;
          }
        }
      }

      if (searchTerm.length > 1) {
        params = CustomWordDetailsParams(
          searchTerm: searchTerm.substring(0, searchTerm.length - 1),
          contextDataSource: contextDataSource,
          contextPosition: contextPosition,
          originalSearchTerm: searchTerm,
          fallbackTerm: generateFallbackTerm(
              searchTerm.substring(0, searchTerm.length - 1)),
          entryStoreReference: storeReference,
          tagStoreReference: gTagStore.reference,
          allStoreReferences: getAllStoreReferences(),
        );
        results = await compute(getCustomWordDetails, params);
        if (results != null) {
          return results;
        }
      }

      if (searchTerm.length >= 4) {
        params = CustomWordDetailsParams(
          searchTerm: searchTerm.substring(0, searchTerm.length - 2),
          contextDataSource: contextDataSource,
          contextPosition: contextPosition,
          originalSearchTerm: searchTerm,
          fallbackTerm: generateFallbackTerm(
              searchTerm.substring(0, searchTerm.length - 2)),
          entryStoreReference: storeReference,
          tagStoreReference: gTagStore.reference,
          allStoreReferences: getAllStoreReferences(),
        );
        results = await compute(getCustomWordDetails, params);
        if (results != null) {
          return results;
        }
      }

      return null;
    } catch (e) {
      print(e);
    }
  });

  return gCustomDictionarySearchCache[dictionaryName][searchTerm].future;
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

List<ByteData> getAllStoreReferences() {
  List<ByteData> storeReferences = [];
  gCustomDictionaryStores.values.forEach((store) {
    storeReferences.add(store.reference);
  });
  return storeReferences;
}

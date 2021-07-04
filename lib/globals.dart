import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/objectbox.g.dart';
import 'package:jidoujisho/preferences.dart';

String gAppDirPath;
String gPreviewImageDir;
String gPreviewAudioDir;
PackageInfo gPackageInfo;

Mecab gMecabTagger;

bool gIsYouTubeAllowed = true;
bool gIsTapToSelectSupported = true;

SharedPreferences gSharedPrefs;
ValueNotifier<bool> gIsResumable;
ValueNotifier<bool> gIsSelectMode;
List<String> gReservedDictionaryNames = const [
  "Jisho.org API",
  "Sora Dictionary API"
];

AsyncMemoizer gTrendingCache = AsyncMemoizer();
AsyncMemoizer gChannelCache = AsyncMemoizer();
AsyncMemoizer gTrendingChannelCache = AsyncMemoizer();
Map<String, AsyncMemoizer> gSearchCache = {};
Map<String, AsyncMemoizer> gBilingualSearchCache = {};
Map<String, AsyncMemoizer> gMonolingualSearchCache = {};
Map<String, Map<String, AsyncMemoizer>> gCustomDictionarySearchCache = {};
Map<String, AsyncMemoizer> gCaptioningCache = {};
Map<String, List<Video>> gChannelVideoCache = {};
Map<String, AsyncMemoizer> gMetadataCache = {};
Map<String, Store> gCustomDictionaryStores = {};

ValueNotifier<List<DictionaryEntry>> gKanjiumDictionary = ValueNotifier([]);
ScrollController gCurrentScrollbar;

ValueNotifier<String> gShareText = ValueNotifier<String>("");
ValueNotifier<String> gShareTextMatch = ValueNotifier<String>("");
ValueNotifier<String> gActiveDictionary =
    ValueNotifier<String>(getCurrentDictionary());

ValueNotifier<bool> gPlayPause = ValueNotifier<bool>(true);

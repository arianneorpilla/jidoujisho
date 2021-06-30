import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jidoujisho/dictionary.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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

AsyncMemoizer gTrendingCache = AsyncMemoizer();
AsyncMemoizer gChannelCache = AsyncMemoizer();
AsyncMemoizer gTrendingChannelCache = AsyncMemoizer();
Map<String, AsyncMemoizer> gSearchCache = {};
Map<String, AsyncMemoizer> gBilingualSearchCache = {};
Map<String, AsyncMemoizer> gMonolingualSearchCache = {};
Map<String, AsyncMemoizer> gCaptioningCache = {};
Map<String, List<Video>> gChannelVideoCache = {};
Map<String, AsyncMemoizer> gMetadataCache = {};

ValueNotifier<List<DictionaryEntry>> gKanjiumDictionary = ValueNotifier([]);
ScrollController gCurrentScrollbar;

ValueNotifier<String> gShareText = ValueNotifier<String>("");
ValueNotifier<String> gShareTextMatch = ValueNotifier<String>("");

ValueNotifier<bool> gPlayPause = ValueNotifier<bool>(true);

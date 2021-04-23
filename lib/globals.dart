import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jidoujisho/dictionary.dart';

String gAppDirPath;
String gPreviewImageDir;
String gPreviewAudioDir;
PackageInfo gPackageInfo;

Mecab gMecabTagger;

bool gIsYouTubeAllowed = true;

SharedPreferences gSharedPrefs;
ValueNotifier<bool> gIsResumable;
ValueNotifier<bool> gIsSelectMode;

AsyncMemoizer gTrendingCache = AsyncMemoizer();
AsyncMemoizer gChannelCache = AsyncMemoizer();
Map<String, AsyncMemoizer> gSearchCache = {};
Map<String, AsyncMemoizer> gCaptioningCache = {};
Map<String, AsyncMemoizer> gChannelVideoCache = {};
Map<String, AsyncMemoizer> gMetadataCache = {};

List<DictionaryEntry> gCustomDictionary;
Fuzzy gCustomDictionaryFuzzy;

ValueNotifier<bool> gPlayPause = ValueNotifier<bool>(true);

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:chisa/anki/enhancements/bing_search_enhancement.dart';
import 'package:chisa/anki/enhancements/camera_image_enhancement.dart';
import 'package:chisa/anki/enhancements/crop_image_enhancement.dart';
import 'package:chisa/anki/enhancements/dictionary_menu_enhancement.dart';
import 'package:chisa/anki/enhancements/image_picker_enhancement.dart';
import 'package:chisa/anki/enhancements/search_dictionary_enhancement.dart';
import 'package:chisa/anki/enhancements/text_segmentation_enhancement.dart';
import 'package:chisa/dictionary/formats/naver_dictionary_format.dart';
import 'package:chisa/language/languages/korean_language.dart';
import 'package:chisa/media/media_sources/player_network_stream_source.dart';
import 'package:chisa/media/media_sources/reader_browser_media_source.dart';
import 'package:chisa/media/media_sources/reader_ttu_media_source.dart';
import 'package:chisa/media/media_sources/viewer_camera_media_source.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

import 'package:chisa/dictionary/formats/cccedict_simplified_format.dart';
import 'package:chisa/dictionary/formats/cccedict_traditional_format.dart';
import 'package:chisa/dictionary/formats/yomichan_term_bank_format.dart';
import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/language/languages/chinese_simplified_language.dart';
import 'package:chisa/language/languages/chinese_traditional_language.dart';
import 'package:chisa/language/languages/english_language.dart';
import 'package:chisa/language/languages/japanese_language.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_histories/dictionary_media_history.dart';
import 'package:chisa/media/media_history_items/dictionary_media_history_item.dart';
import 'package:chisa/media/media_sources/player_local_media_source.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_sources/player_youtube_source.dart';
import 'package:chisa/media/media_sources/reader_media_source.dart';
import 'package:chisa/media/media_sources/viewer_local_media_source.dart';
import 'package:chisa/media/media_sources/viewer_media_source.dart';
import 'package:chisa/media/media_sources_dialog.dart';
import 'package:chisa/util/blur_widget.dart';
import 'package:chisa/util/subtitle_options.dart';
import 'package:chisa/util/dictionary_widget_field.dart';
import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/anki/enhancements/clear_button_enhancement.dart';
import 'package:chisa/anki/enhancements/pitch_accent_export_enhancement.dart';
import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_dialog.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/dictionary/dictionary_import.dart';
import 'package:chisa/dictionary/dictionary_widget_enhancement.dart';
import 'package:chisa/dictionary/enhancements/pitch_accent_enhancement.dart';
import 'package:chisa/language/language.dart';
import 'package:chisa/language/language_dialog.dart';
import 'package:chisa/objectbox.g.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:chisa/util/dictionary_entry_widget.dart';

/// A scoped model for parameters that affect the entire application.
/// [Provider] is used for global state management across multiple layers,
/// especially for preferences that persist across application restarts.
class AppModel with ChangeNotifier {
  AppModel({
    required sharedPreferences,
    required packageInfo,
  })  : _sharedPreferences = sharedPreferences,
        _packageInfo = packageInfo;

  late ValueNotifier<bool> resumableNotifier;

  /// For saving options and settings and persisting across app restarts.
  final SharedPreferences _sharedPreferences;
  SharedPreferences get sharedPreferences => _sharedPreferences;

  ValueNotifier<bool> dictionaryUpdateFlipflop = ValueNotifier<bool>(false);
  ValueNotifier<bool> playerUpdateFlipflop = ValueNotifier<bool>(false);
  ValueNotifier<bool> readerUpdateFlipflop = ValueNotifier<bool>(false);
  ValueNotifier<bool> viewerUpdateFlipflop = ValueNotifier<bool>(false);

  /// Necessary to get version details upon app start.
  final PackageInfo _packageInfo;
  PackageInfo get packageInfo => _packageInfo;

  /// Flag to ensure initialisation doesn't happen after the first time.
  bool _hasInitialised = false;
  bool get hasInitialized => _hasInitialised;

  /// If this is on, no dictionary search operations should be startable.
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  /// Used to indicate if the app is currently in a source page.
  bool isInSource = false;

  final Map<MediaType, ScrollController> _scrollOffsets = {};
  final Map<MediaType, FloatingSearchBarController> _homeSearchControllers = {};
  final Map<String, Map<String, DictionarySearchResult>> _resultsCache = {};

  ScrollController getScrollController(MediaType type) {
    _scrollOffsets[type] ??= ScrollController(initialScrollOffset: 0);
    return _scrollOffsets[type]!;
  }

  FloatingSearchBarController getSearchController(MediaType type) {
    _homeSearchControllers[type] ??= FloatingSearchBarController();
    return _homeSearchControllers[type]!;
  }

  /// All populated in initialisation when the app is started.
  final Map<String, Dictionary> _availableDictionaries = {};
  final Map<String, DictionaryFormat> _availableDictionaryFormats = {};
  final Map<String, Language> _availableLanguages = {};
  final Map<MediaType, Map<String, MediaSource>> _availableMediaSources = {};
  final Map<AnkiExportField, Map<String, AnkiExportEnhancement>>
      _availableExportEnhancements = {};
  final Map<DictionaryWidgetField, Map<String, DictionaryWidgetEnhancement>>
      _availableWidgetEnhancements = {};

  final Map<String, Store> _dictionaryStores = {};

  final List<MediaType> _mediaTypes = [
    MediaType.player,
    MediaType.reader,
    MediaType.viewer,
    MediaType.dictionary,
  ];
  List<MediaType> get mediaTypes => _mediaTypes;

  /// Cache for dictionaries to use if they need to improve performance.
  final Map<String, Map<String, dynamic>> _dictionaryCache = {};

  Map<String, Dictionary> get availableDictionaries => _availableDictionaries;
  Map<String, DictionaryFormat> get availableDictionaryFormats =>
      _availableDictionaryFormats;
  Map<String, Language> get availableLanguages => _availableLanguages;
  Map<MediaType, Map<String, MediaSource>> get availableMediaSources =>
      _availableMediaSources;
  Map<AnkiExportField, Map<String, AnkiExportEnhancement>>
      get availableExportEnhancements => _availableExportEnhancements;
  Map<DictionaryWidgetField, Map<String, DictionaryWidgetEnhancement>>
      get availableWidgetEnhancements => _availableWidgetEnhancements;

  List<DictionaryFormat> dictionaryFormats = [
    YomichanTermBankFormat(),
    CCCEdictTraditionalFormat(),
    CCCEdictSimplifiedFormat(),
    NaverDictionaryFormat(),
  ];
  List<PlayerMediaSource> playerMediaSources = [
    PlayerLocalMediaSource(),
    PlayerYouTubeSource(),
    PlayerNetworkStreamSource(),
  ];
  List<ReaderMediaSource> readerMediaSources = [
    ReaderTtuMediaSource(),
    ReaderBrowserSource(),
  ];
  List<ViewerMediaSource> viewerMediaSources = [
    ViewerLocalMediaSource(),
    ViewerCameraMediaSource(),
  ];

  Future<void> initialiseAppModel() async {
    if (!_hasInitialised) {
      populateDictionaryFormats();
      populateLanguages();
      populateMediaSources();
      populateExportEnhancements();
      populateWidgetEnhancements();

      await initialiseImportedDictionaries();
      await initialiseExportEnhancements();
      await initialiseWidgetEnhancements();
      await initialiseCurrentLanguage();

      resumableNotifier = ValueNotifier<bool>(isResumable());

      _hasInitialised = true;
      if (!isFirstTimeInitialised()) {
        for (AnkiExportField field in AnkiExportField.values) {
          await ClearButtonEnhancement(appModel: this, enhancementField: field)
              .setEnabled(field, 3);
        }

        await TextSegmentationEnhancement(appModel: this)
            .setEnabled(AnkiExportField.sentence, 2);
        await DictionaryMenuEnhancement(appModel: this)
            .setEnabled(AnkiExportField.word, 2);
        await SearchDictionaryEnhancement(appModel: this)
            .setEnabled(AnkiExportField.word, 1);
        await BingSearchEnhancement(appModel: this)
            .setEnabled(AnkiExportField.image, 2);

        setFirstTimeInitialised();
      }
      notifyListeners();
    }
  }

  void populateDictionaryFormats() {
    for (DictionaryFormat format in dictionaryFormats) {
      _availableDictionaryFormats[format.formatName] = format;
    }
  }

  void populateLanguages() {
    List<Language> languages = [
      ChineseTraditionalLanguage(),
      ChineseSimplifiedLanguage(),
      JapaneseLanguage(),
      KoreanLanguage(),
    ];

    for (Language language in languages) {
      _availableLanguages[language.languageName] = language;
    }
  }

  void populateMediaSources() {
    for (MediaType mediaType in mediaTypes) {
      _availableMediaSources[mediaType] = {};
    }

    for (PlayerMediaSource source in playerMediaSources) {
      _availableMediaSources[MediaType.player]![source.sourceName] = source;
    }

    for (ReaderMediaSource source in readerMediaSources) {
      _availableMediaSources[MediaType.reader]![source.sourceName] = source;
    }
    for (ViewerMediaSource source in viewerMediaSources) {
      _availableMediaSources[MediaType.viewer]![source.sourceName] = source;
    }
  }

  void populateExportEnhancements() {
    List<AnkiExportEnhancement> imageEnhancements = [
      ClearButtonEnhancement(
        appModel: this,
        enhancementField: AnkiExportField.image,
      ),
      BingSearchEnhancement(appModel: this),
      CropImageEnhancement(appModel: this),
      ImagePickerEnhancement(appModel: this),
      CameraImageEnhancement(appModel: this),
    ];
    List<AnkiExportEnhancement> audioEnhancements = [
      ClearButtonEnhancement(
        appModel: this,
        enhancementField: AnkiExportField.audio,
      ),
    ];
    List<AnkiExportEnhancement> sentenceEnhancements = [
      ClearButtonEnhancement(
        appModel: this,
        enhancementField: AnkiExportField.sentence,
      ),
      TextSegmentationEnhancement(appModel: this),
    ];
    List<AnkiExportEnhancement> wordEnhancements = [
      ClearButtonEnhancement(
        appModel: this,
        enhancementField: AnkiExportField.word,
      ),
      DictionaryMenuEnhancement(appModel: this),
      SearchDictionaryEnhancement(appModel: this),
    ];
    List<AnkiExportEnhancement> readingEnhancements = [
      ClearButtonEnhancement(
        appModel: this,
        enhancementField: AnkiExportField.reading,
      ),
      PitchAccentExportEnhancement(appModel: this),
    ];
    List<AnkiExportEnhancement> meaningEnhancements = [
      ClearButtonEnhancement(
        appModel: this,
        enhancementField: AnkiExportField.meaning,
      ),
    ];
    List<AnkiExportEnhancement> extraEnhancements = [
      ClearButtonEnhancement(
        appModel: this,
        enhancementField: AnkiExportField.extra,
      ),
    ];

    for (AnkiExportField field in AnkiExportField.values) {
      _availableExportEnhancements[field] = {};
    }

    for (AnkiExportEnhancement enhancement in imageEnhancements) {
      _availableExportEnhancements[AnkiExportField.image]![
          enhancement.enhancementName] = enhancement;
    }
    for (AnkiExportEnhancement enhancement in audioEnhancements) {
      _availableExportEnhancements[AnkiExportField.audio]![
          enhancement.enhancementName] = enhancement;
    }
    for (AnkiExportEnhancement enhancement in sentenceEnhancements) {
      _availableExportEnhancements[AnkiExportField.sentence]![
          enhancement.enhancementName] = enhancement;
    }
    for (AnkiExportEnhancement enhancement in wordEnhancements) {
      _availableExportEnhancements[AnkiExportField.word]![
          enhancement.enhancementName] = enhancement;
    }
    for (AnkiExportEnhancement enhancement in readingEnhancements) {
      _availableExportEnhancements[AnkiExportField.reading]![
          enhancement.enhancementName] = enhancement;
    }
    for (AnkiExportEnhancement enhancement in meaningEnhancements) {
      _availableExportEnhancements[AnkiExportField.meaning]![
          enhancement.enhancementName] = enhancement;
    }
    for (AnkiExportEnhancement enhancement in extraEnhancements) {
      _availableExportEnhancements[AnkiExportField.extra]![
          enhancement.enhancementName] = enhancement;
    }
  }

  void populateWidgetEnhancements() {
    List<DictionaryWidgetEnhancement> wordEnhancements = [];
    List<DictionaryWidgetEnhancement> readingEnhancements = [
      PitchAccentEnhancement(appModel: this),
    ];
    List<DictionaryWidgetEnhancement> meaningEnhancements = [];

    for (DictionaryWidgetField field in DictionaryWidgetField.values) {
      _availableWidgetEnhancements[field] = {};
    }

    for (DictionaryWidgetEnhancement enhancement in wordEnhancements) {
      _availableWidgetEnhancements[DictionaryWidgetField.word]![
          enhancement.enhancementName] = enhancement;
    }
    for (DictionaryWidgetEnhancement enhancement in readingEnhancements) {
      _availableWidgetEnhancements[DictionaryWidgetField.reading]![
          enhancement.enhancementName] = enhancement;
    }
    for (DictionaryWidgetEnhancement enhancement in meaningEnhancements) {
      _availableWidgetEnhancements[DictionaryWidgetField.meaning]![
          enhancement.enhancementName] = enhancement;
    }
  }

  Future<Store> initialiseDictionaryStore(String dictionaryName) async {
    String appDirDocPath = (await getApplicationDocumentsDirectory()).path;

    Directory objectBoxDirDirectory = Directory(
      p.join(appDirDocPath, "customDictionaries", dictionaryName),
    );
    if (!objectBoxDirDirectory.existsSync()) {
      objectBoxDirDirectory.createSync(recursive: true);
    }

    _dictionaryStores[dictionaryName] = Store(
      getObjectBoxModel(),
      directory: objectBoxDirDirectory.path,
    );

    return _dictionaryStores[dictionaryName]!;
  }

  Future<void> initialiseImportedDictionaries() async {
    List<Dictionary> dictionaries = getDictionaryRecord();
    for (Dictionary dictionary in dictionaries) {
      _dictionaryStores[dictionary.dictionaryName] =
          await initialiseDictionaryStore(dictionary.dictionaryName);
      _availableDictionaries[dictionary.dictionaryName] = dictionary;
    }
  }

  Future<void> initialiseExportEnhancements() async {
    for (AnkiExportField field in AnkiExportField.values) {
      for (AnkiExportEnhancement? enhancement
          in getExportEnabledFieldEnhancement(field)) {
        if (enhancement != null && !enhancement.isInitialised) {
          await enhancement.initialiseEnhancement();
          enhancement.isInitialised = true;
        }
      }

      AnkiExportEnhancement? enhancement = getAutoFieldEnhancement(field);
      if (enhancement != null && !enhancement.isInitialised) {
        await enhancement.initialiseEnhancement();
        enhancement.isInitialised = true;
      }
    }
  }

  Future<void> initialiseWidgetEnhancements() async {
    for (DictionaryWidgetField field in DictionaryWidgetField.values) {
      DictionaryWidgetEnhancement? enhancement =
          getFieldWidgetEnhancement(field);
      if (enhancement != null && !enhancement.isInitialised) {
        await enhancement.initialiseEnhancement();
        enhancement.isInitialised = true;
      }
    }
  }

  Future<void> initialiseCurrentLanguage() async {
    Language language = getCurrentLanguage();
    if (!language.isInitialised) {
      language.initialiseLanguage();
    }
  }

  Dictionary? getCurrentDictionary() {
    return _availableDictionaries[getCurrentDictionaryName()];
  }

  /// Get the current theme, whether or not dark mode should be on.
  bool getIsDarkMode() {
    return _sharedPreferences.getBool("isDarkMode") ??
        Brightness.dark ==
            (SchedulerBinding.instance?.window.platformBrightness ?? false);
  }

  /// Called when the toggle button is called in the drop down options menu,
  /// and toggles between light and dark mode, also saving the option.
  Future<void> toggleActiveTheme() async {
    bool isDarkMode = getIsDarkMode();
    _sharedPreferences.setBool("isDarkMode", !isDarkMode);

    notifyListeners();
  }

  /// Get the saved last main menu item so it can be shown on application start.
  int getLastActiveTabIndex() {
    int tabIndex = mediaTypes.indexWhere((mediaType) =>
        "$mediaType" == _sharedPreferences.getString("lastActiveMediaType"));

    if (tabIndex == -1) {
      return 0;
    }

    return tabIndex;
  }

  /// Save the last index and remember it on application restart.
  Future<void> setLastActiveTabIndex(int tabIndex) async {
    await _sharedPreferences.setString(
        "lastActiveMediaType", mediaTypes[tabIndex].toString());
  }

  /// Get the current active dictionary, the last one used.
  String getCurrentDictionaryName() {
    return _sharedPreferences.getString("currentDictionaryName") ?? "";
  }

  /// Save a new active dictionary and remember it on application restart.
  Future<void> setCurrentDictionaryName(String dictionaryName) async {
    await _sharedPreferences.setString("currentDictionaryName", dictionaryName);
  }

  MediaSource getCurrentMediaTypeSource(MediaType mediaType) {
    return availableMediaSources[mediaType]![
        getCurrentMediaTypeSourceName(mediaType)]!;
  }

  String getCurrentMediaTypeSourceName(MediaType mediaType) {
    return _sharedPreferences
            .getString("${mediaType.prefsDirectory()}/currentSource") ??
        availableMediaSources[mediaType]!.values.first.sourceName;
  }

  Future<void> setCurrentMediaTypeSourceName(
      MediaType mediaType, String sourceName) async {
    await _sharedPreferences.setString(
        "${mediaType.prefsDirectory()}/currentSource", sourceName);
  }

  bool getMediaSourceShown(MediaSource source) {
    return _sharedPreferences.getBool(
            "${source.mediaType.prefsDirectory()}/${source.sourceName}/shown") ??
        true;
  }

  Future<void> setMediaSourceShown(MediaSource source, bool shown) async {
    await _sharedPreferences.setBool(
        "${source.mediaType.prefsDirectory()}/${source.sourceName}/shown",
        shown);
  }

  /// Method for future proofing and saving performance. Dump one time data
  /// stores for use here.
  Map<String, dynamic> getDictionaryCache(String dictionaryName) {
    if (_dictionaryCache[dictionaryName] == null) {
      _dictionaryCache[dictionaryName] = {};
    }

    return _dictionaryCache[dictionaryName]!;
  }

  /// With the list of imported dictionaries, set the next one after the
  /// current dictionary as the new current one. If the current is last, the
  /// next will be the first dictionary.
  Future<void> setNextDictionary() async {
    List<Dictionary> allDictionaries = getDictionaryRecord();
    int currentIndex = allDictionaries.indexWhere((dictionary) =>
        dictionary.dictionaryName == getCurrentDictionaryName());

    if (currentIndex + 1 > allDictionaries.length - 1) {
      await setCurrentDictionaryName(allDictionaries[0].dictionaryName);
    } else {
      await setCurrentDictionaryName(
          allDictionaries[currentIndex + 1].dictionaryName);
    }
  }

  /// With the list of imported dictionaries, set the previous one before the
  /// current dictionary as the new current one. If the current is first, the
  /// next will be the last dictionary.
  Future<void> setPrevDictionary() async {
    List<Dictionary> allDictionaries = getDictionaryRecord();
    int currentIndex = allDictionaries.indexWhere((dictionary) =>
        dictionary.dictionaryName == getCurrentDictionaryName());

    if (currentIndex - 1 < 0) {
      await setCurrentDictionaryName(
          allDictionaries[allDictionaries.length - 1].dictionaryName);
    } else {
      await setCurrentDictionaryName(
          allDictionaries[currentIndex - 1].dictionaryName);
    }
  }

  /// Show the dictionary menu. This should be callable from many parts of the
  /// app, so it is appropriately handled by the model.
  Future<void> showDictionaryMenu(
    BuildContext context, {
    bool manageAllowed = false,
    Function()? onDictionaryChange,
    bool horizontalHack = false,
    ThemeData? themeData,
  }) async {
    Widget dictionaryDialog = DictionaryDialog(
      manageAllowed: manageAllowed,
      onDictionaryChange: onDictionaryChange,
    );

    if (themeData != null) {
      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => Theme(
          data: themeData,
          child: (horizontalHack)
              ? RotatedBox(quarterTurns: 1, child: dictionaryDialog)
              : dictionaryDialog,
        ),
      );
    } else {
      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => (horizontalHack)
            ? RotatedBox(quarterTurns: 1, child: dictionaryDialog)
            : dictionaryDialog,
      );
    }
  }

  /// Show the dictionary menu. This should be callable from many parts of the
  /// app, so it is appropriately handled by the model.
  Future<void> showSourcesMenu({
    required BuildContext context,
    required MediaType mediaType,
    bool manageAllowed = false,
  }) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => MediaSourcesDialog(
        mediaType: mediaType,
        manageAllowed: manageAllowed,
      ),
    );
  }

  Future<void> moveDictionaryUp(Dictionary target) async {
    List<Dictionary> dictionaries = getDictionaryRecord();
    if (dictionaries.length < 2) {
      return;
    }

    int targetIndex = dictionaries.indexWhere(
        (dictionary) => dictionary.dictionaryName == target.dictionaryName);
    if (targetIndex == 0) {
      dictionaries.removeAt(targetIndex);
      dictionaries.add(target);
    } else {
      Dictionary swapName = dictionaries[targetIndex - 1];
      dictionaries[targetIndex] = swapName;
      dictionaries[targetIndex - 1] = target;
    }

    await setDictionaryRecord(dictionaries);
  }

  Future<void> moveDictionaryDown(Dictionary target) async {
    List<Dictionary> dictionaries = getDictionaryRecord();
    if (dictionaries.length < 2) {
      return;
    }

    int targetIndex = dictionaries.indexWhere(
        (dictionary) => dictionary.dictionaryName == target.dictionaryName);
    if (targetIndex == dictionaries.length - 1) {
      dictionaries.removeAt(targetIndex);
      List<Dictionary> newDictionaries = [target];
      newDictionaries.addAll(dictionaries);
      dictionaries = newDictionaries;
    } else {
      Dictionary swapName = dictionaries[targetIndex + 1];
      dictionaries[targetIndex] = swapName;
      dictionaries[targetIndex + 1] = target;
    }

    await setDictionaryRecord(dictionaries);
  }

  /// Show the language menu.
  Future<void> showLanguageMenu(
    BuildContext context,
  ) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => const LanguageDialog(),
    );
  }

  /// Get the last selected dictionary format.
  String getLastDictionaryFormatName() {
    return _sharedPreferences.getString("lastDictionaryFormat") ??
        getDictionaryFormatNames().first;
  }

  /// Save a new active dictionary and remember it on application restart.
  Future<void> setLastDictionaryFormatName(String formatName) async {
    await _sharedPreferences.setString("lastDictionaryFormat", formatName);
  }

  Store? getDictionaryStore(String dictionaryName) {
    return _dictionaryStores[dictionaryName];
  }

  void removeDictionaryStore(String dictionaryName) {
    _dictionaryStores.remove(dictionaryName);
  }

  Future<void> deleteCurrentDictionary() async {
    String appDirDocPath = (await getApplicationDocumentsDirectory()).path;
    String dictionaryName = getCurrentDictionaryName();
    _resultsCache[dictionaryName] = {};

    List<DictionaryMediaHistoryItem> mediaHistoryItems =
        getDictionaryMediaHistory().getDictionaryItems().toList();

    /// Dispose of potential format breaking dictionary entries.
    for (DictionaryMediaHistoryItem item in mediaHistoryItems) {
      if (item.author == dictionaryName) {
        getDictionaryMediaHistory().removeDictionaryItem(item);
      }
    }

    if (getDictionaryRecord().length != 1) {
      setPrevDictionary();
    } else {
      await setCurrentDictionaryName("");
    }

    try {
      Store entryStore = _dictionaryStores[dictionaryName]!;
      Box entryBox = entryStore.box<DictionaryEntry>();
      entryBox.removeAll();
      entryStore.close();
      removeDictionaryStore(dictionaryName);

      Directory objectBoxDirDirectory = Directory(
        p.join(appDirDocPath, "customDictionaries", dictionaryName),
      );
      objectBoxDirDirectory.deleteSync(recursive: true);
    } finally {
      await removeDictionaryRecord(dictionaryName);
    }
  }

  Future<void> addDictionaryRecord(Dictionary dictionary) async {
    List<Dictionary> dictionaries = getDictionaryRecord();

    dictionaries.removeWhere((existingDictionary) =>
        existingDictionary.dictionaryName == dictionary.dictionaryName);
    dictionaries.add(dictionary);

    await setDictionaryRecord(dictionaries);
  }

  Future<void> removeDictionaryRecord(String dictionaryName) async {
    List<Dictionary> dictionaries = getDictionaryRecord();

    dictionaries.removeWhere(
        (dictionary) => dictionaryName == dictionary.dictionaryName);
    await setDictionaryRecord(dictionaries);
  }

  List<Dictionary> getDictionaryRecord() {
    String jsonList = _sharedPreferences.getString("dictionaryRecord") ?? '[]';

    List<dynamic> serialisedItems = (jsonDecode(jsonList) as List<dynamic>);

    List<Dictionary> dictionaries = [];
    for (var serialisedItem in serialisedItems) {
      Dictionary dictionary = Dictionary.fromJson(serialisedItem);
      dictionaries.add(dictionary);
    }

    return dictionaries;
  }

  Future<void> setDictionaryRecord(List<Dictionary> items) async {
    List<String> serialisedItems = [];
    for (Dictionary item in items) {
      serialisedItems.add(
        item.toJson(),
      );
    }

    await _sharedPreferences.setString(
      "dictionaryRecord",
      jsonEncode(serialisedItems),
    );
  }

  List<MediaSource> getMediaSourcesByType(MediaType mediaType) {
    return availableMediaSources[mediaType]!.values.toList();
  }

  List<String> getImportedDictionaryNames() {
    return getDictionaryRecord()
        .map((dictionary) => dictionary.dictionaryName)
        .toList();
  }

  List<String> getDictionaryFormatNames() {
    return availableDictionaryFormats.keys.toList();
  }

  String getTargetLanguageName() {
    return _sharedPreferences.getString("targetLanguage") ?? "日本語";
  }

  Future<void> setTargetLanguageName(String targetLanguage) async {
    await _sharedPreferences.setString("targetLanguage", targetLanguage);
    await initialiseCurrentLanguage();
    notifyListeners();
  }

  List<String> getAppLanguageNames() {
    return AppLocalizations.localizations();
  }

  String getAppLanguageName() {
    return _sharedPreferences.getString("appLanguage") ??
        AppLocalizations.localizations().first;
  }

  Future<void> setAppLanguageName(String appLanguage) async {
    await _sharedPreferences.setString("appLanguage", appLanguage);
    notifyListeners();
  }

  DictionaryFormat getDictionaryFormatFromName(String formatName) {
    return availableDictionaryFormats[formatName]!;
  }

  MediaSource getMediaSourceFromName(MediaType type, String sourceName) {
    return availableMediaSources[type]![sourceName]!;
  }

  Dictionary getDictionaryFromName(String dictionaryName) {
    return availableDictionaries[dictionaryName]!;
  }

  Language getCurrentLanguage() {
    return availableLanguages[getTargetLanguageName()]!;
  }

  Future<DictionarySearchResult> searchDictionary(
    String searchTerm, {
    MediaHistoryItem? mediaHistoryItem,
  }) async {
    _isSearching = true;
    searchTerm = searchTerm.trim();

    // For isolate updates.
    ReceivePort receivePort = ReceivePort();
    receivePort.listen((data) {
      debugPrint(data.toString());
    });

    Language currentLanguage = getCurrentLanguage();
    Dictionary currentDictionary = getCurrentDictionary()!;
    DictionaryFormat dictionaryFormat =
        getDictionaryFormatFromName(currentDictionary.formatName);

    _resultsCache[currentDictionary.dictionaryName] ??= {};

    if (_resultsCache[currentDictionary.dictionaryName]![searchTerm] != null) {
      return Future.value(
          _resultsCache[currentDictionary.dictionaryName]![searchTerm]!);
    }

    Store store = _dictionaryStores[currentDictionary.dictionaryName]!;
    ByteData storeReference = store.reference;

    /// Populate an empty [DictionarySearchResult] with metadata, it will be
    /// filled with database search results in the next step.
    DictionarySearchResult emptyResult = DictionarySearchResult(
      dictionaryName: currentDictionary.dictionaryName,
      formatName: currentDictionary.formatName,
      originalSearchTerm: searchTerm,
      fallbackSearchTerms:
          await currentLanguage.generateFallbackTerms(searchTerm),
      entries: [],
      storeReference: storeReference,
      mediaHistoryItem: mediaHistoryItem,
    );

    if (searchTerm.trim().isEmpty) {
      _isSearching = false;
      return emptyResult;
    }

    /// If the [DictionaryFormat] has a database search function override, use
    /// that instead of this.
    DictionarySearchResult unprocessedResult;
    ResultsProcessingParams params = ResultsProcessingParams(
      result: emptyResult,
      metadata: currentDictionary.metadata,
      sendPort: receivePort.sendPort,
    );
    unprocessedResult = await compute(
        dictionaryFormat.databaseSearchEnhancement ?? searchDatabase, params);

    /// If a [DictionaryFormat] has a specific post-processing method for a
    /// database search result, clean it up. Otherwise, do nothing.
    DictionarySearchResult processedResult;
    params = ResultsProcessingParams(
      result: unprocessedResult,
      metadata: currentDictionary.metadata,
      sendPort: receivePort.sendPort,
    );
    if (!dictionaryFormat.isOnline) {
      if (dictionaryFormat.searchResultsEnhancement != null) {
        processedResult =
            await compute(dictionaryFormat.searchResultsEnhancement!, params);
      } else {
        processedResult = unprocessedResult;
      }
    } else {
      if (dictionaryFormat.searchResultsEnhancement != null) {
        processedResult =
            await dictionaryFormat.searchResultsEnhancement!(params);
      } else {
        processedResult = unprocessedResult;
      }
    }

    if (processedResult.entries.isNotEmpty) {
      await addDictionaryHistoryItem(
        DictionaryMediaHistoryItem.fromDictionarySearchResult(
          processedResult,
        ),
      );
    }

    if (processedResult.entries.isNotEmpty) {
      _resultsCache[currentDictionary.dictionaryName]![searchTerm] =
          processedResult;
    }

    _isSearching = false;

    return processedResult;
  }

  void clearExportParams(AnkiExportParams params) {
    params.sentence = "";
    params.word = "";
    params.reading = "";
    params.meaning = "";
    params.extra = "";
    params.imageFile = null;
    params.audioFile = null;
  }

  List<AnkiExportEnhancement?> getExportEnabledFieldEnhancement(
      AnkiExportField field) {
    List<AnkiExportEnhancement?> enhancements = [];

    for (int i = 0; i < 4; i++) {
      String? positionKey = sharedPreferences.getString(
        AnkiExportEnhancement.getFieldEnabledPositionKey(field, i),
      );
      AnkiExportEnhancement? enhancement =
          _availableExportEnhancements[field]![positionKey];

      enhancements.add(enhancement);
    }

    return enhancements;
  }

  AnkiExportEnhancement? getAutoFieldEnhancement(AnkiExportField field) {
    String? positionKey = sharedPreferences.getString(
      AnkiExportEnhancement.getFieldAutoKey(field),
    );
    return _availableExportEnhancements[field]![positionKey];
  }

  List<AnkiExportEnhancement> getFieldExportEnhancements(
      AnkiExportField field) {
    List<AnkiExportEnhancement> enhancements =
        _availableExportEnhancements[field]!.values.toList();

    return enhancements;
  }

  DictionaryWidgetEnhancement? getFieldWidgetEnhancement(
      DictionaryWidgetField field) {
    String? positionKey = sharedPreferences
        .getString(DictionaryWidgetEnhancement.getFieldKey(field));

    return _availableWidgetEnhancements[field]![positionKey];
  }

  List<DictionaryWidgetEnhancement> getFieldWidgetEnhancements(
      DictionaryWidgetField field) {
    return _availableWidgetEnhancements[field]!.values.toList();
  }

  DictionaryMediaHistory getDictionaryMediaHistory() {
    return DictionaryMediaHistory(
      prefsDirectory: "dictionary_media_type",
      appModel: this,
    );
  }

  Map<String, int> getDictionaryHistoryIndexMap() {
    String indexMapJson =
        sharedPreferences.getString("dictionaryHistoryIndexMap") ?? "{}";
    Map<String, int> indexMap = Map<String, int>.from(jsonDecode(indexMapJson));

    return indexMap;
  }

  Future<void> setDictionaryHistoryIndexMap(Map<String, int> indexMap) async {
    await sharedPreferences.setString(
        "dictionaryHistoryIndexMap", jsonEncode(indexMap));
  }

  Future<void> addDictionaryHistoryItem(DictionaryMediaHistoryItem item) {
    return getDictionaryMediaHistory().addDictionaryItem(item);
  }

  int getDictionaryHistoryIndex(DictionaryMediaHistoryItem item) {
    Map<String, int> indexMap = getDictionaryHistoryIndexMap();
    return indexMap["${item.title}/${item.author}"] ?? 0;
  }

  Future<void> setDictionaryHistoryIndex(
      DictionaryMediaHistoryItem item, int? index) async {
    Map<String, int> indexMap = getDictionaryHistoryIndexMap();
    if (index == null) {
      indexMap.remove("${item.title}/${item.author}");
    } else {
      indexMap["${item.title}/${item.author}"] = index;
    }
    await setDictionaryHistoryIndexMap(indexMap);
  }

  Widget buildDictionarySearchResult({
    required BuildContext context,
    required DictionaryEntry dictionaryEntry,
    required DictionaryFormat dictionaryFormat,
    required Dictionary dictionary,
    required bool selectable,
  }) {
    Widget? word;
    Widget? reading;
    Widget? meaning;

    DictionaryWidgetEnhancement? wordEnhancement =
        getFieldWidgetEnhancement(DictionaryWidgetField.word);
    DictionaryWidgetEnhancement? readingEnhancement =
        getFieldWidgetEnhancement(DictionaryWidgetField.reading);
    DictionaryWidgetEnhancement? meaningEnhancement =
        getFieldWidgetEnhancement(DictionaryWidgetField.meaning);

    if (wordEnhancement != null) {
      word = wordEnhancement.buildWord(dictionaryEntry);
    }
    if (readingEnhancement != null) {
      reading = readingEnhancement.buildReading(dictionaryEntry);
    }
    if (meaningEnhancement != null) {
      meaning = meaningEnhancement.buildMeaning(dictionaryEntry);
    }

    if (dictionaryFormat.widgetDisplayEnhancement != null) {
      return dictionaryFormat.widgetDisplayEnhancement!(
        context: context,
        dictionaryEntry: dictionaryEntry,
        dictionaryFormat: dictionaryFormat,
        dictionary: dictionary,
        selectable: selectable,
      )
          .buildMainWidget(
        word: word,
        reading: reading,
        meaning: meaning,
      );
    } else {
      return DictionaryWidget(
        context: context,
        dictionaryEntry: dictionaryEntry,
        dictionaryFormat: dictionaryFormat,
        dictionary: dictionary,
        selectable: selectable,
      ).buildMainWidget(
        word: word,
        reading: reading,
        meaning: meaning,
      );
    }
  }

  String translate(String localisedValue) {
    return AppLocalizations.getLocalizedValue(
      getAppLanguageName(),
      localisedValue,
    );
  }

  String getAppLanguageCode() {
    return AppLocalizations.getLanguageCode(
      getAppLanguageName(),
    );
  }

  Directory getLastPickedDirectory(MediaType type) {
    return Directory(sharedPreferences.getString('$type/lastPickedFile') ??
        'storage/emulated/0');
  }

  Future<List<Directory>> getMediaTypeDirectories(MediaType type) async {
    List<Directory> directories = [];
    directories.add(getLastPickedDirectory(type));

    List<String> paths = await ExternalPath.getExternalStorageDirectories();
    for (String path in paths) {
      Directory directory = Directory(path);
      if (!directories.contains(directory)) {
        directories.add(directory);
      }
    }

    return directories;
  }

  Future<void> setLastPickedDirectory(
      MediaType type, Directory directory) async {
    await sharedPreferences.setString('$type/lastPickedFile', directory.path);
  }

  TextStyle getTextStyle() {
    return TextStyle(
      locale: getCurrentLanguage().getLocale(),
      textBaseline: getCurrentLanguage().getTextBaseline(),
    );
  }

  TextTheme getTextTheme() {
    return TextTheme(
      headline1: getTextStyle(),
      headline2: getTextStyle(),
      headline3: getTextStyle(),
      headline4: getTextStyle(),
      headline5: getTextStyle(),
      headline6: getTextStyle(),
      bodyText1: getTextStyle(),
      bodyText2: getTextStyle(),
      subtitle1: getTextStyle(),
      subtitle2: getTextStyle(),
      caption: getTextStyle(),
      button: getTextStyle(),
      overline: getTextStyle(),
    );
  }

  ThemeData getLightTheme(BuildContext context) {
    return ThemeData(
      backgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.red,
        secondary: Colors.red,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      focusColor: Colors.red,
      selectedRowColor: Colors.grey.shade300,
      primaryTextTheme:
          Typography.material2018(platform: TargetPlatform.android).black,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Colors.black,
        ),
      ),
      textTheme: (hasInitialized) ? getTextTheme() : null,
      iconTheme: const IconThemeData(color: Colors.black),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        elevation: 0,
      ),
      scrollbarTheme: const ScrollbarThemeData().copyWith(
        thumbColor: MaterialStateProperty.all(Colors.grey[500]),
      ),
      sliderTheme: const SliderThemeData(
        trackShape: RectangularSliderTrackShape(),
        trackHeight: 2.0,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
      ),
    );
  }

  ThemeData getDarkTheme(BuildContext context) {
    return ThemeData(
      backgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.red,
        secondary: Colors.red,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.grey.shade900,
      focusColor: Colors.red,
      selectedRowColor: Colors.grey.shade600,
      primaryTextTheme:
          Typography.material2018(platform: TargetPlatform.android).white,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Colors.white,
        ),
      ),
      textTheme: (hasInitialized) ? getTextTheme() : null,
      iconTheme: const IconThemeData(color: Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        elevation: 0,
      ),
      scrollbarTheme: const ScrollbarThemeData().copyWith(
        thumbColor: MaterialStateProperty.all(Colors.grey.shade700),
      ),
      sliderTheme: const SliderThemeData(
        trackShape: RectangularSliderTrackShape(),
        trackHeight: 2.0,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
      ),
    );
  }

  TextBaseline? getBaseline() {
    try {
      getCurrentLanguage();
    } catch (e) {
      return null;
    }

    Language language = getCurrentLanguage();

    if (language is JapaneseLanguage ||
        language is ChineseSimplifiedLanguage ||
        language is ChineseTraditionalLanguage ||
        language is KoreanLanguage) {
      return TextBaseline.ideographic;
    }

    if (language is EnglishLanguage) {
      return TextBaseline.alphabetic;
    }

    return null;
  }

  bool getIncognitoMode() {
    return sharedPreferences.getBool("incognitoMode") ?? false;
  }

  Future<void> toggleIncognitoMode() async {
    await sharedPreferences.setBool("incognitoMode", !getIncognitoMode());
  }

  bool getPlayerDefinitionFocusMode() {
    return sharedPreferences.getBool("playerDefinitionFocusMode") ?? false;
  }

  Future<void> togglePlayerDefinitionFocusMode() async {
    await sharedPreferences.setBool(
        "playerDefinitionFocusMode", !getPlayerDefinitionFocusMode());
  }

  bool getListeningComprehensionMode() {
    return sharedPreferences.getBool("playerListeningComprehensionMode") ??
        false;
  }

  Future<void> toggleListeningComprehensionMode() async {
    await sharedPreferences.setBool(
        "playerListeningComprehensionMode", !getListeningComprehensionMode());
  }

  bool getPlayerDragToSelectMode() {
    return sharedPreferences.getBool("playerDragToSelectMode") ?? false;
  }

  Future<void> togglePlayerDragToSelectMode() async {
    await sharedPreferences.setBool(
        "playerDragToSelectMode", !getPlayerDragToSelectMode());
  }

  BlurWidgetOptions getBlurWidgetOptions() {
    double width = sharedPreferences.getDouble("blurWidgetWidth") ?? 200;
    double height = sharedPreferences.getDouble("blurWidgetHeight") ?? 200;
    double left = sharedPreferences.getDouble("blurWidgetLeft") ?? -1;
    double top = sharedPreferences.getDouble("blurWidthTop") ?? -1;

    int colorRed = sharedPreferences.getInt("blurWidgetRed") ??
        Colors.black.withOpacity(0.5).red;
    int colorGreen = sharedPreferences.getInt("blurWidgetGreen") ??
        Colors.black.withOpacity(0.5).green;
    int colorBlue = sharedPreferences.getInt("blurWidgetBlue") ??
        Colors.black.withOpacity(0.5).blue;
    double colorOpacity = sharedPreferences.getDouble("blurWidgetOpacity") ??
        Colors.black.withOpacity(0.5).opacity;

    Color color = Color.fromRGBO(colorRed, colorGreen, colorBlue, colorOpacity);

    double blurRadius =
        sharedPreferences.getDouble("blurWidgetBlurRadius") ?? 5;
    bool visible = sharedPreferences.getBool("blurWidgetVisible") ?? false;

    return BlurWidgetOptions(
        width, height, left, top, color, blurRadius, visible);
  }

  Future<void> setBlurWidgetOptions(BlurWidgetOptions blurWidgetOptions) async {
    await sharedPreferences.setDouble(
        "blurWidgetWidth", blurWidgetOptions.width);
    await sharedPreferences.setDouble(
        "blurWidgetHeight", blurWidgetOptions.height);
    await sharedPreferences.setDouble("blurWidgetLeft", blurWidgetOptions.left);
    await sharedPreferences.setDouble("blurWidthTop", blurWidgetOptions.top);

    await sharedPreferences.setInt(
        "blurWidgetRed", blurWidgetOptions.color.red);
    await sharedPreferences.setInt(
        "blurWidgetGreen", blurWidgetOptions.color.green);
    await sharedPreferences.setInt(
        "blurWidgetBlue", blurWidgetOptions.color.blue);
    await sharedPreferences.setDouble(
        "blurWidgetOpacity", blurWidgetOptions.color.opacity);

    await sharedPreferences.setDouble(
        "blurWidgetBlurRadius", blurWidgetOptions.blurRadius);
    await sharedPreferences.setBool(
        "blurWidgetVisible", blurWidgetOptions.visible);
  }

  SubtitleOptions getSubtitleOptions() {
    int audioAllowance = sharedPreferences.getInt("audioAllowance") ?? 0;
    int subtitleDelay = sharedPreferences.getInt("subtitleDelay") ?? 0;
    double fontSize = sharedPreferences.getDouble("fontSize") ?? 24;
    String regexFilter = sharedPreferences.getString("regexFilter") ?? "";

    return SubtitleOptions(
      audioAllowance,
      subtitleDelay,
      fontSize,
      regexFilter,
    );
  }

  Future setSubtitleOptions(SubtitleOptions subtitleOptions) async {
    await sharedPreferences.setInt(
        "audioAllowance", subtitleOptions.audioAllowance);
    await sharedPreferences.setInt(
        "subtitleDelay", subtitleOptions.subtitleDelay);
    await sharedPreferences.setDouble("fontSize", subtitleOptions.fontSize);
    await sharedPreferences.setString(
        "regexFilter", subtitleOptions.regexFilter);
  }

  String getLastAnkiDroidDeck() {
    return _sharedPreferences.getString("lastAnkiDroidDeck") ?? "Default";
  }

  Future<void> setLastAnkiDroidDeck(String deckName) async {
    await _sharedPreferences.setString("lastAnkiDroidDeck", deckName);
  }

  Future<void> addToSearchHistory(String key,
      {String historyType = "dictionary"}) async {
    if (getIncognitoMode()) {
      return;
    }

    int maxSearchHistoryCount = 100;
    List<String> searchHistory = getSearchHistory(historyType: historyType);

    searchHistory.removeWhere((historyKey) => key == historyKey);
    searchHistory.add(key);

    if (searchHistory.length >= maxSearchHistoryCount) {
      searchHistory =
          searchHistory.sublist(searchHistory.length - maxSearchHistoryCount);
    }

    await setSearchHistory(searchHistory, historyType: historyType);
  }

  Future<void> removeFromSearchHistory(String key,
      {String historyType = "dictionary"}) async {
    List<String> searchHistory = getSearchHistory(historyType: historyType);
    searchHistory.remove(key);
    await setSearchHistory(searchHistory, historyType: historyType);
  }

  Future<void> setSearchHistory(List<String> searchHistory,
      {String historyType = "dictionary"}) async {
    await sharedPreferences.setStringList(
        "searchHistory/$historyType", searchHistory);
  }

  List<String> getSearchHistory({String historyType = "dictionary"}) {
    List<String> searchHistory =
        sharedPreferences.getStringList("searchHistory/$historyType") ?? [];
    return searchHistory;
  }

  MediaHistoryItem? getResumeMediaHistoryItem() {
    String? itemJson = sharedPreferences.getString("resumeMediaHistoryItem");

    if (itemJson == null) {
      return null;
    }

    return MediaHistoryItem.fromJson(itemJson);
  }

  bool isResumable() {
    return getResumeMediaHistoryItem() != null;
  }

  bool isFirstTimeInitialised() {
    return sharedPreferences.getBool("firstTimeInitialisation") ?? false;
  }

  Future<void> setFirstTimeInitialised() async {
    await sharedPreferences.setBool("firstTimeInitialisation", true);
  }

  bool isPlayerOrientationPortrait() {
    return sharedPreferences.getBool("isPlayerOrientationPortrait") ?? false;
  }

  Future<void> togglePlayerOrientationPortrait() async {
    await sharedPreferences.setBool(
        "isPlayerOrientationPortrait", !isPlayerOrientationPortrait());
  }

  bool isViewerRightToLeft() {
    return sharedPreferences.getBool("isViewerRightToLeft") ?? false;
  }

  Future<void> toggleViewerRightToLeft() async {
    await sharedPreferences.setBool(
        "isViewerRightToLeft", !isViewerRightToLeft());
  }

  Color getViewerColorBackground() {
    int colorRed = sharedPreferences.getInt("viewerBackgroundRed") ??
        Colors.black.withOpacity(0).red;
    int colorGreen = sharedPreferences.getInt("viewerBackgroundGreen") ??
        Colors.black.withOpacity(0).green;
    int colorBlue = sharedPreferences.getInt("viewerBackgroundBlue") ??
        Colors.black.withOpacity(0).blue;

    Color color = Color.fromRGBO(colorRed, colorGreen, colorBlue, 1.0);

    return color;
  }

  Future<void> setViewerColorBackground(Color color) async {
    await sharedPreferences.setInt("viewerBackgroundRed", color.red);
    await sharedPreferences.setInt("viewerBackgroundGreen", color.green);
    await sharedPreferences.setInt("viewerBackgroundBlue", color.blue);
  }

  void refresh() {
    notifyListeners();
  }
}

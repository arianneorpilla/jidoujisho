import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:chisa/dictionary/formats/yomichan_term_bank_format.dart';
import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/language/languages/english_language.dart';
import 'package:chisa/language/languages/japanese_language.dart';
import 'package:chisa/media/media_histories/default_media_history.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_sources/player_local_media_source.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_sources/reader_media_source.dart';
import 'package:chisa/media/media_sources/viewer_media_source.dart';
import 'package:chisa/media/media_sources_dialog.dart';
import 'package:chisa/media/media_types/dictionary_media_type.dart';
import 'package:chisa/media/media_types/player_media_type.dart';
import 'package:chisa/media/media_types/reader_media_type.dart';
import 'package:chisa/media/media_types/viewer_media_type.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

import 'package:chisa/media/media_histories/dictionary_media_history.dart';
import 'package:chisa/media/media_history_items/dictionary_media_history_item.dart';
import 'package:chisa/media/media_history_item.dart';
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
import 'package:chisa/media/media_type.dart';
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

  /// For saving options and settings and persisting across app restarts.
  final SharedPreferences _sharedPreferences;
  SharedPreferences get sharedPreferences => _sharedPreferences;

  /// Necessary to get version details upon app start.
  final PackageInfo _packageInfo;
  PackageInfo get packageInfo => _packageInfo;

  /// Flag to ensure initialisation doesn't happen after the first time.
  bool _hasInitialised = false;
  bool get hasInitialized => _hasInitialised;

  /// If this is on, no dictionary search operations should be startable.
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  /// Saves the offset scroll value of the dictionary.
  double _scrollOffset = 0;
  get scrollOffset => _scrollOffset;
  set setScrollOffset(double offset) {
    _scrollOffset = offset;
  }

  /// All populated in initialisation when the app is started.
  final Map<String, Dictionary> _availableDictionaries = {};
  final Map<String, DictionaryFormat> _availableDictionaryFormats = {};
  final Map<String, Language> _availableLanguages = {};
  final Map<String, MediaType> _availableMediaTypes = {};
  final Map<String, Map<String, MediaSource>> _availableMediaSources = {};
  final Map<AnkiExportField, Map<String, AnkiExportEnhancement>>
      _availableExportEnhancements = {};
  final Map<DictionaryWidgetField, Map<String, DictionaryWidgetEnhancement>>
      _availableWidgetEnhancements = {};

  final Map<String, Store> _dictionaryStores = {};

  final List<MediaType> _mediaTypes = [
    PlayerMediaType(),
    ReaderMediaType(),
    DictionaryMediaType(),
  ];
  List<MediaType> get mediaTypes => _mediaTypes;

  /// Cache for dictionaries to use if they need to improve performance.
  final Map<String, Map<String, dynamic>> _dictionaryCache = {};

  Map<String, Dictionary> get availableDictionaries => _availableDictionaries;
  Map<String, DictionaryFormat> get availableDictionaryFormats =>
      _availableDictionaryFormats;
  Map<String, Language> get availableLanguages => _availableLanguages;
  Map<String, MediaType> get availableMediaTypes => _availableMediaTypes;
  Map<String, Map<String, MediaSource>> get availableMediaSources =>
      _availableMediaSources;
  Map<AnkiExportField, Map<String, AnkiExportEnhancement>>
      get availableExportEnhancements => _availableExportEnhancements;
  Map<DictionaryWidgetField, Map<String, DictionaryWidgetEnhancement>>
      get availableWidgetEnhancements => _availableWidgetEnhancements;

  List<DictionaryFormat> dictionaryFormats = [
    YomichanTermBankFormat(),
  ];
  List<PlayerMediaSource> playerMediaSources = [
    PlayerLocalMediaSource(),
  ];
  List<ReaderMediaSource> readerMediaSources = [];
  List<ViewerMediaSource> viewerMediaSources = [];

  Future<void> initialiseAppModel() async {
    if (!_hasInitialised) {
      populateDictionaryFormats();
      populateLanguages();
      populateMediaTypes();
      populateMediaSources();
      populateExportEnhancements();
      populateWidgetEnhancements();

      await initialiseImportedDictionaries();
      await initialiseExportEnhancements();
      await initialiseWidgetEnhancements();
      await initialiseCurrentLanguage();

      _hasInitialised = true;
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
      JapaneseLanguage(),
      EnglishLanguage(),
    ];

    for (Language language in languages) {
      _availableLanguages[language.languageName] = language;
    }
  }

  void populateMediaTypes() {
    for (MediaType mediaType in mediaTypes) {
      _availableMediaTypes[mediaType.mediaTypeName] = mediaType;
    }
  }

  void populateMediaSources() {
    for (MediaType mediaType in mediaTypes) {
      _availableMediaSources[mediaType.mediaTypeName] = {};
    }

    for (PlayerMediaSource source in playerMediaSources) {
      _availableMediaSources["Player"]![source.sourceName] = source;
    }
    for (ReaderMediaSource source in readerMediaSources) {
      _availableMediaSources["Reader"]![source.sourceName] = source;
    }
    // for (ViewerMediaSource source in viewerMediaSources) {
    //   _availableMediaSources["Viewer"]![source.sourceName] = source;
    // }
  }

  void populateExportEnhancements() {
    List<AnkiExportEnhancement> imageEnhancements = [
      ClearButtonEnhancement(
        appModel: this,
        enhancementField: AnkiExportField.image,
      ),
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
    ];
    List<AnkiExportEnhancement> wordEnhancements = [
      ClearButtonEnhancement(
        appModel: this,
        enhancementField: AnkiExportField.word,
      ),
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
    getDictionaryRecord().forEach((dictionary) async {
      _dictionaryStores[dictionary.dictionaryName] =
          await initialiseDictionaryStore(dictionary.dictionaryName);
      _availableDictionaries[dictionary.dictionaryName] = dictionary;
    });
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
    return _sharedPreferences.getBool("isDarkMode") ?? false;
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
    String? lastActiveMediaType =
        _sharedPreferences.getString("lastActiveMediaType");

    if (lastActiveMediaType == null) {
      return 0;
    } else {
      return mediaTypes.indexWhere(
          (mediaType) => mediaType.mediaTypeName == lastActiveMediaType);
    }
  }

  /// Save the last index and remember it on application restart.
  Future<void> setLastActiveTabIndex(int tabIndex) async {
    await _sharedPreferences.setString(
        "lastActiveMediaType", mediaTypes[tabIndex].mediaTypeName);
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
    return availableMediaSources[mediaType.mediaTypeName]![
        getCurrentMediaTypeSourceName(mediaType)]!;
  }

  String getCurrentMediaTypeSourceName(MediaType mediaType) {
    return _sharedPreferences
            .getString("${mediaType.mediaTypeName}/currentSource") ??
        availableMediaSources[mediaType.mediaTypeName]!.values.first.sourceName;
  }

  Future<void> setCurrentMediaTypeSourceName(
      MediaType type, String sourceName) async {
    await _sharedPreferences.setString(
        "${type.mediaTypeName}/currentSource", sourceName);
  }

  bool getMediaSourceShown(MediaSource source) {
    return _sharedPreferences.getBool(
            "${source.mediaType.mediaTypeName}/${source.sourceName}/shown") ??
        false;
  }

  Future<void> setMediaSourceShown(MediaSource source, bool shown) async {
    await _sharedPreferences.setBool(
        "${source.mediaType.mediaTypeName}/${source.sourceName}/shown", shown);
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
  }) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => DictionaryDialog(
        manageAllowed: manageAllowed,
      ),
    );
  }

  /// Show the dictionary menu. This should be callable from many parts of the
  /// app, so it is appropriately handled by the model.
  Future<void> showSourcesMenu(
    BuildContext context,
    MediaType mediaType, {
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

  Future<void> deleteCurrentDictionary() async {
    String appDirDocPath = (await getApplicationDocumentsDirectory()).path;
    String dictionaryName = getCurrentDictionaryName();

    List<DictionaryMediaHistoryItem> mediaHistoryItems =
        getDictionaryMediaHistory().getDictionaryItems().toList();
    List<DictionarySearchResult> results = mediaHistoryItems
        .map((item) => DictionarySearchResult.fromJson(item.key))
        .toList();

    /// Dispose of potential format breaking dictionary entries.
    for (DictionarySearchResult result in results) {
      if (result.dictionaryName == dictionaryName) {
        getDictionaryMediaHistory().removeDictionaryItem(result.toJson());
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
    return availableMediaSources[mediaType.mediaTypeName]!.values.toList();
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
    return _sharedPreferences.getString("targetLanguage") ??
        availableLanguages.keys.first;
  }

  Future<void> setTargetLanguageName(String targetLanguage) async {
    await _sharedPreferences.setString("targetLanguage", targetLanguage);
    await initialiseCurrentLanguage();
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

  MediaSource getMediaSourceFromName(String mediaTypeName, String sourceName) {
    return availableMediaSources[mediaTypeName]![sourceName]!;
  }

  Dictionary getDictionaryFromName(String dictionaryName) {
    return availableDictionaries[dictionaryName]!;
  }

  Language getCurrentLanguage() {
    return availableLanguages[getTargetLanguageName()]!;
  }

  MediaType getMediaTypeFromName(String mediaTypeName) {
    return availableMediaTypes[mediaTypeName]!;
  }

  Future<DictionarySearchResult> searchDictionary(
    String searchTerm, {
    String contextSource = "",
    int contextPosition = -1,
    String contextMediaTypeName = "",
  }) async {
    _isSearching = true;
    searchTerm = searchTerm.trim();

    // For isolate updates.
    ReceivePort receivePort = ReceivePort();
    receivePort.listen((data) {
      debugPrint(data);
    });

    Language currentLanguage = getCurrentLanguage();
    Dictionary currentDictionary = getCurrentDictionary()!;
    DictionaryFormat dictionaryFormat =
        getDictionaryFormatFromName(currentDictionary.formatName);

    Store store = _dictionaryStores[currentDictionary.dictionaryName]!;
    ByteData storeReference = store.reference;

    /// Populate an empty [DictionarySearchResult] with metadata, it will be
    /// filled with database search results in the next step.
    DictionarySearchResult emptyResult = DictionarySearchResult(
      dictionaryName: currentDictionary.dictionaryName,
      formatName: currentDictionary.formatName,
      originalSearchTerm: searchTerm,
      fallbackSearchTerms: currentLanguage.generateFallbackTerms(searchTerm),
      entries: [],
      storeReference: storeReference,
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
    if (dictionaryFormat.searchResultsEnhancement != null) {
      processedResult =
          await compute(dictionaryFormat.searchResultsEnhancement!, params);
    } else {
      processedResult = unprocessedResult;
    }

    if (processedResult.entries.isNotEmpty) {
      await addDictionaryHistoryItem(
        DictionaryMediaHistoryItem.fromDictionarySearchResult(
          processedResult,
        ),
      );
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
      sharedPreferences: sharedPreferences,
    );
  }

  DefaultMediaHistory getMediaHistory(MediaType mediaType) {
    return DefaultMediaHistory(
      prefsDirectory: mediaType.mediaTypeName,
      sharedPreferences: sharedPreferences,
    );
  }

  Future<void> addDictionaryHistoryItem(MediaHistoryItem item) {
    return getDictionaryMediaHistory().addItem(item);
  }

  Future<void> updateDictionaryHistoryIndex(
      DictionaryMediaHistoryItem newItem, int index) async {
    List<DictionaryMediaHistoryItem> history =
        getDictionaryMediaHistory().getDictionaryItems();
    history.firstWhere((entry) => entry.key == newItem.key).progress =
        newItem.progress;

    await getDictionaryMediaHistory().setItems(history);
  }

  Future<void> removeDictionaryHistoryItem(DictionarySearchResult result) {
    return getDictionaryMediaHistory().removeItem(result.toJson());
  }

  Widget buildDictionarySearchResult({
    required BuildContext context,
    required DictionaryEntry dictionaryEntry,
    required DictionaryFormat dictionaryFormat,
    required Dictionary dictionary,
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

  Directory getLastPickedDirectory(MediaType type) {
    return Directory(
        sharedPreferences.getString('${type.mediaTypeName}/lastPickedFile') ??
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
    await sharedPreferences.setString(
        '${type.mediaTypeName}/lastPickedFile', directory.path);
  }

  // MediaSource getActiveMediaTypeSource(MediaType type) {
  //   return Directory(
  //       sharedPreferences.getString('${type.mediaTypeName}/lastPickedFile') ??
  //           'storage/emulated/0');
  // }

  // Future<void> setActiveMediaTypeSource(
  //     MediaType type, Directory directory) async {
  //   await sharedPreferences.setString(
  //       '${type.mediaTypeName}/lastPickedFile', directory.path);
  // }
}

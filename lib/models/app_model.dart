import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:chisa/language/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';

import 'package:chisa/media/histories/dictionary_media_history.dart';
import 'package:chisa/media/history_items/dictionary_media_history_item.dart';
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
import 'package:chisa/util/dictionary_entry_widget.dart';
import 'package:chisa/dictionary/dictionary_widget_enhancement.dart';
import 'package:chisa/dictionary/enhancements/pitch_accent_enhancement.dart';
import 'package:chisa/dictionary/formats/yomichan_term_bank_format.dart';

import 'package:chisa/language/language.dart';
import 'package:chisa/language/language_dialog.dart';
import 'package:chisa/language/languages/english_language.dart';
import 'package:chisa/language/languages/japanese_language.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/dictionary_media_type.dart';
import 'package:chisa/media/media_types/reader_media_type.dart';
import 'package:chisa/media/media_types/player_media_type.dart';
import 'package:chisa/objectbox.g.dart';
import 'package:chisa/util/anki_export_field.dart';

/// A scoped model for parameters that affect the entire application.
/// [Provider] is used for global state management across multiple layers,
/// especially for preferences that persist across application restarts.
class AppModel with ChangeNotifier {
  AppModel({
    required sharedPreferences,
    required packageInfo,
  })  : _sharedPreferences = sharedPreferences,
        _packageInfo = packageInfo;

  final Map<String, Store> _dictionaryStores = {};
  final SharedPreferences _sharedPreferences;
  final PackageInfo _packageInfo;
  bool _isSearching = false;

  final Map<String, DictionaryFormat> _availableDictionaryFormats = {
    "Yomichan Term Bank": YomichanTermBankFormat()
  };

  /// Cache for dictionaries to use if they need to improve performance.
  final Map<String, Map<String, dynamic>> _dictionaryCache = {};

  final Map<String, Dictionary> _availableDictionaries = {};
  final List<MediaType> _availableMediaTypes = [
    PlayerMediaType(),
    ReaderMediaType(),
    DictionaryMediaType(),
  ];

  final Map<String, Language> _availableLanguages = {
    '日本語': JapaneseLanguage(),
    'English': EnglishLanguage(),
  };

  /// Populated in [initialiseExportEnhancements] when the app is started.
  final List<AnkiExportEnhancement> _availableExportEnhancements = [];

  /// Populated in [initialiseExportEnhancements] when the app is started.
  final List<DictionaryWidgetEnhancement> _availableWidgetEnhancements = [];

  bool _hasInitialized = false;
  bool get isSearching => _isSearching;
  PackageInfo get packageInfo => _packageInfo;
  SharedPreferences get sharedPreferences => _sharedPreferences;

  /// Save the offset scroll value of the dictionary.
  double scrollOffset = 0;

  List<AnkiExportEnhancement> get availableExportEnhancements =>
      _availableExportEnhancements;

  List<MediaType> get availableMediaTypes => _availableMediaTypes;
  Map<String, Language> get availableLanguages => _availableLanguages;
  Map<String, Dictionary> get availableDictionaries => _availableDictionaries;
  Map<String, DictionaryFormat> get availableDictionaryFormats =>
      _availableDictionaryFormats;

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
      return availableMediaTypes.indexWhere(
          (mediaType) => mediaType.mediaTypeName == lastActiveMediaType);
    }
  }

  /// Save the last index and remember it on application restart.
  Future<void> setLastActiveTabIndex(int tabIndex) async {
    await _sharedPreferences.setString(
        "lastActiveMediaType", availableMediaTypes[tabIndex].mediaTypeName);
  }

  /// Get the current active dictionary, the last one used.
  String getCurrentDictionaryName() {
    return _sharedPreferences.getString("currentDictionaryName") ?? "";
  }

  /// Save a new active dictionary and remember it on application restart.
  Future<void> setCurrentDictionaryName(String dictionaryName) async {
    await _sharedPreferences.setString("currentDictionaryName", dictionaryName);
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
  Future<void> showDictionaryMenu(BuildContext context,
      {manageAllowed = false}) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => DictionaryDialog(
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

  Future<void> initialiseAppModel() async {
    if (!_hasInitialized) {
      await initialiseImportedDictionaries();
      await initialiseExportEnhancements();
      await initialiseWidgetEnhancements();
      await initialiseLanguage();

      _hasInitialized = true;
      notifyListeners();
    }
  }

  Future<void> initialiseImportedDictionaries() async {
    getDictionaryRecord().forEach((dictionary) {
      initialiseImportedDictionary(dictionary);
    });
  }

  Future<void> initialiseExportEnhancements() async {
    for (AnkiExportField field in AnkiExportField.values) {
      _availableExportEnhancements.add(
        ClearButtonEnhancement(
          appModel: this,
          enhancementField: field,
        ),
      );
    }
    _availableExportEnhancements.addAll([
      PitchAccentExportEnhancement(appModel: this),
    ]);

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
    // for (DictionaryWidgetField field in DictionaryWidgetField.values) {
    //   _availableExportEnhancements.add(
    //     ClearButtonEnhancement(
    //       appModel: this,
    //       enhancementField: field,
    //     ),
    //   );
    // }
    _availableWidgetEnhancements.addAll([
      PitchAccentEnhancement(appModel: this),
    ]);

    for (DictionaryWidgetField field in DictionaryWidgetField.values) {
      DictionaryWidgetEnhancement? enhancement =
          getFieldWidgetEnhancement(field);
      if (enhancement != null && !enhancement.isInitialised) {
        await enhancement.initialiseEnhancement();
        enhancement.isInitialised = true;
      }
    }
  }

  Future<void> initialiseLanguage() async {
    Language language = getCurrentLanguage();
    if (!language.isInitialised) {
      language.initialiseLanguage();
    }
  }

  Future<Store> initialiseImportedDictionary(Dictionary dictionary) async {
    String appDirDocPath = (await getApplicationDocumentsDirectory()).path;

    Directory objectBoxDirDirectory = Directory(
      p.join(appDirDocPath, "customDictionaries", dictionary.dictionaryName),
    );
    if (!objectBoxDirDirectory.existsSync()) {
      objectBoxDirDirectory.createSync(recursive: true);
    }

    _dictionaryStores[dictionary.dictionaryName] = Store(
      getObjectBoxModel(),
      directory: objectBoxDirDirectory.path,
    );

    _availableDictionaries[dictionary.dictionaryName] = dictionary;

    return _dictionaryStores[dictionary.dictionaryName]!;
  }

  Dictionary? getCurrentDictionary() {
    return getDictionaryRecord().firstWhereOrNull((dictionary) =>
        dictionary.dictionaryName == getCurrentDictionaryName());
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
    await initialiseLanguage();
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

  Dictionary getDictionaryFromName(String dictionaryName) {
    return availableDictionaries[dictionaryName]!;
  }

  Language getCurrentLanguage() {
    return availableLanguages[getTargetLanguageName()]!;
  }

  MediaType getMediaTypeFromName(String mediaTypeName) {
    return availableMediaTypes
        .firstWhere((mediaType) => mediaType.mediaTypeName == mediaTypeName);
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
      AnkiExportEnhancement? enhancement =
          _availableExportEnhancements.firstWhereOrNull((enhancement) =>
              enhancement.enhancementField == field &&
              enhancement.enhancementName ==
                  sharedPreferences.getString(
                      AnkiExportEnhancement.getFieldEnabledPositionKey(
                          field, i)));

      enhancements.add(enhancement);
    }

    return enhancements;
  }

  AnkiExportEnhancement? getAutoFieldEnhancement(AnkiExportField field) {
    return _availableExportEnhancements.firstWhereOrNull((enhancement) =>
        enhancement.enhancementField == field &&
        enhancement.enhancementName ==
            sharedPreferences
                .getString(AnkiExportEnhancement.getFieldAutoKey(field)));
  }

  List<AnkiExportEnhancement> getFieldExportEnhancements(
      AnkiExportField field) {
    List<AnkiExportEnhancement> enhancements = _availableExportEnhancements
        .where((enhancement) => enhancement.enhancementField == field)
        .toList();

    return enhancements;
  }

  DictionaryWidgetEnhancement? getFieldWidgetEnhancement(
      DictionaryWidgetField field) {
    return _availableWidgetEnhancements.firstWhereOrNull((enhancement) =>
        enhancement.enhancementField == field &&
        enhancement.enhancementName ==
            sharedPreferences
                .getString(DictionaryWidgetEnhancement.getFieldKey(field)));
  }

  List<DictionaryWidgetEnhancement> getFieldWidgetEnhancements(
      DictionaryWidgetField field) {
    List<DictionaryWidgetEnhancement> enhancements =
        _availableWidgetEnhancements
            .where((enhancement) => enhancement.enhancementField == field)
            .toList();

    return enhancements;
  }

  DictionaryMediaHistory getDictionaryMediaHistory() {
    return DictionaryMediaHistory(
      prefsDirectory: "dictionary_media_type",
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

  Widget buildDictionarySearchResult(
    BuildContext context,
    DictionaryEntry dictionaryEntry,
    DictionaryFormat dictionaryFormat,
    Dictionary dictionary,
  ) {
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
}

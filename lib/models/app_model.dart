import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/anki/enhancements/clear_button.dart';
import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_dialog.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_search_results.dart';
import 'package:chisa/dictionary/dictionary_utils.dart';
import 'package:chisa/dictionary/formats/yomichan_term_bank_format.dart';
import 'package:chisa/language/app_localizations.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';

/// A scoped model for parameters that affect the entire application.
/// [Provider] is used for global state management across multiple layers,
/// especially for preferences that persist across application restarts.
class AppModel with ChangeNotifier {
  Language _language;
  final Map<String, Store> _dictionaryStores = {};
  final SharedPreferences _sharedPreferences;
  final PackageInfo _packageInfo;
  AnkiExportParams _ankiExportParams = AnkiExportParams();

  final List<DictionaryFormat> _availableDictionaryFormats = [
    YomichanTermBankFormat(),
  ];
  final List<MediaType> _availableMediaTypes = [
    PlayerMediaType(),
    ReaderMediaType(),
    DictionaryMediaType(),
  ];
  final List<Language> _availableLanguages = [
    JapaneseLanguage(),
    EnglishLanguage(),
  ];
  final List<AnkiExportEnhancement> _availableExportEnhancements = [];

  bool _firstTimeInitialisation = true;

  Language get language => _language;
  PackageInfo get packageInfo => _packageInfo;
  SharedPreferences get sharedPreferences => _sharedPreferences;

  List<AnkiExportEnhancement> get availableExportEnhancements =>
      _availableExportEnhancements;

  List<MediaType> get availableMediaTypes => _availableMediaTypes;
  List<Language> get availableLanguages => _availableLanguages;
  List<DictionaryFormat> get availableDictionaryFormats =>
      _availableDictionaryFormats;
  AnkiExportParams get ankiExportParams => _ankiExportParams;

  AppModel({
    required sharedPreferences,
    required packageInfo,
  })  : _language = JapaneseLanguage(),
        _sharedPreferences = sharedPreferences,
        _packageInfo = packageInfo;

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

  /// Change the language to the new provided option.
  void changeLanguage(Language language) {
    _language = language;
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
          (mediaType) => lastActiveMediaType == mediaType.mediaTypeName);
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
    if (_firstTimeInitialisation) {
      await initialiseImportedDictionaries();
      initialiseExportEnhancements();
      for (Language language in availableLanguages) {
        await language.initialiseLanguage();
      }
      _firstTimeInitialisation = false;
    }
  }

  void initialiseExportEnhancements() {
    for (AnkiExportField field in AnkiExportField.values) {
      _availableExportEnhancements
          .add(ClearButton(appModel: this, enhancementField: field));
    }
    _availableExportEnhancements.addAll([]);
  }

  Future<void> initialiseImportedDictionaries() async {
    getDictionaryRecord().forEach((dictionary) {
      initialiseImportedDictionary(dictionary.dictionaryName);
    });
  }

  Future<Store> initialiseImportedDictionary(String dictionaryName) async {
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

  Dictionary getCurrentDictionary() {
    return getDictionaryRecord().firstWhere((dictionary) =>
        dictionary.dictionaryName == getCurrentDictionaryName());
  }

  Future<void> deleteCurrentDictionary() async {
    String appDirDocPath = (await getApplicationDocumentsDirectory()).path;
    String dictionaryName = getCurrentDictionaryName();

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
    return availableDictionaryFormats
        .map((format) => format.formatName)
        .toList();
  }

  String getTargetLanguageName() {
    return _sharedPreferences.getString("targetLanguage") ??
        availableLanguages.first.languageName;
  }

  Future<void> setTargetLanguageName(String targetLanguage) async {
    await _sharedPreferences.setString("targetLanguage", targetLanguage);
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
    return availableDictionaryFormats
        .firstWhere((format) => format.formatName == formatName);
  }

  Language getCurrentLangauge() {
    return availableLanguages.firstWhere(
        (language) => language.languageName == getTargetLanguageName());
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
    Language currentLanguage = getCurrentLangauge();
    Dictionary currentDictionary = getCurrentDictionary();

    Store store = _dictionaryStores[currentDictionary.dictionaryName]!;
    ByteData storeReference = store.reference;

    DictionarySearchResult unprocessedResult = DictionarySearchResult(
        dictionaryName: currentDictionary.dictionaryName,
        formatName: currentDictionary.formatName,
        originalSearchTerm: searchTerm,
        fallbackSearchTerm: currentLanguage.getRootForm(searchTerm),
        results: [],
        storeReference: storeReference);
    DictionarySearchResult processedResult =
        await compute(searchDatabase, unprocessedResult);

    return Future.value(processedResult);
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

  void setExportParams(AnkiExportParams params) {
    _ankiExportParams = params;
    notifyListeners();
  }

  void setExportWord(String word) {
    _ankiExportParams.word = word;
    notifyListeners();
  }

  void setExportSentence(String context) {
    _ankiExportParams.sentence = context;
    notifyListeners();
  }

  void setExportReading(String reading) {
    _ankiExportParams.reading = reading;
    notifyListeners();
  }

  void setExportMeaning(String meaning) {
    _ankiExportParams.meaning = meaning;
    notifyListeners();
  }

  void setExportExtra(String extra) {
    _ankiExportParams.extra = extra;
    notifyListeners();
  }

  void setExportImageFile(File? imageFile) {
    _ankiExportParams.imageFile = imageFile;
    notifyListeners();
  }

  void setExportAudioFile(File? audioFile) {
    _ankiExportParams.audioFile = audioFile;
    notifyListeners();
  }

  List<AnkiExportEnhancement?> getExportEnabledFieldEnhancement(
      AnkiExportField field) {
    List<AnkiExportEnhancement?> enhancements = [];

    for (int i = 0; i < 3; i++) {
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

  List<AnkiExportEnhancement> getFieldEnhancements(AnkiExportField field) {
    List<AnkiExportEnhancement> enhancements = _availableExportEnhancements
        .where((enhancement) => enhancement.enhancementField == field)
        .toList();

    return enhancements;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:daijidoujisho/dictionary/dictionary.dart';
import 'package:daijidoujisho/dictionary/dictionary_dialog.dart';
import 'package:daijidoujisho/dictionary/dictionary_entry.dart';
import 'package:daijidoujisho/dictionary/dictionary_format.dart';
import 'package:daijidoujisho/dictionary/formats/yomichan_term_bank_format.dart';
import 'package:daijidoujisho/language/app_localizations.dart';
import 'package:daijidoujisho/language/language.dart';
import 'package:daijidoujisho/language/language_dialog.dart';
import 'package:daijidoujisho/language/languages/english_language.dart';
import 'package:daijidoujisho/language/languages/japanese_language.dart';
import 'package:daijidoujisho/media/media_type.dart';
import 'package:daijidoujisho/media/media_types/reader_media_type.dart';
import 'package:daijidoujisho/media/media_types/player_media_type.dart';
import 'package:daijidoujisho/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

/// A scoped model for parameters that affect the entire application.
/// [Provider] is used for global state management across multiple layers,
/// especially for preferences that persist across application restarts.
class AppModel with ChangeNotifier {
  Language _language;
  final Map<String, Store> _dictionaryStores = {};
  final SharedPreferences _sharedPreferences;
  final PackageInfo _packageInfo;

  Language get language => _language;
  PackageInfo get packageInfo => _packageInfo;

  List<MediaType> get availableMediaTypes => [
        PlayerMediaType(),
        ReaderMediaType(),
      ];

  List<Language> get availableLanguages => [
        JapaneseLanguage(),
        EnglishLanguage(),
      ];

  List<DictionaryFormat> get availableDictionaryFormats => [
        YomichanTermBankFormat(),
      ];

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
  String getLastDictionaryFormat() {
    return _sharedPreferences.getString("lastDictionaryFormat") ??
        getDictionaryFormatNames().first;
  }

  /// Save a new active dictionary and remember it on application restart.
  Future<void> setLastDictionaryFormat(String formatName) async {
    await _sharedPreferences.setString("lastDictionaryFormat", formatName);
  }

  Store? getDictionaryStore(String dictionaryName) {
    return _dictionaryStores[dictionaryName];
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

  Future<void> deleteImportedDictionary(String dictionaryName) async {
    String appDirDocPath = (await getApplicationDocumentsDirectory()).path;

    Store entryStore = _dictionaryStores[dictionaryName]!;
    Box entryBox = entryStore.box<DictionaryEntry>();
    entryBox.removeAll();
    entryStore.close();

    Directory objectBoxDirDirectory = Directory(
      p.join(appDirDocPath, "customDictionaries", dictionaryName),
    );
    objectBoxDirDirectory.deleteSync(recursive: true);

    await removeDictionaryRecord(dictionaryName);
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

  String getTargetLanguage() {
    return _sharedPreferences.getString("targetLanguage") ??
        availableLanguages.first.languageName;
  }

  Future<void> setTargetLanguage(String targetLanguage) async {
    await _sharedPreferences.setString("targetLanguage", targetLanguage);
  }

  String getAppLanguage() {
    return _sharedPreferences.getString("appLanguage") ??
        AppLocalizations.localizations().first;
  }

  Future<void> setAppLanguage(String appLanguage) async {
    await _sharedPreferences.setString("appLanguage", appLanguage);
    notifyListeners();
  }
}

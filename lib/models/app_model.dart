import 'package:daijidoujisho/dictionary/dictionary_dialog.dart';
import 'package:daijidoujisho/dictionary/dictionary_format.dart';
import 'package:daijidoujisho/language/language.dart';
import 'package:daijidoujisho/language/languages/english_language.dart';
import 'package:daijidoujisho/language/languages/japanese_language.dart';
import 'package:daijidoujisho/media/media_type.dart';
import 'package:daijidoujisho/media/media_types/reader_media_type.dart';
import 'package:daijidoujisho/media/media_types/player_media_type.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A scoped model for parameters that affect the entire application.
/// [Provider] is used for global state management across multiple layers,
/// especially for preferences that persist across application restarts.
class AppModel with ChangeNotifier {
  Language _language;
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

  List<DictionaryFormat> get availableDictionaryFormats => [];

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
  String getCurrentDictionary() {
    return _sharedPreferences.getString("currentDictionary") ?? "";
  }

  /// Save a new active dictionary and remember it on application restart.
  Future<void> setCurrentDictionary(String dictionaryName) async {
    await _sharedPreferences.setString("currentDictionary", dictionaryName);
  }

  /// Get the list of all imported dictionaries.
  List<String> getImportedDictionaries() {
    return _sharedPreferences.getStringList('importedDictionaries') ?? [];
  }

  /// Update the persisted list of all imported dictionaries.
  Future<void> setImportedDictionaries(List<String> customDictionaries) async {
    await _sharedPreferences.setStringList(
        'importedDictionaries', customDictionaries);
  }

  /// Add a new dictionary to the list of persisted imported dictionaries.
  Future<void> addImportedDictionary(String customDictionary) async {
    List<String> customDictionaries = getImportedDictionaries();
    customDictionaries.add(customDictionary);
    await setImportedDictionaries(customDictionaries);
  }

  /// Remove a new dictionary from the list of persisted imported dictionaries.
  Future<void> removeImportedDictionary(String customDictionary) async {
    List<String> customDictionaries = getImportedDictionaries();
    customDictionaries.remove(customDictionary);
    await setImportedDictionaries(customDictionaries);
  }

  /// With the list of imported dictionaries, set the next one after the
  /// current dictionary as the new current one. If the current is last, the
  /// next will be the first dictionary.
  Future<void> setNextDictionary() async {
    List<String> allDictionaries = getImportedDictionaries();
    int currentIndex = allDictionaries.indexOf(getCurrentDictionary());

    if (currentIndex + 1 > allDictionaries.length - 1) {
      await setCurrentDictionary(allDictionaries[0]);
    } else {
      await setCurrentDictionary(allDictionaries[currentIndex + 1]);
    }
  }

  /// With the list of imported dictionaries, set the previous one before the
  /// current dictionary as the new current one. If the current is first, the
  /// next will be the last dictionary.
  Future<void> setPrevDictionary() async {
    List<String> allDictionaries = getImportedDictionaries();
    int currentIndex = allDictionaries.indexOf(getCurrentDictionary());

    if (currentIndex - 1 < 0) {
      await setCurrentDictionary(allDictionaries[allDictionaries.length - 1]);
    } else {
      await setCurrentDictionary(allDictionaries[currentIndex - 1]);
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

  /// Get the last selected dictionary format.
  String getLastDictionaryFormat() {
    return _sharedPreferences.getString("lastDictionaryFormat") ?? "";
  }

  /// Save a new active dictionary and remember it on application restart.
  Future<void> setLastDictionaryFormat(String formatName) async {
    await _sharedPreferences.setString("lastDictionaryFormat", formatName);
  }
}

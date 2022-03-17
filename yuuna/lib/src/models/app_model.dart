import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/src/utils/jidoujisho_localisations.dart';

/// A global [Provider] for app-wide configuration and state management.
final appProvider = ChangeNotifierProvider<AppModel>((ref) {
  return AppModel();
});

/// A scoped model for parameters that affect the entire application.
/// RiverPod is used for global state management across multiple layers,
/// especially for preferences that persist across application restarts.
class AppModel with ChangeNotifier {
  /// Used for storing and retrieving persistent data. See [initialise].
  SharedPreferences get sharedPreferences => _sharedPreferences;
  late final SharedPreferences _sharedPreferences;

  /// Used to get the versioning metadata of the app. See [initialise].
  PackageInfo get packageInfo => _packageInfo;
  late final PackageInfo _packageInfo;

  /// Used to fetch a language by its locale tag with constant time performance.
  /// Initialised with [populateLanguages] at startup.
  late final Map<String, Language> languagesByLocaleTag;

  /// Used to fetch a media type by its unique key with constant time
  /// performance. Initialised with [populateMediaTypes] at startup.
  late final Map<String, MediaType> mediaTypesByUniqueKey;

  /// A list of languages that the app will support at runtime.
  final List<Language> languages = List<Language>.unmodifiable(
    [
      EnglishLanguage(),
    ],
  );

  /// A list of media types that the app will support at runtime.
  final List<MediaType> mediaTypes = List<MediaType>.unmodifiable(
    [
      PlayerMediaType(),
      ReaderMediaType(),
      ViewerMediaType(),
      DictionaryMediaType(),
    ],
  );

  /// Populate languages with maps at startup to optimise performance.
  Future<void> populateLanguages() async {
    languagesByLocaleTag = Map<String, Language>.unmodifiable(
      Map<String, Language>.fromEntries(
        languages.map(
          (language) => MapEntry(language.locale.toLanguageTag(), language),
        ),
      ),
    );
  }

  /// Populate languages with maps at startup to optimise performance.
  Future<void> populateMediaTypes() async {
    mediaTypesByUniqueKey = Map<String, MediaType>.unmodifiable(
      Map<String, MediaType>.fromEntries(
        mediaTypes.map(
          (mediaType) => MapEntry(mediaType.uniqueKey, mediaType),
        ),
      ),
    );
  }

  /// Prepare application data and state to be ready of use upon starting up
  /// the application. [AppModel] is initialised in the main function before
  /// [runApp] is executed.
  Future<void> initialise() async {
    /// Prepare late entities that are required at startup.
    _sharedPreferences = await SharedPreferences.getInstance();
    _packageInfo = await PackageInfo.fromPlatform();

    /// Populate entities with key-value maps for constant time performance.
    await populateLanguages();
    await populateMediaTypes();
  }

  /// Get whether or not the current theme is dark mode.
  bool get isDarkMode {
    bool isSystemDarkMode = Brightness.dark ==
        (SchedulerBinding.instance?.window.platformBrightness ?? false);
    bool isDarkMode =
        _sharedPreferences.getBool('is_dark_mode') ?? isSystemDarkMode;
    return isDarkMode;
  }

  /// Toggle between light and dark mode.
  Future<void> toggleDarkMode() async {
    await _sharedPreferences.setBool('is_dark_mode', !isDarkMode);
    notifyListeners();
  }

  /// Get the target language from persisted settings.
  Language get targetLanguage {
    String defaultLocaleTag = languages.first.locale.toLanguageTag();
    String localeTag =
        _sharedPreferences.getString('target_language') ?? defaultLocaleTag;

    return languagesByLocaleTag[localeTag]!;
  }

  /// Get the current home tab index. The order of the tab indexes are based on
  /// the ordering in [mediaTypes].
  int get currentHomeTabIndex =>
      _sharedPreferences.getInt('current_home_tab_index') ?? 0;

  /// Persist the new tab after switching home tabs.
  Future<void> setCurrentHomeTabIndex(int index) async {
    await _sharedPreferences.setInt('current_home_tab_index', index);
  }

  /// Get the value of a localisation item given the current target language.
  String translate(String key) {
    return JidoujishoLocalisations
        .localisations[targetLanguage.locale.toLanguageTag()]![key]!;
  }
}

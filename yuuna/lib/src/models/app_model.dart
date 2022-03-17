import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  late final Box _preferences;

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
      EnglishLanguage.instance,
    ],
  );

  /// A list of media types that the app will support at runtime.
  final List<MediaType> mediaTypes = List<MediaType>.unmodifiable(
    [
      PlayerMediaType.instance,
      ReaderMediaType.instance,
      ViewerMediaType.instance,
      DictionaryMediaType.instance,
    ],
  );

  /// Populate languages with maps at startup to optimise performance.
  void populateLanguages() async {
    languagesByLocaleTag = Map<String, Language>.unmodifiable(
      Map<String, Language>.fromEntries(
        languages.map(
          (language) => MapEntry(language.locale.toLanguageTag(), language),
        ),
      ),
    );
  }

  /// Populate languages with maps at startup to optimise performance.
  void populateMediaTypes() async {
    mediaTypesByUniqueKey = Map<String, MediaType>.unmodifiable(
      Map<String, MediaType>.fromEntries(
        mediaTypes.map(
          (mediaType) => MapEntry(mediaType.uniqueKey, mediaType),
        ),
      ),
    );
  }

  /// Get the current target language and prepare its resources for use. This
  /// will not re-run if the target language is already initialised, as
  /// a [Language] should always have a singleton instance and will not
  /// re-prepare its resources if already initialised. See
  /// [Language.initialise] for more details.
  Future<void> initialiseLanguage() async {
    await targetLanguage.initialise();
  }

  /// Ready the progress and duration persistent stores of all [MediaType]
  /// histories at startup.
  Future<void> initialiseMediaTypes() async {
    for (MediaType mediaType in mediaTypes) {
      await mediaType.initialise();
    }
  }

  /// Prepare application data and state to be ready of use upon starting up
  /// the application. [AppModel] is initialised in the main function before
  /// [runApp] is executed.
  Future<void> initialise() async {
    /// Prepare late entities that are required at startup.
    _preferences = await Hive.openBox('appModel');
    _packageInfo = await PackageInfo.fromPlatform();

    /// Populate entities with key-value maps for constant time performance.
    /// This is not the initialisation step, which occurs below.
    populateLanguages();
    populateMediaTypes();

    /// Prepare entities for use at startup.
    await initialiseLanguage();
    await initialiseMediaTypes();
  }

  /// Get whether or not the current theme is dark mode.
  bool get isDarkMode {
    bool isSystemDarkMode = Brightness.dark ==
        (SchedulerBinding.instance?.window.platformBrightness ?? false);
    bool isDarkMode =
        _preferences.get('is_dark_mode', defaultValue: isSystemDarkMode);
    return isDarkMode;
  }

  /// Toggle between light and dark mode.
  Future<void> toggleDarkMode() async {
    await _preferences.put('is_dark_mode', !isDarkMode);
    notifyListeners();
  }

  /// Get the target language from persisted preferences.
  Language get targetLanguage {
    String defaultLocaleTag = languages.first.locale.toLanguageTag();
    String localeTag =
        _preferences.get('target_language', defaultValue: defaultLocaleTag);

    return languagesByLocaleTag[localeTag]!;
  }

  /// Persist a new target language in preferences.
  Future<void> setTargetLanguage(Language language) async {
    String localeTag = language.locale.toLanguageTag();
    await _preferences.put('target_language', localeTag);
  }

  /// Get the current home tab index. The order of the tab indexes are based on
  /// the ordering in [mediaTypes].
  int get currentHomeTabIndex =>
      _preferences.get('current_home_tab_index', defaultValue: 0);

  /// Persist the new tab after switching home tabs.
  Future<void> setCurrentHomeTabIndex(int index) async {
    await _preferences.put('current_home_tab_index', index);
  }

  /// Get the value of a localisation item given the current target language.
  String translate(String key) {
    return JidoujishoLocalisations
        .localisations[targetLanguage.locale.toLanguageTag()]![key]!;
  }
}

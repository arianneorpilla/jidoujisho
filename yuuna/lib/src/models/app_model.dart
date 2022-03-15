import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yuuna/language.dart';

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
  late final Map<String, TargetLanguage> languagesByLocaleTag;

  /// A list of languages that the app will support at runtime.
  final List<TargetLanguage> languages = List<TargetLanguage>.unmodifiable(
    [
      EnglishLanguage(),
    ],
  );

  /// Populate languages with maps at startup to optimise performance.
  Future<void> populateLanguages() async {
    languagesByLocaleTag = Map<String, TargetLanguage>.unmodifiable(
      Map<String, TargetLanguage>.fromEntries(
        languages.map(
          (language) => MapEntry(language.locale.toLanguageTag(), language),
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

    /// Initialise persisted settings.
    await Settings.init();

    /// Populate entities with key-value maps for constant time performance.
    await populateLanguages();
  }

  /// Get whether or not the current theme is dark mode.
  bool get isDarkMode {
    bool isSystemDarkMode = Brightness.dark ==
        (SchedulerBinding.instance?.window.platformBrightness ?? false);
    bool isDarkMode = Settings.getValue('isDarkMode', isSystemDarkMode);
    return isDarkMode;
  }

  /// Toggle between light and dark mode.
  Future<void> toggleDarkMode() async {
    await Settings.setValue('isDarkMode', !isDarkMode);
    notifyListeners();
  }

  /// Get the target language from persisted settings.
  TargetLanguage get targetLanguage {
    String defaultLocaleTag = languages.first.locale.toLanguageTag();
    String localeTag = Settings.getValue('targetLanguage', defaultLocaleTag);

    return languagesByLocaleTag[localeTag]!;
  }
}

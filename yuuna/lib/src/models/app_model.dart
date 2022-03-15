import 'package:flutter/widgets.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yuuna/language.dart';

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

  /// A list of languages that the app will support at runtime. Requires
  /// initialisation at startup.
  late final Map<String, TargetLanguage> languagesByLocaleTag;

  /// A list of languages that the app will support at runtime. Requires
  /// initialisation at startup.
  final List<TargetLanguage> languages = [
    EnglishLanguage(),
  ];

  /// Populate languages with maps at startup to optimise performance.
  Future<void> populateLanguages() async {
    languagesByLocaleTag = Map<String, TargetLanguage>.fromEntries(
      languages.map(
        (language) => MapEntry(language.locale.toLanguageTag(), language),
      ),
    );
  }

  /// Get the target language from persisted settings.
  TargetLanguage get targetLanguage {
    String defaultLocaleTag = languages.first.locale.toLanguageTag();
    String localeTag = Settings.getValue('targetLanguage', defaultLocaleTag);

    return languagesByLocaleTag[localeTag]!;
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
}

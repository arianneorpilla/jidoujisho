import 'dart:io';
import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yuuna/creator.dart';
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

  /// These directories are prepared at startup in order to reduce redundancy
  /// in actual runtime.
  /// Directory where data that may be dumped is stored.
  Directory get temporaryDirectory => _temporaryDirectory;
  late final Directory _temporaryDirectory;

  /// Directory where data may be persisted.
  Directory get appDirectory => _appDirectory;
  late final Directory _appDirectory;

  /// Directory where key-value data is stored.
  Directory get hiveDirectory => _hiveDirectory;
  late final Directory _hiveDirectory;

  /// Used to fetch a language by its locale tag with constant time performance.
  /// Initialised with [populateLanguages] at startup.
  late final Map<String, Language> sortedLanguages;

  /// Used to fetch a media type by its unique key with constant time
  /// performance. Initialised with [populateMediaTypes] at startup.
  late final Map<String, MediaType> sortedMediaTypes;

  /// Used to fetch initialised enhancements by their unique key with constant
  /// time performance. Initialised with [populateEnhancements] at startup.
  late final Map<Field, Map<String, Enhancement>> sortedEnhancements;

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

  /// A list of enhancements that the app will support at runtime.
  final Map<Field, List<Enhancement>> fieldEnhancements = {
    Field.audio: [],
    Field.extra: [],
    Field.image: [],
    Field.meaning: [],
    Field.reading: [],
    Field.sentence: [],
    Field.word: [],
  };

  /// Populate languages with maps at startup to optimise performance.
  void populateLanguages() async {
    sortedLanguages = Map<String, Language>.unmodifiable(
      Map<String, Language>.fromEntries(
        languages.map(
          (language) => MapEntry(language.locale.toLanguageTag(), language),
        ),
      ),
    );
  }

  /// Populate languages with maps at startup to optimise performance.
  void populateMediaTypes() async {
    sortedMediaTypes = Map<String, MediaType>.unmodifiable(
      Map<String, MediaType>.fromEntries(
        mediaTypes.map(
          (mediaType) => MapEntry(mediaType.uniqueKey, mediaType),
        ),
      ),
    );
  }

  /// Populate enhancements with maps at startup to optimise performance.
  void populateEnhancements() async {
    sortedEnhancements = Map<Field, Map<String, Enhancement>>.unmodifiable(
      fieldEnhancements.map(
        (field, enhancements) => MapEntry(
          field,
          Map<String, Enhancement>.unmodifiable(
            Map<String, Enhancement>.fromEntries(
              enhancements.map(
                (enhancement) => MapEntry(enhancement.uniqueKey, enhancement),
              ),
            ),
          ),
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
    /// Prepare entities that may be repeatedly used at runtime.
    _packageInfo = await PackageInfo.fromPlatform();

    /// These directories will commonly be accessed.
    _temporaryDirectory = await getTemporaryDirectory();
    _appDirectory = await getApplicationDocumentsDirectory();
    _hiveDirectory = Directory(path.join(appDirectory.path, 'hive'));

    /// Initialise persistent store or all Hive boxes.
    await Hive.initFlutter();
    _preferences = await Hive.openBox('appModel');

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
  void toggleDarkMode() async {
    await _preferences.put('is_dark_mode', !isDarkMode);
    notifyListeners();
  }

  /// Get the target language from persisted preferences.
  Language get targetLanguage {
    String defaultLocaleTag = languages.first.locale.toLanguageTag();
    String localeTag =
        _preferences.get('target_language', defaultValue: defaultLocaleTag);

    return sortedLanguages[localeTag]!;
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

  /// Given a slot [position] of a certain field, get the unique key of the
  /// [Enhancement] assigned to it.
  Enhancement? getEnhancement({
    required Field field,
    required int position,
  }) {
    String uniqueKey = _preferences.get('field_slots_${field.name}/$position');
    return sortedEnhancements[field]![uniqueKey];
  }

  /// Given an [enhancement], persist to a numbered slot [position] for a
  /// [field].
  Future<void> persistEnhancement({
    required Field field,
    required Enhancement enhancement,
    required int position,
  }) async {
    await _preferences.put(
        'field_slots_${field.name}/$position', enhancement.uniqueKey);
  }
}

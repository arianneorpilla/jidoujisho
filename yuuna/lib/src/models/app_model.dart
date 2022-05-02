import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A global [Provider] for app-wide configuration and state management.
final appProvider = ChangeNotifierProvider<AppModel>((ref) {
  return AppModel();
});

/// A scoped model for parameters that affect the entire application.
/// RiverPod is used for global state management across multiple layers,
/// especially for preferences that persist across application restarts.
class AppModel with ChangeNotifier {
  /// Used for showing dialogs without needing to pass around a [BuildContext].
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  late final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  /// Used for accessing persistent key-value data. See [initialise].
  late final Box _preferences;

  /// Used for accessing persistent database data. See [initialise].
  late final Isar _database;

  /// Used to get the versioning metadata of the app. See [initialise].
  PackageInfo get packageInfo => _packageInfo;
  late final PackageInfo _packageInfo;

  /// Used for caching images and audio produced from media seeds.
  DefaultCacheManager get cacheManager => _cacheManager;
  final _cacheManager = DefaultCacheManager();

  /// These directories are prepared at startup in order to reduce redundancy
  /// in actual runtime.
  /// Directory where data that may be dumped is stored.
  Directory get temporaryDirectory => _temporaryDirectory;
  late final Directory _temporaryDirectory;

  /// Directory where data may be persisted.
  Directory get appDirectory => _appDirectory;
  late final Directory _appDirectory;

  /// Directory where Hive key-value data is stored.
  Directory get hiveDirectory => _hiveDirectory;
  late final Directory _hiveDirectory;

  /// Directory where Isar database data is stored.
  Directory get isarDirectory => _isarDirectory;
  late final Directory _isarDirectory;

  /// Directory used as a working directory for dictionary imports.
  Directory get dictionaryImportWorkingDirectory =>
      _dictionaryImportWorkingDirectory;
  late final Directory _dictionaryImportWorkingDirectory;

  /// Used to fetch a language by its locale tag with constant time performance.
  /// Initialised with [populateLanguages] at startup.
  late final Map<String, Language> languages;

  /// Used to fetch an app locale by its locale tag with constant time
  /// performance. Initialised with [populateLocales] at startup.
  late final Map<String, Locale> locales;

  /// Used to fetch a dictionary format by its unique key with constant time
  /// performance. Initialised with [populateDictionaryFormats] at startup.
  late final Map<String, DictionaryFormat> dictionaryFormats;

  /// Used to fetch a media type by its unique key with constant time
  /// performance. Initialised with [populateMediaTypes] at startup.
  late final Map<String, MediaType> mediaTypes;

  /// Used to fetch initialised enhancements by their unique key with constant
  /// time performance. Initialised with [populateEnhancements] at startup.
  late final Map<Field, Map<String, Enhancement>> enhancements;

  /// Used to fetch initialised sources by their unique key with constant
  /// time performance. Initialised with [populateMediaSources] at startup.
  late final Map<MediaType, Map<String, MediaSource>> mediaSources;

  /// Returns all dictionaries imported into the database. Sorted by the
  /// user-defined order in the dictionary menu.
  List<Dictionary> get dictionaries =>
      _database.dictionarys.where().sortByOrder().findAllSync();

  /// Returns all dictionaries imported into the database. Sorted by the
  /// user-defined order in the dictionary menu.
  List<AnkiMapping> get mappings =>
      _database.ankiMappings.where().sortByOrder().findAllSync();

  /// Update the user-defined order of a given dictionary in the database.
  /// See the dictionary dialog's [ReorderableListView] for usage.
  void updateDictionaryOrder(int oldIndex, int newIndex) async {
    _database.writeTxnSync((isar) {
      Dictionary dictionaryPick = dictionaries[oldIndex];
      Dictionary dictionarySwap = dictionaries[newIndex];

      _database.dictionarys.deleteAllByOrderSync([oldIndex, newIndex]);
      dictionaryPick.order = newIndex;
      dictionarySwap.order = oldIndex;

      _database.dictionarys.putAllSync([dictionaryPick, dictionarySwap]);
    });
  }

  /// Update the user-defined order of a given dictionary in the database.
  /// See the dictionary dialog's [ReorderableListView] for usage.
  void updateMappingsOrder(int oldIndex, int newIndex) async {
    _database.writeTxnSync((isar) {
      AnkiMapping mappingPick = mappings[oldIndex];
      AnkiMapping mappingSwap = mappings[newIndex];

      _database.ankiMappings.deleteAllByOrderSync([oldIndex, newIndex]);
      mappingPick.order = newIndex;
      mappingSwap.order = oldIndex;

      _database.ankiMappings.putAllSync([mappingPick, mappingSwap]);
    });
  }

  /// Populate maps for languages at startup to optimise performance.
  void populateLanguages() async {
    /// A list of languages that the app will support at runtime.
    final List<Language> availableLanguages = List<Language>.unmodifiable(
      [
        JapaneseLanguage.instance,
      ],
    );

    languages = Map<String, Language>.unmodifiable(
      Map<String, Language>.fromEntries(
        availableLanguages.map(
          (language) => MapEntry(language.locale.toLanguageTag(), language),
        ),
      ),
    );
  }

  /// Populate maps for locales at startup to optimise performance.
  void populateLocales() async {
    /// A list of locales that the app will support at runtime. This is not
    /// related to supported target languages.
    final List<Locale> availableLocales = List<Locale>.unmodifiable(
      [
        const Locale('en', 'US'),
      ],
    );

    locales = Map<String, Locale>.unmodifiable(
      Map<String, Locale>.fromEntries(
        availableLocales.map(
          (locale) => MapEntry(locale.toLanguageTag(), locale),
        ),
      ),
    );
  }

  /// Populate maps for media types at startup to optimise performance.
  void populateMediaTypes() async {
    /// A list of media types that the app will support at runtime.
    final List<MediaType> availableMediaTypes = List<MediaType>.unmodifiable(
      [
        PlayerMediaType.instance,
        ReaderMediaType.instance,
        ViewerMediaType.instance,
        DictionaryMediaType.instance,
      ],
    );

    mediaTypes = Map<String, MediaType>.unmodifiable(
      Map<String, MediaType>.fromEntries(
        availableMediaTypes.map(
          (mediaType) => MapEntry(mediaType.uniqueKey, mediaType),
        ),
      ),
    );
  }

  /// Populate maps for media sources at startup to optimise performance.
  void populateMediaSources() async {
    /// A list of media sources that the app will support at runtime.
    final Map<MediaType, List<MediaSource>> availableMediaSources = {
      PlayerMediaType.instance: [],
      ReaderMediaType.instance: [],
      ViewerMediaType.instance: [],
      DictionaryMediaType.instance: [],
    };

    mediaSources = Map<MediaType, Map<String, MediaSource>>.unmodifiable(
      availableMediaSources.map(
        (type, sources) => MapEntry(
          type,
          Map<String, MediaSource>.unmodifiable(
            Map<String, MediaSource>.fromEntries(
              sources.map(
                (source) => MapEntry(source.uniqueKey, source),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Populate maps for dictionary formats at startup to optimise performance.
  void populateDictionaryFormats() async {
    /// A list of dictionary formats that the app will support at runtime.
    final List<DictionaryFormat> availableDictionaryFormats =
        List<DictionaryFormat>.unmodifiable(
      [
        YomichanTermBankFormat.instance,
      ],
    );

    dictionaryFormats = Map<String, DictionaryFormat>.unmodifiable(
      Map<String, DictionaryFormat>.fromEntries(
        availableDictionaryFormats.map(
          (dictionaryFormat) => MapEntry(
            dictionaryFormat.formatName,
            dictionaryFormat,
          ),
        ),
      ),
    );
  }

  /// Populate maps for enhancements at startup to optimise performance.
  void populateEnhancements() async {
    /// A list of enhancements that the app will support at runtime.
    final Map<Field, List<Enhancement>> availableEnhancements = {
      Field.audio: [],
      Field.extra: [],
      Field.image: [],
      Field.meaning: [],
      Field.reading: [],
      Field.sentence: [],
      Field.word: [],
    };

    enhancements = Map<Field, Map<String, Enhancement>>.unmodifiable(
      availableEnhancements.map(
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

  /// Populate default mapping if it does not exist in the database.
  void populateDefaultMapping() async {
    if (_database.ankiMappings.where().findAllSync().isEmpty) {
      _database.writeTxnSync((isar) {
        _database.ankiMappings.putSync(AnkiMapping.defaultMapping(0));
      });
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
    _isarDirectory = Directory(path.join(appDirectory.path, 'isar'));
    _dictionaryImportWorkingDirectory = Directory(
        path.join(appDirectory.path, 'dictionaryImportWorkingDirectory'));

    hiveDirectory.createSync();
    isarDirectory.createSync();
    dictionaryImportWorkingDirectory.createSync();

    /// Initialise persistent key-value store.
    await Hive.initFlutter();
    _preferences = await Hive.openBox('appModel');

    /// Initialise persistent database.
    _database = await Isar.open(
      directory: isarDirectory.path,
      schemas: [
        DictionarySchema,
        DictionaryEntrySchema,
        MediaItemSchema,
        CreatorContextSchema,
        AnkiMappingSchema,
      ],
    );

    /// Populate entities with key-value maps for constant time performance.
    /// This is not the initialisation step, which occurs below.
    populateLanguages();
    populateLocales();
    populateMediaTypes();
    populateMediaSources();
    populateDictionaryFormats();
    populateDefaultMapping();

    /// Get the current target language and prepare its resources for use. This
    /// will not re-run if the target language is already initialised, as
    /// a [Language] should always have a singleton instance and will not
    /// re-prepare its resources if already initialised. See
    /// [Language.initialise] for more details.
    await targetLanguage.initialise();

    /// Ready the progress and duration persistent stores of all [MediaType]
    /// histories at startup.
    for (MediaType mediaType in mediaTypes.values) {
      await mediaType.initialise();
    }
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

  /// Get whether or not the app is in incognito mode.
  bool get isIncognitoMode {
    bool isDarkMode =
        _preferences.get('is_incognito_mode', defaultValue: false);
    return isDarkMode;
  }

  /// Toggle incognito mode.
  void toggleIncognitoMode() async {
    await _preferences.put('is_incognito_mode', !isIncognitoMode);
    notifyListeners();
  }

  /// Get the target language from persisted preferences.
  Language get targetLanguage {
    String defaultLocaleTag = languages.values.first.locale.toLanguageTag();
    String localeTag =
        _preferences.get('target_language', defaultValue: defaultLocaleTag);

    return languages[localeTag]!;
  }

  /// Get the target language from persisted preferences.
  DictionaryFormat get lastSelectedDictionaryFormat {
    String firstDictionaryFormatName =
        dictionaryFormats.values.first.formatName;
    String lastDictionaryFormatName = _preferences.get(
      'last_selected_dictionary_format',
      defaultValue: firstDictionaryFormatName,
    );

    return dictionaryFormats[lastDictionaryFormatName]!;
  }

  /// Get the current app locale from persisted preferences.
  Locale get appLocale {
    String defaultLocaleTag = locales.values.first.toLanguageTag();
    String localeTag =
        _preferences.get('app_locale', defaultValue: defaultLocaleTag);

    return locales[localeTag]!;
  }

  /// Get the last selected model from persisted preferences.
  String? get lastSelectedModel {
    String? modelName = _preferences.get('last_selected_model');
    return modelName;
  }

  /// Get the last selected mapping from persisted preferences. This should
  /// always be guaranteed to have a result, as it is impossible to delete the
  /// default mapping.
  AnkiMapping? get lastSelectedMapping {
    String mappingName = _preferences.get('last_selected_mapping',
        defaultValue: mappings.first.label);

    AnkiMapping? mapping = _database.ankiMappings
        .filter()
        .labelEqualTo(mappingName)
        .findFirstSync();

    return mapping;
  }

  /// Persist a new target language in preferences.
  Future<void> setTargetLanguage(Language language) async {
    String localeTag = language.locale.toLanguageTag();
    await _preferences.put('target_language', localeTag);
    notifyListeners();
  }

  /// Persist a new app locale in preferences.
  Future<void> setAppLocale(String localeTag) async {
    await _preferences.put('app_locale', localeTag);
    notifyListeners();
  }

  /// Persist a new last selected dictionary format. This is called when the
  /// user changes the import format in the dictionary menu.
  Future<void> setLastSelectedDictionaryFormat(
      DictionaryFormat dictionaryFormat) async {
    String lastDictionaryFormatName = dictionaryFormat.formatName;
    await _preferences.put(
        'last_selected_dictionary_format', lastDictionaryFormatName);
  }

  /// Persist a new last selected model name. This is called when the user
  /// changes the selected model to map in the profiles menu.
  Future<void> setLastSelectedModelName(String modelName) async {
    await _preferences.put('last_selected_model', modelName);
    notifyListeners();
  }

  /// Persist a new last selected model name. This is called when the user
  /// changes the selected model to map in the profiles menu.
  Future<void> setLastSelectedMapping(AnkiMapping mapping) async {
    await _preferences.put('last_selected_mapping', mapping.label);
    notifyListeners();
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
    String tag = appLocale.toLanguageTag();
    try {
      return JidoujishoLocalisations.localisations[tag]![key]!;
    } catch (e) {
      debugPrint('Localisation for key $key not found for locale $tag');
      rethrow;
    }
  }

  /// Given a slot [position] of a certain field, get the unique key of the
  /// [Enhancement] assigned to it.
  Enhancement? getEnhancement({
    required Field field,
    required int position,
  }) {
    String uniqueKey = _preferences.get('field_slots_${field.name}/$position');
    return enhancements[field]![uniqueKey];
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

  /// Show the dictionary menu. This should be callable from many parts of the
  /// app, so it is appropriately handled by the model.
  Future<void> showDictionaryMenu() async {
    await showDialog(
      barrierDismissible: true,
      context: navigatorKey.currentContext!,
      builder: (context) => const DictionaryDialogPage(),
    );
  }

  /// Show the language menu. This should be callable from many parts of the
  /// app, so it is appropriately handled by the model.
  Future<void> showLanguageMenu() async {
    await showDialog(
      barrierDismissible: true,
      context: navigatorKey.currentContext!,
      builder: (context) => const LanguageDialogPage(),
    );
  }

  /// Show the language menu. This should be callable from many parts of the
  /// app, so it is appropriately handled by the model.
  Future<void> showProfilesMenu() async {
    List<String> models = await AnkiUtilities.getModelList();
    String initialModel = lastSelectedModel ?? models.first;

    await showDialog(
      barrierDismissible: true,
      context: navigatorKey.currentContext!,
      builder: (context) => ProfilesDialogPage(
        models: models,
        initialModel: initialModel,
      ),
    );
  }

  /// Start the process of importing a dictionary. This is called from the
  /// dictionary menu, and starts the process of importing for the
  /// [lastSelectedDictionaryFormat].
  Future<void> importDictionary({required Function() onImportSuccess}) async {
    /// The last selected dictionary format in the dictionary menu is used for
    /// dictionary import.
    DictionaryFormat dictionaryFormat = lastSelectedDictionaryFormat;

    /// This is the directory where files are prepared for processing.
    Directory workingDirectory = dictionaryImportWorkingDirectory;

    /// Over-engineered way to deliver localised dictionary progress messages
    /// across multiple isolates.
    DictionaryImportLocalisation localisation = DictionaryImportLocalisation(
      importMessageStart: translate('import_message_start'),
      importMessageClean: translate('import_message_clean'),
      importMessageExtraction: translate('import_message_extraction'),
      importMessageName: translate('import_message_name'),
      importMessageEntries: translate('import_message_entries'),
      importMessageCount: translate('import_message_count'),
      importMessageMetadata: translate('import_message_metadata'),
      importMessageDatabase: translate('import_message_database'),
      importMessageError: translate('import_message_error'),
      importMessageFailed: translate('import_message_failed'),
      importMessageComplete: translate('import_message_complete'),
    );

    /// A [ValueNotifier] that will update a message based on the progress of
    /// the ongoing dictionary file import. See [DictionaryImportProgressPage].
    ValueNotifier<String> progressNotifier = ValueNotifier<String>('');

    /// Importing makes heavy use of isolates as it is very performance
    /// intensive to work with files. In order to ensure the UI isolate isn't
    /// blocked, a [ReceivePort] is necessary to receive UI updates.
    ReceivePort receivePort = ReceivePort();
    SendPort sendPort = receivePort.sendPort;
    receivePort.listen((data) {
      if (data is String) {
        progressNotifier.value = data;
        debugPrint(data);
      }
    });

    /// If any [Exception] occurs, the process is aborted with a message as
    /// shown below. A dialog is shown to show the progress of the dictionary
    /// file import, with messages pertaining to the above [ValueNotifier].
    try {
      File? file;
      if (lastSelectedDictionaryFormat.requiresFile) {
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        file = File(result!.files.single.path!);
      }

      showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentContext!,
        builder: (context) =>
            DictionaryDialogImportPage(progressNotifier: progressNotifier),
      );

      /// The following hard waits give enough time to inform the user to read
      /// the progress messages.
      progressNotifier.value = localisation.importMessageStart;
      await Future.delayed(const Duration(milliseconds: 500), () {});

      /// The working directory should always be emptied before and after
      /// dictionary import to ensure that no files bloat the system and that
      /// files from previous imports do not carry over.
      if (workingDirectory.existsSync()) {
        progressNotifier.value = localisation.importMessageClean;
        await Future.delayed(const Duration(milliseconds: 500), () {});
        workingDirectory.deleteSync(recursive: true);
        workingDirectory.createSync();
      }

      /// Show the file picker if the [lastSelectedDictionaryFormat] requires a
      /// file for dictionary import.
      late final PrepareDirectoryParams prepareDirectoryParams;
      if (lastSelectedDictionaryFormat.requiresFile) {
        prepareDirectoryParams = PrepareDirectoryParams(
          file: file,
          workingDirectory: workingDirectory,
          sendPort: sendPort,
          localisation: localisation,
        );

        /// Many formats require ZIP extraction, while others have their own
        /// particular cases.
        ///
        /// The purpose of this function is to make it such that it can be
        /// assumed that the remaining operations after this can be performed
        /// from the working directory, and allow different formats to
        /// gracefully follow the remaining generic steps.
        progressNotifier.value = localisation.importMessageExtraction;
        await dictionaryFormat.prepareDirectory(prepareDirectoryParams);
      } else {
        prepareDirectoryParams = PrepareDirectoryParams(
          file: null,
          workingDirectory: workingDirectory,
          sendPort: sendPort,
          localisation: localisation,
        );
      }

      /// It is now assumed that the rest of the operations can be performed
      /// from the working area. A dictionary name is required for import, and
      /// all dictionaries in the database must have a unique name. Hence,
      /// through the [workingDirectory], a [String] name must be obtainable,
      /// and generically handled by all formats.
      ///
      /// If a format does not keep the name of a dictionary as metadata, it
      /// should provide a sufficiently unique and considerate name with no
      /// collision with other existing dictionaries and other dictionary
      /// formats.
      String dictionaryName = await compute(
        dictionaryFormat.prepareName,
        prepareDirectoryParams,
      );
      progressNotifier.value =
          localisation.importMessageNameWithVar(dictionaryName);

      Dictionary? duplicateDictionary = _database.dictionarys
          .filter()
          .dictionaryNameEqualTo(dictionaryName)
          .findFirstSync();

      if (duplicateDictionary != null) {
        throw Exception('Dictionary with same name found.');
      }

      /// From the working directory, the format is mainly responsible for
      /// parsing its entries. [extractAndDepositEntries] handles two main
      /// performance-intensive operations. Firstly, the format-defined entry
      /// extraction function [getDictionaryEntries]. Then, it adds these to an
      /// Isar database -- ensuring other developers don't have to learn Isar to
      /// implement their own formats is vital.
      ///
      /// It is necessary to perform the database deposit in another isolate
      /// itself as receiving the entries and then pushing these arguments to
      /// another isolate will cause a lot of jank. Therefore, one isolate is
      /// necessary for these two operations.
      progressNotifier.value = localisation.importMessageEntries;
      PrepareDictionaryParams prepareDictionaryParams = PrepareDictionaryParams(
        dictionaryName: dictionaryName,
        dictionaryFormat: dictionaryFormat,
        workingDirectory: workingDirectory,
        sendPort: sendPort,
        isarDirectoryPath: isarDirectory.path,
        localisation: localisation,
      );
      await compute(depositDictionaryEntries, prepareDictionaryParams);

      /// Finally, any necessary metadata that is pertaining to the dictionary
      /// format that will come in handy when in actual use (i.e. interacting
      /// with the database or during searches) should be provided in this step.
      progressNotifier.value = localisation.importMessageMetadata;
      Map<String, String> dictionaryMetadata = await compute(
        dictionaryFormat.prepareMetadata,
        prepareDictionaryParams,
      );

      /// Get the highest order in the dictionary database.
      Dictionary? highestOrderDictionary =
          _database.dictionarys.where().sortByOrderDesc().findFirstSync();
      late int order;
      if (highestOrderDictionary != null) {
        order = highestOrderDictionary.order + 1;
      } else {
        order = 0;
      }

      Dictionary dictionary = Dictionary(
        dictionaryName: dictionaryName,
        formatName: dictionaryFormat.formatName,
        metadata: dictionaryMetadata,
        order: order,
        collapsed: false,
        hidden: false,
      );

      _database.writeTxnSync((isar) {
        _database.dictionarys.putSync(dictionary);
      });

      /// The working directory should always be emptied before and after
      /// dictionary import to ensure that no files bloat the system and that
      /// files from previous imports do not carry over.
      if (workingDirectory.existsSync()) {
        progressNotifier.value = localisation.importMessageClean;
        await Future.delayed(const Duration(milliseconds: 500), () {});
        workingDirectory.deleteSync(recursive: true);
        workingDirectory.createSync();
      }

      progressNotifier.value = localisation.importMessageComplete;
      await Future.delayed(const Duration(seconds: 1), () {});

      onImportSuccess();
    } catch (e) {
      progressNotifier.value = localisation.importMessageErrorWithVar('$e');
      await Future.delayed(const Duration(seconds: 3), () {});
      progressNotifier.value = localisation.importMessageFailed;
      await Future.delayed(const Duration(seconds: 1), () {});

      throw Exception(e);
    } finally {
      /// Close the import progress dialog opened earlier.
      Navigator.pop(navigatorKey.currentContext!);
    }
  }

  /// Toggle a dictionary's between collapsed and expanded state. This will
  /// affect how a dictionary's search results are shown by default.
  void toggleDictionaryCollapsed(Dictionary dictionary) {
    _database.writeTxnSync((isar) {
      dictionary.collapsed = !dictionary.collapsed;
      _database.dictionarys.putSync(dictionary);
    });
  }

  /// Toggle a dictionary's between hidden and shown state. This will
  /// affect how a dictionary's search results are shown by default.
  void toggleDictionaryHidden(Dictionary dictionary) {
    _database.writeTxnSync((isar) {
      dictionary.hidden = !dictionary.hidden;
      _database.dictionarys.putSync(dictionary);
    });
  }

  /// Delete a selected dictionary from the database.
  Future<void> deleteDictionary(Dictionary dictionary) async {
    showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (context) => const DictionaryDialogDeletePage(),
    );

    DeleteDictionaryParams params = DeleteDictionaryParams(
      dictionaryName: dictionary.dictionaryName,
      isarDirectoryPath: isarDirectory.path,
    );
    await compute(deleteDictionaryData, params);

    Navigator.pop(navigatorKey.currentContext!);
  }

  /// Delete a selected mapping from the database.
  void deleteMapping(AnkiMapping mapping) async {
    _database.writeTxnSync((database) {
      database.ankiMappings.deleteSync(mapping.id!);
    });
  }

  /// Add a selected mapping to the database.
  void addMapping(AnkiMapping mapping) async {
    _database.writeTxnSync((database) {
      if (mapping.id != null &&
          database.ankiMappings.getSync(mapping.id!) != null) {
        database.ankiMappings.deleteSync(mapping.id!);
      }
      database.ankiMappings.putSync(mapping);
    });
  }

  /// Gets the raw unprocessed entries straight from a dictionary database
  /// given a search term. This will be processed later for user viewing.
  Future<DictionarySearchResult> getDictionarySearchEntries(
      String searchTerm) async {
    String fallbackTerm = await targetLanguage.getRootForm(searchTerm);
    DictionarySearchParams params = DictionarySearchParams(
      searchTerm: searchTerm,
      fallbackTerm: fallbackTerm,
      isarDirectoryPath: isarDirectory.path,
    );

    List<DictionaryEntry> entries =
        await compute(targetLanguage.prepareSearchResults!, params);

    Map<DictionaryPair, List<DictionaryEntry>> entriesByPair =
        groupBy<DictionaryEntry, DictionaryPair>(
      entries,
      (entry) => DictionaryPair(word: entry.word, reading: entry.reading),
    );

    List<List<int>> mapping = entriesByPair.values
        .map((entries) => entries.map((entry) => entry.id!).toList())
        .toList();

    DictionarySearchResult result = DictionarySearchResult(
      searchTerm: searchTerm,
      mapping: mapping,
    );

    return result;
  }

  /// Get a specific dictionary entry index from the database.
  DictionaryEntry getEntryFromIndex(int index) {
    return _database.dictionaryEntrys.getSync(index)!;
  }

  /// Check if a mapping with a certain name with a different order already
  /// exists.
  bool mappingNameHasDuplicate(AnkiMapping mapping) {
    return _database.ankiMappings
            .filter()
            .labelEqualTo(mapping.label)
            .and()
            .not()
            .orderEqualTo(mapping.order)
            .findFirstSync() !=
        null;
  }

  /// Get the newest available order for a new mapping.
  int get nextMappingOrder {
    AnkiMapping? highestOrderMapping =
        _database.ankiMappings.where().sortByOrderDesc().findFirstSync();
    late int order;
    if (highestOrderMapping != null) {
      order = highestOrderMapping.order + 1;
    } else {
      order = 0;
    }

    return order;
  }
}

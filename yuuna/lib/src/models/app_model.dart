import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart' as intl;
import 'package:path/path.dart' as path;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/creator/actions/instant_export_action.dart';
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

  /// Directory where media for export is stored for communication with
  /// third-party APIs.
  Directory get exportDirectory => _exportDirectory;
  late final Directory _exportDirectory;

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

  /// Used to fetch initialised actions by their unique key with constant
  /// time performance. Initialised with [populateQuickActions] at startup.
  late final Map<String, QuickAction> quickActions;

  /// Used to fetch initialised sources by their unique key with constant
  /// time performance. Initialised with [populateMediaSources] at startup.
  late final Map<MediaType, Map<String, MediaSource>> mediaSources;

  /// Maximum number of manual enhancements in a field.
  final int maximumFieldEnhancements = 4;

  /// Maximum number of quick actions.
  final int maximumQuickActions = 6;

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
      Field.audio: [
        ClearFieldEnhancement(field: Field.audio),
      ],
      Field.extra: [
        ClearFieldEnhancement(field: Field.extra),
      ],
      Field.image: [
        ClearFieldEnhancement(field: Field.image),
      ],
      Field.meaning: [
        ClearFieldEnhancement(field: Field.meaning),
      ],
      Field.reading: [
        ClearFieldEnhancement(field: Field.reading),
      ],
      Field.sentence: [
        ClearFieldEnhancement(field: Field.sentence),
      ],
      Field.word: [
        ClearFieldEnhancement(field: Field.word),
      ],
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

  /// Populate maps for actions at startup to optimise performance.
  void populateQuickActions() async {
    /// A list of actions that the app will support at runtime.
    final List<QuickAction> availableQuickActions = [
      CardCreatorAction(),
      InstantExportAction(),
    ];

    quickActions = Map<String, QuickAction>.unmodifiable(
      Map<String, QuickAction>.fromEntries(
        availableQuickActions.map(
          (quickAction) => MapEntry(quickAction.uniqueKey, quickAction),
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

  /// Return the app external directory found in the public DCIM directory.
  /// This path also initialises the folder if it does not exist, and includes
  /// a .nomedia file within the folder.
  Future<Directory> prepareJidoujishoDirectory() async {
    String dcimDirectory = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DCIM,
    );

    String directoryPath = path.join(dcimDirectory, 'jidoujisho');
    String noMediaFilePath = path.join(dcimDirectory, 'jidoujisho', '.nomedia');

    Directory jidoujishoDirectory = Directory(directoryPath);
    File noMediaFile = File(noMediaFilePath);

    if (!jidoujishoDirectory.existsSync()) {
      jidoujishoDirectory.createSync(recursive: true);
    }
    if (!noMediaFile.existsSync()) {
      noMediaFile.createSync();
    }

    return jidoujishoDirectory;
  }

  /// Prepare application data and state to be ready of use upon starting up
  /// the application. [AppModel] is initialised in the main function before
  /// [runApp] is executed.
  Future<void> initialise() async {
    /// Prepare entities that may be repeatedly used at runtime.
    _packageInfo = await PackageInfo.fromPlatform();

    /// Perform startup activities unnecessary to further initialisation here.
    await requestExternalStoragePermissions();
    await requestAnkidroidPermissions();

    /// These directories will commonly be accessed.
    _temporaryDirectory = await getTemporaryDirectory();
    _appDirectory = await getApplicationDocumentsDirectory();
    _hiveDirectory = Directory(path.join(appDirectory.path, 'hive'));
    _isarDirectory = Directory(path.join(appDirectory.path, 'isar'));
    _dictionaryImportWorkingDirectory = Directory(
        path.join(appDirectory.path, 'dictionaryImportWorkingDirectory'));
    _exportDirectory = await prepareJidoujishoDirectory();

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
    populateEnhancements();
    populateQuickActions();
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
    bool isSystemDarkMode =
        Brightness.dark == SchedulerBinding.instance.window.platformBrightness;
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

  /// Get the last selected deck from persisted preferences.
  String get lastSelectedDeckName {
    String deckName =
        _preferences.get('last_selected_deck', defaultValue: 'Default');
    return deckName;
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
  AnkiMapping get lastSelectedMapping {
    String mappingName = _preferences.get('last_selected_mapping',
        defaultValue: mappings.first.label);

    AnkiMapping mapping = _database.ankiMappings
            .filter()
            .labelEqualTo(mappingName)
            .findFirstSync() ??
        _database.ankiMappings
            .filter()
            .labelEqualTo(mappings.first.label)
            .findFirstSync()!;

    return mapping;
  }

  /// Get the last selected mapping's name from persisted preferences. This is
  /// faster than getting the mapping specifically from the database.
  String get lastSelectedMappingName {
    String mappingName = _preferences.get('last_selected_mapping',
        defaultValue: mappings.first.label);
    return mappingName;
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

  /// Persist a new last selected deck name. This is called when the user
  /// changes the selected deck to map in the creator.
  Future<void> setLastSelectedDeck(String deckName) async {
    await _preferences.put('last_selected_deck', deckName);
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
    List<String> models = await getModelList();
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

    if (mapping.label == lastSelectedMappingName) {
      await setLastSelectedMapping(mappings.first);
    }
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
  Future<DictionaryResult> searchDictionary(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      return DictionaryResult(
        searchTerm: searchTerm,
        mapping: [],
      );
    }

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

    List<List<DictionaryEntry>> mapping = entriesByPair.values
        .map((entries) => entries.map((entry) => entry).toList())
        .toList();

    DictionaryResult result = DictionaryResult(
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

  /// Requests for full external storage permissions. Required to handle video
  /// files and their subtitle files in the same directory.
  static Future<void> requestExternalStoragePermissions() async {
    AndroidDeviceInfo androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
    await Permission.storage.request();

    if (androidDeviceInfo.version.sdkInt! >= 30) {
      await Permission.manageExternalStorage.request();
    }
  }

  /// Used to communicate back and forth with Dart and native code.
  static const MethodChannel methodChannel =
      MethodChannel('app.lrorpilla.yuuna/anki');

  /// Shows the AnkiDroid API message. Called when an Anki-related API get call
  /// fails.
  void showAnkidroidApiMessage() async {
    String errorAnkidroidApi = translate('error_ankidroid_api');
    String errorAnkidroidApiContent = translate('error_ankidroid_api_content');
    String dialogCloseLabel = translate('dialog_close');
    String dialogLaunchAnkidroidLabel = translate('dialog_launch_ankidroid');

    await showDialog(
      barrierDismissible: true,
      context: _navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text(errorAnkidroidApi),
        content: Text(
          errorAnkidroidApiContent,
          textAlign: TextAlign.justify,
        ),
        actions: [
          TextButton(
            child: Text(dialogLaunchAnkidroidLabel),
            onPressed: () async {
              await LaunchApp.openApp(
                androidPackageName: 'com.ichi2.anki',
                openStore: true,
              );
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(dialogCloseLabel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Used to ask for AnkiDroid database permissions. Should be called at
  /// startup.
  Future<void> requestAnkidroidPermissions() async {
    await methodChannel.invokeMethod('requestAnkidroidPermissions');
  }

  /// Adds the default 'jidoujisho Yuuna' model to the list of Anki card types.
  void addDefaultModelIfMissing() async {
    String infoStandardModel = translate('info_standard_model');
    String infoStandardModelContent = translate('info_standard_model_content');
    String dialogCloseLabel = translate('dialog_close');

    List<String> models = await getModelList();
    if (!models.contains(AnkiMapping.standardModelName)) {
      methodChannel.invokeMethod('addDefaultModel');

      await showDialog(
        barrierDismissible: true,
        context: _navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: Text(infoStandardModel),
          content: Text(
            infoStandardModelContent,
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              child: Text(dialogCloseLabel),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  /// Get the file to be written to for image export.
  File getImageExportFile() {
    String imagePath = path.join(exportDirectory.path, 'exportImage.jpg');
    return File(imagePath);
  }

  /// Get the file to be written to for audio export.
  File getAudioExportFile() {
    String audioPath = path.join(exportDirectory.path, 'exportAudio.mp3');
    return File(audioPath);
  }

  /// Get a list of decks from the Anki background service that can be used
  /// for export.
  Future<List<String>> getDecks() async {
    try {
      Map<dynamic, dynamic> result =
          await methodChannel.invokeMethod('getDecks');
      List<String> decks = result.values.toList().cast<String>();

      decks.sort((a, b) => a.compareTo(b));
      return decks;
    } catch (e) {
      showAnkidroidApiMessage();
      rethrow;
    }
  }

  /// Get a list of models from the Anki background service that can be used
  /// for export.
  Future<List<String>> getModelList() async {
    try {
      Map<dynamic, dynamic> result =
          await methodChannel.invokeMethod('getModelList');
      List<String> models = result.values.toList().cast<String>();

      models.sort((a, b) => a.compareTo(b));
      return models;
    } catch (e) {
      showAnkidroidApiMessage();
      rethrow;
    }
  }

  /// Get a list of field names for a given [model] name in Anki. This function
  /// assumes that the model name can be found in [getDecks] and is valid.
  Future<List<String>> getFieldList(String model) async {
    try {
      List<String> fields = List<String>.from(
        await methodChannel.invokeMethod(
          'getFieldList',
          <String, dynamic>{
            'model': model,
          },
        ),
      );

      return fields;
    } catch (e) {
      showAnkidroidApiMessage();
      rethrow;
    }
  }

  /// Add a note with certain [details] and a [mapping] of fields to a model
  /// to a given [deck].
  Future<void> addNote({
    required ExportDetails details,
    required AnkiMapping mapping,
    required String deck,
  }) async {
    String timestamp =
        intl.DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
    String preferredName = 'jidoujisho-$timestamp';

    String? imageFileName;
    String? audioFileName;

    if (details.image != null) {
      imageFileName = await addFileToMedia(
        exportFile: details.image!,
        preferredName: preferredName,
        mimeType: 'image',
      );
    }

    if (details.audio != null) {
      audioFileName = await addFileToMedia(
        exportFile: details.audio!,
        preferredName: preferredName,
        mimeType: 'audio',
      );
    }

    String model = mapping.model;
    List<String> fields = getCardFields(
      details: details,
      mapping: mapping,
      imageFileName: imageFileName,
      audioFileName: audioFileName,
    );

    try {
      return await methodChannel.invokeMethod(
        'addNote',
        <String, dynamic>{
          'deck': deck,
          'model': model,
          'fields': fields,
        },
      );
    } on PlatformException {
      debugPrint('Failed to add note for [$preferredName]');
      rethrow;
    } finally {
      debugPrint('Added note for [$preferredName] to Anki media');
    }
  }

  /// Add a file to Anki media. [mimeType] can be 'image' or 'audio'.
  /// [preferredName] is used as a prefix to the file when exported to the
  /// media store. Returns the name of the file once successfully added to
  /// Anki media.
  Future<String> addFileToMedia({
    required File exportFile,
    required String preferredName,
    required String mimeType,
  }) async {
    late File destinationFile;
    if (mimeType == 'image') {
      destinationFile = getImageExportFile();
    } else if (mimeType == 'audio') {
      destinationFile = getAudioExportFile();
    } else {
      throw Exception('Invalid mime type, must be image or audio');
    }

    String destinationPath = destinationFile.path;
    exportFile.copySync(destinationPath);

    String uriPath = 'file:///${destinationFile.uri}';

    try {
      return await methodChannel.invokeMethod(
        'addFileToMedia',
        <String, String>{
          'uriPath': uriPath,
          'preferredName': preferredName,
          'mimeType': mimeType,
        },
      );
    } on PlatformException {
      debugPrint('Failed to add [$mimeType] to Anki media');
      rethrow;
    } finally {
      debugPrint('Added $mimeType for [$preferredName] to Anki media');
    }
  }

  /// Returns the list that will be passed to the Anki card creation API to
  /// fill a card's fields. The contents of the list will correspond to the
  /// order of the [mapping] provided, with each field in the list replaced
  /// with the corresponding [details] or in the case of the image and audio
  /// fields, the file names.
  static List<String> getCardFields({
    required ExportDetails details,
    required AnkiMapping mapping,
    required String? imageFileName,
    required String? audioFileName,
  }) {
    List<String> fields = mapping.fieldIndexes.map<String>((index) {
      if (index == null) {
        return '';
      }

      Field field = Field.values.elementAt(index);

      switch (field) {
        case Field.sentence:
          return details.sentence ?? '';
        case Field.word:
          return details.word ?? '';
        case Field.reading:
          return details.reading ?? '';
        case Field.meaning:
          return details.meaning ?? '';
        case Field.extra:
          return details.extra ?? '';
        case Field.context:
          return details.context ?? '';
        case Field.image:
          return imageFileName ?? '';
        case Field.audio:
          return audioFileName ?? '';
      }
    }).toList();

    return fields;
  }

  /// Returns whether or not a given [AnkiMapping] has the same amount of
  /// fields as the model it uses.
  Future<bool> profileFieldMatchesCardTypeCount(AnkiMapping mapping) async {
    List<String> fields = await getFieldList(mapping.model);
    return mapping.fieldIndexes.length == fields.length;
  }

  /// Returns whether or not a given [AnkiMapping]'s model exists in Anki.
  Future<bool> profileModelExists(AnkiMapping mapping) async {
    List<String> models = await getModelList();
    return models.contains(mapping.model);
  }

  /// Persist the standard profile as the last selected mapping.
  Future<void> selectStandardProfile() async {
    await _preferences.put(
        'last_selected_mapping', AnkiMapping.standardProfileName);
    notifyListeners();
  }

  /// Resets a profile's fields such that it will have the model's number of
  /// fields, all empty.
  Future<void> resetProfileFields(AnkiMapping mapping) async {
    List<String> fields = await getFieldList(mapping.model);
    List<int?> fieldIndexes = List.generate(fields.length, (index) => null);

    AnkiMapping resetMapping = mapping.copyWith(fieldIndexes: fieldIndexes);
    _database.writeTxnSync((database) {
      if (mapping.id != null &&
          database.ankiMappings.getSync(resetMapping.id!) != null) {
        database.ankiMappings.deleteSync(resetMapping.id!);
      }
      database.ankiMappings.putSync(resetMapping);
    });
  }

  /// Check for errors relating to the current selected export profile.
  Future<void> validateSelectedMapping({
    required BuildContext context,
    required AnkiMapping mapping,
  }) async {
    String errorModelChanged = translate('error_model_changed');
    String errorModelChangedContent = translate('error_model_changed_content');
    String errorModelMissing = translate('error_model_missing');
    String errorModelMissingContent = translate('error_model_missing_content');
    String dialogCloseLabel = translate('dialog_close');

    bool newMappingModelExists = await profileModelExists(mapping);

    /// Ensure that the following case never happens to the default profile.
    addDefaultModelIfMissing();

    if (!newMappingModelExists) {
      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => AlertDialog(
          title: Text(errorModelMissing),
          content: Text(
            errorModelMissingContent,
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              child: Text(dialogCloseLabel),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

      await selectStandardProfile();
      return;
    }

    bool newMappingModelLengthMatches =
        await profileFieldMatchesCardTypeCount(mapping);

    if (!newMappingModelLengthMatches) {
      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => AlertDialog(
          title: Text(errorModelChanged),
          content: Text(
            errorModelChangedContent,
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              child: Text(dialogCloseLabel),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

      await resetProfileFields(mapping);
    }
  }

  /// A helper function for opening the creator from any page in the
  /// application for card export purposes.
  Future<void> openCreator() async {
    List<String> decks = await getDecks();

    await Navigator.push(
      _navigatorKey.currentContext!,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => CreatorPage(
          decks: decks,
          editMode: false,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  /// A helper function for opening the creator from any page in the
  /// application for editing purposes.
  Future<void> openCreatorEnhancementsEditor() async {
    List<String> decks = await getDecks();

    await Navigator.push(
      _navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => CreatorPage(
          decks: decks,
          editMode: true,
        ),
      ),
    );
  }

  /// Updates a given [mapping]'s persisted enhancement for a given [field]
  /// and [slotNumber].
  void setFieldEnhancement({
    required AnkiMapping mapping,
    required Field field,
    required int slotNumber,
    required Enhancement enhancement,
  }) async {
    mapping.enhancements[field]![slotNumber] = enhancement.uniqueKey;

    _database.writeTxnSync((isar) {
      isar.ankiMappings.putSync(mapping);
    });
  }

  /// Removes a given [mapping]'s persisted enhancement for a given [field]
  /// and [slotNumber].
  void removeFieldEnhancement({
    required AnkiMapping mapping,
    required Field field,
    required int slotNumber,
  }) async {
    mapping.enhancements[field]!.remove(slotNumber);

    _database.writeTxnSync((isar) {
      isar.ankiMappings.putSync(mapping);
    });
  }

  /// Updates a given [mapping]'s persisted action for a given [slotNumber].
  void setQuickAction(
      {required AnkiMapping mapping,
      required int slotNumber,
      required QuickAction quickAction}) async {
    mapping.actions[slotNumber] = quickAction.uniqueKey;

    _database.writeTxnSync((isar) {
      isar.ankiMappings.putSync(mapping);
    });
  }

  /// Removes a given [mapping]'s persisted action for a given [slotNumber].
  void removeQuickAction({
    required AnkiMapping mapping,
    required int slotNumber,
  }) async {
    mapping.actions.remove(slotNumber);

    _database.writeTxnSync((isar) {
      isar.ankiMappings.putSync(mapping);
    });
  }

  /// Updates a given [mapping]'s persisted auto enhancement for a given
  /// [field].
  void setAutoFieldEnhancement({
    required AnkiMapping mapping,
    required Field field,
    required Enhancement enhancement,
  }) async {
    /// -1 is reserved for the auto enhancement.
    mapping.enhancements[field]![AnkiMapping.autoModeSlotNumber] =
        enhancement.uniqueKey;

    _database.writeTxnSync((isar) {
      isar.ankiMappings.putSync(mapping);
    });
  }

  /// Removes a given [mapping]'s persisted auto enhancement for a given
  /// [field].
  void removeAutoFieldEnhancement({
    required AnkiMapping mapping,
    required Field field,
  }) async {
    /// -1 is reserved for the auto enhancement.
    mapping.enhancements[field]!.remove(AnkiMapping.autoModeSlotNumber);

    _database.writeTxnSync((isar) {
      isar.ankiMappings.putSync(mapping);
    });
  }
}

import 'dart:async';

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart' as ag;
import 'package:cancelable_compute/cancelable_compute.dart' as cancelable;
import 'package:collection/collection.dart';
import 'package:clipboard/clipboard.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart' as intl;
import 'package:path/path.dart' as path;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:restart_app/restart_app.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakelock/wakelock.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// Schemas used in Isar database.
final List<CollectionSchema> globalSchemas = [
  DictionarySchema,
  DictionaryEntrySchema,
  DictionaryHeadingSchema,
  DictionaryPitchSchema,
  DictionaryFrequencySchema,
  DictionaryTagSchema,
  DictionarySearchResultSchema,
  MediaItemSchema,
  AnkiMappingSchema,
  SearchHistoryItemSchema,
  MessageItemSchema,
  MokuroCatalogSchema,
  BrowserBookmarkSchema,
];

/// A list of fields that the app will support at runtime.
final List<Field> globalFields = List<Field>.unmodifiable(
  [
    SentenceField.instance,
    TermField.instance,
    ReadingField.instance,
    MeaningField.instance,
    NotesField.instance,
    ImageField.instance,
    AudioField.instance,
    AudioSentenceField.instance,
    PitchAccentField.instance,
    FuriganaField.instance,
    FrequencyField.instance,
    ContextField.instance,
    ClozeBeforeField.instance,
    ClozeInsideField.instance,
    ClozeAfterField.instance,
    ExpandedMeaningField.instance,
    CollapsedMeaningField.instance,
    HiddenMeaningField.instance,
    TagsField.instance,
  ],
);

/// A list of media types that the app will support at runtime.
final Map<String, Field> fieldsByKey = Map.unmodifiable(
  Map<String, Field>.fromEntries(
    globalFields.map(
      (field) => MapEntry(field.uniqueKey, field),
    ),
  ),
);

/// A global [Provider] for app-wide configuration and state management.
final appProvider = ChangeNotifierProvider<AppModel>((ref) {
  return AppModel();
});

/// Provides color for all quick actions.
final quickActionColorProvider =
    FutureProvider.family<Map<String, Color?>, DictionaryHeading>(
        (ref, heading) async {
  AppModel appModel = ref.watch(appProvider);
  List<Future<Color?>> futures = appModel.quickActions.values.map((e) async {
    return e.getIconColor(
      appModel: appModel,
      heading: heading,
    );
  }).toList();

  List<Color?> colors = await Future.wait(futures);
  return Map<String, Color?>.fromEntries(
      appModel.quickActions.values.mapIndexed((i, action) {
    return MapEntry(action.uniqueKey, colors[i]);
  }));
});

/// A global [Provider] for maintaining visible once state.
final visibleOnceProvider =
    StateProvider.family<bool, DictionaryHeading>((ref, heading) => false);

/// A global [Provider] for listening to search term changes in PIP mode.
final pipSearchTermProvider = StateProvider<String>((ref) => '');

/// A global [Provider] for listening to search term position changes in PIP mode.
final pipSearchPositionProvider = StateProvider<int>((ref) => 0);

/// A scoped model for parameters that affect the entire application.
/// RiverPod is used for global state management across multiple layers,
/// especially for preferences that persist across application restarts.
class AppModel with ChangeNotifier {
  /// Used for showing dialogs without needing to pass around a [BuildContext].
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  late final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  /// Used to get the versioning metadata of the app. See [initialise].
  RouteObserver<PageRoute> get routeObserver => _routeObserver;
  final RouteObserver<PageRoute> _routeObserver = RouteObserver<PageRoute>();

  /// Used for accessing persistent key-value data. See [initialise].
  late final Box _preferences;

  /// Used for accessing persistent dictonary history. See [initialise].
  late final Box<int> _dictionaryHistory;

  /// Used for accessing persistent database data. See [initialise].
  late final Isar _database;

  /// Used to get the versioning metadata of the app. See [initialise].
  PackageInfo get packageInfo => _packageInfo;
  late final PackageInfo _packageInfo;

  /// Used to get information on the Android version of the device.
  AndroidDeviceInfo get androidDeviceInfo => _androidDeviceInfo;
  late final AndroidDeviceInfo _androidDeviceInfo;

  /// Used for caching images and audio produced from media seeds.
  DefaultCacheManager get cacheManager => _cacheManager;
  final _cacheManager = DefaultCacheManager();

  /// Used to notify dictionary widgets to dictionary history additions.
  final ChangeNotifier dictionaryEntriesNotifier = ChangeNotifier();

  /// Used to notify dictionary widgets to dictionary import additions.
  final ChangeNotifier dictionarySearchAgainNotifier = ChangeNotifier();

  /// Used to notify dictionary widgets to dictionary menu changes.
  final ChangeNotifier dictionaryMenuNotifier = ChangeNotifier();

  /// For refreshing on dictionary result additions.
  void refreshDictionaryHistory() {
    dictionaryMenuNotifier.notifyListeners();
  }

  /// Used to strip emoji from search terms.
  final _removeEmoji = RemoveEmoji();

  /// Used to notify toggling incognito. Updates the app logo to and from
  /// grayscale.
  final ChangeNotifier incognitoNotifier = ChangeNotifier();

  /// Notifies app to stop showing any screens.
  final ChangeNotifier databaseCloseNotifier = ChangeNotifier();

  /// These directories are prepared at startup in order to reduce redundancy
  /// in actual runtime.
  /// Directory where data that may be dumped is stored.
  Directory get temporaryDirectory => _temporaryDirectory;
  late final Directory _temporaryDirectory;

  /// Directory where data may be persisted.
  Directory get appDirectory => _appDirectory;
  late final Directory _appDirectory;

  /// Directory where database data is persisted.
  Directory get databaseDirectory => _databaseDirectory;
  late final Directory _databaseDirectory;

  /// Directory where browser cache data may be persisted.
  Directory get browserDirectory => _browserDirectory;
  late final Directory _browserDirectory;

  /// Directory where media source thumbnails may be persisted.
  Directory get thumbnailsDirectory => _thumbnailsDirectory;
  late final Directory _thumbnailsDirectory;

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

  /// Directory where the browser media source saves web archives for offline
  /// use.
  Directory get webArchiveDirectory => _webArchiveDirectory;
  late final Directory _webArchiveDirectory;

  /// Directory where media for export is stored for communication with
  /// third-party APIs. Fallback for failure.
  Directory get alternateExportDirectory => _alternateExportDirectory;
  late final Directory _alternateExportDirectory;

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

  /// Used to fetch initialised fields by their unique key with constant
  /// time performance. Initialised with [populateEnhancements] at startup.
  late final Map<String, Field> fields;

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
  final int maximumFieldEnhancements = 5;

  /// Maximum number of quick actions.
  final int maximumQuickActions = 6;

  /// Maximum number of search history items.
  final int maximumSearchHistoryItems = 60;

  /// Maximum number of media history items.
  final int maximumMediaHistoryItems = 100;

  /// Maximum number of dictionary history items.
  final int maximumDictionaryHistoryItems = 10;

  /// Maximum number of dictionary search results stored in the database.
  final int maximumDictionarySearchResults = 200;

  /// Maximum number of headwords in a returned dictionary result for
  /// performance purposes.
  final int defaultMaximumDictionaryTermsInResult = 10;

  /// Used as the history key used for the Stash.
  final String stashKey = 'stash';

  /// Used to check if the dictionary tab should be refreshed on switching tabs.
  bool shouldRefreshTabs = false;

  /// Returns all dictionaries imported into the database. Sorted by the
  /// user-defined order in the dictionary menu.
  List<Dictionary> get dictionaries =>
      _database.dictionarys.where().sortByOrder().findAllSync();

  /// Returns all export profiles.
  List<AnkiMapping> get mappings =>
      _database.ankiMappings.where().sortByOrder().findAllSync();

  /// Returns all Mokuro catalogs.
  List<MokuroCatalog> get mokuroCatalogs =>
      _database.mokuroCatalogs.where().sortByOrder().findAllSync();

  /// Returns all Browser bookmarks.
  List<BrowserBookmark> get browserBookmarks =>
      _database.browserBookmarks.where().anyId().findAllSync();

  /// Returns the message log for the [ReaderChatgptSource].
  List<MessageItem> get messages =>
      _database.messageItems.where().findAllSync();

  /// Adds a message to the  log for the [ReaderChatgptSource].
  int addMessage(MessageItem message) {
    late int id;
    _database.writeTxnSync(() {
      id = _database.messageItems.putSync(message);
    });

    return id;
  }

  /// Removes the last message from the log for the [ReaderChatgptSource].
  void removeMessage(int id) {
    _database.writeTxnSync(() {
      _database.messageItems.deleteSync(id);
    });
  }

  /// Clears the message log for the [ReaderChatgptSource].
  Future<void> clearMessages() async {
    await _database.writeTxn(() async {
      await _database.messageItems.clear();
    });
  }

  /// Returns all dictionary history results. Oldest is first.
  List<DictionarySearchResult> get dictionaryHistory =>
      _database.dictionarySearchResults
          .getAllSync(_dictionaryHistory.values.toList())
          .whereNotNull()
          .toList();

  /// For watching the dictionary history collection.
  Stream<void> Function(int) get watchDictionaryItem =>
      _database.dictionarySearchResults.watchObjectLazy;

  /// For invoking pauses from media where needed.
  Stream<void> get currentMediaPauseStream =>
      _currentMediaPauseController.stream;
  final StreamController<void> _currentMediaPauseController =
      StreamController.broadcast();

  /// For listening to searches made inside the Card Creator.
  Stream<void> get cardCreatorRecursiveSearchStream =>
      _cardCreatorRecursiveSearchStreamController.stream;
  final StreamController<void> _cardCreatorRecursiveSearchStreamController =
      StreamController.broadcast();

  /// Broadcast that a search was made in the Card Creator
  void notifyRecursiveSearch() {
    _cardCreatorRecursiveSearchStreamController.add(null);
  }

  /// Allows actions to be performed upon Play/Pause on headset buttons.
  Stream<void> get playPauseHeadsetActionStream =>
      _playPauseHeadsetActionStreamController.stream;
  final StreamController<void> _playPauseHeadsetActionStreamController =
      StreamController.broadcast();

  /// For listening to changes for whether or not the Card Creator is open.
  Stream<bool> get creatorActiveStream => _creatorActiveController.stream;
  final StreamController<bool> _creatorActiveController =
      StreamController.broadcast();

  /// Used to check whether or not the creator is currently in the navigation
  /// stack.
  bool get isCreatorOpen => _isCreatorOpen;
  bool _isCreatorOpen = false;

  /// Used to check whether or not the app is currently using a media source.
  bool get isMediaOpen => _currentMediaSource != null;

  /// Current active media source.
  MediaSource? get currentMediaSource => _currentMediaSource;
  MediaSource? _currentMediaSource;

  /// Current active media item.
  MediaItem? get currentMediaItem => _currentMediaItem;
  MediaItem? _currentMediaItem;

  /// Blocks creator from processing initial media while player controller is not ready.
  bool blockCreatorInitialMedia = false;

  /// Get the app-wide text style.
  TextStyle get textStyle => TextStyle(
        fontFamily: targetLanguage.defaultFontFamily,
        fontFeatures: const [FontFeature('liga', 0)],
        locale: targetLanguage.locale,
        textBaseline: targetLanguage.textBaseline,
      );

  /// This override is a workaround required to theme the app-wide [TextTheme]
  /// based on the [Locale] and [TextBaseline] of the active target language.
  TextTheme get textTheme => TextTheme(
        displayLarge: textStyle,
        displayMedium: textStyle,
        displaySmall: textStyle,
        headlineLarge: textStyle,
        headlineMedium: textStyle,
        headlineSmall: textStyle,
        titleLarge: textStyle,
        titleMedium: textStyle,
        titleSmall: textStyle,
        bodyLarge: textStyle,
        bodyMedium: textStyle,
        bodySmall: textStyle,
        labelLarge: textStyle,
        labelMedium: textStyle,
        labelSmall: textStyle,
      );

  /// Shows when the current mode is a light theme.
  ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: Colors.white,
        unselectedWidgetColor: Colors.black54,
        textTheme: textTheme,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateColor.resolveWith((states) {
            return states.contains(MaterialState.selected)
                ? Colors.red
                : Colors.white;
          }),
          trackColor: MaterialStateColor.resolveWith((states) {
            return states.contains(MaterialState.selected)
                ? Colors.red.withOpacity(0.5)
                : Colors.grey;
          }),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: textTheme.labelSmall,
          unselectedLabelStyle: textTheme.labelSmall,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(),
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
        ),
        cardColor: Colors.white,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
        ),
        listTileTheme: ListTileThemeData(
          dense: true,
          selectedTileColor: Colors.grey.shade300,
          selectedColor: Colors.black,
          horizontalTitleGap: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black54,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thickness: MaterialStateProperty.all(3),
          thumbVisibility: MaterialStateProperty.all(true),
        ),
        sliderTheme: const SliderThemeData(
          thumbColor: Colors.red,
          activeTrackColor: Colors.red,
          inactiveTrackColor: Colors.grey,
          trackShape: RectangularSliderTrackShape(),
          trackHeight: 2,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(
              primary: Colors.red,
              secondary: Colors.red,
              brightness: Brightness.light,
            )
            .copyWith(background: Colors.white),
      );

  /// Shows when the current mode is a dark theme.
  ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: Colors.black,
        textTheme: textTheme,
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateColor.resolveWith((states) {
            return states.contains(MaterialState.selected)
                ? Colors.red
                : Colors.grey;
          }),
          trackColor: MaterialStateColor.resolveWith((states) {
            return states.contains(MaterialState.selected)
                ? Colors.red.withOpacity(0.5)
                : Colors.grey;
          }),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: textTheme.labelSmall,
          unselectedLabelStyle: textTheme.labelSmall,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: Colors.black,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: Color.fromARGB(255, 30, 30, 30),
          shape: RoundedRectangleBorder(),
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: Color.fromARGB(255, 30, 30, 30),
          shape: RoundedRectangleBorder(),
        ),
        cardColor: const Color.fromARGB(255, 30, 30, 30),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
        listTileTheme: ListTileThemeData(
          dense: true,
          selectedTileColor: Colors.grey.shade600,
          selectedColor: Colors.white,
          horizontalTitleGap: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white70,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: MaterialStateProperty.all(true),
        ),
        sliderTheme: const SliderThemeData(
          thumbColor: Colors.red,
          activeTrackColor: Colors.red,
          inactiveTrackColor: Colors.grey,
          trackShape: RectangularSliderTrackShape(),
          trackHeight: 2,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(
              primary: Colors.red,
              secondary: Colors.red,
              brightness: Brightness.dark,
            )
            .copyWith(background: Colors.black),
      );

  /// Get the sentence to be used by the [SentenceField] upon card creation.
  JidoujishoTextSelection getCurrentSentence() {
    if (isMediaOpen) {
      return _currentMediaSource!.currentSentence;
    } else {
      MediaType mediaType = mediaTypes.values.toList()[currentHomeTabIndex];
      if (mediaType is DictionaryMediaType) {
        return JidoujishoTextSelection(
          text: '',
        );
      } else {
        return (_currentMediaSource ??
                (getCurrentSourceForMediaType(mediaType: mediaType)))
            .currentSentence;
      }
    }
  }

  /// This should all be refactored as part of [MediaItem] if possible. No
  /// reason to expose it here if not for card export functions. This is super
  /// cursed. Need to extract this to its own Provider at some point.

  /// Current player controller.
  VlcPlayerController? currentPlayerController;

  /// Current subtitle.
  ValueNotifier<Subtitle?> get currentSubtitle => _currentSubtitle;
  final ValueNotifier<Subtitle?> _currentSubtitle =
      ValueNotifier<Subtitle?>(null);

  /// Current subtitle options.
  ValueNotifier<SubtitleOptions>? get currentSubtitleOptions {
    _currentSubtitleOptions ??= ValueNotifier<SubtitleOptions>(subtitleOptions);
    return _currentSubtitleOptions;
  }

  ValueNotifier<SubtitleOptions>? _currentSubtitleOptions;

  /// Override color for the dictionary widget.
  Color? get overrideDictionaryColor => _overrideDictionaryColor;
  Color? _overrideDictionaryColor;

  /// Override theme for the dictionary widget.
  ThemeData? get overrideDictionaryTheme => _overrideDictionaryTheme;
  ThemeData? _overrideDictionaryTheme;

  /// Override color for the dictionary widget.
  void setOverrideDictionaryColor(Color? color) {
    _overrideDictionaryColor = color;
  }

  /// Override theme for the dictionary widget.
  void setOverrideDictionaryTheme(ThemeData? themeData) {
    _overrideDictionaryTheme = themeData;
  }

  /// Get the current media item for use in tracking history and generating
  /// media for card creation based on media progress.
  MediaItem? getCurrentMediaItem() {
    if (_currentMediaSource == null) {
      return null;
    } else {
      return _currentMediaItem;
    }
  }

  /// Manually flag that the app is now using a media item. Prefer [openMedia]
  /// instead of this.
  void setCurrentMediaItem(MediaItem mediaItem) {
    _currentMediaItem = mediaItem;
    _currentMediaSource = mediaItem.getMediaSource(appModel: this);
  }

  /// Get a mapping with a given mapping name.
  AnkiMapping? getMappingFromLabel(String label) {
    return _database.ankiMappings.where().labelEqualTo(label).findFirstSync();
  }

  /// Change this once a field hide/show system is in place.
  List<Field> get activeFields => [
        ...lastSelectedMapping.getCreatorFields(),
        ...lastSelectedMapping.getCreatorCollapsedFields()
      ];

  /// Update the user-defined order of a given dictionary in the database.
  /// See the dictionary dialog's [ReorderableListView] for usage.
  void updateDictionaryOrder(List<Dictionary> newDictionaries) async {
    _database.writeTxnSync(() {
      _database.dictionarys.putAllSync(newDictionaries);
    });
  }

  /// Update the user-defined order of a given dictionary in the database.
  /// See the dictionary dialog's [ReorderableListView] for usage.
  void updateMappingsOrder(List<AnkiMapping> newMappings) async {
    _database.writeTxnSync(() {
      _database.ankiMappings.clearSync();
      _database.ankiMappings.putAllSync(newMappings);
    });
  }

  /// Update the user-defined order of given catalogs in the database.
  /// See the catalog dialog's [ReorderableListView] for usage.
  void updateCatalogsOrder(List<MokuroCatalog> newCatalogs) async {
    _database.writeTxnSync(() {
      _database.mokuroCatalogs.clearSync();
      _database.mokuroCatalogs.putAllSync(newCatalogs);
    });
  }

  /// Populate maps for languages at startup to optimise performance.
  void populateLanguages() async {
    /// A list of languages that the app will support at runtime.
    final List<Language> availableLanguages = List<Language>.unmodifiable(
      [
        JapaneseLanguage.instance,
        EnglishLanguage.instance,
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
      PlayerMediaType.instance: [
        PlayerLocalMediaSource.instance,
        PlayerYoutubeSource.instance,
        PlayerNetworkStreamSource.instance
      ],
      ReaderMediaType.instance: [
        ReaderTtuSource.instance,
        ReaderMokuroSource.instance,
        ReaderBrowserSource.instance,
        ReaderLyricsSource.instance,
        ReaderChatgptSource.instance,
        ReaderClipboardSource.instance,
        ReaderWebsocketSource.instance,
      ],
      ViewerMediaType.instance: [
        ViewerCameraSource.instance,
      ],
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
        YomichanFormat.instance,
        MigakuFormat.instance,
        AbbyyLingvoFormat.instance,
      ],
    );

    dictionaryFormats = Map<String, DictionaryFormat>.unmodifiable(
      Map<String, DictionaryFormat>.fromEntries(
        availableDictionaryFormats.map(
          (dictionaryFormat) => MapEntry(
            dictionaryFormat.uniqueKey,
            dictionaryFormat,
          ),
        ),
      ),
    );
  }

  /// Populate maps for fields at startup to optimise performance.
  void populateFields() async {
    fields = Map<String, Field>.unmodifiable(
      Map<String, Field>.fromEntries(
        globalFields.map(
          (field) => MapEntry(field.uniqueKey, field),
        ),
      ),
    );
  }

  /// Populate maps for enhancements at startup to optimise performance.
  void populateEnhancements() async {
    /// A list of enhancements that the app will support at runtime.
    final Map<Field, List<Enhancement>> availableEnhancements = {
      AudioField.instance: [
        ClearFieldEnhancement(field: AudioField.instance),
        JapanesePod101AudioEnhancement(),
        ForvoAudioEnhancement(),
        PickAudioEnhancement(field: AudioField.instance),
        AudioRecorderEnhancement(field: AudioField.instance),
      ],
      AudioSentenceField.instance: [
        ClearFieldEnhancement(field: AudioSentenceField.instance),
        PickAudioEnhancement(field: AudioSentenceField.instance),
        AudioRecorderEnhancement(field: AudioSentenceField.instance),
      ],
      NotesField.instance: [
        ClearFieldEnhancement(field: NotesField.instance),
        OpenStashEnhancement(field: NotesField.instance),
        PopFromStashEnhancement(field: NotesField.instance),
        TextSegmentationEnhancement(field: NotesField.instance),
      ],
      ImageField.instance: [
        ClearFieldEnhancement(field: ImageField.instance),
        BingImagesSearchEnhancement(),
        CropImageEnhancement(),
        PickImageEnhancement(),
        CameraEnhancement(),
      ],
      MeaningField.instance: [
        ClearFieldEnhancement(field: MeaningField.instance),
        SentencePickerEnhancement(field: MeaningField.instance),
        TextSegmentationEnhancement(field: MeaningField.instance),
      ],
      ReadingField.instance: [
        ClearFieldEnhancement(field: ReadingField.instance),
      ],
      SentenceField.instance: [
        ClearFieldEnhancement(field: SentenceField.instance),
        TextSegmentationEnhancement(field: SentenceField.instance),
        SentencePickerEnhancement(field: SentenceField.instance),
        OpenStashEnhancement(field: SentenceField.instance),
        PopFromStashEnhancement(field: SentenceField.instance),
      ],
      TermField.instance: [
        ClearFieldEnhancement(field: TermField.instance),
        SearchDictionaryEnhancement(),
        MassifExampleSentencesEnhancement(),
        TatoebaExampleSentencesEnhancement(),
        ImmersionKitEnhancement(),
        OpenStashEnhancement(field: TermField.instance),
        PopFromStashEnhancement(field: TermField.instance),
      ],
      ContextField.instance: [
        ClearFieldEnhancement(field: ContextField.instance),
        OpenStashEnhancement(field: ContextField.instance),
        PopFromStashEnhancement(field: ContextField.instance),
      ],
      PitchAccentField.instance: [
        ClearFieldEnhancement(field: PitchAccentField.instance),
      ],
      FuriganaField.instance: [
        ClearFieldEnhancement(field: FuriganaField.instance),
      ],
      FrequencyField.instance: [
        ClearFieldEnhancement(field: FrequencyField.instance),
      ],
      CollapsedMeaningField.instance: [
        ClearFieldEnhancement(field: CollapsedMeaningField.instance),
        SentencePickerEnhancement(field: CollapsedMeaningField.instance),
        TextSegmentationEnhancement(field: CollapsedMeaningField.instance),
      ],
      ExpandedMeaningField.instance: [
        ClearFieldEnhancement(field: ExpandedMeaningField.instance),
        SentencePickerEnhancement(field: ExpandedMeaningField.instance),
        TextSegmentationEnhancement(field: ExpandedMeaningField.instance),
      ],
      HiddenMeaningField.instance: [
        ClearFieldEnhancement(field: HiddenMeaningField.instance),
        SentencePickerEnhancement(field: HiddenMeaningField.instance),
        TextSegmentationEnhancement(field: HiddenMeaningField.instance),
      ],
      TagsField.instance: [
        ClearFieldEnhancement(field: TagsField.instance),
        SaveTagsEnhancement(),
      ],
      ClozeBeforeField.instance: [
        ClearFieldEnhancement(field: ClozeBeforeField.instance),
      ],
      ClozeAfterField.instance: [
        ClearFieldEnhancement(field: ClozeAfterField.instance),
      ],
      ClozeInsideField.instance: [
        ClearFieldEnhancement(field: ClozeInsideField.instance),
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
      AddToStashAction(),
      CopyToClipboardAction(),
      ShareAction(),
      PlayAudioAction(),
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
  void populateDefaultMapping(Language language) async {
    if (_database.ankiMappings.where().findAllSync().isEmpty) {
      _database.writeTxnSync(() {
        _database.ankiMappings.putSync(AnkiMapping.defaultMapping(
          language: language,
          order: 0,
        ));
      });
    } else {
      AnkiMapping standardProfile = _database.ankiMappings
          .where()
          .labelEqualTo(AnkiMapping.standardProfileName)
          .findFirstSync()!;
      if (standardProfile.model != AnkiMapping.standardModelName) {
        String newLabel = 'Legacy Standard';
        int attempts = 1;

        while (_database.ankiMappings
            .where()
            .labelEqualTo(newLabel)
            .findAllSync()
            .isNotEmpty) {
          attempts += 1;
          newLabel = 'Legacy Standard ($attempts)';
        }

        AnkiMapping legacyProfile = standardProfile.copyWith(
          label: newLabel,
        );

        _database.writeTxnSync(() {
          _database.ankiMappings.putAllSync(
            [
              legacyProfile,
              AnkiMapping.defaultMapping(
                language: language,
                order: nextMappingOrder,
              ),
            ],
          );
        });

        await showDialog(
          barrierDismissible: true,
          context: _navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: Text(t.info_standard_update),
            content: Text(
              t.info_standard_update_content,
            ),
            actions: [
              TextButton(
                child: Text(t.dialog_close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Populate list of bookmarks included with the app by default.
  void populateBookmarks() {
    if (populateBookmarksFlag) {
      return;
    }

    List<BrowserBookmark> defaultBookmarks = [
      BrowserBookmark(
          name: 'jidoujisho', url: 'https://github.com/lrorpilla/jidoujisho'),
      BrowserBookmark(name: 'Google', url: 'https://google.com/'),
      BrowserBookmark(name: 'DuckDuckGo', url: 'https://duckduckgo.com/'),
      BrowserBookmark(name: 'Wikipedia', url: 'https://wikipedia.org/'),
      BrowserBookmark(name: 'Syosetu', url: 'https://syosetu.com/'),
      BrowserBookmark(name: 'Kurashiru', url: 'https://kurashiru.com/'),
      BrowserBookmark(name: 'Oricon', url: 'https://www.oricon.co.jp/'),
      BrowserBookmark(name: 'NHK News', url: 'https://www3.nhk.or.jp/news/'),
      BrowserBookmark(name: 'BBC News', url: 'https://www.bbc.com/news'),
    ];

    _database.writeTxnSync(() {
      _database.browserBookmarks.putAllSync(defaultBookmarks);
    });

    setPopulateBookmarksFlag();
  }

  /// Return the app external directory found in the public DCIM directory.
  /// This path also initialises the folder if it does not exist, and includes
  /// a .nomedia file within the folder.
  Future<Directory> prepareJidoujishoDirectory() async {
    String publicDirectory =
        await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DCIM);
    try {
      String directoryPath = path.join(publicDirectory, 'jidoujisho');
      String noMediaFilePath =
          path.join(publicDirectory, 'jidoujisho', '.nomedia');

      Directory jidoujishoDirectory = Directory(directoryPath);
      File noMediaFile = File(noMediaFilePath);

      if (!jidoujishoDirectory.existsSync()) {
        jidoujishoDirectory.createSync(recursive: true);
      }
      if (!noMediaFile.existsSync()) {
        noMediaFile.createSync();
      }

      return jidoujishoDirectory;
    } catch (e) {
      debugPrint('Failed to create directory in DCIM.');
      return prepareFallbackJidoujishoDirectory();
    }
  }

  /// Return the app external directory found in the internal app directory.
  /// This path also initialises the folder if it does not exist, and includes
  /// a .nomedia file within the folder.
  Future<Directory> prepareFallbackJidoujishoDirectory() async {
    String directoryPath = path.join(appDirectory.path, 'jidoujishoExport');
    String noMediaFilePath =
        path.join(appDirectory.path, 'jidoujishoExport', '.nomedia');

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

  /// Preloads the app icon so that there is no pop-in.
  final Image appIcon = Image.asset(
    'assets/meta/icon.png',
  );

  /// Injects licenses to be displayed in the licenses page that aren't
  /// pre-included by Flutter upon compilation but are included as assets.
  Future<void> injectAssetLicenses() async {
    final packageNames = [
      'ebook-reader',
      'ipadic',
      've',
    ];

    for (String packageName in packageNames) {
      String licenseText =
          await rootBundle.loadString('assets/licenses/$packageName.txt');
      LicenseRegistry.addLicense(
        () => Stream<LicenseEntry>.value(
          LicenseEntryWithLineBreaks(<String>[packageName], licenseText),
        ),
      );
    }
  }

  /// Prepare application data and state to be ready of use upon starting up
  /// the application. [AppModel] is initialised in the main function before
  /// [runApp] is executed.
  Future<void> initialise() async {
    /// Prepare entities that may be repeatedly used at runtime.
    _packageInfo = await PackageInfo.fromPlatform();
    _androidDeviceInfo = await DeviceInfoPlugin().androidInfo;

    /// Initialise persistent key-value store.
    await Hive.initFlutter();
    _preferences = await Hive.openBox('appModel');
    _dictionaryHistory = await Hive.openBox('dictionaryHistory');

    /// Perform startup activities unnecessary to further initialisation here.
    await requestExternalStoragePermissions();
    await requestAnkidroidPermissions();

    /// These directories will commonly be accessed.
    _temporaryDirectory = await getTemporaryDirectory();
    _appDirectory = await getApplicationDocumentsDirectory();
    _databaseDirectory = await getApplicationSupportDirectory();
    _browserDirectory = Directory(path.join(appDirectory.path, 'browser'));
    _thumbnailsDirectory =
        Directory(path.join(appDirectory.path, 'thumbnails'));
    _hiveDirectory = Directory(path.join(appDirectory.path, 'hive'));

    _dictionaryImportWorkingDirectory = Directory(
        path.join(appDirectory.path, 'dictionaryImportWorkingDirectory'));
    _exportDirectory = await prepareJidoujishoDirectory();
    _alternateExportDirectory = await prepareFallbackJidoujishoDirectory();
    _webArchiveDirectory =
        Directory(path.join(appDirectory.path, 'webArchive'));

    thumbnailsDirectory.createSync();
    hiveDirectory.createSync();
    dictionaryImportWorkingDirectory.createSync();

    /// Inject open source licenses for non-Flutter dependencies that are
    /// included as assets.
    await injectAssetLicenses();

    /// Populate entities with key-value maps for constant time performance.
    /// This is not the initialisation step, which occurs below.
    populateLanguages();
    populateLocales();
    populateMediaTypes();
    populateMediaSources();
    populateDictionaryFormats();
    populateEnhancements();
    populateQuickActions();

    /// Get the current target language and prepare its resources for use. This
    /// will not re-run if the target language is already initialised, as
    /// a [Language] should always have a singleton instance and will not
    /// re-prepare its resources if already initialised. See
    /// [Language.initialise] for more details.
    await targetLanguage.initialise();

    /// Ready all enhancements sources for use.
    for (Field field in globalFields) {
      for (Enhancement enhancement in enhancements[field]!.values) {
        await enhancement.initialise();
      }
    }

    /// Ready all quick actions for use.
    for (QuickAction action in quickActions.values) {
      await action.initialise();
    }

    /// Ready all media sources for use.
    for (MediaType type in mediaTypes.values) {
      for (MediaSource source in mediaSources[type]!.values) {
        await source.initialise();
      }
    }

    /// Initialise persistent database.
    _database = await Isar.open(
      globalSchemas,
      directory: _databaseDirectory.path,
      maxSizeMiB: 8192,
    );

    /// Preloads the search database in memory.
    searchDictionary(
      searchTerm: targetLanguage.helloWorld,
      searchWithWildcards: false,
      useCache: false,
    ).then((_) {
      /// Preloads for wildcard searches.
      searchDictionary(
        searchTerm: '${targetLanguage.helloWorld.substring(0, 1)}?',
        searchWithWildcards: true,
        useCache: false,
      ).then((_) {
        searchDictionary(
          searchTerm: '${targetLanguage.helloWorld.substring(0, 1)}*',
          searchWithWildcards: true,
          useCache: false,
        );
      });
    });
  }

  /// Get whether or not the current theme is dark mode.
  bool get isDarkMode {
    bool isDarkMode = _preferences.get('is_dark_mode',
        defaultValue:
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    return isDarkMode;
  }

  /// Toggle between light and dark mode.
  void toggleDarkMode() async {
    await _preferences.put('is_dark_mode', !isDarkMode);
    Restart.restartApp();
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
    String firstDictionaryFormatName = dictionaryFormats.values.first.uniqueKey;
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
    String mappingName = _preferences.get(
      'last_selected_mapping',
      defaultValue: mappings.first.label,
    );

    AnkiMapping mapping = _database.ankiMappings
            .where()
            .labelEqualTo(mappingName)
            .findFirstSync() ??
        _database.ankiMappings
            .where()
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

    language.initialise();

    notifyListeners();
  }

  /// Persist a new app locale in preferences.
  Future<void> setAppLocale(String localeTag) async {
    await _preferences.put('appf_locale', localeTag);
    notifyListeners();
  }

  /// Persist a new last selected dictionary format. This is called when the
  /// user changes the import format in the dictionary menu.
  Future<void> setLastSelectedDictionaryFormat(
      DictionaryFormat dictionaryFormat) async {
    String lastDictionaryFormatName = dictionaryFormat.uniqueKey;
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
  Future<void> setLastSelectedMapping(AnkiMapping mapping,
      {bool notify = true}) async {
    await _preferences.put('last_selected_mapping', mapping.label);
    if (notify) {
      notifyListeners();
    }
  }

  /// Get the current home tab index. The order of the tab indexes are based on
  /// the ordering in [mediaTypes].
  int get currentHomeTabIndex =>
      _preferences.get('current_home_tab_index', defaultValue: 0);

  /// Persist the new tab after switching home tabs.
  Future<void> setCurrentHomeTabIndex(int index) async {
    await _preferences.put('current_home_tab_index', index);
  }

  /// Show the dictionary menu. This should be callable from many parts of the
  /// app, so it is appropriately handled by the model.
  Future<void> showDictionaryMenu() async {
    await showDialog(
      barrierDismissible: true,
      context: navigatorKey.currentContext!,
      builder: (context) => const DictionaryDialogPage(),
    );

    notifyListeners();
    dictionaryMenuNotifier.notifyListeners();
  }

  /// Show the language menu. This should be callable from many parts of the
  /// app, so it is appropriately handled by the model.
  Future<void> showLanguageMenu() async {
    await showDialog(
      barrierDismissible: true,
      context: navigatorKey.currentContext!,
      builder: (context) => LanguageDialogPage(
        isFirstTimeSetup: isFirstTimeSetup,
      ),
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

    notifyListeners();
  }

  /// Start the process of importing a dictionary. This is called from the
  /// dictionary menu, and starts the process of importing for the
  /// [lastSelectedDictionaryFormat].
  Future<void> importDictionary({
    required File file,
    required ValueNotifier<String> progressNotifier,
    required Function() onImportSuccess,
  }) async {
    /// New results may be wrong after dictionary is added so this has to be
    /// done.
    clearDictionaryResultsCache();

    Directory workingDirectory = _dictionaryImportWorkingDirectory;
    DictionaryFormat dictionaryFormat = lastSelectedDictionaryFormat;

    /// Importing makes heavy use of isolates as it is very performance
    /// intensive to work with files. In order to ensure the UI isolate isn't
    /// blocked, a [ReceivePort] is necessary to receive UI updates.
    ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) {
      progressNotifier.value = '$message';
    });

    /// Used to show an [AlertDialog] if critical information needs to be
    /// given to a user regarding the dictionary they are importing.
    ReceivePort alertReceivePort = ReceivePort();
    alertReceivePort.listen((message) {
      Fluttertoast.showToast(
        msg: message.toString(),
        toastLength: Toast.LENGTH_LONG,
      );
    });

    /// If any [Exception] occurs, the process is aborted with a message as
    /// shown below. A dialog is shown to show the progress of the dictionary
    /// file import, with messages pertaining to the above [ValueNotifier].
    try {
      /// The working directory should always be emptied before and after
      /// dictionary import to ensure that no files bloat the system and that
      /// files from previous imports do not carry over.
      if (workingDirectory.existsSync()) {
        progressNotifier.value = t.import_clean;
        workingDirectory.deleteSync(recursive: true);
        workingDirectory.createSync();
      }

      String charset = '';

      /// Find a way to check if this is a text file or a binary file instead
      /// of doing this, it's not good to do format-specific tweaks in a
      /// general function like this.
      if (dictionaryFormat.isTextFormat) {
        var randomAccessFile = file.openSync();
        var bytes = randomAccessFile.readSync(100);
        DecodingResult result = await CharsetDetector.autoDecode(bytes);
        charset = result.charset;
      }

      PrepareDirectoryParams prepareDirectoryParams = PrepareDirectoryParams(
        file: file,
        charset: charset,
        directoryPath: _databaseDirectory.path,
        workingDirectory: workingDirectory,
        dictionaryFormat: dictionaryFormat,
        sendPort: receivePort.sendPort,
      );
      progressNotifier.value = t.import_extract;
      await dictionaryFormat.prepareDirectory(prepareDirectoryParams);

      String name = await dictionaryFormat.prepareName(prepareDirectoryParams);
      progressNotifier.value = t.import_name(name: name);
      Dictionary? bottomMostDictionary = _database.dictionarys
          .where(sort: Sort.desc)
          .anyOrder()
          .findFirstSync();

      Dictionary? sameNameDictionary =
          _database.dictionarys.where().nameEqualTo(name).findFirstSync();
      if (sameNameDictionary != null) {
        throw Exception(t.import_duplicate(name: name));
      }

      int order = (bottomMostDictionary?.order ?? 0) + 1;

      Dictionary dictionary = Dictionary(
        order: order,
        name: name,
        formatKey: dictionaryFormat.uniqueKey,
      );

      PrepareDictionaryParams prepareDictionaryParams = PrepareDictionaryParams(
        dictionary: dictionary,
        workingDirectory: workingDirectory,
        directoryPath: _databaseDirectory.path,
        dictionaryFormat: dictionaryFormat,
        useSlowImport: useSlowImport,
        sendPort: receivePort.sendPort,
        alertSendPort: alertReceivePort.sendPort,
      );

      await compute(depositDictionaryDataHelper, prepareDictionaryParams);

      /// The working directory should always be emptied before and after
      /// dictionary import to ensure that no files bloat the system and that
      /// files from previous imports do not carry over.
      if (workingDirectory.existsSync()) {
        progressNotifier.value = t.import_clean;
        workingDirectory.deleteSync(recursive: true);
        workingDirectory.createSync();
      }

      progressNotifier.value = t.import_complete;
      onImportSuccess();
      await Future.delayed(const Duration(seconds: 1), () {});
    } catch (e) {
      progressNotifier.value = '$e';
      await Future.delayed(const Duration(seconds: 3), () {});
      progressNotifier.value = t.import_failed;
      await Future.delayed(const Duration(seconds: 1), () {});
    } finally {
      receivePort.close();
    }
  }

  /// Toggle a dictionary's between collapsed and expanded state. This will
  /// affect how a dictionary's search results are shown by default.
  void toggleDictionaryCollapsed(Dictionary dictionary) {
    _database.writeTxnSync(() {
      if (dictionary.isCollapsed(targetLanguage)) {
        dictionary.collapsedLanguages = [...dictionary.collapsedLanguages]
          ..remove(targetLanguage.languageCode);
      } else {
        dictionary.collapsedLanguages = [
          ...dictionary.collapsedLanguages,
          targetLanguage.languageCode
        ];
      }
      _database.dictionarys.putSync(dictionary);
    });
  }

  /// Toggle a dictionary's between hidden and shown state. This will
  /// affect how a dictionary's search results are shown by default.
  void toggleDictionaryHidden(Dictionary dictionary) {
    _database.writeTxnSync(() {
      if (dictionary.isHidden(targetLanguage)) {
        dictionary.hiddenLanguages = [...dictionary.hiddenLanguages]
          ..remove(targetLanguage.languageCode);
      } else {
        dictionary.hiddenLanguages = [
          ...dictionary.hiddenLanguages,
          targetLanguage.languageCode
        ];
      }
      _database.dictionarys.putSync(dictionary);
    });
  }

  /// Delete all dictionary data from the database.
  Future<void> deleteDictionaries() async {
    /// New results may be wrong after dictionary is added so this has to be
    /// done.
    clearDictionaryResultsCache();

    ReceivePort receivePort = ReceivePort();
    DeleteDictionaryParams params = DeleteDictionaryParams(
      directoryPath: _databaseDirectory.path,
      sendPort: receivePort.sendPort,
    );

    await compute(deleteDictionariesHelper, params);
    await _dictionaryHistory.clear();

    dictionarySearchAgainNotifier.notifyListeners();
  }

  /// Delete all dictionary data from the database.
  Future<void> deleteDictionary(Dictionary dictionary) async {
    /// New results may be wrong after dictionary is added so this has to be
    /// done.
    clearDictionaryResultsCache();

    ReceivePort receivePort = ReceivePort();
    DeleteDictionaryParams params = DeleteDictionaryParams(
      dictionaryId: dictionary.id,
      directoryPath: _databaseDirectory.path,
      sendPort: receivePort.sendPort,
    );

    await compute(deleteDictionaryHelper, params);
    await _dictionaryHistory.clear();

    dictionarySearchAgainNotifier.notifyListeners();
  }

  /// Delete a selected mapping from the database.
  void deleteMapping(AnkiMapping mapping) async {
    _database.writeTxnSync(() {
      _database.ankiMappings.deleteSync(mapping.id!);
    });

    if (mapping.label == lastSelectedMappingName) {
      await setLastSelectedMapping(mappings.first);
    }
  }

  /// Add a selected mapping to the database.
  void addMapping(AnkiMapping mapping) async {
    _database.writeTxnSync(() {
      if (mapping.id != null &&
          _database.ankiMappings.getSync(mapping.id!) != null) {
        _database.ankiMappings.deleteSync(mapping.id!);
      }
      _database.ankiMappings.putSync(mapping);
    });
  }

  /// Delete a selected catalog from the database.
  void deleteCatalog(MokuroCatalog mapping) async {
    _database.writeTxnSync(() {
      _database.mokuroCatalogs.deleteSync(mapping.id!);
    });
  }

  /// Delete a selected catalog from the database.
  void deleteBookmark(BrowserBookmark bookmark) async {
    _database.writeTxnSync(() {
      _database.browserBookmarks.deleteSync(bookmark.id!);
    });
  }

  /// Add a selected catalog to the database.
  Future<void> addCatalog(MokuroCatalog catalog) async {
    await _database.writeTxnSync(() async {
      if (catalog.id != null &&
          _database.mokuroCatalogs.getSync(catalog.id!) != null) {
        _database.mokuroCatalogs.deleteSync(catalog.id!);
      }
      _database.mokuroCatalogs.putSync(catalog);
    });
  }

  /// Add a selected bookmark to the database.
  Future<void> addBookmark(BrowserBookmark bookmark) async {
    await _database.writeTxnSync(() async {
      if (bookmark.id != null &&
          _database.browserBookmarks.getSync(bookmark.id!) != null) {
        _database.browserBookmarks.deleteSync(bookmark.id!);
      }
      _database.browserBookmarks.putSync(bookmark);
    });
  }

  /// Used for caching search results. Cleared when a dictionary is added or
  /// deleted.
  final Map<String, DictionarySearchResult> _dictionarySearchCache = {};

  /// Used when a dictionary is added or removed as those results may now be
  /// wrong.
  void clearDictionaryResultsCache() {
    _dictionarySearchCache.clear();
  }

  /// Whether or not the app is currently searching.
  cancelable.ComputeOperation? _searchOperation;

  /// Gets the raw unprocessed entries straight from a dictionary database
  /// given a search term. This will be processed later for user viewing.
  Future<DictionarySearchResult> searchDictionary({
    required String searchTerm,
    required bool searchWithWildcards,
    int? overrideMaximumTerms,
    bool useCache = true,
  }) async {
    if (_dictionarySearchCache['$searchTerm/$overrideMaximumTerms'] != null &&
        useCache) {
      return _dictionarySearchCache['$searchTerm/$overrideMaximumTerms']!;
    }

    searchTerm = searchTerm.replaceAll('\n', ' ');
    searchTerm = _removeEmoji.clean(searchTerm, ' ', false);

    /// Strip lone surrogates that may crash the search.
    RegExp loneSurrogate = RegExp(
      '[\uD800-\uDBFF](?![\uDC00-\uDFFF])|(?:[^\uD800-\uDBFF]|^)[\uDC00-\uDFFF]',
    );
    searchTerm = searchTerm.replaceAll(loneSurrogate, ' ');

    ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) {
      debugPrint(message.toString());
    });

    DictionarySearchParams params = DictionarySearchParams(
      searchTerm: searchTerm,
      directoryPath: _databaseDirectory.path,
      maximumDictionarySearchResults: maximumDictionarySearchResults,
      maximumDictionaryTermsInResult: overrideMaximumTerms ?? maximumTerms,
      searchWithWildcards: searchWithWildcards,
      enabledDictionaryIds: [],
      sendPort: receivePort.sendPort,
    );

    if (params.searchTerm.trim().isEmpty) {
      return DictionarySearchResult(searchTerm: searchTerm);
    }

    /// Searching also persists the result in the database. This is useful for
    /// dictionary search history, as well as allowing a result to be linked
    /// to the actual data, rather than duplicating that data within the
    /// database, which is not ideal for storage purposes.
    _searchOperation =
        cancelable.compute(targetLanguage.prepareSearchResults, params);
    int? id = await _searchOperation?.value;

    if (id == null) {
      return DictionarySearchResult(searchTerm: searchTerm);
    }

    DictionarySearchResult? result =
        _database.dictionarySearchResults.getSync(id);

    if (result != null && result.headingIds.isNotEmpty) {
      _dictionarySearchCache['$searchTerm/$overrideMaximumTerms'] = result;
      return result;
    } else {
      return DictionarySearchResult(searchTerm: searchTerm);
    }
  }

  /// Check if a mapping with a certain name with a different order already
  /// exists.
  bool mappingNameHasDuplicate(AnkiMapping mapping) {
    return _database.ankiMappings
            .where()
            .labelEqualTo(mapping.label)
            .filter()
            .not()
            .orderEqualTo(mapping.order)
            .findFirstSync() !=
        null;
  }

  /// Check if a catalog with a certain name with a different order already
  /// exists.
  bool catalogUrlHasDuplicate(MokuroCatalog catalog) {
    return _database.mokuroCatalogs
            .where()
            .urlEqualTo(catalog.url)
            .filter()
            .not()
            .orderEqualTo(catalog.order)
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

  /// Get the newest available order for a new catalog.
  int get nextCatalogOrder {
    MokuroCatalog? highestOrderCatalog =
        _database.mokuroCatalogs.where().sortByOrderDesc().findFirstSync();
    late int order;
    if (highestOrderCatalog != null) {
      order = highestOrderCatalog.order + 1;
    } else {
      order = 0;
    }

    return order;
  }

  /// Override flag for when [isMediaOpen] is true but the status bar should
  /// be kept open instead of closed.
  bool get shouldHideStatusBarWhenInMedia => _shouldHideStatusBarWhenInMedia;
  bool _shouldHideStatusBarWhenInMedia = true;

  /// Override the flag for automatically disabling the status bar. Necessary
  /// for some very specific edge cases and byproduct of letting global state
  /// run its course. This is a band-aid solution.
  Future<void> temporarilyDisableStatusBarHiding(
      {required Future Function() action}) async {
    _shouldHideStatusBarWhenInMedia = false;
    await action.call();
    _shouldHideStatusBarWhenInMedia = true;
  }

  /// Requests for full external storage permissions. Required to handle video
  /// files and their subtitle files in the same directory.
  Future<void> requestExternalStoragePermissions() async {
    if (isFirstTimeSetup) {
      Fluttertoast.showToast(
        msg: t.storage_permissions,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }

    final cameraGranted = await Permission.camera.isGranted;
    if (!cameraGranted) {
      await Permission.camera.request();
    }

    final storageGranted = await Permission.storage.isGranted;
    if (!storageGranted) {
      await Permission.storage.request();
    }

    if (_androidDeviceInfo.version.sdkInt >= 30) {
      final manageStorageGranted =
          await Permission.manageExternalStorage.isGranted;
      if (!manageStorageGranted) {
        await Permission.manageExternalStorage.request();
      }
    }
  }

  /// Used to communicate back and forth with Dart and native code.
  static const MethodChannel methodChannel =
      MethodChannel('app.lrorpilla.yuuna/anki');

  /// Shows the AnkiDroid API message. Called when an Anki-related API get call
  /// fails.
  Future<void> showAnkidroidApiMessage() async {
    await requestAnkidroidPermissions();

    await showDialog(
      barrierDismissible: true,
      context: _navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text(t.error_ankidroid_api),
        content: Text(
          t.error_ankidroid_api_content,
        ),
        actions: [
          TextButton(
            child: Text(t.dialog_launch_ankidroid),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await LaunchApp.openApp(
                androidPackageName: 'com.ichi2.anki',
                openStore: true,
              );
              navigator.pop();
            },
          ),
          TextButton(
            child: Text(t.dialog_close),
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

  /// Adds the default 'jidoujisho Kinomoto' model to the list of Anki card types.
  Future<void> addDefaultModelIfMissing() async {
    List<String> models = await getModelList();
    if (!models.contains(AnkiMapping.standardModelName)) {
      methodChannel.invokeMethod('addDefaultModel');

      await showDialog(
        barrierDismissible: true,
        context: _navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: Text(t.info_standard_model),
          content: Text(
            t.info_standard_model_content,
          ),
          actions: [
            TextButton(
              child: Text(t.dialog_close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  /// Get the file to be written to for image export.
  File getImageExportFile({bool fallback = false}) {
    String imagePath = path.join(
        (fallback ? alternateExportDirectory : exportDirectory).path,
        'exportImage.jpg');
    return File(imagePath);
  }

  /// Get the placeholder file to compress for image export.
  File getImageCompressedFile({bool fallback = false}) {
    String imagePath = path.join(
        (fallback ? alternateExportDirectory : exportDirectory).path,
        'compressedImage.jpg');
    return File(imagePath);
  }

  /// Get the file to be written to for audio export.
  File getAudioExportFile({bool fallback = false}) {
    String audioPath = path.join(
        (fallback ? alternateExportDirectory : exportDirectory).path,
        'exportAudio.mp3');
    return File(audioPath);
  }

  /// Get the file to be written to for image export.
  File getPreviewImageFile(Directory directory, int index) {
    String imagePath = path.join(directory.path, 'previewImage$index.jpg');
    return File(imagePath);
  }

  /// Get the file to be written to for audio export.
  File getAudioPreviewFile(Directory directory) {
    String audioPath = path.join(directory.path, 'previewAudio.mp3');
    return File(audioPath);
  }

  /// Get the file to be written to for thumbnail export.
  File getThumbnailFile() {
    String imagePath = path.join(exportDirectory.path, 'thumbnail.jpg');
    return File(imagePath);
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
      await showAnkidroidApiMessage();
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
      await showAnkidroidApiMessage();
      rethrow;
    }
  }

  /// Get the target language from persisted preferences.
  DictionaryFormat getDictionaryFormat(Dictionary dictionary) {
    return dictionaryFormats[dictionary.formatKey]!;
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

  /// Given a value and a model name, checks if there are cards that have a
  /// first field with a matching value.
  Future<bool> checkForDuplicates(String key) async {
    try {
      final result = await methodChannel.invokeMethod(
        'checkForDuplicates',
        <String, dynamic>{
          'models': duplicateCheckModels,
          'key': key,
        },
      );
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Add a note with certain [creatorFieldValues] and a [mapping] of fields to
  /// a model to a given [deck].
  Future<void> addNote({
    required CreatorFieldValues creatorFieldValues,
    required AnkiMapping mapping,
    required String deck,
    required Function() onSuccess,
  }) async {
    if (mapping.isExportFieldsEmpty) {
      Fluttertoast.showToast(
        msg: t.export_profile_empty,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    Map<Field, String> exportedImages = {};
    Map<Field, String> exportedAudio = {};

    for (MapEntry<Field, File> entry
        in creatorFieldValues.imagesToExport.entries) {
      Field field = entry.key;
      File exportFile = entry.value;

      String timestamp =
          intl.DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
      String preferredName = 'jidoujisho-$timestamp';

      String? imageFileName;
      if (exportFile.existsSync()) {
        imageFileName = await addFileToMedia(
          exportFile: exportFile,
          preferredName: preferredName,
          mimeType: 'image',
        );

        exportedImages[field] = imageFileName;
      }
    }

    for (MapEntry<Field, File> entry
        in creatorFieldValues.audioToExport.entries) {
      Field field = entry.key;
      File exportFile = entry.value;

      String timestamp =
          intl.DateFormat('yyyyMMddTkkmmss').format(DateTime.now());
      String preferredName = 'jidoujisho-$timestamp';

      String? audioFileName;
      if (exportFile.existsSync()) {
        audioFileName = await addFileToMedia(
          exportFile: exportFile,
          preferredName: preferredName,
          mimeType: 'audio',
        );

        exportedAudio[field] = audioFileName;
      }
    }

    String model = mapping.model;
    List<String> fields = getCardFields(
      creatorFieldValues: creatorFieldValues,
      mapping: mapping,
      exportedImages: exportedImages,
      exportedAudio: exportedAudio,
    );

    List<String> tags =
        creatorFieldValues.textValues[TagsField.instance]?.split(' ') ?? [];

    try {
      await methodChannel.invokeMethod(
        'addNote',
        <String, dynamic>{
          'deck': deck,
          'model': model,
          'fields': fields,
          'tags': tags,
        },
      );

      Fluttertoast.showToast(
        msg: t.card_exported(deck: deck),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      onSuccess.call();
    } on PlatformException {
      debugPrint('Failed to add note');

      Fluttertoast.showToast(
        msg: t.error_add_note,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      rethrow;
    } finally {
      debugPrint('Added note to Anki media');
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
    bool fallback = false,
  }) async {
    late File destinationFile;
    if (mimeType == 'image') {
      destinationFile = getImageExportFile(fallback: fallback);
    } else if (mimeType == 'audio') {
      destinationFile = getAudioExportFile(fallback: fallback);
    } else {
      throw Exception('Invalid mime type, must be image or audio');
    }

    if (destinationFile.existsSync()) {
      destinationFile.deleteSync();
    }

    String destinationPath = destinationFile.path;
    if (mimeType == 'image') {
      File compressedFile = getImageCompressedFile(fallback: fallback);
      if (compressedFile.existsSync()) {
        compressedFile.deleteSync();
      }
      await FlutterImageCompress.compressAndGetFile(
        exportFile.path,
        compressedFile.path,
        quality: 70,
        keepExif: true,
      );

      debugPrint('Original image size: ${exportFile.lengthSync()} bytes');
      debugPrint('Compressed image size: ${compressedFile.lengthSync()} bytes');

      compressedFile.copySync(destinationPath);
    } else {
      exportFile.copySync(destinationPath);
    }

    try {
      String response = await methodChannel.invokeMethod(
        'addFileToMedia',
        <String, String>{
          'filename': destinationPath,
          'preferredName': preferredName,
          'mimeType': mimeType,
        },
      );
      debugPrint('Added $mimeType for [$preferredName] to Anki media');
      if (destinationFile.existsSync()) {
        destinationFile.deleteSync();
      }

      return response;
    } on PlatformException {
      if (fallback) {
        Fluttertoast.showToast(
          msg: t.error_export_media_ankidroid,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        rethrow;
      } else {
        return addFileToMedia(
          exportFile: exportFile,
          preferredName: preferredName,
          mimeType: mimeType,
          fallback: true,
        );
      }
    }
  }

  /// Returns the list that will be passed to the Anki card creation API to
  /// fill a card's fields. The contents of the list will correspond to the
  /// order of the [mapping] provided, with each field in the list replaced
  /// with the corresponding [creatorFieldValues] or in the case of the image
  /// and audio fields, the file names.
  static List<String> getCardFields({
    required CreatorFieldValues creatorFieldValues,
    required AnkiMapping mapping,
    required Map<Field, String> exportedImages,
    required Map<Field, String> exportedAudio,
  }) {
    List<String> fields = mapping.getExportFields().map<String>((field) {
      if (field == null) {
        return '';
      } else {
        if (field is ImageExportField) {
          if (exportedImages[field] == null) {
            return '';
          } else {
            String text = exportedImages[field]!;
            if (mapping.exportMediaTags ?? false) {
              return '<img src="$text">';
            } else {
              return text;
            }
          }
        } else if (field is AudioExportField) {
          if (exportedAudio[field] == null) {
            return '';
          } else {
            String text = exportedAudio[field]!;
            if (mapping.exportMediaTags ?? false) {
              return '[sound:$text]';
            } else {
              return text;
            }
          }
        } else {
          String text = creatorFieldValues.textValues[field] ?? '';
          if (mapping.useBrTags ?? false) {
            text = text.replaceAll('\n', '<br>');
          }

          return text;
        }
      }
    }).toList();

    return fields;
  }

  /// Returns whether or not a given [AnkiMapping] has the same amount of
  /// fields as the model it uses.
  Future<bool> profileFieldMatchesCardTypeCount(AnkiMapping mapping) async {
    List<String> fields = await getFieldList(mapping.model);
    return mapping.exportFieldKeys.length == fields.length;
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

  /// Refresh all screens and have them respond to new variables.
  Future<void> refresh() async {
    notifyListeners();
  }

  /// Resets a profile's fields such that it will have the model's number of
  /// fields, all empty.
  Future<void> resetProfileFields(AnkiMapping mapping) async {
    List<String> fields = await getFieldList(mapping.model);
    List<String?> exportFieldKeys =
        List.generate(fields.length, (index) => null);

    AnkiMapping resetMapping =
        mapping.copyWith(exportFieldKeys: exportFieldKeys);
    _database.writeTxnSync(() {
      if (mapping.id != null &&
          _database.ankiMappings.getSync(resetMapping.id!) != null) {
        _database.ankiMappings.deleteSync(resetMapping.id!);
      }
      _database.ankiMappings.putSync(resetMapping);
    });
  }

  /// Check for errors relating to the current selected export profile.
  Future<void> validateSelectedMapping({
    required BuildContext context,
    required AnkiMapping mapping,
  }) async {
    final navigator = Navigator.of(context);

    /// Ensure that the following case never happens to the default profile.
    await addDefaultModelIfMissing();

    bool newMappingModelExists = await profileModelExists(mapping);

    if (!newMappingModelExists) {
      if (context.mounted) {
        await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) => AlertDialog(
            title: Text(t.error_model_missing),
            content: Text(
              t.error_model_missing_content,
            ),
            actions: [
              TextButton(
                onPressed: navigator.pop,
                child: Text(t.dialog_close),
              ),
            ],
          ),
        );
      }

      await selectStandardProfile();
      deleteMapping(mapping);
      return;
    }

    bool newMappingModelLengthMatches =
        await profileFieldMatchesCardTypeCount(mapping);

    if (!newMappingModelLengthMatches) {
      if (context.mounted) {
        await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) => AlertDialog(
            title: Text(t.error_model_changed),
            content: Text(
              t.error_model_changed_content,
            ),
            actions: [
              TextButton(
                onPressed: navigator.pop,
                child: Text(t.dialog_close),
              ),
            ],
          ),
        );
      }

      await resetProfileFields(mapping);
    }
  }

  /// A helper function for opening the creator from any page in the
  /// application for card export purposes. Normally, the fields are provided
  /// by values in the app state. For example, the sentence field provides its
  /// value upon opening the creator from current media, which if null is
  /// empty.
  Future<void> openCreator({
    required WidgetRef ref,
    required bool killOnPop,
    CreatorFieldValues? creatorFieldValues,
    List<Subtitle>? subtitles,
  }) async {
    _currentMediaPauseController.add(null);

    List<String> decks = await getDecks();

    CreatorModel creatorModel = ref.watch(creatorProvider);
    creatorModel.clearAll(
      overrideLocks: true,
      savedTags: savedTags,
    );
    if (creatorFieldValues != null) {
      creatorModel.copyContext(creatorFieldValues);
    }

    _isCreatorOpen = true;
    _creatorActiveController.add(true);

    await Navigator.push(
      _navigatorKey.currentContext!,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation1, animation2) => CreatorPage(
          decks: decks,
          editEnhancements: false,
          editFields: false,
          killOnPop: killOnPop,
          subtitles: subtitles,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        settings: RouteSettings(name: (CreatorPage).toString()),
      ),
    );

    _isCreatorOpen = false;
    _creatorActiveController.add(false);
  }

  /// Whether or not the media item should be killed upon exit.
  bool _shouldKillMediaOnPop = false;

  /// A helper function for launching a media source.
  Future<void> openMedia({
    required WidgetRef ref,
    required MediaSource mediaSource,
    bool killOnPop = false,
    bool pushReplacement = false,
    MediaItem? item,
  }) async {
    if (killOnPop) {
      _shouldKillMediaOnPop = true;
    }

    mediaSource.clearCurrentSentence();
    mediaSource.clearExtraData();
    await initialiseAudioHandler();

    _currentMediaSource = mediaSource;
    if (item != null) {
      _currentMediaItem = item;
    }

    _currentSubtitleOptions = ValueNotifier(subtitleOptions);
    _overrideDictionaryColor = null;
    _overrideDictionaryTheme = null;

    await Wakelock.enable();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (item != null && mediaSource.implementsHistory) {
      addMediaItem(item);
    }

    if (pushReplacement) {
      await Navigator.pushReplacement(
        _navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => mediaSource.buildLaunchPage(item: item),
        ),
      );
    } else {
      await Navigator.push(
        _navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => mediaSource.buildLaunchPage(item: item),
        ),
      );
    }
  }

  /// Ends a media session and ensures that values are reset.
  Future<void> closeMedia({
    required WidgetRef ref,
    required MediaSource mediaSource,
    MediaItem? item,
  }) async {
    _audioHandler?.mediaItem.add(null);

    mediaSource.setShouldGenerateImage(value: true);
    mediaSource.setShouldGenerateAudio(value: true);
    mediaSource.clearCurrentSentence();
    mediaSource.clearExtraData();
    _currentMediaSource = null;
    _currentMediaItem = null;
    _overrideDictionaryColor = null;
    _overrideDictionaryTheme = null;
    blockCreatorInitialMedia = false;
    isProcessingEmbeddedSubtitles = false;
    await Wakelock.disable();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await mediaSource.onSourceExit(
      appModel: this,
      ref: ref,
    );

    await _audioHandler?.stop();

    mediaSource.mediaType.refreshTab();
    DictionaryMediaType.instance.refreshTab();

    if (_shouldKillMediaOnPop) {
      shutdown();
    }
  }

  /// A helper function for opening the creator from any page in the
  /// application for editing enhancements.
  Future<void> openCreatorEnhancementsEditor() async {
    List<String> decks = await getDecks();

    await Navigator.push(
      _navigatorKey.currentContext!,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => CreatorPage(
          decks: decks,
          editEnhancements: true,
          editFields: false,
          killOnPop: false,
          subtitles: null,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // A helper function for opening the creator from any page in the
  /// application for editing fields.
  Future<void> openCreatorFieldsEditor() async {
    List<String> decks = await getDecks();

    await Navigator.push(
      _navigatorKey.currentContext!,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => CreatorPage(
          decks: decks,
          editEnhancements: false,
          editFields: true,
          killOnPop: false,
          subtitles: null,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  /// A helper function for opening the creator from any page in the
  /// application for editing purposes.
  Future<void> openStash({
    required Function(String) onSelect,
    required Function(String) onSearch,
  }) async {
    await showDialog(
      context: _navigatorKey.currentContext!,
      builder: (context) => OpenStashDialogPage(
        onSelect: onSelect,
        onSearch: onSearch,
      ),
    );
  }

  /// A helper function for doing a recursive dictionary search.
  Future<void> openRecursiveDictionarySearch({
    required String searchTerm,
    required bool killOnPop,
    Function(String)? onUpdateQuery,
  }) async {
    _currentMediaPauseController.add(null);

    if (searchTerm.trim().isEmpty) {
      return;
    }

    await Navigator.push(
      _navigatorKey.currentContext!,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            RecursiveDictionaryPage(
          searchTerm: searchTerm,
          killOnPop: killOnPop,
          onUpdateQuery: onUpdateQuery,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    refreshDictionaryHistory();
  }

  /// A helper function for showing a result already in dictionary history.
  Future<void> openResultFromHistory({
    required DictionarySearchResult result,
  }) async {
    await Navigator.push(
      _navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => RecursiveDictionaryHistoryPage(
          result: result,
        ),
      ),
    );
  }

  /// A helper function for opening a text segmentation dialog.
  Future<void> openTextSegmentationDialog({
    required String sourceText,
    List<String>? segmentedText,
    Function(JidoujishoTextSelection)? onSelect,
    Function(JidoujishoTextSelection)? onSearch,
  }) async {
    if (sourceText.trim().isEmpty) {
      return;
    }

    segmentedText ??= targetLanguage.textToWords(sourceText);

    await showDialog(
      context: _navigatorKey.currentContext!,
      builder: (context) => TextSegmentationDialogPage(
        sourceText: sourceText,
        segmentedText: segmentedText!,
        onSelect: onSelect,
        onSearch: onSearch,
      ),
    );
  }

  /// A helper function for opening an example sentence dialog.
  Future<void> openExampleSentenceDialog({
    required List<String> exampleSentences,
    required Function(List<String>) onSelect,
    Function(List<String>)? onAppend,
  }) async {
    await showDialog(
      context: _navigatorKey.currentContext!,
      builder: (context) => ExampleSentencesDialogPage(
        exampleSentences: exampleSentences,
        onSelect: onSelect,
        onAppend: onAppend,
      ),
    );
  }

  /// A helper function for opening an example sentence dialog for sentences
  /// returned from Massif.
  Future<void> openMassifSentenceDialog({
    required List<MassifResult> exampleSentences,
    required Function(List<MassifResult>) onSelect,
    required Function(List<MassifResult>) onAppend,
  }) async {
    await showDialog(
      context: _navigatorKey.currentContext!,
      builder: (context) => MassifSentencesDialogPage(
        exampleSentences: exampleSentences,
        onSelect: onSelect,
        onAppend: onAppend,
      ),
    );
  }

  /// A helper function for opening an example sentence dialog for sentences
  /// returned from ImmersionKitEnhancement.
  Future<void> openImmersionKitSentenceDialog({
    required List<ImmersionKitResult> exampleSentences,
    required Function(List<ImmersionKitResult>) onSelect,
    required Function(List<ImmersionKitResult>) onAppend,
  }) async {
    await showDialog(
      context: _navigatorKey.currentContext!,
      builder: (context) => ImmersionKitSentencesDialogPage(
        exampleSentences: exampleSentences,
        onSelect: onSelect,
        onAppend: onAppend,
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
    mapping.enhancements![field.uniqueKey] ??= {};
    mapping.enhancements![field.uniqueKey]![slotNumber] = enhancement.uniqueKey;

    _database.writeTxnSync(() {
      _database.ankiMappings.putSync(mapping);
    });
  }

  /// Updates a given [mapping] to remove a [Field].
  void removeField({
    required AnkiMapping mapping,
    required Field field,
    required bool isCollapsed,
  }) async {
    if (isCollapsed) {
      mapping.creatorCollapsedFieldKeys = [
        ...(mapping.creatorCollapsedFieldKeys)
            .whereNot((key) => key == field.uniqueKey)
      ];
    } else {
      mapping.creatorFieldKeys = [
        ...(mapping.creatorFieldKeys).whereNot((key) => key == field.uniqueKey)
      ];
    }

    _database.writeTxnSync(() {
      _database.ankiMappings.putSync(mapping);
    });
  }

  /// Updates a given [mapping] to include a [Field].
  void setField({
    required AnkiMapping mapping,
    required Field field,
    required bool isCollapsed,
  }) async {
    if (isCollapsed) {
      mapping.creatorCollapsedFieldKeys = [
        ...mapping.creatorCollapsedFieldKeys,
        field.uniqueKey,
      ];
    } else {
      mapping.creatorFieldKeys = [
        ...mapping.creatorFieldKeys,
        field.uniqueKey,
      ];
    }

    _database.writeTxnSync(() {
      _database.ankiMappings.putSync(mapping);
    });
  }

  /// Removes a given [mapping]'s persisted enhancement for a given [field]
  /// and [slotNumber].
  void removeFieldEnhancement({
    required AnkiMapping mapping,
    required Field field,
    required int slotNumber,
  }) async {
    mapping.enhancements![field.uniqueKey]!.remove(slotNumber);

    _database.writeTxnSync(() {
      _database.ankiMappings.putSync(mapping);
    });
  }

  /// Updates a given [mapping]'s persisted action for a given [slotNumber].
  void setQuickAction(
      {required AnkiMapping mapping,
      required int slotNumber,
      required QuickAction quickAction}) async {
    mapping.actions![slotNumber] = quickAction.uniqueKey;

    _database.writeTxnSync(() {
      _database.ankiMappings.putSync(mapping);
    });

    notifyListeners();
  }

  /// Removes a given [mapping]'s persisted action for a given [slotNumber].
  void removeQuickAction({
    required AnkiMapping mapping,
    required int slotNumber,
  }) async {
    mapping.actions!.remove(slotNumber);

    _database.writeTxnSync(() {
      _database.ankiMappings.putSync(mapping);
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
    mapping.enhancements![field.uniqueKey]![AnkiMapping.autoModeSlotNumber] =
        enhancement.uniqueKey;

    _database.writeTxnSync(() {
      _database.ankiMappings.putSync(mapping);
    });
  }

  /// Removes a given [mapping]'s persisted auto enhancement for a given
  /// [field].
  void removeAutoFieldEnhancement({
    required AnkiMapping mapping,
    required Field field,
  }) async {
    /// -1 is reserved for the auto enhancement.
    mapping.enhancements![field.uniqueKey]!
        .remove(AnkiMapping.autoModeSlotNumber);

    _database.writeTxnSync(() {
      _database.ankiMappings.putSync(mapping);
    });
  }

  /// Add the [searchTerm] to a search history with the given [historyKey]. If
  /// there are already a maximum number of items in history, this will be
  /// capped. Oldest items will be discarded in that scenario.
  void addToSearchHistory({
    required String historyKey,
    required String searchTerm,
  }) async {
    if (searchTerm.trim().isEmpty) {
      return;
    }

    _database.writeTxnSync(() {
      SearchHistoryItem searchHistoryItem = SearchHistoryItem(
        searchTerm: searchTerm,
        historyKey: historyKey,
      );

      _database.searchHistoryItems
          .deleteByUniqueKeySync(searchHistoryItem.uniqueKey);

      _database.searchHistoryItems.putSync(searchHistoryItem);

      int countInSameHistory = _database.searchHistoryItems
          .filter()
          .historyKeyEqualTo(historyKey)
          .countSync();

      if (maximumSearchHistoryItems < countInSameHistory) {
        int surplus = countInSameHistory - maximumSearchHistoryItems;
        _database.searchHistoryItems
            .filter()
            .historyKeyEqualTo(historyKey)
            .limit(surplus)
            .build()
            .deleteAllSync();
      }
    });
  }

  /// Remove the [searchTerm] from a search history with the given [historyKey].
  Future<void> removeFromSearchHistory({
    required String historyKey,
    required String searchTerm,
  }) async {
    _database.writeTxnSync(() {
      SearchHistoryItem searchHistoryItem = SearchHistoryItem(
        searchTerm: searchTerm,
        historyKey: historyKey,
      );

      _database.searchHistoryItems
          .deleteByUniqueKeySync(searchHistoryItem.uniqueKey);
    });
  }

  /// Clear the search history with the given [historyKey].
  void clearSearchHistory({
    required String historyKey,
  }) {
    _database.writeTxnSync(() {
      _database.searchHistoryItems
          .where()
          .historyKeyEqualTo(historyKey)
          .build()
          .deleteAllSync();
    });
  }

  /// Get the search history for a given collection named [historyKey].
  List<String> getSearchHistory({required String historyKey}) {
    List<SearchHistoryItem> items = _database.searchHistoryItems
        .filter()
        .historyKeyEqualTo(historyKey)
        .build()
        .findAllSync();

    List<String> history = items.map((item) => item.searchTerm).toList();

    return history;
  }

  /// Get whether or not a certain [searchTerm] is in a certain history.
  bool isTermInSearchHistory({
    required String historyKey,
    required String searchTerm,
  }) {
    SearchHistoryItem searchHistoryItem = SearchHistoryItem(
      searchTerm: searchTerm,
      historyKey: historyKey,
    );

    SearchHistoryItem? duplicateItem = _database.searchHistoryItems
        .getByUniqueKeySync(searchHistoryItem.uniqueKey);

    return duplicateItem != null;
  }

  /// Adds the [terms] to the Stash and shows a message indicating the addition.
  void addToStash({
    required List<String> terms,
  }) async {
    if (terms.isEmpty) {
      return;
    }

    bool hasNonEmpty = false;
    for (String term in terms) {
      if (term.trim().isNotEmpty) {
        hasNonEmpty = true;
      }
    }
    if (!hasNonEmpty) {
      return;
    }

    for (String term in terms) {
      addToSearchHistory(
        historyKey: stashKey,
        searchTerm: term,
      );
    }

    if (terms.length == 1) {
      Fluttertoast.showToast(
        msg: t.stash_added_single(term: terms.first),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      Fluttertoast.showToast(
        msg: t.stash_added_multiple,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  /// Remove a certain [term] from the Stash.
  Future<void> removeFromStash({
    required String term,
  }) async {
    removeFromSearchHistory(
      historyKey: stashKey,
      searchTerm: term,
    );

    Fluttertoast.showToast(
      msg: t.stash_clear_single(term: term),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  /// Clear the contents of the Stash.
  void clearStash() {
    clearSearchHistory(historyKey: stashKey);
  }

  /// Get the contents of the Stash.
  List<String> getStash() {
    return getSearchHistory(historyKey: stashKey);
  }

  /// Get the contents of the Stash.
  bool isTermInStash(String searchTerm) {
    return isTermInSearchHistory(historyKey: stashKey, searchTerm: searchTerm);
  }

  /// Shown when a query fails to be made to an online service. For example,
  /// when there is no internet connection.
  void showFailedToCommunicateMessage() {
    Fluttertoast.showToast(
      msg: t.failed_online_service,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  /// Update the scroll index of a given [DictionarySearchResult] in the database.
  Future<void> updateDictionaryResultScrollIndex({
    required DictionarySearchResult result,
    required int newIndex,
  }) async {
    ReceivePort receivePort = ReceivePort();
    UpdateDictionaryHistoryParams params = UpdateDictionaryHistoryParams(
      resultId: result.id!,
      directoryPath: _databaseDirectory.path,
      newPosition: newIndex,
      maximumDictionaryHistoryItems: maximumDictionaryHistoryItems,
      sendPort: receivePort.sendPort,
    );
    await compute(updateDictionaryHistoryHelper, params);
  }

  /// Clear the entire dictionary history. This must be performed when a
  /// dictionary is deleted, otherwise history data cannot be viewed without
  /// the necessary dictionary metadata.
  Future<void> clearDictionaryHistory() async {
    await _dictionaryHistory.clear();

    dictionaryEntriesNotifier.notifyListeners();
  }

  /// Add a [MediaItem] to history. This should be called at startup
  /// when the media item is launched.
  void addMediaItem(MediaItem item) {
    _database.writeTxnSync(() {
      _database.mediaItems.deleteByUniqueKeySync(item.uniqueKey);
      item.id = null;

      _database.mediaItems.putSync(item);

      int countInSameHistory = _database.mediaItems
          .filter()
          .mediaTypeIdentifierEqualTo(item.mediaTypeIdentifier)
          .countSync();

      if (maximumMediaHistoryItems < countInSameHistory) {
        int surplus = countInSameHistory - maximumSearchHistoryItems;
        _database.mediaItems
            .filter()
            .mediaTypeIdentifierEqualTo(item.mediaTypeIdentifier)
            .limit(surplus)
            .build()
            .deleteAllSync();
      }
    });
  }

  /// Update a media item, without performing any deletion or mutation
  /// operations. This is useful when updating constantly, for example,
  /// with the player where the position needs to be constantly updated.
  void updateMediaItem(MediaItem item) {
    _database.writeTxnSync(() {
      _database.mediaItems.putSync(item);
    });
  }

  /// Deletes a [MediaItem] from the reading list.
  void removeFromReadingList(String mediaIdentifier) {
    _database.writeTxnSync(() {
      _database.mediaItems
          .where()
          .mediaSourceIdentifierEqualTo(ReaderBrowserSource.instance.uniqueKey)
          .filter()
          .mediaIdentifierEqualTo(mediaIdentifier)
          .deleteAllSync();
    });
  }

  /// Deletes a [MediaItem] from history and also rids of override values.
  Future<void> deleteMediaItem(MediaItem item) async {
    MediaSource mediaSource = item.getMediaSource(appModel: this);
    await mediaSource.clearOverrideValues(appModel: this, item: item);
    await mediaSource.onMediaItemClear(item);

    _database.writeTxnSync(() {
      _database.mediaItems.deleteSync(item.id!);
    });
  }

  /// Copies a [term] to clipboard and shows an appropriate toast.
  void copyToClipboard(String term) {
    FlutterClipboard.copy(term);

    /// Redundant to do this with the share notification on Android
    if (_androidDeviceInfo.version.sdkInt < 33) {
      Fluttertoast.showToast(
        msg: t.copied_to_clipboard,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  /// For a given [MediaType], return the selected media source. If there is
  /// no persisted media source, use the first source in the list.
  MediaSource getCurrentSourceForMediaType({
    required MediaType mediaType,
  }) {
    MediaSource fallbackSource = mediaSources[mediaType]!.values.first;
    String uniqueKey = _preferences.get('current_source/${mediaType.uniqueKey}',
        defaultValue: fallbackSource.uniqueKey);

    return mediaSources[mediaType]![uniqueKey] ?? fallbackSource;
  }

  /// For a given [MediaType], set the selected media source.
  void setCurrentSourceForMediaType({
    required MediaType mediaType,
    required MediaSource mediaSource,
  }) {
    _preferences.put(
        'current_source/${mediaType.uniqueKey}', mediaSource.uniqueKey);
  }

  /// Get the history of [MediaItem] for a particular [MediaType].
  List<MediaItem> getMediaTypeHistory({required MediaType mediaType}) {
    return _database.mediaItems
        .filter()
        .mediaTypeIdentifierEqualTo(mediaType.uniqueKey)
        .findAllSync();
  }

  /// Get the history of [MediaItem] for a particular [MediaSource].
  List<MediaItem> getMediaSourceHistory({required MediaSource mediaSource}) {
    return _database.mediaItems
        .filter()
        .mediaSourceIdentifierEqualTo(mediaSource.uniqueKey)
        .findAllSync();
  }

  /// Returns the last navigated directory the user used for picking a file for a
  /// certain media type.
  Directory? getLastPickedDirectory(MediaType type) {
    String path = _preferences.get('${type.uniqueKey}/last_picked_file',
        defaultValue: '');
    if (path.isEmpty) {
      return null;
    }

    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      return null;
    }
    return directory;
  }

  /// Returns the last navigated directory the user used for picking a file for a
  /// certain media type.
  void setLastPickedDirectory({
    required MediaType type,
    required Directory directory,
  }) {
    _preferences.put('${type.uniqueKey}/last_picked_file', directory.path);
  }

  /// Returns valid file picker directories. If there is a last picked directory for
  /// a media type, this will be included as first on the list. Otherwise, external
  /// root directories will be included.
  Future<List<Directory>> getFilePickerDirectoriesForMediaType(
      MediaType type) async {
    List<Directory> directories = [];
    Directory? lastPickedDirectory = getLastPickedDirectory(type);
    if (lastPickedDirectory != null) {
      directories.add(lastPickedDirectory);
    }

    List<String> paths = await ExternalPath.getExternalStorageDirectories();
    for (String path in paths) {
      Directory directory = Directory(path);
      if (!directories.contains(directory)) {
        directories.add(directory);
      }
    }

    return directories;
  }

  /// Get the blur options used in the player.
  BlurOptions get blurOptions {
    double width = _preferences.get('blur_width', defaultValue: 200.0);
    double height = _preferences.get('blur_height', defaultValue: 200.0);
    double left = _preferences.get('blur_left', defaultValue: -1.0);
    double top = _preferences.get('blur_top', defaultValue: -1.0);

    int red = _preferences.get('blur_red',
        defaultValue: Colors.black.withOpacity(0).red);
    int green = _preferences.get('blur_green',
        defaultValue: Colors.black.withOpacity(0).green);
    int blue = _preferences.get('blur_blue',
        defaultValue: Colors.black.withOpacity(0).blue);
    double opacity = _preferences.get('blur_opacity',
        defaultValue: Colors.black.withOpacity(0).opacity);

    Color color = Color.fromRGBO(red, green, blue, opacity);

    double blurRadius = _preferences.get('blur_radius', defaultValue: 5.0);
    bool visible = _preferences.get('blur_visible', defaultValue: false);

    return BlurOptions(
      width: width,
      height: height,
      left: left,
      top: top,
      color: color,
      blurRadius: blurRadius,
      visible: visible,
    );
  }

  /// Set the blur options used in the player.
  void setBlurOptions(BlurOptions options) {
    _preferences.put('blur_width', options.width);
    _preferences.put('blur_height', options.height);
    _preferences.put('blur_left', options.left);
    _preferences.put('blur_top', options.top);

    _preferences.put('blur_red', options.color.red);
    _preferences.put('blur_green', options.color.green);
    _preferences.put('blur_blue', options.color.blue);
    _preferences.put('blur_opacity', options.color.opacity);

    _preferences.put('blur_radius', options.blurRadius);
    _preferences.put('blur_visible', options.visible);
  }

  /// Get the subtitle options used in the player.
  SubtitleOptions get subtitleOptions {
    int audioAllowance = _preferences.get('audio_allowance', defaultValue: 0);
    int subtitleDelay = _preferences.get('subtitle_delay', defaultValue: 0);
    double fontSize = _preferences.get('font_size', defaultValue: 20.0);
    String fontName = _preferences
        .get('font_name/${targetLanguage.languageCode}', defaultValue: '');
    String regexFilter = _preferences.get('regex_filter', defaultValue: '');
    double subtitleBackgroundOpacity =
        _preferences.get('subtitle_background_opacity', defaultValue: 0.0);
    double subtitleOutlineWidth =
        _preferences.get('subtitle_outline_width', defaultValue: 3.0);
    double subtitleBackgroundBlurRadius =
        _preferences.get('subtitle_background_blur_radius', defaultValue: 0.0);
    bool alwaysAboveBottomBar =
        _preferences.get('subtitle_above_bar', defaultValue: false);

    return SubtitleOptions(
      audioAllowance: audioAllowance,
      subtitleDelay: subtitleDelay,
      subtitleBackgroundOpacity: subtitleBackgroundOpacity,
      subtitleBackgroundBlurRadius: subtitleBackgroundBlurRadius,
      fontSize: fontSize,
      fontName: fontName,
      regexFilter: regexFilter,
      subtitleOutlineWidth: subtitleOutlineWidth,
      alwaysAboveBottomBar: alwaysAboveBottomBar,
    );
  }

  /// Set the subtitle options used in the player.
  void setSubtitleOptions(SubtitleOptions options) {
    _preferences.put('audio_allowance', options.audioAllowance);
    _preferences.put('subtitle_delay', options.subtitleDelay);
    _preferences.put('font_size', options.fontSize);
    _preferences.put(
        'font_name/${targetLanguage.languageCode}', options.fontName);
    _preferences.put('regex_filter', options.regexFilter);
    _preferences.put(
        'subtitle_background_opacity', options.subtitleBackgroundOpacity);
    _preferences.put('subtitle_outline_width', options.subtitleOutlineWidth);
    _preferences.put('subtitle_background_blur_radius',
        options.subtitleBackgroundBlurRadius);
    _preferences.put('subtitle_above_bar', options.alwaysAboveBottomBar);
  }

  /// Gets the last used audio index of a given media item.
  int getMediaItemPreferredAudioIndex(MediaItem item) {
    return _preferences.get('audio_index/${item.uniqueKey}', defaultValue: 0);
  }

  /// Sets the last used audio index of a given media item.
  void setMediaItemPreferredAudioIndex(MediaItem item, int index) {
    _preferences.put('audio_index/${item.uniqueKey}', index);
  }

  /// Get the playback mode for the player.
  PlaybackMode get playbackMode {
    int index = _preferences.get(
      'player_playback_mode',
      defaultValue: PlaybackMode.normalPlayback.index,
    );
    return PlaybackMode.values.elementAt(index);
  }

  /// Set the playback mode for the player.
  void setPlaybackMode(PlaybackMode playbackMode) {
    _preferences.put('player_playback_mode', playbackMode.index);
  }

  /// Get definition focus mode for player.
  bool get isPlayerListeningComprehensionMode {
    return _preferences.get('player_listening_comprehension_mode',
        defaultValue: false);
  }

  /// Toggle definition focus mode for player.
  void togglePlayerListeningComprehensionMode() async {
    await _preferences.put('player_listening_comprehension_mode',
        !isPlayerListeningComprehensionMode);
  }

  /// Get orientation for player.
  bool get isPlayerOrientationPortrait {
    return _preferences.get('player_orientation_portrait', defaultValue: false);
  }

  /// Toggle orientation for player.
  void togglePlayerOrientationPortrait() async {
    await _preferences.put(
        'player_orientation_portrait', !isPlayerOrientationPortrait);
  }

  /// Get whether or not to stretch to fill screen.
  bool get isStretchToFill {
    return _preferences.get('stretch_to_fill_screen', defaultValue: false);
  }

  /// Toggle stretch to fill screen.
  void toggleStretchToFill() async {
    await _preferences.put('stretch_to_fill_screen', !isStretchToFill);
  }

  /// Whether or not the player should use hardware acceleration.
  bool get playerHardwareAcceleration {
    return _preferences.get('player_hardware_acceleration', defaultValue: true);
  }

  /// Set whether or not the player should use hardware acceleration.
  void setPlayerHardwareAcceleration({required bool value}) async {
    await _preferences.put('player_hardware_acceleration', value);
  }

  /// Whether or not the player should allow background play.
  bool get playerBackgroundPlay {
    return _preferences.get('player_background_play', defaultValue: true);
  }

  /// Set whether or not the player should allow background play.
  void setPlayerBackgroundPlay({required bool value}) async {
    await _preferences.put('player_background_play', value);
  }

  /// Whether or not the player should show subtitles in notifications.
  bool get showSubtitlesInNotification {
    return _preferences.get('player_subtitle_notification', defaultValue: true);
  }

  /// Set whether or not the player should show subtitles in notifications.
  void setShowSubtitlesInNotification({required bool value}) async {
    await _preferences.put('player_subtitle_notification', value);
  }

  /// Whether or not the player should use hardware acceleration.
  bool get playerUseOpenSLES {
    return _preferences.get('player_use_opensles', defaultValue: true);
  }

  /// Set whether or not the player should use hardware acceleration.
  void setPlayerUseOpenSLES({required bool value}) async {
    await _preferences.put('player_use_opensles', value);
  }

  /// Allows the player screen to listen to play/pause changes.
  Stream<void> get playStream => _playStreamController.stream;
  final StreamController<void> _playStreamController =
      StreamController.broadcast();

  /// Allows the player screen to listen to seek changes.
  Stream<Duration> get seekStream => _seekStreamController.stream;
  final StreamController<Duration> _seekStreamController =
      StreamController.broadcast();

  /// Allows the player screen to listen to seek backward changes.
  Stream<void> get rewindStream => _rewindStreamController.stream;
  final StreamController<void> _rewindStreamController =
      StreamController.broadcast();

  /// Allows the player screen to listen to seek forward changes.
  Stream<void> get fastForwardStream => _fastForwardStreamController.stream;
  final StreamController<void> _fastForwardStreamController =
      StreamController.broadcast();

  /// For managing audio session events.
  JidoujishoAudioHandler? get audioHandler => _audioHandler;
  JidoujishoAudioHandler? _audioHandler;

  /// Initialises the audio service.
  Future<void> initialiseAudioHandler() async {
    if (_audioHandler != null) {
      return;
    }

    _audioHandler = await ag.AudioService.init<JidoujishoAudioHandler>(
      builder: () => JidoujishoAudioHandler(
        onPlayPause: () {
          _playStreamController.add(null);
        },
        onSeek: (position) {
          _seekStreamController.add(position);
        },
        onRewind: () {
          _rewindStreamController.add(null);
        },
        onFastForward: () {
          _fastForwardStreamController.add(null);
        },
      ),
      config: const ag.AudioServiceConfig(
        androidNotificationChannelId: 'app.lrorpilla.yuuna.channel.audio',
        androidNotificationChannelName: 'jidoujisho',
        androidNotificationIcon: 'drawable/splash',
        notificationColor: Colors.black,
        fastForwardInterval: Duration(seconds: 5),
        rewindInterval: Duration(seconds: 5),
      ),
    );
  }

  /// Whether or not the app should use slow import. This is to prevent
  /// crashing on older devices and make performance faster for newer devices.
  bool get useSlowImport {
    return _preferences.get('use_slow_import', defaultValue: false);
  }

  /// Toggle slow import option.
  void toggleSlowImport() async {
    await _preferences.put('use_slow_import', !useSlowImport);
  }

  /// Whether or not searching in the app is performed without hitting the
  /// submit button.
  bool get autoSearchEnabled {
    return _preferences.get('auto_search', defaultValue: true);
  }

  /// Toggle auto search option.
  void toggleAutoSearchEnabled() async {
    await _preferences.put('auto_search', !autoSearchEnabled);
  }

  /// Search debounce delay in milliseconds by default.
  final int defaultSearchDebounceDelay = 100;

  /// The search debounce delay in milliseconds for searching in the app..
  int get searchDebounceDelay {
    return _preferences.get('auto_search_debounce_delay',
        defaultValue: defaultSearchDebounceDelay);
  }

  /// Sets the debounce delay in milliseconds for searching in the app..
  void setSearchDebounceDelay(int debounceDelay) async {
    await _preferences.put('auto_search_debounce_delay', debounceDelay);
  }

  /// Default dictionary font size for meanings.
  final double defaultDictionaryFontSize = 16;

  /// The search debounce delay in milliseconds for searching in the app..
  double get dictionaryFontSize {
    return _preferences.get('dictionary_entry_font_size',
        defaultValue: defaultDictionaryFontSize);
  }

  /// Sets the debounce delay in milliseconds for searching in the app..
  void setDictionaryFontSize(double fontSize) async {
    await _preferences.put('dictionary_entry_font_size', fontSize);
  }

  /// The search debounce delay in milliseconds for searching in the app..
  bool get closeCreatorOnExport {
    return _preferences.get('close_on_export', defaultValue: false);
  }

  /// Sets the debounce delay in milliseconds for searching in the app..
  void toggleCloseCreatorOnExport() async {
    await _preferences.put('close_on_export', !closeCreatorOnExport);
  }

  /// Default value of [doubleTapSeekDuration].
  final int defaultDoubleTapSeekDuration = 5000;

  /// The default duration that the video player will seek forward or backward
  /// when double tapped by the user.
  int get doubleTapSeekDuration {
    return _preferences.get('double_tap_seek_duration',
        defaultValue: defaultDoubleTapSeekDuration);
  }

  /// Sets the default duration that the video player will seek forward or
  /// backward when double tapped by the user.
  void setDoubleTapSeekDuration(int value) async {
    await _preferences.put('double_tap_seek_duration', value);
  }

  /// Whether or not it is the app's first time setup to show the languages
  /// dialog.
  bool get isFirstTimeSetup {
    return _preferences.get('first_time_setup', defaultValue: true);
  }

  /// Sets the first time setup flag so the first time message does not show
  /// again.
  void setFirstTimeSetupFlag() async {
    await _preferences.put('first_time_setup', false);
  }

  /// The maximum dictionary terms in a result.
  int get maximumTerms {
    return _preferences.get('maximum_terms',
        defaultValue: defaultMaximumDictionaryTermsInResult);
  }

  /// Sets the maximum dictionary terms in a result.
  void setMaximumTerms(int value) async {
    await _preferences.put('maximum_terms', value);
  }

  /// Adds a [DictionarySearchResult] to dictionary history.
  void addToDictionaryHistory({required DictionarySearchResult result}) async {
    MediaType mediaType = mediaTypes.values.toList()[currentHomeTabIndex];
    if (mediaType != DictionaryMediaType.instance) {
      shouldRefreshTabs = true;
      ScrollController scrollController =
          DictionaryMediaType.instance.scrollController;
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    }

    if (result.headings.isEmpty || result.searchTerm.isEmpty) {
      return;
    }

    _dictionaryHistory.deleteAll(_dictionaryHistory
        .toMap()
        .entries
        .where((e) => e.value == result.id)
        .map((e) => e.key)
        .toList());

    await _dictionaryHistory.add(result.id!);

    int countInSameHistory = _dictionaryHistory.length;

    if (maximumDictionaryHistoryItems < countInSameHistory) {
      int surplus = countInSameHistory - maximumDictionaryHistoryItems;

      _dictionaryHistory
          .deleteAll(_dictionaryHistory.keys.toList().sublist(0, surplus));
    }
  }

  /// Adds a [DictionarySearchResult] to dictionary history.
  List<DictionaryFrequency> getNoReadingFrequencies(
      {required DictionaryHeading heading}) {
    if (heading.reading.isEmpty) {
      return [];
    }

    return _database.dictionaryHeadings
            .getSync(DictionaryHeading.hash(term: heading.term, reading: ''))
            ?.frequencies
            .where((frequency) =>
                !frequency.dictionary.value!.isHidden(targetLanguage))
            .toList() ??
        [];
  }

  /// Check if the database is still open or has the app been flagged to be
  /// shutdown.
  bool get isDatabaseOpen => _database.isOpen;

  /// Safely shutdown and stop database operations.
  void shutdown() async {
    databaseCloseNotifier.notifyListeners();
    await _database.close();
    FlutterExitApp.exitApp();
  }

  /// Flag for when the player is currently busy processing subtitles. Image
  /// and audio export cannot be done when this flag is on, so a toast is
  /// shown.
  bool isProcessingEmbeddedSubtitles = false;

  /// Get whether or not the transcript should show play/pause.
  bool get isTranscriptPlayerMode {
    return _preferences.get('is_transcript_player_mode', defaultValue: false);
  }

  /// Toggle transcript player mode.
  void toggleTranscriptPlayerMode() async {
    await _preferences.put(
      'is_transcript_player_mode',
      !isTranscriptPlayerMode,
    );
  }

  /// Get whether or not the transcript should have a background.
  bool get isTranscriptOpaque {
    return _preferences.get('is_transcript_opaque', defaultValue: false);
  }

  /// Toggle transcript background.
  void toggleTranscriptOpaque() async {
    await _preferences.put(
      'is_transcript_opaque',
      !isTranscriptOpaque,
    );
  }

  /// Get whether or not subtitle timings are shown.
  bool get subtitleTimingsShown {
    return _preferences.get('subtitle_timings_shown', defaultValue: true);
  }

  /// Toggle subtitle timings shown.
  void toggleSubtitleTimingsShown() async {
    await _preferences.put(
      'subtitle_timings_shown',
      !subtitleTimingsShown,
    );
  }

  /// Get the saved value that the user has set for the [TagsField].
  String get savedTags {
    return _preferences.get('saved_tags', defaultValue: '');
  }

  /// Set the saved value that the user has set for the [TagsField].
  void setSavedTags(String value) async {
    await _preferences.put('saved_tags', value);
  }

  /// Get the list of model names that will be checked for duplicates.
  List<String> get duplicateCheckModels {
    return _preferences.get('duplicate_check_models', defaultValue: [
      AnkiMapping.standardModelName,
    ]);
  }

  /// Set the list of model names that will be checked for duplicates.
  void setDuplicateCheckModels(List<String> value) async {
    await _preferences.put('duplicate_check_models', value);
  }

  /// Get whether or not bookmarks have been populated.
  bool get populateBookmarksFlag {
    return _preferences.get('populate_bookmarks', defaultValue: false);
  }

  /// Sets the populate bookmarks flag so bookmarks don't get added again.
  void setPopulateBookmarksFlag() async {
    await _preferences.put('populate_bookmarks', true);
  }
}

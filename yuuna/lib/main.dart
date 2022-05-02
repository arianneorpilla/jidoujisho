import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';

/// Application execution starts here.
void main() {
  /// Run and handle an error zone to customise the action performed upon
  /// an error or exception. This allows for error logging for debug purposes
  /// as well as communicating errors to Crashlytics if enabled.
  runZonedGuarded<Future<void>>(() async {
    /// Necessary to initialise Flutter when running native code before
    /// starting the application.
    WidgetsFlutterBinding.ensureInitialized();

    /// Perform startup activities unrelated to the [AppModel] here.
    AnkiUtilities.requestAnkidroidPermissions();

    /// Used in order to access and initialise an [AppModel] without requiring
    /// a [WidgetRef].
    final container = ProviderContainer();
    final appModel = container.read(appProvider);
    await appModel.initialise();

    /// Start the application, specifying the [ProviderContainer] with the
    /// already initialised [AppModel].
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const JidoujishoApp(),
      ),
    );
  }, (exception, stack) {
    /// Print error details to the console.
    final details = FlutterErrorDetails(exception: exception, stack: stack);
    FlutterError.dumpErrorToConsole(details);
  });
}

/// Encapsulates theming, spacing and other configurable options pertaining to
/// the entire app, with some parameters dependent on the [AppModel].
class JidoujishoApp extends ConsumerStatefulWidget {
  /// Initialises an instance of the app.
  const JidoujishoApp({Key? key}) : super(key: key);

  @override
  ConsumerState<JidoujishoApp> createState() => _JidoujishoAppState();
}

class _JidoujishoAppState extends ConsumerState<JidoujishoApp> {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: appModel.navigatorKey,
      home: home,
      locale: locale,
      themeMode: themeMode,
      theme: theme,
      darkTheme: darkTheme,
      // This is responsible for the initialising the global spacing across
      // the entire project, making use of the [spaces] package.
      builder: (context, child) => Spacing(
        dataBuilder: (context) {
          final mediaQuery = MediaQuery.of(context);
          if (mediaQuery.size.width > 500) {
            return SpacingData.generate(30);
          }
          return SpacingData.generate(10);
        },
        child: child!,
      ),
    );
  }

  /// Responsible for managing global app-wide state.
  AppModel get appModel => ref.watch(appProvider);

  /// The application will open to this page upon startup.
  Widget get home => const HomePage();

  /// The current theme mode, which by default is based on system setting
  /// and toggleable.
  ThemeMode get themeMode =>
      appModel.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// The current locale, dependent on the active target language.
  Locale get locale => appModel.targetLanguage.locale;

  /// The current text baseline, dependent on the active target language.
  TextBaseline get textBaseline => appModel.targetLanguage.textBaseline;

  /// This override is a workaround required to theme the app-wide [TextStyle]
  /// based on the [Locale] and [TextBaseline] of the active target language.
  TextStyle get textStyle => TextStyle(
        locale: locale,
        textBaseline: textBaseline,
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

  /// Shows when the current [themeMode] is a light theme.
  ThemeData get theme => ThemeData(
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        selectedRowColor: Colors.grey.shade300,
        textTheme: textTheme,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.red,
          secondary: Colors.red,
          brightness: Brightness.light,
        ),
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
          shape: RoundedRectangleBorder(),
        ),
        dialogTheme: const DialogTheme(
          shape: RoundedRectangleBorder(),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.black,
          ),
        ),
        listTileTheme: ListTileThemeData(
          dense: true,
          selectedTileColor: Colors.grey.shade300,
          selectedColor: Colors.black,
          horizontalTitleGap: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color:
                    Theme.of(context).unselectedWidgetColor.withOpacity(0.5)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).focusColor),
          ),
        ),
        scrollbarTheme: const ScrollbarThemeData(isAlwaysShown: true),
      );

  /// Shows when the current [themeMode] is a dark theme.
  ThemeData get darkTheme => ThemeData(
        backgroundColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        selectedRowColor: Colors.grey.shade600,
        textTheme: textTheme,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.red,
          secondary: Colors.red,
          brightness: Brightness.dark,
        ),
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
          shape: RoundedRectangleBorder(),
        ),
        dialogTheme: const DialogTheme(
          shape: RoundedRectangleBorder(),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.white,
          ),
        ),
        listTileTheme: ListTileThemeData(
          dense: true,
          selectedTileColor: Colors.grey.shade600,
          selectedColor: Colors.white,
          horizontalTitleGap: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color:
                    Theme.of(context).unselectedWidgetColor.withOpacity(0.5)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).focusColor),
          ),
        ),
        scrollbarTheme: const ScrollbarThemeData(isAlwaysShown: true),
      );
}

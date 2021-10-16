import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:daijidoujisho/models/app_model.dart';
import 'package:daijidoujisho/pages/home_page.dart';

/// Application execution starts here.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  // Language language = JapaneseLanguage();
  // await language.initialiseLanguage();
  // String lemma = language.getRootForm("まかされる");
  // print(lemma);

  runApp(
    App(
      sharedPreferences: sharedPreferences,
      packageInfo: packageInfo,
    ),
  );
}

class App extends StatelessWidget {
  const App({
    Key? key,
    required this.sharedPreferences,
    required this.packageInfo,
  }) : super(key: key);

  final SharedPreferences sharedPreferences;
  final PackageInfo packageInfo;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppModel>(
      create: (_) => AppModel(
        sharedPreferences: sharedPreferences,
        packageInfo: packageInfo,
      ),
      child: Consumer<AppModel>(
        builder: (_, appModel, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: getLightTheme(context),
            darkTheme: getDarkTheme(context),
            themeMode:
                appModel.getIsDarkMode() ? ThemeMode.dark : ThemeMode.light,
            home: const HomePage(),
          );
        },
      ),
    );
  }

  ThemeData getLightTheme(BuildContext context) {
    return ThemeData(
      backgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: Colors.red,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      focusColor: Colors.red,
      selectedRowColor: Colors.grey.shade300,
      primaryTextTheme:
          Typography.material2018(platform: TargetPlatform.android).black,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Colors.black,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }

  ThemeData getDarkTheme(BuildContext context) {
    return ThemeData(
      backgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: Colors.red,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.grey.shade900,
      focusColor: Colors.red,
      selectedRowColor: Colors.grey,
      primaryTextTheme:
          Typography.material2018(platform: TargetPlatform.android).white,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}

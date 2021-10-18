import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/home_page.dart';

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
            home: FutureBuilder(
              future: appModel.initialiseAppModel(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else {
                  return const HomePage();
                }
              },
            ),
          );
        },
      ),
    );
  }

  ThemeData getLightTheme(BuildContext context) {
    return ThemeData(
      backgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.red,
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
      iconTheme: const IconThemeData(color: Colors.black),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      scrollbarTheme: const ScrollbarThemeData().copyWith(
        thumbColor: MaterialStateProperty.all(Colors.grey[500]),
      ),
    );
  }

  ThemeData getDarkTheme(BuildContext context) {
    return ThemeData(
      backgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.red,
        secondary: Colors.red,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
      cardColor: Colors.grey.shade900,
      focusColor: Colors.red,
      selectedRowColor: Colors.grey.shade600,
      primaryTextTheme:
          Typography.material2018(platform: TargetPlatform.android).white,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Colors.white,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      scrollbarTheme: const ScrollbarThemeData().copyWith(
        thumbColor: MaterialStateProperty.all(Colors.grey.shade700),
      ),
    );
  }
}

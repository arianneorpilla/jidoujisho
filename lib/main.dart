import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/export_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/home_page.dart';
import 'package:wakelock/wakelock.dart';

/// Application execution starts here.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Wakelock.disable();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Permission.manageExternalStorage.request();
  requestAnkiDroidPermissions();

  initialiseExportPaths();

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

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
        builder: (context, appModel, __) {
          return MaterialApp(
            locale: (appModel.hasInitialized)
                ? appModel.getCurrentLanguage().getLocale()
                : null,
            debugShowCheckedModeBanner: false,
            theme: appModel.getLightTheme(context),
            darkTheme: appModel.getDarkTheme(context),
            themeMode:
                appModel.getIsDarkMode() ? ThemeMode.dark : ThemeMode.light,
            home: blankWhileUninitialised(context),
          );
        },
      ),
    );
  }

  Widget blankWhileUninitialised(BuildContext context) {
    AppModel appModel = Provider.of<AppModel>(context);
    Future<void> initialiseAppModel = appModel.initialiseAppModel();

    if (appModel.hasInitialized) {
      return const HomePage();
    } else {
      return FutureBuilder(
        future: initialiseAppModel,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else {
            return const HomePage();
          }
        },
      );
    }
  }
}

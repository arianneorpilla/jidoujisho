import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/home_page.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/export_paths.dart';
import 'package:chisa/firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Application execution starts here.
void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    await Wakelock.disable();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    await Permission.storage.request();
    if ((await DeviceInfoPlugin().androidInfo).version.sdkInt! >= 30) {
      await Permission.manageExternalStorage.request();
    }

    requestAnkiDroidPermissions();
    initialiseExportPaths();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AppModel appModel = AppModel(
      sharedPreferences: sharedPreferences,
      packageInfo: packageInfo,
    );
    await appModel.initialiseAppModel();
    runApp(App(appModel: appModel));
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class App extends StatelessWidget {
  const App({
    required this.appModel,
    Key? key,
  }) : super(key: key);

  final AppModel appModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppModel>.value(
      value: appModel,
      child: Consumer<AppModel>(
        builder: (context, appModel, __) {
          return MaterialApp(
            locale: appModel.getCurrentLanguage().getLocale(),
            debugShowCheckedModeBanner: false,
            theme: appModel.getLightTheme(context),
            darkTheme: appModel.getDarkTheme(context),
            themeMode:
                appModel.getIsDarkMode() ? ThemeMode.dark : ThemeMode.light,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

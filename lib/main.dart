import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:clipboard_monitor/clipboard_monitor.dart';

import 'package:jidoujishi/local_player.dart';
import 'package:jidoujishi/web_player.dart';

File videoFile;
String subtitlesFile;
String webURL = "";

final globalClipboard = ValueNotifier<String>("");
final JsonEncoder encoder = JsonEncoder.withIndent('  ');

String appName;
String packageName;
String version;
String buildNumber;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  startClipboardMonitor();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  appName = packageInfo.appName;
  packageName = packageInfo.packageName;
  version = packageInfo.version;
  buildNumber = packageInfo.buildNumber;

  runApp(
    Phoenix(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        /* light theme settings */
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          showText("jidoujisho", 36, FontWeight.w600),
          showText("A video player for language learners", 20, FontWeight.w400),
          Container(height: 20),
          showButton(context, "Play Local Media", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LocalPlayer()),
            );
          }),
          showButton(context, "Play YouTube Video", () {
            TextEditingController _textFieldController =
                TextEditingController();

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Play YouTube Video"),
                  content: TextField(
                    controller: _textFieldController,
                    decoration:
                        InputDecoration(hintText: "Enter a YouTube URL"),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('CANCEL'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        webURL = _textFieldController.text;

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WebPlayer()),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }),
          showButton(context, "About This App", () {
            showLicensePage(
                context: context,
                applicationName: "jidoujisho",
                applicationVersion: version,
                applicationLegalese: "Developed by Leo Rafael Orpilla.\n" +
                    "Built for the Japanese language learning community.\n\n" +
                    "This software is open-source and free of charge.\n\n" +
                    "Word definitions queried from Jisho.org.\n\n" +
                    "If you like my work, you can help me out by rating the app, making\n " +
                    "a donation or collaborating with me on further improvements.");
          }),
          Container(height: 20),
          showText(version, 16, FontWeight.w200),
        ],
      ),
    );
  }
}

Widget showText(String text, double size, FontWeight weight) {
  return Container(
    width: double.infinity,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size,
        fontWeight: weight,
      ),
    ),
  );
}

Widget showButton(BuildContext context, String caption, VoidCallback action) {
  return Padding(
    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: InkWell(
      onTap: action,
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: double.infinity,
        color: Theme.of(context).backgroundColor.withOpacity(0.6),
        child: Column(
          children: [
            Text(
              caption,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void startClipboardMonitor() {
  ClipboardMonitor.registerCallback(onClipboardText);
}

void stopClipboardMonitor() {
  ClipboardMonitor.unregisterCallback(onClipboardText);
}

void onClipboardText(String text) {
  globalClipboard.value = text;
  print("clipboard changed: $text");
}

void stopAllClipboardMonitoring() {
  ClipboardMonitor.unregisterAllCallbacks();
}

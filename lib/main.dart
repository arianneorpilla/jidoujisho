import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:path_provider/path_provider.dart' as ph;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:jidoujisho/player.dart';

String extDirPath;
String previewImageDir;
String previewAudioDir;

String appName;
String packageName;
String version;
String buildNumber;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);

  Directory extDir = await ph.getExternalStorageDirectory();
  extDirPath = extDir.path;
  previewImageDir =
      extDirPath + "/Android/data/com.lrorpilla.jidoujisho/exportImage.jpg";
  previewAudioDir =
      extDirPath + "/Android/data/com.lrorpilla.jidoujisho/exportAudio.mp3";

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  appName = packageInfo.appName;
  packageName = packageInfo.packageName;
  version = packageInfo.version;
  buildNumber = packageInfo.buildNumber;

  await Permission.storage.request();

  runApp(Phoenix(child: App()));
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
      backgroundColor: Colors.redAccent[900],
      body: Container(
        // use LayoutBuilder to fetch the parent widget's constraints
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInImage(
                    image: AssetImage('assets/icon/icon.png'),
                    placeholder: MemoryImage(kTransparentImage),
                    width: 48,
                    height: 48,
                  ),
                  Container(height: 5),
                  showText("jidoujisho", 36, FontWeight.w600),
                  showText("A video player for language learners", 18,
                      FontWeight.w200),
                  // showContinueButton(context),
                  showLocalMediaButton(context),
                  showWatchYouTubeButton(context),
                  showAboutButton(context),
                  Container(height: 10),
                  showText(version, 16, FontWeight.w200),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget showLocalMediaButton(BuildContext context) {
    return showButton(
        context, "Play Local Media", Icons.video_collection_outlined, () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Player("")));
    });
  }

  // Widget showContinueButton(BuildContext context) {
  //   return showButton(context, "Continue Playback", Icons.refresh_outlined, () {
  //     Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => Player("")));
  //   });
  // }

  Widget showWatchYouTubeButton(BuildContext context) {
    return showButton(
        context, "Play YouTube Video", Icons.ondemand_video_outlined, () {
      TextEditingController _textFieldController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Play YouTube Video"),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter a YouTube URL"),
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
                  String _webURL = _textFieldController.text;

                  try {
                    if (YoutubePlayer.convertUrlToId(_webURL) != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Player(_webURL),
                        ),
                      );
                    }
                  } on Exception {
                    Navigator.pop(context);
                    print("Invalid link");
                  } catch (error) {
                    Navigator.pop(context);
                    print("Invalid link");
                  }
                },
              ),
            ],
          );
        },
      );
    });
  }

  Widget showAboutButton(BuildContext context) {
    const String legalese =
        "Built for the Japanese language learning community by Leo Rafael " +
            "Orpilla.\nLogo by Aaron Marbella. Word definitions queried " +
            "from Jisho.org.\n\nIf you like my work, you can help me out " +
            "by rating the app, making a donation or collaborating with me " +
            "on further improvements.";

    return showButton(
      context,
      "About This App",
      Icons.help_center_outlined,
      () {
        showLicensePage(
          context: context,
          applicationName: "jidoujisho",
          applicationIcon: Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Image(
              image: AssetImage("assets/icon/icon.png"),
              height: 48,
              width: 48,
            ),
          ),
          applicationVersion: version,
          applicationLegalese: legalese,
        );
      },
    );
  }

  Widget showText(String text, double size, FontWeight weight) {
    return Container(
      width: double.infinity,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: size, fontWeight: weight),
      ),
    );
  }

  Widget showButton(BuildContext context, String caption, IconData icon,
      VoidCallback action) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: InkWell(
        onTap: action,
        child: Container(
          padding: EdgeInsets.all(12.0),
          width: double.infinity,
          color: Theme.of(context).backgroundColor.withOpacity(0.6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.redAccent),
              Container(width: 10),
              Text(
                caption,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

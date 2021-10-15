import 'package:daijidoujisho/dictionary/dictionary_dialog.dart';
import 'package:daijidoujisho/media/media_type.dart';
import 'package:daijidoujisho/media/media_types/reader_media_type.dart';
import 'package:daijidoujisho/models/app_model.dart';
import 'package:daijidoujisho/pages/reader_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late MediaType mediaType;
  int selectedTabIndex = 0;

  late AppModel appModel;

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    selectedTabIndex = appModel.getLastActiveTabIndex();
    mediaType = appModel.availableMediaTypes[selectedTabIndex];

    return Scaffold(
      appBar: AppBar(
        leading: getLeading(),
        title: getTitle(),
        actions: [
          getResumeButton(),
          getSeeMoreButton(context),
        ],
      ),
      body: getBody(context),
      bottomNavigationBar: getBottomNavigationBar(),
    );
  }

  Widget getLeading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 9, 0, 9),
      child: FadeInImage(
        image: const AssetImage('assets/icon/icon.png'),
        placeholder: MemoryImage(kTransparentImage),
      ),
    );
  }

  Widget getTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("jidoujisho"),
        getVersion(),
      ],
    );
  }

  Widget getVersion() {
    String version = appModel.packageInfo.version;
    return Text(
      " $version preview",
      style: const TextStyle(
        fontWeight: FontWeight.w200,
        fontSize: 11,
      ),
      overflow: TextOverflow.fade,
    );
  }

  Widget getBody(BuildContext context) {
    List<MediaType> mediaTypes = appModel.availableMediaTypes;
    return mediaTypes[selectedTabIndex].getHomeBody(context);
  }

  void changeTab(int index) {
    appModel.setLastActiveTabIndex(index);
    setState(() {
      selectedTabIndex = index;
    });
  }

  Widget getBottomNavigationBar() {
    List<BottomNavigationBarItem> items = [];
    for (MediaType mediaType in appModel.availableMediaTypes) {
      items.add(mediaType.getHomeTab());
    }

    return BottomNavigationBar(
      items: items,
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedTabIndex,
      onTap: (index) => changeTab(index),
      selectedFontSize: 10,
      unselectedFontSize: 10,
      selectedIconTheme: IconThemeData(
          color: appModel.getIsDarkMode() ? Colors.white : Colors.red),
      selectedItemColor: appModel.getIsDarkMode() ? Colors.red : Colors.black,
      unselectedIconTheme:
          IconThemeData(color: Theme.of(context).unselectedWidgetColor),
      unselectedLabelStyle:
          TextStyle(color: Theme.of(context).unselectedWidgetColor),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget getResumeButton() {
    return IconButton(
      icon: const Icon(Icons.update),
      onPressed: () => resumeMedia(),
    );
  }

  Widget getSeeMoreButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: GestureDetector(
        child: const Icon(Icons.more_vert),
        onTapDown: (TapDownDetails details) =>
            showDropDownOptions(context, details.globalPosition),
      ),
    );
  }

  void resumeMedia() {}

  void showDropDownOptions(BuildContext context, Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;

    PopupMenuItem<VoidCallback> menuItem(
        {required String label, required IconData icon, required action}) {
      return PopupMenuItem<VoidCallback>(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
        value: action,
        padding: const EdgeInsets.only(left: 32, top: 16, bottom: 16),
      );
    }

    VoidCallback? callbackAction = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        menuItem(
          label:
              appModel.getIsDarkMode() ? 'Use light theme' : 'Use dark theme',
          icon: appModel.getIsDarkMode() ? Icons.light_mode : Icons.dark_mode,
          action: () async {
            await appModel.toggleActiveTheme();
          },
        ),
        menuItem(
          label: 'Manage dictionaries',
          icon: Icons.auto_stories,
          action: () async {
            await appModel.showDictionaryMenu(
              context,
              manageAllowed: true,
            );
          },
        ),
        menuItem(
          label: 'Language settings',
          icon: Icons.translate,
          action: () async {},
        ),
        menuItem(
          label: 'View repository on GitHub',
          icon: Icons.code,
          action: () async {
            await launch("https://github.com/lrorpilla/jidoujisho");
          },
        ),
        menuItem(
          label: 'Licenses and attribution',
          icon: Icons.info,
          action: () async {
            const String legalese = "A mobile video player, reader assistant, "
                "image mining workflow and card creation toolkit tailored for "
                "language learners.\n\nBuilt for the Japanese language "
                "learning community by Leo Rafael Orpilla. Pitch accent "
                "patterns from Kanjium. Reader WebView linked to ッツ "
                "Ebook Reader. Video streaming via YouTube. Image search via "
                "Bing. Logo by Aaron Marbella.\n\njidoujisho is free and open "
                "source software. Liking the application? Help out by "
                "providing feedback, making a donation, reporting issues or "
                "collaborating for further improvements on GitHub.";

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Theme(
                  data: Theme.of(context).copyWith(
                    cardColor:
                        appModel.getIsDarkMode() ? Colors.black : Colors.white,
                  ),
                  child: LicensePage(
                    applicationName: "jidoujisho",
                    applicationVersion: appModel.packageInfo.version,
                    applicationIcon: const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      child: Image(
                        image: AssetImage("assets/icon/icon.png"),
                        height: 48,
                        width: 48,
                      ),
                    ),
                    applicationLegalese: legalese,
                  ),
                ),
              ),
            );
          },
        ),
      ],
      elevation: 8.0,
    );

    if (callbackAction != null) {
      callbackAction();
    }
  }
}

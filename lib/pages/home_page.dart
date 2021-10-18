import 'package:chisa/dictionary/dictionary_widget_enhancement.dart';
import 'package:chisa/dictionary/dictionary_widget_enhancement_dialog.dart';
import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/dictionary_widget_field.dart';
import 'package:chisa/util/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    List<MediaType> mediaTypes = appModel.availableMediaTypes;

    return Scaffold(
      appBar: AppBar(
        leading: getLeading(),
        title: getTitle(),
        actions: [
          getResumeButton(),
          getSeeMoreButton(context),
        ],
      ),
      body: mediaTypes[selectedTabIndex].getHomeBody(context),
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
        Text(
          AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "app_title"),
        ),
        getVersion(),
      ],
    );
  }

  Widget getVersion() {
    String version = appModel.packageInfo.version;
    return Text(
      " $version preview",
      style: const TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 12,
      ),
      overflow: TextOverflow.fade,
    );
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
      items.add(mediaType.getHomeTab(context));
    }

    return BottomNavigationBar(
      elevation: 0,
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
      padding: const EdgeInsets.fromLTRB(12, 0, 14, 0),
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

    VoidCallback? callbackAction = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        menuItem(
          label: appModel.getIsDarkMode()
              ? AppLocalizations.getLocalizedValue(
                  appModel.getAppLanguageName(), "options_theme_light")
              : AppLocalizations.getLocalizedValue(
                  appModel.getAppLanguageName(), "options_theme_dark"),
          icon: appModel.getIsDarkMode() ? Icons.light_mode : Icons.dark_mode,
          action: () async {
            await appModel.toggleActiveTheme();
          },
        ),
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "options_dictionaries"),
          icon: Icons.auto_stories,
          action: () async {
            await appModel.showDictionaryMenu(
              context,
              manageAllowed: true,
            );
            setState(() {});
          },
        ),
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "options_enhancements"),
          icon: Icons.auto_fix_high,
          action: () async {
            showEnhancementOptions(context, offset);
          },
        ),
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "options_language"),
          icon: Icons.translate,
          action: () async {
            await appModel.showLanguageMenu(
              context,
            );
          },
        ),
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "options_github"),
          icon: Icons.code,
          action: () async {
            await launch("https://github.com/lrorpilla/jidoujisho");
          },
        ),
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "options_licenses"),
          icon: Icons.info,
          action: () async {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Theme(
                  data: Theme.of(context).copyWith(
                    cardColor:
                        appModel.getIsDarkMode() ? Colors.black : Colors.white,
                  ),
                  child: LicensePage(
                      applicationName: AppLocalizations.getLocalizedValue(
                          appModel.getAppLanguageName(), "app_title"),
                      applicationVersion: appModel.packageInfo.version,
                      applicationIcon: const Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Image(
                          image: AssetImage("assets/icon/icon.png"),
                          height: 48,
                          width: 48,
                        ),
                      ),
                      applicationLegalese: AppLocalizations.getLocalizedValue(
                          appModel.getAppLanguageName(),
                          "license_screen_legalese")),
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

  void showEnhancementOptions(BuildContext context, Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;

    VoidCallback? callbackAction = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "creator_options_menu"),
          icon: Icons.widgets,
          action: () async {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const CreatorPage(editMode: true),
              ),
            );
            setState(() {});
          },
        ),
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "creator_options_auto"),
          icon: Icons.hdr_auto,
          action: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const CreatorPage(autoMode: true),
              ),
            );
            setState(() {});
          },
        ),
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "widget_options"),
          icon: Icons.auto_stories,
          action: () async {
            showWidgetFieldOptions(context, offset);
          },
        ),
      ],
      elevation: 8.0,
    );

    if (callbackAction != null) {
      callbackAction();
    }
  }

  void showWidgetFieldOptions(BuildContext context, Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;

    Future<void> changeFieldWidget(DictionaryWidgetField field) async {
      DictionaryWidgetEnhancement? enhancement = await showDialog(
        context: context,
        builder: (context) => DictionaryWidgetEnhancementDialog(
          field: field,
        ),
      );

      if (enhancement != null) {
        if (enhancement == appModel.getFieldWidgetEnhancement(field)) {
          await enhancement.setDisabled(field);
        } else {
          await enhancement.setEnabled(field);
        }
      }
      setState(() {});
    }

    VoidCallback? callbackAction = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "field_label_word"),
          icon: Icons.speaker_notes_outlined,
          action: () async {
            await changeFieldWidget(DictionaryWidgetField.word);
          },
        ),
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "field_label_reading"),
          icon: Icons.surround_sound_outlined,
          action: () async {
            await changeFieldWidget(DictionaryWidgetField.reading);
          },
        ),
        menuItem(
          label: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "field_label_meaning"),
          icon: Icons.translate_rounded,
          action: () async {
            await changeFieldWidget(DictionaryWidgetField.meaning);
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

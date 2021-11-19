import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_widget_enhancement.dart';
import 'package:chisa/dictionary/dictionary_widget_enhancement_dialog.dart';

import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/dictionary_widget_field.dart';
import 'package:chisa/util/greyscale_wrapper.dart';
import 'package:chisa/util/popup_item.dart';
import 'package:chisa/util/return_from_context.dart';
import 'package:chisa/util/share_intent.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AppModel appModel;
  PageController? pageController;
  late MediaType mediaType;
  late ScrollController scrollController;

  ValueNotifier<int> selectedTabIndex = ValueNotifier<int>(0);

  MediaType getCurrentMediaTabType() {
    return appModel.mediaTypes[selectedTabIndex.value];
  }

  bool initialTextProcessed = false;
  bool initialLinkProcessed = false;

  ImageProvider<Object> imageIcon = const AssetImage("assets/icon/icon.png");
  ValueNotifier<bool>? incognitoNotifier;

  @override
  void initState() {
    super.initState();

    ReceiveSharingIntent.getInitialText().then((String? text) {
      if (text != null) {
        textShareIntentAction(context, text);
      }
    });
    ReceiveSharingIntent.getTextStream().listen((String? text) {
      if (text != null) {
        textShareIntentAction(context, text);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(imageIcon, context);
  }

  Widget getTabs() {
    List<Widget> widgets = [];
    for (MediaType mediaType in appModel.mediaTypes) {
      Widget widget =
          mediaType.getHomeBody(appModel.getSearchController(mediaType));
      widgets.add(widget);
    }

    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    selectedTabIndex.value = appModel.getLastActiveTabIndex();

    pageController ??= PageController(
      initialPage: selectedTabIndex.value,
    );
    scrollController = appModel.getScrollController(
      getCurrentMediaTabType(),
    );

    return Scaffold(
      appBar: AppBar(
        leading: getLeading(),
        title: getTitle(),
        actions: [
          getResumeButton(),
          getCardCreatorButton(),
          getSeeMoreButton(context),
        ],
      ),
      body: getTabs(),
      bottomNavigationBar: getBottomNavigationBar(),
    );
  }

  Widget getLeading() {
    incognitoNotifier ??= ValueNotifier<bool>(appModel.getIncognitoMode());
    return ValueListenableBuilder<bool>(
      valueListenable: incognitoNotifier!,
      builder: (BuildContext context, bool incognito, Widget? child) {
        if (incognito) {
          return GreyscaleWrapper(child: getIcon());
        } else {
          return getIcon();
        }
      },
    );
  }

  Widget getIcon() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 9, 0, 9),
      child: Image(
        image: imageIcon,
      ),
    );
  }

  Widget getTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          appModel.translate("app_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
    if (selectedTabIndex.value == index) {
      appModel.getScrollController(getCurrentMediaTabType()).animateTo(0,
          duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
      appModel.getSearchController(getCurrentMediaTabType()).clear();
      appModel.getSearchController(getCurrentMediaTabType()).close();
    } else {
      selectedTabIndex.value = index;
      pageController!.jumpToPage(index);
      appModel.setLastActiveTabIndex(index);
    }
  }

  Widget getBottomNavigationBar() {
    List<BottomNavigationBarItem> items = [];
    for (MediaType mediaType in appModel.mediaTypes) {
      items.add(mediaType.getHomeTab(context));
    }

    return ValueListenableBuilder<int>(
      valueListenable: selectedTabIndex,
      builder: (context, int currentIndex, _) {
        return BottomNavigationBar(
          elevation: 0,
          items: items,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (index) => changeTab(index),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedIconTheme: IconThemeData(
              color: appModel.getIsDarkMode() ? Colors.white : Colors.red),
          selectedItemColor:
              appModel.getIsDarkMode() ? Colors.red : Colors.black,
          unselectedIconTheme:
              IconThemeData(color: Theme.of(context).unselectedWidgetColor),
          unselectedLabelStyle:
              TextStyle(color: Theme.of(context).unselectedWidgetColor),
          backgroundColor: Theme.of(context).backgroundColor,
        );
      },
    );
  }

  Widget getResumeButton() {
    return ValueListenableBuilder<bool>(
        valueListenable: appModel.resumableNotifier,
        builder: (context, bool resumable, _) {
          return IconButton(
              icon: const Icon(Icons.update),
              onPressed: (resumable)
                  ? () async {
                      returnFromContext(
                          context, appModel.getResumeMediaHistoryItem()!);
                      setState(() {});
                    }
                  : null);
        });
  }

  Widget getCardCreatorButton() {
    return IconButton(
        icon: const Icon(Icons.note_add_outlined),
        onPressed: () async {
          await navigateToCreator(
            context: context,
            appModel: appModel,
          );
          setState(() {});
        });
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

  void showDropDownOptions(BuildContext context, Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;

    VoidCallback? callbackAction = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        popupItem(
          label: appModel.getIsDarkMode()
              ? appModel.translate("options_theme_light")
              : appModel.translate("options_theme_dark"),
          icon: appModel.getIsDarkMode() ? Icons.light_mode : Icons.dark_mode,
          action: () async {
            await appModel.toggleActiveTheme();
          },
        ),
        popupItem(
          label: appModel.getIncognitoMode()
              ? appModel.translate("options_incognito_off")
              : appModel.translate("options_incognito_on"),
          icon: appModel.getIncognitoMode()
              ? Icons.person_off_outlined
              : Icons.person_off,
          action: () async {
            await appModel.toggleIncognitoMode();
            incognitoNotifier!.value = appModel.getIncognitoMode();
          },
        ),
        popupItem(
          label: appModel.translate("options_dictionaries"),
          icon: Icons.auto_stories,
          action: () async {
            List<Dictionary> dictionaryRecord = appModel.getDictionaryRecord();
            await appModel.showDictionaryMenu(
              context,
              manageAllowed: true,
            );
            if (dictionaryRecord != appModel.getDictionaryRecord() &&
                getCurrentMediaTabType() == MediaType.dictionary) {
              setState(() {});
            }
          },
        ),
        popupItem(
          label: appModel.translate("options_sources"),
          icon: Icons.perm_media,
          action: () async {
            showMediaSourceOptions(context, offset);
          },
        ),
        popupItem(
          label: appModel.translate("options_enhancements"),
          icon: Icons.auto_fix_high,
          action: () async {
            showEnhancementOptions(context, offset);
          },
        ),
        popupItem(
          label: appModel.translate("options_language"),
          icon: Icons.translate,
          action: () async {
            await appModel.showLanguageMenu(
              context,
            );
          },
        ),
        popupItem(
          label: appModel.translate("options_github"),
          icon: Icons.code,
          action: () async {
            await launch("https://github.com/lrorpilla/jidoujisho");
          },
        ),
        popupItem(
          label: appModel.translate("options_licenses"),
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
                    applicationName: appModel.translate("app_title"),
                    applicationVersion: appModel.packageInfo.version,
                    applicationIcon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Image(
                        image: imageIcon,
                        height: 48,
                        width: 48,
                      ),
                    ),
                    applicationLegalese:
                        appModel.translate("license_screen_legalese"),
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

  void showEnhancementOptions(BuildContext context, Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;

    VoidCallback? callbackAction = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        popupItem(
          label: appModel.translate("creator_options_menu"),
          icon: Icons.widgets,
          action: () async {
            await navigateToCreator(
              context: context,
              appModel: appModel,
              editMode: true,
            );
            setState(() {});
          },
        ),
        popupItem(
          label: appModel.translate("creator_options_auto"),
          icon: Icons.hdr_auto,
          action: () async {
            await navigateToCreator(
              context: context,
              appModel: appModel,
              autoMode: true,
            );
            setState(() {});
          },
        ),
        popupItem(
          label: appModel.translate("widget_options"),
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
        popupItem(
          label: appModel.translate("field_label_word"),
          icon: Icons.speaker_notes_outlined,
          action: () async {
            await changeFieldWidget(DictionaryWidgetField.word);
          },
        ),
        popupItem(
          label: appModel.translate("field_label_reading"),
          icon: Icons.surround_sound_outlined,
          action: () async {
            await changeFieldWidget(DictionaryWidgetField.reading);
          },
        ),
        popupItem(
          label: appModel.translate("field_label_meaning"),
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

  void showMediaSourceOptions(BuildContext context, Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;

    VoidCallback? callbackAction = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        popupItem(
          label: appModel.translate("player_media_type"),
          icon: Icons.video_library,
          action: () async {
            String sourceName =
                appModel.getCurrentMediaTypeSourceName(MediaType.player);
            await appModel.showSourcesMenu(
              context: context,
              mediaType: MediaType.player,
              manageAllowed: true,
            );
            if (sourceName !=
                    appModel.getCurrentMediaTypeSourceName(MediaType.player) &&
                getCurrentMediaTabType() == MediaType.player) {
              setState(() {});
            }
          },
        ),
        popupItem(
          label: appModel.translate("reader_media_type"),
          icon: Icons.library_books,
          action: () async {
            String sourceName =
                appModel.getCurrentMediaTypeSourceName(MediaType.reader);
            await appModel.showSourcesMenu(
              context: context,
              mediaType: MediaType.reader,
              manageAllowed: true,
            );
            if (sourceName !=
                    appModel.getCurrentMediaTypeSourceName(MediaType.reader) &&
                getCurrentMediaTabType() == MediaType.reader) {
              setState(() {});
            }
          },
        ),
        popupItem(
          label: appModel.translate("viewer_media_type"),
          icon: Icons.photo_library,
          action: () async {
            String sourceName =
                appModel.getCurrentMediaTypeSourceName(MediaType.viewer);
            await appModel.showSourcesMenu(
              context: context,
              mediaType: MediaType.viewer,
              manageAllowed: true,
            );
            if (sourceName !=
                    appModel.getCurrentMediaTypeSourceName(MediaType.viewer) &&
                getCurrentMediaTabType() == MediaType.viewer) {
              setState(() {});
            }
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

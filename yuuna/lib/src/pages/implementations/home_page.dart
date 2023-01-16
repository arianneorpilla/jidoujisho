import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// Appears at startup as the portal from which a user may select media and
/// broadly select their activity of choice. The page characteristically has
/// an [AppBar] and a [BottomNavigationBar].
class HomePage extends BasePage {
  /// Construct an instance of the [HomePage].
  const HomePage({super.key});

  @override
  BasePageState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BasePageState<HomePage> {
  late final List<Widget> mediaTypeBodies;
  late final List<BottomNavigationBarItem> navBarItems;

  String get appName => appModel.packageInfo.appName;
  String get appVersion => appModel.packageInfo.version;
  late final Image appIcon;

  int get currentHomeTabIndex => appModel.currentHomeTabIndex;

  String get optionsToggleDark => appModel.translate('options_theme_dark');
  String get optionsToggleLight => appModel.translate('options_theme_light');
  String get optionsIncognitoOn => appModel.translate('options_incognito_on');
  String get optionsIncognitoOff => appModel.translate('options_incognito_off');
  String get optionsDictionaries => appModel.translate('options_dictionaries');
  String get optionsProfiles => appModel.translate('options_profiles');
  String get optionsEnhancements => appModel.translate('options_enhancements');
  String get optionsLanguage => appModel.translate('options_language');
  String get optionsGithub => appModel.translate('options_github');
  String get optionsAttribution => appModel.translate('options_attribution');

  String get resumeLastMediaLabel => appModel.translate('resume_last_media');
  String get cardCreatorLabel => appModel.translate('card_creator');
  String get showMenuLabel => appModel.translate('show_menu');

  @override
  void initState() {
    super.initState();

    /// Populate and define the tabs and their respective content bodies based
    /// on the media types specified and ordered by [AppModel]. As [ref.watch]
    /// cannot be used here, [ref.read] is used instead, via [appModelNoUpdate].
    mediaTypeBodies = List.unmodifiable(
        appModelNoUpdate.mediaTypes.values.map((mediaType) => mediaType.home));
    navBarItems = List.unmodifiable(
      appModelNoUpdate.mediaTypes.values.map(
        (mediaType) => BottomNavigationBarItem(
          activeIcon: Icon(mediaType.icon),
          icon: Icon(mediaType.outlinedIcon),
          label: appModelNoUpdate.translate(mediaType.uniqueKey),
        ),
      ),
    );

    /// Define the app icon for precaching so that it does not pop in.
    appIcon = Image.asset(
      'assets/meta/icon.png',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (appModel.isFirstTimeSetup) {
        await appModel.showLanguageMenu();
        appModel.populateDefaultMapping(appModel.targetLanguage);
        appModel.setLastSelectedDictionaryFormat(
            appModel.targetLanguage.standardFormat);
        appModel.setFirstTimeSetupFlag();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(appIcon.image, context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: buildAppBar(),
        body: buildBody(),
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      leading: buildLeading(),
      title: buildTitle(),
      actions: buildActions(),
      titleSpacing: 8,
    );
  }

  Widget? buildBody() {
    return IndexedStack(
      index: currentHomeTabIndex,
      children: mediaTypeBodies,
    );
  }

  Widget? buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: switchTab,
      currentIndex: currentHomeTabIndex,
      items: navBarItems,
      selectedFontSize: textTheme.labelSmall!.fontSize!,
      unselectedFontSize: textTheme.labelSmall!.fontSize!,
    );
  }

  void switchTab(int index) async {
    if (index == currentHomeTabIndex) {
      MediaType mediaType = appModelNoUpdate.mediaTypes.values.toList()[index];
      mediaType.floatingSearchBarController.close();

      if (mediaType.scrollController.hasClients) {
        if (mediaType.scrollController.offset > 5000) {
          mediaType.scrollController.jumpTo(0);
        } else {
          mediaType.scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
      }
    } else {
      await appModel.setCurrentHomeTabIndex(index);
      setState(() {});
    }
  }

  Widget? buildLeading() {
    return ChangeNotifierBuilder(
      notifier: appModel.incognitoNotifier,
      builder: (context, notifier, widget) {
        return Padding(
          padding: Spacing.of(context).insets.onlyLeft.normal,
          child: appModel.isIncognitoMode
              ? ColorFiltered(
                  colorFilter: JidoujishoColor.greyscaleWithAlphaFilter,
                  child: appIcon,
                )
              : appIcon,
        );
      },
    );
  }

  Widget buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appName,
          style: textTheme.titleLarge,
        ),
        const Space.extraSmall(),
        Text(
          appVersion,
          style: textTheme.labelSmall!.copyWith(
            letterSpacing: 0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> buildActions() {
    return [
      buildCreatorButton(),
      const Space.small(),
      buildShowMenuButton(),
      const Space.extraSmall(),
    ];
  }

  Widget buildResumeButton() {
    return JidoujishoIconButton(
      tooltip: resumeLastMediaLabel,
      icon: Icons.update,
      enabled: false,
      onTap: resumeAction,
    );
  }

  Widget buildCreatorButton() {
    return JidoujishoIconButton(
      tooltip: cardCreatorLabel,
      icon: Icons.note_add_outlined,
      onTap: () => appModel.openCreator(
        ref: ref,
        killOnPop: false,
      ),
    );
  }

  Widget buildShowMenuButton() {
    return JidoujishoIconButton(
      tooltip: showMenuLabel,
      icon: Icons.more_vert,
      onTapDown: (details) async {
        openMenu(details);
      },
    );
  }

  PopupMenuItem<VoidCallback> buildPopupItem({
    required String label,
    required Function() action,
    IconData? icon,
    Color? color,
  }) {
    return PopupMenuItem<VoidCallback>(
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: textTheme.bodyMedium?.fontSize,
              color: color,
            ),
          if (icon != null) const Space.normal(),
          Text(
            label,
            style: TextStyle(color: color),
          ),
        ],
      ),
      value: action,
    );
  }

  void resumeAction() {}

  void openMenu(TapDownDetails details) async {
    RelativeRect position = RelativeRect.fromLTRB(
        details.globalPosition.dx, details.globalPosition.dy, 0, 0);
    Function()? selectedAction = await showMenu(
      context: context,
      position: position,
      items: getMenuItems(),
    );

    selectedAction?.call();

    if (selectedAction == null) {
      Future.delayed(const Duration(milliseconds: 50), () {
        FocusScope.of(context).unfocus();
      });
    }
  }

  void browseToGithub() async {
    launchUrl(
      Uri.parse('https://github.com/lrorpilla/jidoujisho'),
      mode: LaunchMode.externalApplication,
    );
  }

  void navigateToLicensePage() async {
    String applicationLegalese =
        'A full-featured immersion language learning suite for mobile.\n\n'
        'Originally built for the Japanese language learning community by Leo Rafael Orpilla. Logo by suzy and Aaron Marbella.'
        '\n\njidoujisho is free and open source software. See the '
        'project repository for a comprehensive list of other licenses '
        'and attribution notices. Enjoying the application? Help out by '
        'providing feedback, making a donation, reporting issues or '
        'contributing improvements on GitHub.';

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Theme(
          data: theme.copyWith(
            cardColor: theme.backgroundColor,
          ),
          child: LicensePage(
            applicationName: appModel.packageInfo.appName,
            applicationVersion: appModel.packageInfo.version,
            applicationLegalese: applicationLegalese,
            applicationIcon: Padding(
              padding: Spacing.of(context).insets.all.normal,
              child: Image.asset(
                'assets/meta/icon.png',
                height: 128,
                width: 128,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<PopupMenuItem<VoidCallback>> getMenuItems() {
    return [
      buildPopupItem(
        label: appModel.isDarkMode ? optionsToggleLight : optionsToggleDark,
        icon: appModel.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        action: appModel.toggleDarkMode,
      ),
      buildPopupItem(
        label:
            appModel.isIncognitoMode ? optionsIncognitoOff : optionsIncognitoOn,
        icon: appModel.isIncognitoMode
            ? Icons.person_off_outlined
            : Icons.person_off,
        action: appModel.toggleIncognitoMode,
      ),
      buildPopupItem(
        label: optionsDictionaries,
        icon: Icons.auto_stories_rounded,
        action: appModel.showDictionaryMenu,
      ),
      buildPopupItem(
        label: optionsEnhancements,
        icon: Icons.auto_fix_high,
        action: appModel.openCreatorEnhancementsEditor,
      ),
      buildPopupItem(
        label: optionsLanguage,
        icon: Icons.translate,
        action: appModel.showLanguageMenu,
      ),
      buildPopupItem(
        label: optionsProfiles,
        icon: Icons.switch_account,
        action: appModel.showProfilesMenu,
      ),
      buildPopupItem(
        label: optionsGithub,
        icon: Icons.code,
        action: browseToGithub,
      ),
      buildPopupItem(
        label: optionsAttribution,
        icon: Icons.info,
        action: navigateToLicensePage,
      ),
    ];
  }
}

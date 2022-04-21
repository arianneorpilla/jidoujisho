import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// Appears at startup as the portal from which a user may select media and
/// broadly select their activity of choice. The page characteristically has
/// an [AppBar] and a [BottomNavigationBar].
class HomePage extends BasePage {
  /// Construct an instance of the [HomePage].
  const HomePage({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();

    /// Populate and define the tabs and their respective content bodies based
    /// on the media types specified and ordered by [AppModel]. As [ref.watch]
    /// cannot be used here, [ref.read] is used instead, via [appModelNoUpdate].
    mediaTypeBodies = List.unmodifiable(
        appModelNoUpdate.mediaTypes.map((mediaType) => mediaType.home));
    navBarItems = List.unmodifiable(
      appModelNoUpdate.mediaTypes.map(
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(appIcon.image, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: buildAppBar(),
      body: buildBody(),
      bottomNavigationBar: buildBottomNavigationBar(),
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
    await appModel.setCurrentHomeTabIndex(index);
    setState(() {});
  }

  Widget? buildLeading() {
    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.normal,
      child: appIcon,
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
      buildStashButton(),
      buildCreatorButton(),
      buildShowMenuButton(),
      const Space.extraSmall(),
    ];
  }

  Widget buildStashButton() {
    return JidoujishoIconButton(
      tooltip: appModel.translate('stash'),
      icon: Icons.queue_outlined,
      enabled: false,
      onPressed: openQueue,
    );
  }

  Widget buildCreatorButton() {
    return JidoujishoIconButton(
      tooltip: appModel.translate('card_creator'),
      icon: Icons.note_add_outlined,
      onPressed: openCreator,
    );
  }

  Widget buildShowMenuButton() {
    return JidoujishoIconButton(
      tooltip: appModel.translate('show_menu'),
      icon: Icons.more_vert,
      onPressed: openMenu,
    );
  }

  PopupMenuItem<VoidCallback> buildPopupItem({
    required String label,
    required IconData icon,
    required Function() action,
  }) {
    return PopupMenuItem<VoidCallback>(
      child: Row(
        children: [
          Icon(icon, size: textTheme.bodyMedium?.fontSize),
          const Space.normal(),
          Text(label, style: textTheme.bodyMedium),
        ],
      ),
      value: action,
    );
  }

  void openQueue() {}

  void openCreator() {}

  void openMenu() async {
    RelativeRect position =
        const RelativeRect.fromLTRB(double.maxFinite, 0, 0, 0);
    Function()? selectedAction = await showMenu(
      context: context,
      position: position,
      items: getMenuItems(),
    );

    selectedAction?.call();
  }

  void browseToGithub() async {
    launch('https://github.com/lrorpilla/jidoujisho');
  }

  void navigateToLicensePage() async {
    String applicationLegalese = 'A highly versatile and modular framework '
        'enabling language-agnostic immersion learning on mobile. \n\n'
        'Originally built for the Japanese language learning '
        'community by Leo Rafael Orpilla. Logo by suzy and Aaron Marbella.'
        '\n\njidoujisho is free and open source software. Visit the '
        'repository for a more comprehensive list of other licenses '
        'and attribution notices. Liking the application? Help out by '
        'providing feedback, making a donation, reporting issues or '
        'collaborating for further improvements on GitHub.';

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(
            cardColor: Theme.of(context).backgroundColor,
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
        icon: Icons.auto_stories,
        action: () {},
      ),
      buildPopupItem(
        label: optionsEnhancements,
        icon: Icons.auto_fix_high,
        action: () {},
      ),
      buildPopupItem(
        label: optionsLanguage,
        icon: Icons.translate,
        action: () {},
      ),
      buildPopupItem(
        label: optionsProfiles,
        icon: Icons.send_to_mobile,
        action: () {},
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

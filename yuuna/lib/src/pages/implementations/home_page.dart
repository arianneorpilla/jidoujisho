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
  const HomePage({
    super.key,
  });

  @override
  BasePageState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BasePageState<HomePage>
    with WidgetsBindingObserver {
  late final List<Widget> mediaTypeBodies;
  late final List<BottomNavigationBarItem> navBarItems;

  String get appName => appModel.packageInfo.appName;
  String get appVersion => appModel.packageInfo.version;

  int get currentHomeTabIndex => appModel.currentHomeTabIndex;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    appModelNoUpdate.databaseCloseNotifier.addListener(refresh);

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
          label: t[mediaType.uniqueKey],
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      appModel.populateDefaultMapping(appModel.targetLanguage);
      appModel.populateBookmarks();
      if (appModel.isFirstTimeSetup) {
        await appModel.showLanguageMenu();
        appModel.setLastSelectedDictionaryFormat(
            appModel.targetLanguage.standardFormat);

        appModel.setFirstTimeSetupFlag();
      }
    });
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appModelNoUpdate.databaseCloseNotifier.removeListener(refresh);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (AppLifecycleState.resumed == state) {
      /// Keep the search database ready.
      debugPrint('Lifecycle Resumed');
      appModel.searchDictionary(
        searchTerm: appModel.targetLanguage.helloWorld,
        searchWithWildcards: false,
        useCache: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!appModel.isDatabaseOpen) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: buildAppBar(),
        body: SafeArea(
          child: buildBody(),
        ),
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

  Widget buildBody() {
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
    MediaType mediaType = appModelNoUpdate.mediaTypes.values.toList()[index];
    if (index == currentHomeTabIndex) {
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

      if (mediaType is DictionaryMediaType && appModel.shouldRefreshTabs) {
        appModel.shouldRefreshTabs = false;
        mediaType.refreshTab();
      }
    }
  }

  Widget? buildLeading() {
    return ChangeNotifierBuilder(
      notifier: appModel.incognitoNotifier,
      builder: (context, notifier, _) {
        return Padding(
          padding: Spacing.of(context).insets.onlyLeft.normal,
          child: Image.asset('assets/meta/icon.png'),
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
      buildShowMenuButton(),
    ];
  }

  Widget buildResumeButton() {
    return JidoujishoIconButton(
      tooltip: t.resume_last_media,
      icon: Icons.update,
      enabled: false,
      onTap: resumeAction,
    );
  }

  Widget buildCreatorButton() {
    return JidoujishoIconButton(
      tooltip: t.card_creator,
      icon: Icons.note_add_outlined,
      onTap: () => appModel.openCreator(
        ref: ref,
        killOnPop: false,
      ),
    );
  }

  Widget buildShowMenuButton() {
    return PopupMenuButton<VoidCallback>(
      splashRadius: 20,
      padding: EdgeInsets.zero,
      tooltip: t.show_menu,
      icon: Icon(
        Icons.more_vert,
        color: theme.iconTheme.color,
        size: 24,
      ),
      color: Theme.of(context).popupMenuTheme.color,
      onSelected: (value) => value(),
      itemBuilder: (context) => getMenuItems(),
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Theme(
          data: theme.copyWith(
            cardColor: theme.colorScheme.background,
          ),
          child: LicensePage(
            applicationName: appModel.packageInfo.appName,
            applicationVersion: appModel.packageInfo.version,
            applicationLegalese: t.legalese,
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
        label:
            appModel.isDarkMode ? t.options_theme_light : t.options_theme_dark,
        icon: appModel.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        action: appModel.toggleDarkMode,
      ),
      // if ((appModel.androidDeviceInfo.version.sdkInt ?? 0) >= 33)
      //   buildPopupItem(
      //     label: optionsPipMode,
      //     icon: Icons.picture_in_picture,
      //     action: () {
      //       appModel.usePictureInPicture(ref: ref);
      //     },
      //   ),
      buildPopupItem(
        label: t.options_dictionaries,
        icon: Icons.auto_stories_rounded,
        action: appModel.showDictionaryMenu,
      ),
      buildPopupItem(
        label: t.options_enhancements,
        icon: Icons.auto_fix_high,
        action: appModel.openCreatorEnhancementsEditor,
      ),
      buildPopupItem(
        label: t.options_language,
        icon: Icons.translate,
        action: appModel.showLanguageMenu,
      ),
      buildPopupItem(
        label: t.options_profiles,
        icon: Icons.switch_account,
        action: appModel.showProfilesMenu,
      ),
      buildPopupItem(
        label: t.options_github,
        icon: Icons.code,
        action: browseToGithub,
      ),
      buildPopupItem(
        label: t.options_attribution,
        icon: Icons.info,
        action: navigateToLicensePage,
      ),
    ];
  }
}

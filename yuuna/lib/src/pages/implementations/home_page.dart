import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/components.dart';

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
      buildQueueButton(),
      buildCreatorButton(),
      buildSettingsButton(),
      const Space.normal(),
    ];
  }

  Widget buildQueueButton() {
    return JidoujishoIcon(
      icon: Icons.queue_outlined,
      enabled: false,
      onPressed: openQueue,
    );
  }

  Widget buildCreatorButton() {
    return JidoujishoIcon(
      icon: Icons.note_add_outlined,
      onPressed: openCreator,
    );
  }

  Widget buildSettingsButton() {
    return JidoujishoIcon(
      icon: Icons.settings_outlined,
      onPressed: openSettings,
    );
  }

  void openQueue() {}
  void openCreator() {}
  void openSettings() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const SettingsPage()));
  }
}

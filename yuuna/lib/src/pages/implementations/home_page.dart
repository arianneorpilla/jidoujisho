import 'package:flutter/material.dart';
import 'package:yuuna/pages.dart';

/// Appears at startup as the portal from which a user may select media and
/// broadly select their activity of choice. The page characteristically has
/// an [AppBar] and a [BottomNavigationBar]
class HomePage extends BasePage {
  /// Construct an instance of the [HomePage].
  const HomePage({Key? key}) : super(key: key);

  @override
  BasePageState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BasePageState<HomePage> {
  int get currentHomeTabIndex => appModel.currentHomeTabIndex;
  late final List<Widget> mediaTypeBodies;
  late final List<BottomNavigationBarItem> navBarItems;

  @override
  void initState() {
    super.initState();

    mediaTypeBodies = List.unmodifiable(
        appModelNoUpdate.mediaTypes.map((mediaType) => mediaType.home));
    navBarItems = List.unmodifiable(
      appModelNoUpdate.mediaTypes.map(
        (mediaType) => BottomNavigationBarItem(
          icon: Icon(mediaType.icon),
          label: appModelNoUpdate.translate(mediaType.uniqueKey),
        ),
      ),
    );
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
    return AppBar();
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
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  void switchTab(int index) async {
    await appModel.setCurrentHomeTabIndex(index);
    setState(() {});
  }
}

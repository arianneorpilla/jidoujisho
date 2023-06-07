import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A template for a single media type's tab body content in the main menu.
/// Has a floating search bar which can be customised depending on the
/// current selected media source.
abstract class BaseTabPage extends BasePage {
  /// Create an instance of this tab page.
  const BaseTabPage({
    super.key,
  });

  @override
  BaseTabPageState<BaseTabPage> createState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
abstract class BaseTabPageState<T extends BaseTabPage> extends BasePageState {
  @override
  void initState() {
    super.initState();
    mediaType.tabRefreshNotifier.addListener(refresh);
  }

  /// Refresh this tab.
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      mediaSource.buildHistoryPage(),
      buildFloatingSearchBar(),
    ]);
  }

  /// Each tab in the home page represents a media type.
  MediaType get mediaType;

  /// Get the active media source for the current media type.
  MediaSource get mediaSource =>
      appModel.getCurrentSourceForMediaType(mediaType: mediaType);

  /// Whether or not the search bar is currently in focus.
  bool _isSearchBarFocused = false;

  /// The search bar to show at the topmost of the tab body. When selected,
  /// [buildSearchBarBody] will take the place of the remainder tab body, or
  /// the elements below the search bar when unselected.
  Widget buildFloatingSearchBar() {
    return mediaSource.buildBar() ??
        FloatingSearchBar(
          isScrollControlled: true,
          hint: mediaSource.getLocalisedSourceName(appModel),
          controller: mediaType.floatingSearchBarController,
          builder: (_, __) => const SizedBox.shrink(),
          borderRadius: BorderRadius.zero,
          elevation: 0,
          backgroundColor: appModel.isDarkMode
              ? const Color.fromARGB(255, 30, 30, 30)
              : const Color.fromARGB(255, 229, 229, 229),
          backdropColor: appModel.isDarkMode ? Colors.black : Colors.white,
          accentColor: theme.colorScheme.primary,
          scrollPadding: const EdgeInsets.only(top: 6, bottom: 56),
          transitionDuration: Duration.zero,
          margins: const EdgeInsets.symmetric(horizontal: 6),
          width: double.maxFinite,
          transition: SlideFadeFloatingSearchBarTransition(),
          automaticallyImplyBackButton: false,
          onFocusChanged: (focused) => onFocusChanged(focused: focused),
          leadingActions: [
            buildChangeSourceButton(),
            buildBackButton(),
          ],
          actions: mediaSource.getActions(
            context: context,
            ref: ref,
            appModel: appModel,
          ),
        );
  }

  /// Respond to tapping to the search bar and execute an action if the source
  /// does not implement search.
  void onFocusChanged({required bool focused}) async {
    _isSearchBarFocused = focused;

    if (!_isSearchBarFocused) {
      mediaType.floatingSearchBarController.close();
      setState(() {});
    } else {
      if (!mediaSource.implementsSearch) {
        final focusScope = FocusScope.of(context);
        await mediaSource.onSearchBarTap(
          context: context,
          ref: ref,
          appModel: appModel,
        );
        mediaType.floatingSearchBarController.clear();
        mediaType.floatingSearchBarController.close();
        setState(() {});
        focusScope.unfocus();
      }
    }
  }

  /// The body to show when the search bar is currently selected.
  Widget buildSearchBarBody(
      BuildContext context, Animation<double> transition) {
    return Container();
  }

  /// Allows user to swap the current active [MediaSource].
  Widget buildChangeSourceButton() {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
        tooltip: t.change_source,
        icon: mediaSource.icon,
        onTap: () async {
          await showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => MediaSourcePickerDialogPage(
              mediaType: mediaType,
            ),
          );
          mediaType.refreshTab();
        },
      ),
    );
  }

  /// Allows user to close the [FloatingSearchBar] when open.
  Widget buildBackButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      showIfClosed: false,
      child: JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
        tooltip: t.back,
        icon: Icons.arrow_back,
        onTap: () {
          mediaType.floatingSearchBarController.close();
        },
      ),
    );
  }
}

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
  /// The message to be shown in the placeholder that displays when
  /// [shouldPlaceholderBeShown] is true. This should be a localised message.
  String get placeholderMessage => appModel.translate('info_empty_home_tab');

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      buildFloatingSearchBar(),
      if (shouldPlaceholderBeShown) buildPlaceholder() else Container()
    ]);
  }

  /// Each tab in the home page represents a media type.
  MediaType get mediaType;

  /// This variable is true when the [buildPlaceholder] should be shown.
  /// For example, if a certain media type does not have any media items to
  /// show in its history.
  bool get shouldPlaceholderBeShown;

  /// This is shown as the body when [shouldPlaceholderBeShown] is true.
  Widget buildPlaceholder() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: mediaType.outlinedIcon,
        message: placeholderMessage,
      ),
    );
  }

  /// The search bar to show at the topmost of the tab body. When selected,
  /// [buildSearchBarBody] will take the place of the remainder tab body, or
  /// the elements below the search bar when unselected.
  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      builder: buildSearchBarBody,
      borderRadius: BorderRadius.zero,
      elevation: 0,
      backgroundColor:
          appModel.isDarkMode ? theme.cardColor : const Color(0xFFE5E5E5),
      backdropColor: appModel.isDarkMode
          ? Colors.black.withOpacity(0.95)
          : Colors.white.withOpacity(0.95),
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: Duration.zero,
      margins: const EdgeInsets.symmetric(horizontal: 6),
      width: double.maxFinite,
      debounceDelay: const Duration(milliseconds: 500),
      transition: SlideFadeFloatingSearchBarTransition(),
      accentColor: theme.focusColor,
      automaticallyImplyBackButton: false,
    );
  }

  /// The body to show when the search bar is currently selected.
  Widget buildSearchBarBody(
      BuildContext context, Animation<double> transition) {
    return Container();
  }
}

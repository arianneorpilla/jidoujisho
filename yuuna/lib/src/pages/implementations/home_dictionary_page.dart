import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The body content for the Dictionary tab in the main menu.
class HomeDictionaryPage extends BaseTabPage {
  /// Create an instance of this page.
  const HomeDictionaryPage({super.key});

  @override
  BaseTabPageState<BaseTabPage> createState() => _HomeDictionaryPageState();
}

class _HomeDictionaryPageState<T extends BaseTabPage> extends BaseTabPageState {
  @override
  MediaType get mediaType => DictionaryMediaType.instance;

  String get backLabel => appModel.translate('back');
  String get dictionariesLabel => appModel.translate('dictionaries');
  String get searchLabel => appModel.translate('search');
  String get searchEllipsisLabel => appModel.translate('search_ellipsis');
  String get noDictionariesLabel =>
      appModel.translate('dictionaries_menu_empty');
  String get noSearchResultsLabel => appModel.translate('no_search_results');
  String get enterSearchTermLabel => appModel.translate('enter_search_term');
  String get clearLabel => appModel.translate('clear');
  String get dialogClearLabel => appModel.translate('dialog_clear');
  String get dialogCancelLabel => appModel.translate('dialog_cancel');
  String get clearDictionaryTitle =>
      appModel.translate('clear_dictionary_title');
  String get clearDictionaryDescription =>
      appModel.translate('clear_dictionary_description');

  final FloatingSearchBarController _controller = FloatingSearchBarController();

  DictionaryResult? _result;

  bool _isSearching = false;

  bool? _lastDarkMode;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appModel.dictionaryNotifier.addListener(searchAgain);
    });
  }

  @override
  void dispose() {
    appModel.dictionaryNotifier.removeListener(searchAgain);
    super.dispose();
  }

  @override
  bool get shouldPlaceholderBeShown => appModel.dictionaryHistory.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (_lastDarkMode != null) {
      if (appModel.isDarkMode != _lastDarkMode) {
        _controller.close();
      }
    }
    _lastDarkMode = appModel.isDarkMode;
    return Stack(children: [
      if (shouldPlaceholderBeShown)
        buildPlaceholder()
      else
        buildDictionaryHistory(),
      buildFloatingSearchBar(),
    ]);
  }

  Widget buildDictionaryHistory() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        const SizedBox(
          height: 60,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: Spacing.of(context).spaces.small,
            right: Spacing.of(context).spaces.small,
          ),
          child: DictionaryHistoryPage(
            onSearch: onSearch,
            onStash: onStash,
          ),
        ),
      ],
    );
  }

  /// The search bar to show at the topmost of the tab body. When selected,
  /// [buildSearchBarBody] will take the place of the remainder tab body, or
  /// the elements below the search bar when unselected.
  @override
  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      hint: searchEllipsisLabel,
      controller: _controller,
      builder: buildFloatingSearchBody,
      borderRadius: BorderRadius.zero,
      elevation: 0,
      backgroundColor:
          appModel.isDarkMode ? theme.cardColor : const Color(0xFFE5E5E5),
      backdropColor: appModel.isDarkMode
          ? Colors.black.withOpacity(0.95)
          : Colors.white.withOpacity(0.95),
      accentColor: theme.colorScheme.primary,
      scrollPadding: const EdgeInsets.only(top: 6, bottom: 56),
      transitionDuration: Duration.zero,
      margins: const EdgeInsets.symmetric(horizontal: 6),
      width: double.maxFinite,
      transition: SlideFadeFloatingSearchBarTransition(),
      debounceDelay: const Duration(milliseconds: 500),
      automaticallyImplyBackButton: false,
      progress: _isSearching,
      leadingActions: [
        buildDictionaryButton(),
        buildBackButton(),
      ],
      actions: [
        buildClearButton(),
        buildSearchButton(),
      ],
      onQueryChanged: onQueryChanged,
    );
  }

  void searchAgain() {
    _result = null;
    onQueryChanged(_controller.query);
  }

  void onQueryChanged(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      _result = await appModel.searchDictionary(query);
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Widget buildDictionaryButton() {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
        tooltip: dictionariesLabel,
        icon: Icons.auto_stories,
        onTap: appModel.showDictionaryMenu,
      ),
    );
  }

  Widget buildBackButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      showIfClosed: false,
      child: JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
        tooltip: backLabel,
        icon: Icons.arrow_back,
        onTap: _controller.close,
      ),
    );
  }

  Widget buildClearButton() {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
        tooltip: clearLabel,
        icon: Icons.clear_all,
        onTap: showDeleteDictionaryPrompt,
      ),
    );
  }

  Widget buildSearchButton() {
    return FloatingSearchBarAction.searchToClear(
      color: theme.appBarTheme.foregroundColor,
      size: textTheme.titleLarge!.fontSize!,
      searchButtonSemanticLabel: searchLabel,
      clearButtonSemanticLabel: clearLabel,
    );
  }

  void showDeleteDictionaryPrompt() async {
    Widget alertDialog = AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal,
      title: Text(clearDictionaryTitle),
      content: Text(
        clearDictionaryDescription,
        textAlign: TextAlign.justify,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            dialogClearLabel,
            style: TextStyle(
              color: theme.colorScheme.primary,
            ),
          ),
          onPressed: () async {
            appModel.clearDictionaryHistory();

            setState(() {});
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(dialogCancelLabel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    await showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  Widget buildFloatingSearchBody(
    BuildContext context,
    Animation<double> transition,
  ) {
    if (appModel.dictionaries.isEmpty) {
      return buildImportDictionariesPlaceholderMessage();
    }
    if (_controller.query.isEmpty) {
      if (appModel.getSearchHistory(historyKey: mediaType.uniqueKey).isEmpty) {
        return buildEnterSearchTermPlaceholderMessage();
      } else {
        return JidoujishoSearchHistory(
          uniqueKey: mediaType.uniqueKey,
          onSearchTermSelect: (searchTerm) {
            setState(() {
              _controller.query = searchTerm;
            });
          },
          onUpdate: () {
            setState(() {});
          },
        );
      }
    }
    if (_isSearching || _result?.searchTerm != _controller.query) {
      if (_result != null) {
        return buildSearchResult();
      } else {
        return const SizedBox.shrink();
      }
    }
    if (_result == null || _result!.mapping.isEmpty) {
      return buildNoSearchResultsPlaceholderMessage();
    }

    return buildSearchResult();
  }

  void onSearch(String searchTerm) {
    appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
    );
  }

  void onStash(String searchTerm) {
    appModel.addToStash(terms: [searchTerm]);
  }

  Widget buildSearchResult() {
    return ClipRect(
      child: DictionaryResultPage(
        onSearch: onSearch,
        onStash: onStash,
        result: _result!,
        getCurrentSearchTerm: () => _controller.query,
      ),
    );
  }

  Widget buildEnterSearchTermPlaceholderMessage() {
    return Padding(
      padding: floatingBodyPadding,
      child: Center(
        child: JidoujishoPlaceholderMessage(
          icon: Icons.search,
          message: enterSearchTermLabel,
        ),
      ),
    );
  }

  Widget buildImportDictionariesPlaceholderMessage() {
    return Padding(
      padding: floatingBodyPadding,
      child: Center(
        child: JidoujishoPlaceholderMessage(
          icon: mediaType.outlinedIcon,
          message: noDictionariesLabel,
        ),
      ),
    );
  }

  Widget buildNoSearchResultsPlaceholderMessage() {
    return Padding(
      padding: floatingBodyPadding,
      child: Center(
        child: JidoujishoPlaceholderMessage(
          icon: Icons.search_off,
          message: noSearchResultsLabel.replaceAll(
            '%searchTerm%',
            _controller.query,
          ),
        ),
      ),
    );
  }
}

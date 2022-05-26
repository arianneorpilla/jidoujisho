import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The page shown after performing a recursive dictionary lookup.
class RecursiveDictionaryPage extends BasePage {
  /// Create an instance of this page.
  const RecursiveDictionaryPage({
    required this.searchTerm,
    required this.killOnPop,
    super.key,
  });

  /// The initial search term that this page searches on initialisation.
  final String searchTerm;

  /// If true, popping will exit the application.
  final bool killOnPop;

  @override
  BasePageState<RecursiveDictionaryPage> createState() =>
      _RecursiveDictionaryPageState();
}

class _RecursiveDictionaryPageState
    extends BasePageState<RecursiveDictionaryPage> {
  String get backLabel => appModel.translate('back');
  String get dictionariesLabel => appModel.translate('dictionaries');
  String get searchLabel => appModel.translate('search');
  String get searchEllipsisLabel => appModel.translate('search_ellipsis');
  String get noDictionariesLabel =>
      appModel.translate('dictionaries_menu_empty');
  String get noSearchResultsLabel => appModel.translate('no_search_results');
  String get enterSearchTermLabel => appModel.translate('enter_search_term');
  String get clearLabel => appModel.translate('clear');
  String get clearSearchTitle => appModel.translate('clear_search_title');
  String get clearSearchDescription =>
      appModel.translate('clear_search_description');
  String get dialogClearLabel => appModel.translate('dialog_clear');
  String get dialogCancelLabel => appModel.translate('dialog_cancel');

  final FloatingSearchBarController _controller = FloatingSearchBarController();

  DictionaryResult? _result;

  bool _isSearching = false;
  @override
  void initState() {
    super.initState();

    _controller.query = widget.searchTerm;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.open();

      Future.delayed(const Duration(milliseconds: 50), () {
        FocusScope.of(context).unfocus();
      });

      appModel.dictionarySearchAgainNotifier.addListener(searchAgain);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: Spacing.of(context).insets.onlyTop.semiSmall,
          child: buildFloatingSearchBar(),
        ),
      ),
    );
  }

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
      backdropColor: Colors.transparent,
      accentColor: theme.colorScheme.primary,
      scrollPadding: const EdgeInsets.only(top: 6, bottom: 56),
      transitionDuration: Duration.zero,
      margins: const EdgeInsets.symmetric(horizontal: 6),
      width: double.maxFinite,
      debounceDelay: const Duration(milliseconds: 200),
      transition: SlideFadeFloatingSearchBarTransition(),
      automaticallyImplyBackButton: false,
      isScrollControlled: true,
      onFocusChanged: (focused) {
        if (!focused) {
          if (widget.killOnPop) {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          } else {
            Navigator.pop(context);
          }
        }
      },
      progress: _isSearching,
      leadingActions: [
        buildDictionaryButton(),
        buildBackButton(),
      ],
      actions: [
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
        tooltip: backLabel,
        icon: Icons.arrow_back,
        onTap: () {
          if (widget.killOnPop) {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          } else {
            Navigator.pop(context);
          }
        },
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

  Widget buildSearchClearButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      showIfClosed: false,
      child: JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
        tooltip: clearLabel,
        icon: Icons.delete_sweep,
        onTap: showDeleteSearchHistoryPrompt,
      ),
    );
  }

  void showDeleteSearchHistoryPrompt() async {
    Widget alertDialog = AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal,
      title: Text(clearSearchTitle),
      content: Text(
        clearSearchDescription,
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
            appModel.clearSearchHistory(
                historyKey: DictionaryMediaType.instance.uniqueKey);

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
      if (appModel
          .getSearchHistory(historyKey: DictionaryMediaType.instance.uniqueKey)
          .isEmpty) {
        return buildEnterSearchTermPlaceholderMessage();
      } else {
        return JidoujishoSearchHistory(
          uniqueKey: DictionaryMediaType.instance.uniqueKey,
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
    if (_result == null || _result!.terms.isEmpty) {
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

  /// Get padding meant for a placeholder message in a floating body.
  EdgeInsets get floatingBodyPadding => EdgeInsets.only(
        top: (MediaQuery.of(context).size.height / 2) -
            (AppBar().preferredSize.height * 2),
      );

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
          icon: Icons.auto_stories,
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

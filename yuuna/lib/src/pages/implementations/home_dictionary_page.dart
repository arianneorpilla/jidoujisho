import 'dart:async';

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

  String get dictionariesLabel => appModel.translate('dictionaries');
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
  String get clearSearchTitle => appModel.translate('clear_search_title');
  String get clearSearchDescription =>
      appModel.translate('clear_search_description');

  /// The message to be shown in the placeholder that displays when
  /// [shouldPlaceholderBeShown] is true. This should be a localised message.
  String get placeholderMessage => appModel.translate('info_empty_home_tab');

  DictionarySearchResult? _result;

  bool _isSearching = false;
  bool _lastOpenedState = false;

  @override
  void initState() {
    super.initState();
    appModelNoUpdate.dictionarySearchAgainNotifier.addListener(searchAgain);
    appModelNoUpdate.dictionaryEntriesNotifier.addListener(() {
      if (mediaType.floatingSearchBarController.isClosed) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool get shouldPlaceholderBeShown => appModel.dictionaryHistory.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      if (shouldPlaceholderBeShown)
        buildPlaceholder()
      else
        buildDictionaryHistory(),
      buildFloatingSearchBar(),
    ]);
  }

  /// This is shown as the body when [shouldPlaceholderBeShown] is true.
  Widget buildPlaceholder() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: mediaType.outlinedIcon,
        message: placeholderMessage,
      ),
    );
  }

  Widget buildDictionaryHistory() {
    if (mediaType.floatingSearchBarController.isOpen) {
      return Container();
    }

    return RawScrollbar(
      thumbVisibility: true,
      thickness: 3,
      controller: DictionaryMediaType.instance.scrollController,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.of(context).spaces.normal,
        ),
        child: DictionaryHistoryPage(
          onSearch: onSearch,
          onStash: onStash,
        ),
      ),
    );
  }

  /// The search bar to show at the topmost of the tab body. When selected,
  /// [buildSearchBarBody] will take the place of the remainder tab body, or
  /// the elements below the search bar when unselected.
  @override
  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      isScrollControlled: true,
      hint: searchEllipsisLabel,
      controller: mediaType.floatingSearchBarController,
      builder: buildFloatingSearchBody,
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
      progress: _isSearching,
      onFocusChanged: (focused) => onFocusChanged(focused: focused),
      onQueryChanged: onQueryChanged,
      onSubmitted: search,
      debounceDelay: Duration(milliseconds: appModel.searchDebounceDelay),
      leadingActions: [
        buildDictionaryButton(),
        buildBackButton(),
      ],
      actions: [
        buildDictionarySettingsButton(),
        buildClearButton(),
        buildSearchClearButton(),
        buildSearchButton(),
      ],
    );
  }

  @override
  void onFocusChanged({required bool focused}) async {
    if (mediaType.floatingSearchBarController.isOpen != _lastOpenedState) {
      _lastOpenedState = mediaType.floatingSearchBarController.isOpen;
      if (!_lastOpenedState) {
        setState(() {});
      }
    }
  }

  void searchAgain() {
    _result = null;
    search(mediaType.floatingSearchBarController.query);
  }

  Duration get historyDelay => const Duration(milliseconds: 500);

  void onQueryChanged(String query) async {
    if (!appModel.autoSearchEnabled) {
      return;
    }

    if (mounted &&
        _result?.searchTerm != query &&
        mediaType.floatingSearchBarController.query == query) {
      search(query);
    }
  }

  String lastQuery = '';

  void search(String query) async {
    if (lastQuery == query) {
      return;
    } else {
      lastQuery = query;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      _result = await appModel.searchDictionary(
        searchTerm: query,
        searchWithWildcards: true,
      );
    } finally {
      if (_result != null) {
        if (_result!.searchTerm ==
            mediaType.floatingSearchBarController.query) {
          Future.delayed(historyDelay, () async {
            if (_result!.searchTerm ==
                mediaType.floatingSearchBarController.query) {
              appModel.addToSearchHistory(
                historyKey: mediaType.uniqueKey,
                searchTerm: mediaType.floatingSearchBarController.query,
              );
              if (_result!.headings.isNotEmpty) {
                appModel.addToDictionaryHistory(result: _result!);
              }
            }
          });

          setState(() {
            _isSearching = false;
          });
        }
      } else {
        setState(() {
          _isSearching = false;
        });
      }
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

  Widget buildClearButton() {
    return FloatingSearchBarAction(
      child: JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
        tooltip: clearDictionaryTitle,
        icon: Icons.delete_sweep,
        onTap: showDeleteDictionaryHistoryPrompt,
      ),
    );
  }

  Widget buildSearchButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      builder: (context, animation) {
        final bar = FloatingSearchAppBar.of(context)!;

        return ValueListenableBuilder<String>(
          valueListenable: bar.queryNotifer,
          builder: (context, query, _) {
            final isEmpty = query.isEmpty;

            return SearchToClear(
              isEmpty: isEmpty,
              size: textTheme.titleLarge!.fontSize!,
              color: bar.style.iconColor,
              duration: const Duration(milliseconds: 900) * 0.5,
              onTap: () {
                if (!isEmpty) {
                  bar.clear();
                } else {
                  bar.isOpen =
                      !bar.isOpen || (!bar.hasFocus && bar.isAlwaysOpened);
                }

                setState(() {});
              },
              searchButtonSemanticLabel: searchLabel,
              clearButtonSemanticLabel: clearLabel,
            );
          },
        );
      },
    );
  }

  Widget buildSearchClearButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      showIfClosed: false,
      child: JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
        tooltip: clearSearchTitle,
        icon: Icons.manage_search,
        onTap: showDeleteSearchHistoryPrompt,
      ),
    );
  }

  /// Dictionary settings bar action.
  Widget buildDictionarySettingsButton() {
    String label = appModel.translate('dictionary_settings');

    return FloatingSearchBarAction(
      showIfOpened: true,
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: label,
        icon: Icons.settings,
        onTap: () async {
          double oldFontSize = appModel.dictionaryFontSize;

          await showDialog(
            context: context,
            builder: (context) => const DictionarySettingsDialogPage(),
          );

          if (appModel.dictionaryFontSize != oldFontSize) {
            appModel.refresh();
          }
        },
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
            mediaType.floatingSearchBarController.clear();

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

  void showDeleteDictionaryHistoryPrompt() async {
    Widget alertDialog = AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal,
      title: Text(clearDictionaryTitle),
      content: Text(
        clearDictionaryDescription,
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
    if (mediaType.floatingSearchBarController.query.isEmpty) {
      if (appModel.getSearchHistory(historyKey: mediaType.uniqueKey).isEmpty) {
        return buildEnterSearchTermPlaceholderMessage();
      } else {
        return JidoujishoSearchHistory(
          uniqueKey: mediaType.uniqueKey,
          onSearchTermSelect: (searchTerm) {
            setState(() {
              mediaType.floatingSearchBarController.query = searchTerm;
              search(searchTerm);
              FocusManager.instance.primaryFocus?.unfocus();
            });
          },
          onUpdate: () {
            setState(() {});
          },
        );
      }
    }
    if (_isSearching ||
        _result?.searchTerm != mediaType.floatingSearchBarController.query) {
      if (_result != null) {
        return buildSearchResult();
      } else {
        return const SizedBox.shrink();
      }
    }
    if (_result == null || _result!.headings.isEmpty) {
      return buildNoSearchResultsPlaceholderMessage();
    }

    return buildSearchResult();
  }

  void onSearch(String searchTerm) async {
    await appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
    );
  }

  void onStash(String searchTerm) {
    appModel.addToStash(terms: [searchTerm]);
  }

  Widget buildSearchResult() {
    return DictionaryResultPage(
      onSearch: onSearch,
      onStash: onStash,
      result: _result!,
    );
  }

  Widget buildEnterSearchTermPlaceholderMessage() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.search,
        message: enterSearchTermLabel,
      ),
    );
  }

  Widget buildImportDictionariesPlaceholderMessage() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: mediaType.outlinedIcon,
        message: noDictionariesLabel,
      ),
    );
  }

  Widget buildNoSearchResultsPlaceholderMessage() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.search_off,
        message: noSearchResultsLabel.replaceAll(
          '%searchTerm%',
          mediaType.floatingSearchBarController.query,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/media/types/dictionary_media_type.dart';
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

  DictionarySearchResult? _result;

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

      appModel.addToSearchHistory(
        historyKey: DictionaryMediaType.instance.uniqueKey,
        searchTerm: widget.searchTerm,
      );

      appModelNoUpdate.dictionarySearchAgainNotifier.addListener(searchAgain);
      search(widget.searchTerm);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
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
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      hint: searchEllipsisLabel,
      controller: _controller,
      builder: buildFloatingSearchBody,
      borderRadius: BorderRadius.zero,
      elevation: 0,
      backgroundColor: appModel.isDarkMode
          ? const Color.fromARGB(255, 30, 30, 30)
          : const Color.fromARGB(255, 229, 229, 229),
      backdropColor: Colors.transparent,
      accentColor: theme.colorScheme.primary,
      scrollPadding: const EdgeInsets.only(top: 6, bottom: 56),
      transitionDuration: Duration.zero,
      margins: const EdgeInsets.symmetric(horizontal: 6),
      width: double.maxFinite,
      transition: SlideFadeFloatingSearchBarTransition(),
      automaticallyImplyBackButton: false,
      isScrollControlled: true,
      debounceDelay: Duration(milliseconds: appModel.searchDebounceDelay),
      onFocusChanged: (focused) {
        if (!focused) {
          if (widget.killOnPop) {
            FlutterExitApp.exitApp();
          } else {
            Navigator.pop(context);
          }
        }
      },
      progress: _isSearching,
      leadingActions: [
        buildBackButton(),
      ],
      actions: [
        buildSegmentButton(),
        buildCreatorButton(),
        buildSearchButton(),
      ],
      onQueryChanged: onQueryChanged,
      onSubmitted: search,
    );
  }

  void searchAgain() {
    _result = null;
    search(_controller.query);
  }

  Duration get historyDelay => Duration.zero;

  void onQueryChanged(String query) async {
    if (!appModel.autoSearchEnabled) {
      return;
    }

    if (mounted &&
        _result?.searchTerm != query &&
        _controller.query == query &&
        !_isSearching) {
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
        if (_result!.searchTerm == _controller.query) {
          Future.delayed(historyDelay, () async {
            if (_result!.searchTerm == _controller.query) {
              appModel.addToSearchHistory(
                historyKey: DictionaryMediaType.instance.uniqueKey,
                searchTerm: _controller.query,
              );
            }
            if (_result!.headings.isNotEmpty) {
              appModel.addToDictionaryHistory(result: _result!);
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

  Widget buildBackButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      showIfClosed: false,
      child: JidoujishoIconButton(
        tooltip: backLabel,
        icon: Icons.arrow_back,
        onTap: () async {
          if (widget.killOnPop) {
            FlutterExitApp.exitApp();
          } else {
            Navigator.pop(context);
          }
        },
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

  Widget buildSegmentButton() {
    String label = appModel.translate('text_segmentation');

    return FloatingSearchBarAction(
      showIfOpened: true,
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: label,
        icon: Icons.account_tree,
        onTap: () {
          appModel.openTextSegmentationDialog(
            sourceText: _controller.query,
            onSearch: (selection, items) async {
              await appModel.openRecursiveDictionarySearch(
                searchTerm: selection,
                killOnPop: false,
              );
            },
          );
        },
      ),
    );
  }

  Widget buildCreatorButton() {
    String label = appModel.translate('card_creator');

    return FloatingSearchBarAction(
      showIfOpened: true,
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: label,
        icon: Icons.note_add,
        onTap: () {
          appModel.openCreator(
            killOnPop: false,
            ref: ref,
            creatorFieldValues: CreatorFieldValues(
              textValues: {
                SentenceField.instance: _controller.query,
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildSearchClearButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      showIfClosed: false,
      child: JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
        tooltip: clearLabel,
        icon: Icons.manage_search,
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
            _controller.clear();

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
    if (_isSearching || _result?.searchTerm != _controller.query) {
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
    return DictionaryResultPage(
      onSearch: onSearch,
      onStash: onStash,
      result: _result!,
    );
  }

  /// Get padding meant for a placeholder message in a floating body.
  EdgeInsets get floatingBodyPadding => EdgeInsets.only(
        top: (MediaQuery.of(context).size.height / 2) -
            (AppBar().preferredSize.height * 2),
      );

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
        icon: Icons.auto_stories_rounded,
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
          _controller.query,
        ),
      ),
    );
  }
}

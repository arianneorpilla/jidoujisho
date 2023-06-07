import 'package:flutter/material.dart';
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
    this.onUpdateQuery,
    super.key,
  });

  /// The initial search term that this page searches on initialisation.
  final String searchTerm;

  /// If true, popping will exit the application.
  final bool killOnPop;

  /// Used to track changes to the query.
  final Function(String)? onUpdateQuery;

  @override
  BasePageState<RecursiveDictionaryPage> createState() =>
      _RecursiveDictionaryPageState();
}

class _RecursiveDictionaryPageState
    extends BasePageState<RecursiveDictionaryPage> {
  final FloatingSearchBarController _controller = FloatingSearchBarController();

  DictionarySearchResult? _result;

  bool _isSearching = false;
  late bool _isCreatorOpen;

  @override
  void initState() {
    super.initState();

    _isCreatorOpen = appModelNoUpdate.isCreatorOpen;

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
    if (!appModel.isDatabaseOpen) {
      return const SizedBox.shrink();
    }

    Color? backgroundColor = theme.colorScheme.background;
    if (appModel.overrideDictionaryColor != null && !_isCreatorOpen) {
      if ((appModel.overrideDictionaryTheme ?? theme).brightness ==
          Brightness.dark) {
        backgroundColor =
            JidoujishoColor.lighten(appModel.overrideDictionaryColor!, 0.025);
      } else {
        backgroundColor =
            JidoujishoColor.darken(appModel.overrideDictionaryColor!, 0.025);
      }
    }

    return Theme(
      data: !_isCreatorOpen ? appModel.overrideDictionaryTheme ?? theme : theme,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: Spacing.of(context).insets.onlyTop.semiSmall,
            child: buildFloatingSearchBar(),
          ),
        ),
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    Color? backgroundColor = appModel.isDarkMode
        ? const Color.fromARGB(255, 30, 30, 30)
        : const Color.fromARGB(255, 229, 229, 229);
    if (appModel.overrideDictionaryColor != null && !_isCreatorOpen) {
      if ((appModel.overrideDictionaryTheme ?? theme).brightness ==
          Brightness.dark) {
        backgroundColor =
            JidoujishoColor.lighten(appModel.overrideDictionaryColor!, 0.05);
      } else {
        backgroundColor =
            JidoujishoColor.darken(appModel.overrideDictionaryColor!, 0.05);
      }
    }

    return FloatingSearchBar(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      hint: t.search_ellipsis,
      controller: _controller,
      builder: buildFloatingSearchBody,
      borderRadius: BorderRadius.zero,
      elevation: 0,
      backgroundColor: backgroundColor,
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
            appModel.shutdown();
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

    if (mounted) {
      search(query);
    }
  }

  bool _showMore = false;

  void search(
    String query, {
    int? overrideMaximumTerms,
  }) async {
    overrideMaximumTerms ??= appModel.maximumTerms;

    if (mounted) {
      setState(() {
        _isSearching = true;
      });
    }

    try {
      _result = await appModel.searchDictionary(
        searchTerm: query,
        searchWithWildcards: true,
        overrideMaximumTerms: overrideMaximumTerms,
      );
    } finally {
      if (_result != null) {
        if (query == _controller.query) {
          if (mounted) {
            setState(() {
              _isSearching = false;
              _showMore = _result!.headings.length < overrideMaximumTerms!;
            });
          }
          Future.delayed(historyDelay, () async {
            if (query == _controller.query) {
              appModel.addToSearchHistory(
                historyKey: DictionaryMediaType.instance.uniqueKey,
                searchTerm: _controller.query,
              );
            }
            if (_result!.headings.isNotEmpty) {
              appModel.addToDictionaryHistory(result: _result!);
            }
          });
        }
      }
    }
  }

  Widget buildBackButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      showIfClosed: false,
      child: JidoujishoIconButton(
        tooltip: t.back,
        icon: Icons.arrow_back,
        onTap: () async {
          if (widget.killOnPop) {
            appModel.shutdown();
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
              searchButtonSemanticLabel: t.search,
              clearButtonSemanticLabel: t.clear,
            );
          },
        );
      },
    );
  }

  @override
  void onSearch(String searchTerm, {String? sentence = ''}) async {
    await appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
      onUpdateQuery: widget.onUpdateQuery,
    );
  }

  Widget buildSegmentButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.text_segmentation,
        icon: Icons.account_tree,
        onTap: () async {
          await appModel.openTextSegmentationDialog(
            sourceText: _controller.query,
            onSearch: (selection) async {
              await appModel.openRecursiveDictionarySearch(
                searchTerm: selection.textInside,
                killOnPop: false,
                onUpdateQuery: widget.onUpdateQuery,
              );
            },
          );

          widget.onUpdateQuery?.call(_controller.query);
        },
      ),
    );
  }

  Widget buildCreatorButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      child: JidoujishoIconButton(
        size: Theme.of(context).textTheme.titleLarge?.fontSize,
        tooltip: t.card_creator,
        icon: Icons.note_add,
        onTap: () {
          appModel.openCreator(
            killOnPop: false,
            ref: ref,
            creatorFieldValues: CreatorFieldValues(
              textValues: {
                SentenceField.instance: _controller.query,
                TermField.instance: '',
                ClozeBeforeField.instance: '',
                ClozeInsideField.instance: '',
                ClozeAfterField.instance: '',
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
        tooltip: t.clear,
        icon: Icons.manage_search,
        onTap: showDeleteSearchHistoryPrompt,
      ),
    );
  }

  void showDeleteSearchHistoryPrompt() async {
    Widget alertDialog = AlertDialog(
      title: Text(t.clear_search_title),
      content: Text(t.clear_browser_description),
      actions: <Widget>[
        TextButton(
          child: Text(
            t.dialog_clear,
            style: TextStyle(
              color: theme.colorScheme.primary,
            ),
          ),
          onPressed: () async {
            appModel.clearSearchHistory(
                historyKey: DictionaryMediaType.instance.uniqueKey);
            _controller.clear();

            if (mounted) {
              Navigator.pop(context);
              setState(() {});
            }
          },
        ),
        TextButton(
          child: Text(t.dialog_cancel),
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
    if (_isSearching) {
      if (_result != null) {
        if (_result!.headings.isNotEmpty) {
          return buildSearchResult();
        } else {
          return buildNoSearchResultsPlaceholderMessage();
        }
      } else {
        return const SizedBox.shrink();
      }
    }
    if (_result == null || _result!.headings.isEmpty) {
      return buildNoSearchResultsPlaceholderMessage();
    }

    return buildSearchResult();
  }

  Widget buildSearchResult() {
    Color? cardColor;
    if (!_isCreatorOpen) {
      cardColor = appModel.overrideDictionaryColor?.withOpacity(1);
    }

    return DictionaryResultPage(
      cardColor: cardColor,
      onSearch: onSearch,
      onStash: onStash,
      onShare: onShare,
      result: _result!,
      footerWidget: footerWidget,
    );
  }

  Widget? get footerWidget {
    if (_showMore) {
      return null;
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: Spacing.of(context).insets.all.small,
        child: Tooltip(
          message: t.show_more,
          child: InkWell(
            onTap: _isSearching
                ? null
                : () async {
                    search(
                      _controller.query,
                      overrideMaximumTerms:
                          _result!.headingIds.length + appModel.maximumTerms,
                    );
                  },
            child: Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              width: double.maxFinite,
              child: Padding(
                padding: Spacing.of(context).insets.all.normal,
                child: Text(
                  t.show_more,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (textTheme.labelMedium?.fontSize)! * 0.9,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
        message: t.enter_search_term,
      ),
    );
  }

  Widget buildImportDictionariesPlaceholderMessage() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.auto_stories_rounded,
        message: t.dictionaries_menu_empty,
      ),
    );
  }

  Widget buildNoSearchResultsPlaceholderMessage() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.search_off,
        message: t.no_search_results,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The search bar used for the home page when a certain source is enabled.
abstract class BaseMediaSearchBar extends BaseTabPage {
  /// Create an instance of this bar.
  const BaseMediaSearchBar({super.key});
}

/// State for [BaseMediaSearchBar].
abstract class BaseMediaSearchBarState<T extends BaseMediaSearchBar>
    extends BaseTabPageState {
  /// The paging controller which holds the media items for the search.
  PagingController<int, MediaItem>? pagingController;

  bool _isSearching = false;

  final ScrollController _scrollController = ScrollController();
  List<String> _searchSuggestions = [];

  /// Search delay upon submit.
  Duration get searchDelay;

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
        isScrollControlled: true,
        hint: mediaSource.getLocalisedSourceName(appModel),
        controller: mediaType.floatingSearchBarController,
        onSubmitted: onSubmitted,
        onQueryChanged: onQueryChanged,
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
        progress: _isSearching,
        width: double.maxFinite,
        transition: SlideFadeFloatingSearchBarTransition(),
        automaticallyImplyBackButton: false,
        onFocusChanged: (focused) => onFocusChanged(focused: focused),
        leadingActions: [
          buildChangeSourceButton(),
          buildBackButton(),
        ],
        actions: [
          buildSearchClearButton(),
          ...mediaSource.getActions(
            context: context,
            ref: ref,
            appModel: appModel,
          ),
          buildSearchButton(),
        ]);
  }

  /// Called when the user has submitted the search query.
  void onSubmitted(String query) async {
    query = query.trim();

    if (!_isSearching) {
      pagingController = null;

      setState(() {
        _isSearching = true;
      });

      pagingController = PagingController(firstPageKey: 1);
      try {
        List<MediaItem>? newItems = await mediaSource.searchMediaItems(
          context: context,
          searchTerm: query,
          pageKey: 1,
        );
        if (newItems != null && newItems.isNotEmpty) {
          pagingController?.appendPage(newItems, 2);
        }
      } catch (e) {
        pagingController?.appendLastPage([]);
      }
      pagingController?.addPageRequestListener((pageKey) async {
        try {
          List<MediaItem>? newItems = await mediaSource.searchMediaItems(
            context: context,
            searchTerm: query,
            pageKey: pageKey,
          );
          if (newItems != null && newItems.isNotEmpty) {
            pagingController?.appendPage(newItems, pageKey);
          }
        } catch (e) {
          pagingController?.appendLastPage([]);
        }
      });
      appModel.addToSearchHistory(
        historyKey: mediaSource.uniqueKey,
        searchTerm: mediaType.floatingSearchBarController.query,
      );

      setState(() {
        _isSearching = false;
      });
    }
  }

  /// Called when the search bar query has changed.
  void onQueryChanged(String query) async {
    query = query.trim();
    pagingController = null;

    if (query.isEmpty) {
      _searchSuggestions = [];
      _isSearching = false;
      setState(() {});
      return;
    }

    mediaSource.generateSearchSuggestions(query).then((newSuggestions) {
      _searchSuggestions = newSuggestions;
      setState(() {});
    });
  }

  /// Changes between search and clear when focused.
  Widget buildSearchButton() {
    return FloatingSearchBarAction.searchToClear(
      color: theme.appBarTheme.foregroundColor,
      size: textTheme.titleLarge!.fontSize!,
      searchButtonSemanticLabel: t.search,
      clearButtonSemanticLabel: t.clear,
    );
  }

  /// Shows when the user has focused the search bar.
  Widget buildSearchClearButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      showIfClosed: false,
      child: JidoujishoIconButton(
        size: textTheme.titleLarge?.fontSize,
        tooltip: t.clear_search_title,
        icon: Icons.manage_search,
        onTap: showDeleteSearchHistoryPrompt,
      ),
    );
  }

  /// Shows when the clear search history is shown.
  void showDeleteSearchHistoryPrompt() async {
    Widget alertDialog = AlertDialog(
      title: Text(t.clear_search_title),
      content: Text(
        t.clear_search_description,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            t.dialog_clear,
            style: TextStyle(
              color: theme.colorScheme.primary,
            ),
          ),
          onPressed: () async {
            appModel.clearSearchHistory(historyKey: mediaSource.uniqueKey);
            mediaType.floatingSearchBarController.clear();

            setState(() {});
            Navigator.pop(context);
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

  /// Shows when the user taps on the floating search bar.
  Widget buildFloatingSearchBody(
    BuildContext context,
    Animation<double> transition,
  ) {
    String query = mediaType.floatingSearchBarController.query.trim();

    if (query.isEmpty) {
      List<String> searchHistory =
          appModel.getSearchHistory(historyKey: mediaSource.uniqueKey);

      if (searchHistory.isEmpty) {
        return buildEnterSearchTermPlaceholderMessage();
      } else {
        return JidoujishoSearchHistory(
          uniqueKey: mediaSource.uniqueKey,
          onSearchTermSelect: (searchTerm) {
            setState(() {
              mediaType.floatingSearchBarController.query = searchTerm;
            });
          },
          onUpdate: () {
            setState(() {});
          },
        );
      }
    }

    if (_isSearching || pagingController == null) {
      return JidoujishoSearchHistory(
        uniqueKey: mediaSource.uniqueKey,
        searchSuggestions: _searchSuggestions,
        onSearchTermSelect: (searchTerm) {
          setState(() {
            mediaType.floatingSearchBarController.query = searchTerm;
          });
        },
        onUpdate: () {
          setState(() {});
        },
      );
    }

    if (pagingController!.itemList != null) {
      return RawScrollbar(
        thickness: 3,
        thumbVisibility: true,
        controller: _scrollController,
        child: buildResultList(),
      );
    }

    return buildNoSearchResultsPlaceholderMessage();
  }

  /// Shows when there are proper search results returned.
  Widget buildResultList() {
    throw UnimplementedError();
  }

  /// Shows when the search term is empty and there is nothing in search history.
  Widget buildEnterSearchTermPlaceholderMessage() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.search,
        message: t.enter_search_term,
      ),
    );
  }

  /// Shows when the media item search has returned no items.
  Widget buildNoSearchResultsPlaceholderMessage() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.search_off,
        message: t.no_search_results,
      ),
    );
  }
}

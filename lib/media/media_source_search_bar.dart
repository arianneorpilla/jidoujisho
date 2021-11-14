import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/center_icon_message.dart';

class MediaSourceSearchBar extends StatefulWidget {
  const MediaSourceSearchBar({
    required this.appModel,
    required this.mediaSource,
    required this.refreshCallback,
    Key? key,
  }) : super(key: key);
  final AppModel appModel;
  final MediaSource mediaSource;
  final Function() refreshCallback;

  @override
  State<StatefulWidget> createState() => MediaSourceSearchBarState();
}

class MediaSourceSearchBarState extends State<MediaSourceSearchBar> {
  late AppModel appModel;
  late MediaSource mediaSource;

  int selectedIndex = 0;
  bool isSearching = false;
  bool isFocus = false;

  PagingController<int, MediaHistoryItem>? pagingController;

  List<MediaHistoryItem>? searchResultItems;
  List<String> searchSuggestions = [];

  FloatingSearchBarController searchBarController =
      FloatingSearchBarController();

  @override
  void initState() {
    super.initState();
    appModel = widget.appModel;
    mediaSource = widget.mediaSource;
  }

  Widget buildPlaceholderMessage({
    required String label,
    required IconData icon,
    bool jumpingDots = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).size.height / 7),
      child: showCenterIconMessage(
        context: context,
        label: label,
        icon: icon,
        jumpingDots: jumpingDots,
      ),
    );
  }

  Widget buildSearchSuggestions() {
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: Material(
        color: Colors.transparent,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: searchSuggestions.length,
          shrinkWrap: true,
          itemExtent: 48,
          itemBuilder: (context, i) {
            String searchTerm = searchSuggestions[i];
            return buildSearchHistoryItem(searchTerm);
          },
        ),
      ),
    );
  }

  Widget buildSearchHistoryItem(String historyItem) {
    return InkWell(
      onTap: () {
        searchBarController.query = historyItem;
      },
      onLongPress: () async {
        if (searchBarController.query.isEmpty) {
          await appModel.removeFromSearchHistory(historyItem,
              historyType: mediaSource.getIdentifier());
          searchSuggestions = appModel
              .getSearchHistory(historyType: mediaSource.getIdentifier())
              .reversed
              .toList();
          setState(() {});
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 24, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.history,
                size: 17,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                historyItem,
                style: const TextStyle(
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ScrollController scrollController = ScrollController();

  Future<void> onFocusChanged(bool focus) async {
    isFocus = focus;

    if (!isFocus) {
      searchBarController.close();
      setState(() {});

      widget.refreshCallback();
    } else {
      if (mediaSource.noSearchAction) {
        await mediaSource.onSearchBarTap(context);
        searchBarController.close();
        setState(() {});
      }
    }

    pagingController = null;
  }

  Future<void> onQueryChanged(String query) async {
    pagingController = null;

    if (query.isEmpty) {
      searchSuggestions = [];
      setState(() {});
      return;
    }

    mediaSource.generateSearchSuggestions(query).then((newSuggestions) {
      searchSuggestions = newSuggestions;
      setState(() {});
    });

    if (!isSearching) {
      String before = query;

      await Future.delayed(const Duration(milliseconds: 500), () async {
        String after = searchBarController.query;
        if (before == after) {
          setState(() {
            isSearching = true;
          });

          await Future.delayed(
              Duration(milliseconds: mediaSource.getSearchDebounceDelay));
          pagingController = PagingController(firstPageKey: 1);
          try {
            List<MediaHistoryItem>? newItems =
                await mediaSource.getSearchMediaHistoryItems(query, 1);
            if (newItems != null && newItems.isNotEmpty) {
              pagingController!.appendPage(newItems, 2);
            }
          } catch (e) {
            pagingController!.appendLastPage([]);
          }
          pagingController!.addPageRequestListener((pageKey) async {
            try {
              List<MediaHistoryItem>? newItems =
                  await mediaSource.getSearchMediaHistoryItems(query, pageKey);
              if (newItems != null && newItems.isNotEmpty) {
                pagingController!.appendPage(newItems, pageKey + 1);
              }
            } catch (e) {
              pagingController!.appendLastPage([]);
            }
          });
          appModel.addToSearchHistory(query,
              historyType: mediaSource.getIdentifier());

          setState(() {
            isSearching = false;
          });
        }
      });
    }
  }

  Future<void> onSubmitted(String query) async {
    if (!isSearching) {
      pagingController = null;

      setState(() {
        isSearching = true;
      });

      await Future.delayed(
          Duration(milliseconds: mediaSource.getSearchDebounceDelay));
      pagingController = PagingController(firstPageKey: 1);
      try {
        List<MediaHistoryItem>? newItems =
            await mediaSource.getSearchMediaHistoryItems(query, 1);
        if (newItems != null && newItems.isNotEmpty) {
          pagingController!.appendPage(newItems, 2);
        }
      } catch (e) {
        pagingController!.appendLastPage([]);
      }
      pagingController!.addPageRequestListener((pageKey) async {
        try {
          List<MediaHistoryItem>? newItems =
              await mediaSource.getSearchMediaHistoryItems(query, pageKey);
          if (newItems != null && newItems.isNotEmpty) {
            pagingController!.appendPage(newItems, pageKey + 1);
          }
        } catch (e) {
          pagingController!.appendLastPage([]);
        }
      });
      appModel.addToSearchHistory(query,
          historyType: mediaSource.getIdentifier());

      setState(() {
        isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    mediaSource = appModel.getCurrentMediaTypeSource(mediaSource.mediaType);

    return FloatingSearchBar(
      controller: searchBarController,
      hint: mediaSource.sourceName,
      borderRadius: BorderRadius.zero,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: Duration.zero,
      margins: const EdgeInsets.symmetric(horizontal: 6),
      physics: const BouncingScrollPhysics(),
      openAxisAlignment: 0.0,
      height: 48,
      width: double.maxFinite,
      closeOnBackdropTap: true,
      debounceDelay: Duration.zero,
      showCursor: !mediaSource.noSearchAction,
      elevation: 0,
      progress: isSearching,
      transition: SlideFadeFloatingSearchBarTransition(),
      onSubmitted: onSubmitted,
      onFocusChanged: onFocusChanged,
      backgroundColor: (appModel.getIsDarkMode())
          ? Theme.of(context).cardColor
          : const Color(0xFFE5E5E5),
      backdropColor: (appModel.getIsDarkMode())
          ? Colors.black.withOpacity(0.95)
          : Colors.white.withOpacity(0.95),
      clearQueryOnClose: true,
      accentColor: Theme.of(context).focusColor,
      onQueryChanged: onQueryChanged,
      leadingActions: [
        buildSourceButton(),
      ],
      automaticallyImplyBackButton: false,
      actions: getAllActions(),
      isScrollControlled: true,
      builder: (context, transition) {
        if (mediaSource.noSearchAction) {
          return Container();
        }

        if (searchSuggestions.isEmpty) {
          searchSuggestions = appModel
              .getSearchHistory(historyType: mediaSource.getIdentifier())
              .reversed
              .toList();
        }

        if (searchBarController.query.isEmpty && searchSuggestions.isEmpty) {
          return buildPlaceholderMessage(
            label: appModel.translate("enter_a_search_term"),
            icon: Icons.search,
          );
        } else if (pagingController == null) {
          return buildSearchSuggestions();
        }

        if (pagingController!.itemList != null &&
            pagingController!.itemList!.isEmpty) {
          return buildPlaceholderMessage(
            label:
                "${appModel.translate("dictionary_nomatch_before")}『${searchBarController.query}』${appModel.translate("dictionary_nomatch_after")}",
            icon: Icons.search_off,
          );
        }

        if (pagingController!.itemList != null || isSearching) {
          return RawScrollbar(
            controller: scrollController,
            thumbColor: (appModel.getIsDarkMode())
                ? Colors.grey[700]
                : Colors.grey[400],
            child: mediaSource.getDisplayLayout(
              appModel: appModel,
              context: context,
              homeRefreshCallback: widget.refreshCallback,
              searchRefreshCallback: () {
                setState(() {});
              },
              scrollController: scrollController,
              pagingController: pagingController!,
            ),
          );
        }

        return buildPlaceholderMessage(
          label:
              "${appModel.translate("dictionary_nomatch_before")}『${searchBarController.query}』${appModel.translate("dictionary_nomatch_after")}",
          icon: Icons.search_off,
        );
      },
    );
  }

  Widget buildSourceButton() {
    return FloatingSearchBarAction(
      showIfOpened: true,
      child: CircularButton(
        icon: Icon(
          mediaSource.icon,
          size: 20,
          color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
        ),
        onPressed: () async {
          await appModel.showSourcesMenu(
            context: context,
            mediaType: mediaSource.mediaType,
          );
          if (mediaSource.noSearchAction && searchBarController.isOpen) {
            searchBarController.close();
            widget.refreshCallback();
          }
          setState(() {});
        },
      ),
    );
  }

  List<Widget> getAllActions() {
    List<Widget> actions = [];
    actions.addAll(
        mediaSource.getSearchBarActions(context, widget.refreshCallback));
    if (!mediaSource.noSearchAction) {
      actions.add(
        FloatingSearchBarAction.searchToClear(
          size: 20,
          duration: Duration.zero,
          showIfClosed: true,
          color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
        ),
      );
    }
    return actions;
  }
}

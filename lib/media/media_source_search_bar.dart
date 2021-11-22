import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/util/media_source_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/center_icon_message.dart';

class MediaSourceSearchBar extends StatefulWidget {
  const MediaSourceSearchBar({
    required this.appModel,
    required this.mediaSource,
    required this.refreshCallback,
    required this.searchBarController,
    Key? key,
  }) : super(key: key);
  final AppModel appModel;
  final MediaSource mediaSource;
  final Function() refreshCallback;
  final FloatingSearchBarController searchBarController;

  @override
  State<StatefulWidget> createState() => MediaSourceSearchBarState();
}

class MediaSourceSearchBarState extends State<MediaSourceSearchBar> {
  late AppModel appModel;
  late MediaSource mediaSource;
  late FloatingSearchBarController searchBarController;

  int selectedIndex = 0;
  bool isSearching = false;
  bool isFocus = false;

  PagingController<int, MediaHistoryItem>? pagingController;

  List<MediaHistoryItem>? searchResultItems;
  List<String> searchSuggestions = [];

  @override
  void initState() {
    super.initState();
    appModel = widget.appModel;
    mediaSource = widget.mediaSource;
    searchBarController = widget.searchBarController;
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
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
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
        searchBarController.clear();
        searchBarController.close();
        setState(() {});
        FocusScope.of(context).unfocus();
      }
    }

    pagingController = null;
  }

  Future<void> onQueryChanged(String query) async {
    if (mediaSource.isDirectTextEntry) {
      return;
    }

    query = query.trim();
    pagingController = null;

    if (query.isEmpty) {
      searchSuggestions = [];
      isSearching = false;
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
                await mediaSource.getSearchMediaHistoryItems(
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
              List<MediaHistoryItem>? newItems =
                  await mediaSource.getSearchMediaHistoryItems(
                context: context,
                searchTerm: query,
                pageKey: pageKey,
              );
              if (newItems != null && newItems.isNotEmpty) {
                pagingController?.appendPage(newItems, pageKey + 1);
              }
            } catch (e) {
              pagingController?.appendLastPage([]);
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
    if (mediaSource.isDirectTextEntry) {
      appModel.addToSearchHistory(query,
          historyType: mediaSource.getIdentifier());
      await mediaSource.onDirectTextEntrySubmit(
          context, searchBarController.query);

      searchBarController.clear();
      return;
    }

    query = query.trim();

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
            await mediaSource.getSearchMediaHistoryItems(
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
          List<MediaHistoryItem>? newItems =
              await mediaSource.getSearchMediaHistoryItems(
            context: context,
            searchTerm: query,
            pageKey: pageKey,
          );
          if (newItems != null && newItems.isNotEmpty) {
            pagingController?.appendPage(newItems, pageKey + 1);
          }
        } catch (e) {
          pagingController?.appendLastPage([]);
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
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      clearQueryOnClose: true,
      accentColor: Theme.of(context).focusColor,
      onQueryChanged: onQueryChanged,
      leadingActions: [
        buildSourceButton(),
        if (!mediaSource.noSearchAction) buildBackButton(),
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
          if (mediaSource.isDirectTextEntry) {
            return buildPlaceholderMessage(
              label: appModel.translate("enter_a_link"),
              icon: Icons.subdirectory_arrow_left,
            );
          } else {
            return buildPlaceholderMessage(
              label: appModel.translate("enter_a_search_term"),
              icon: Icons.search,
            );
          }
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
      showIfOpened: mediaSource.noSearchAction,
      showIfClosed: true,
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
          mediaSource =
              appModel.getCurrentMediaTypeSource(mediaSource.mediaType);
          if (mediaSource.noSearchAction && searchBarController.isOpen) {
            searchBarController.clear();
            searchBarController.close();
            widget.refreshCallback();
            FocusScope.of(context).unfocus();
          }
          setState(() {});
        },
      ),
    );
  }

  Widget buildBackButton() {
    return FloatingSearchBarAction.back(
      showIfClosed: false,
      color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
      size: 20,
    );
  }

  List<Widget> getAllActions() {
    List<Widget> actions = [];

    actions.addAll(
        mediaSource.getSearchBarActions(context, widget.refreshCallback));

    if (mediaSource.isDirectTextEntry) {
      actions.add(
        MediaSourceActionButton(
          context: context,
          source: mediaSource,
          refreshCallback: widget.refreshCallback,
          icon: Icons.paste,
          showIfClosed: false,
          showIfOpened: true,
          onPressed: () async {
            ClipboardData? clipboardData =
                await Clipboard.getData('text/plain');
            setState(() {
              if (clipboardData != null && clipboardData.text != null) {
                searchBarController.query = clipboardData.text!;
              }
            });
          },
        ),
      );

      actions.add(
        MediaSourceActionButton(
          context: context,
          source: mediaSource,
          refreshCallback: widget.refreshCallback,
          icon: Icons.subdirectory_arrow_left,
          showIfClosed: true,
          showIfOpened: true,
          onPressed: () async {
            appModel.addToSearchHistory(searchBarController.query,
                historyType: mediaSource.getIdentifier());
            await mediaSource.onDirectTextEntrySubmit(
                context, searchBarController.query);

            searchBarController.clear();
          },
        ),
      );
    } else if (!mediaSource.noSearchAction) {
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

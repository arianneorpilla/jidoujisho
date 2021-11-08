import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:flutter/material.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:chisa/dictionary/dictionary_search_result.dart';
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
      onLongPress: () {
        appModel.removeFromSearchHistory(historyItem);
        setState(() {});
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
            Text(
              historyItem,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      controller: searchBarController,
      hint: widget.mediaSource.sourceName,
      borderRadius: BorderRadius.zero,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: Duration.zero,
      margins: const EdgeInsets.symmetric(horizontal: 6),
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      height: 48,
      closeOnBackdropTap: true,
      debounceDelay: Duration.zero,
      elevation: 0,
      progress: isSearching,
      transition: SlideFadeFloatingSearchBarTransition(),
      onSubmitted: (query) async {
        if (!isSearching) {
          setState(() {
            isSearching = true;
          });

          searchResultItems =
              await mediaSource.getSearchMediaHistoryItems(query);
          appModel.addToSearchHistory(query,
              historyType: widget.mediaSource.getIdentifier());

          setState(() {
            isSearching = false;
          });
        }
      },
      onFocusChanged: (focus) async {
        isFocus = focus;

        if (!isFocus) {
          searchBarController.close();
          setState(() {});

          widget.refreshCallback();
        } else {
          if (widget.mediaSource.noSearchAction) {
            await widget.mediaSource.onSearchBarTap(context);
            searchBarController.close();
            setState(() {});
          }
        }

        searchResultItems = null;
      },
      backgroundColor: (appModel.getIsDarkMode())
          ? Theme.of(context).cardColor
          : const Color(0xFFE5E5E5),
      backdropColor: (appModel.getIsDarkMode())
          ? Colors.black.withOpacity(0.95)
          : Colors.white.withOpacity(0.95),
      clearQueryOnClose: true,
      accentColor: Theme.of(context).focusColor,
      onQueryChanged: (query) async {
        if (query.isEmpty) {
          searchResultItems = null;
          searchSuggestions = [];
          setState(() {});
          return;
        }

        mediaSource.generateSearchSuggestions(query).then((newSuggestions) {
          searchSuggestions = newSuggestions;
        });
      },
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
          searchSuggestions = appModel.getSearchHistory().reversed.toList();
        }

        if (searchBarController.query.isEmpty && searchSuggestions.isEmpty) {
          return buildPlaceholderMessage(
            label: appModel.translate("enter_a_search_term"),
            icon: Icons.search,
          );
        } else if (searchResultItems == null) {
          return buildSearchSuggestions();
        }

        return RawScrollbar(
          controller: scrollController,
          thumbColor:
              (appModel.getIsDarkMode()) ? Colors.grey[700] : Colors.grey[400],
          child: mediaSource.getDisplayLayout(
            appModel: appModel,
            context: context,
            refreshCallback: widget.refreshCallback,
            scrollController: scrollController,
            items: searchResultItems!,
          ),
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
            mediaType: widget.mediaSource.mediaType,
          );
          widget.refreshCallback();
        },
      ),
    );
  }

  List<Widget> getAllActions() {
    List<Widget> actions = [];
    actions.addAll(widget.mediaSource
        .getSearchBarActions(context, widget.refreshCallback));
    actions.add(
      FloatingSearchBarAction.searchToClear(
        size: 20,
        duration: Duration.zero,
        showIfClosed: true,
        color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
      ),
    );
    return actions;
  }
}

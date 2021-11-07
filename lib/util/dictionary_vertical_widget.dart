import 'dart:ui';

import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/center_icon_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class DictionaryVerticalWidget extends StatefulWidget {
  const DictionaryVerticalWidget({
    required this.appModel,
    required this.refreshCallback,
    Key? key,
  }) : super(key: key);

  final AppModel appModel;
  final Function() refreshCallback;

  @override
  State<StatefulWidget> createState() => DictionaryVerticalWidgetState();
}

class DictionaryVerticalWidgetState extends State<DictionaryVerticalWidget> {
  late AppModel appModel;
  FloatingSearchBarController searchBarController =
      FloatingSearchBarController();

  DictionarySearchResult? searchResult;
  int selectedIndex = 0;
  bool isSearching = false;
  bool isFocus = false;

  @override
  void initState() {
    super.initState();
    appModel = widget.appModel;
  }

  setSearchResult(DictionarySearchResult result) {
    searchResult = result;
    searchBarController.open();
  }

  Widget buildBody() {
    if (!isFocus) {
      return const SizedBox.shrink();
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: appModel.getIsDarkMode()
              ? Colors.black.withOpacity(0.85)
              : Colors.white.withOpacity(0.1),
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
                Icons.youtube_searched_for_outlined,
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

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      controller: searchBarController,
      hint: (appModel.getCurrentDictionary() != null)
          ? appModel.translate("search_dictionary_before") +
              appModel.getCurrentDictionaryName() +
              appModel.translate("search_dictionary_after")
          : appModel.translate("search") + "...",
      borderRadius: BorderRadius.zero,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: Duration.zero,
      margins: const EdgeInsets.symmetric(horizontal: 6),
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      progress: isSearching,
      transition: SlideFadeFloatingSearchBarTransition(),
      onFocusChanged: (focus) {
        isFocus = focus;
        if (!isFocus) {
          setState(() {});
          searchBarController.close();

          widget.refreshCallback();
        } else {}

        searchResult = null;
      },
      backdropColor: appModel.getIsDarkMode()
          ? Colors.black.withOpacity(0.95)
          : Colors.white.withOpacity(0.95),
      clearQueryOnClose: true,
      accentColor: Theme.of(context).focusColor,
      onQueryChanged: (query) async {
        if (appModel.getCurrentDictionary() == null) {
          return;
        }
        if (query.isEmpty) {
          searchResult = null;
          setState(() {});
          return;
        }
        if (!isSearching) {
          setState(() {
            isSearching = true;
          });

          selectedIndex = 0;

          searchResult = await appModel.searchDictionary(query);
          appModel.addToSearchHistory(query);

          setState(() {
            isSearching = false;
          });
        }
      },
      leadingActions: [
        FloatingSearchBarAction(
          showIfOpened: true,
          child: CircularButton(
            icon: Icon(
              Icons.auto_stories,
              size: 20,
              color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
            ),
            onPressed: () async {
              String? currentDictionary = appModel.getCurrentDictionaryName();

              await appModel.showDictionaryMenu(context);

              if (currentDictionary != appModel.getCurrentDictionaryName()) {
                if (searchBarController.query.isEmpty) {
                  searchResult = null;
                  setState(() {});
                  return;
                }
                if (!isSearching) {
                  setState(() {
                    isSearching = true;
                  });

                  searchResult = await appModel
                      .searchDictionary(searchBarController.query);
                  setState(() {
                    isSearching = false;
                  });
                }
              } else {
                setState(() {});
              }
            },
          ),
        ),
      ],
      automaticallyImplyBackButton: false,
      actions: [
        FloatingSearchBarAction.icon(
          onTap: () async {
            DictionaryEntry entry = searchResult!.entries[selectedIndex];

            await navigateToCreator(
              context: context,
              appModel: appModel,
              initialParams: AnkiExportParams(
                word: entry.word,
                meaning: entry.meaning,
                reading: entry.reading,
              ),
            );
          },
          icon: Icon(
            Icons.note_add,
            color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
          ),
          size: 20,
          showIfClosed: false,
        ),
        FloatingSearchBarAction.searchToClear(
          size: 20,
          duration: Duration.zero,
          showIfClosed: true,
          color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
        ),
      ],
      isScrollControlled: searchResult == null || searchResult!.entries.isEmpty,
      builder: (context, transition) {
        if (appModel.getCurrentDictionary() == null) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, MediaQuery.of(context).size.height / 7),
            child: showCenterIconMessage(
              context: context,
              label: appModel.translate("import_dictionaries_for_use"),
              icon: Icons.auto_stories,
              jumpingDots: false,
            ),
          );
        }

        List<String> searchHistory =
            appModel.getSearchHistory().reversed.toList();
        if (searchBarController.query.isEmpty && searchHistory.isEmpty) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, MediaQuery.of(context).size.height / 7),
            child: showCenterIconMessage(
              context: context,
              label: appModel.translate("enter_a_search_term"),
              icon: Icons.search,
              jumpingDots: false,
            ),
          );
        } else if (searchResult == null) {
          return ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Material(
              color: Colors.transparent,
              child: ListView.builder(
                itemCount: searchHistory.length,
                shrinkWrap: true,
                itemExtent: 48,
                itemBuilder: (context, i) {
                  String searchTerm = searchHistory[i];
                  return buildSearchHistoryItem(searchTerm);
                },
              ),
            ),
          );
        }

        if (searchResult!.entries.isEmpty) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, MediaQuery.of(context).size.height / 7),
            child: showCenterIconMessage(
              context: context,
              label:
                  "${appModel.translate("dictionary_nomatch_before")}『${searchResult!.originalSearchTerm}』${appModel.translate("dictionary_nomatch_after")}",
              icon: Icons.search_off,
              jumpingDots: false,
            ),
          );
        }

        List<Widget> widgets = [];
        DictionaryFormat format =
            appModel.getDictionaryFormatFromName(searchResult!.formatName);
        Dictionary dictionary =
            appModel.getDictionaryFromName(searchResult!.dictionaryName);

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: getFooterTextSpans(),
          ),
        );
        for (int i = 0; i < searchResult!.entries.length; i++) {
          DictionaryEntry entry = searchResult!.entries[i];
          widgets.add(
            ClipRect(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    await navigateToCreator(
                      context: context,
                      appModel: appModel,
                      initialParams: AnkiExportParams(
                        word: entry.word,
                        meaning: entry.meaning,
                        reading: entry.reading,
                      ),
                    );
                  },
                  onLongPress: () async {
                    HapticFeedback.vibrate();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.maxFinite,
                    color: appModel.getIsDarkMode()
                        ? Theme.of(context).cardColor.withOpacity(0.75)
                        : Colors.grey.shade200.withOpacity(0.55),
                    child: appModel.buildDictionarySearchResult(
                      context: context,
                      dictionaryEntry: entry,
                      dictionaryFormat: format,
                      dictionary: dictionary,
                      selectable: true,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.zero,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widgets,
            ),
          ),
        );
      },
    );
  }

  Widget getFooterTextSpans() {
    Color labelColor = Theme.of(context).unselectedWidgetColor;

    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          getContextSourceIcon(),
          TextSpan(
            text: appModel.translate("instant_search_label_before"),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: "${searchResult!.entries.length}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: appModel.translate("instant_search_label_after"),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: searchResult!.originalSearchTerm,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: labelColor,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  WidgetSpan getContextSourceIcon() {
    Color labelColor = Theme.of(context).unselectedWidgetColor;

    if (searchResult!.mediaHistoryItem == null) {
      return WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 1),
          child: Icon(MediaType.dictionary.icon(), color: labelColor, size: 12),
        ),
      );
    }

    MediaType mediaType = MediaType.values.firstWhere((type) =>
        type.prefsDirectory() ==
        searchResult!.mediaHistoryItem!.mediaTypePrefs);
    IconData icon = mediaType.icon();

    return WidgetSpan(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 4, 1),
        child: Icon(icon, color: labelColor, size: 12),
      ),
    );
  }
}

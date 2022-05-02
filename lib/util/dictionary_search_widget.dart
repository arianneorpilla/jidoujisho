import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/center_icon_message.dart';

class DictionarySearchWidget extends StatefulWidget {
  const DictionarySearchWidget({
    required this.appModel,
    required this.searchBarController,
    this.focusCallback,
    Key? key,
  }) : super(key: key);

  final AppModel appModel;
  final FloatingSearchBarController searchBarController;
  final Function()? focusCallback;

  @override
  State<StatefulWidget> createState() => DictionarySearchWidgetState();
}

class DictionarySearchWidgetState extends State<DictionarySearchWidget> {
  late AppModel appModel;
  late FloatingSearchBarController searchBarController;
  DictionarySearchResult? searchResult;
  int selectedIndex = 0;
  bool isSearching = false;
  bool isFocus = false;

  @override
  void initState() {
    super.initState();
    appModel = widget.appModel;
    searchBarController = widget.searchBarController;
  }

  setSearchResult(DictionarySearchResult result) {
    searchResult = result;
    searchBarController.open();
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

  Widget buildSearchHistory() {
    List<String> searchHistory = appModel.getSearchHistory().reversed.toList();
    return ClipRRect(
      child: Material(
        color: Colors.transparent,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
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

  Widget buildBody() {
    if (appModel.getCurrentDictionary() == null) {
      return buildPlaceholderMessage(
        label: appModel.translate('import_dictionaries_for_use'),
        icon: Icons.auto_stories,
      );
    }

    List<String> searchHistory = appModel.getSearchHistory().reversed.toList();
    if (searchBarController.query.isEmpty && searchHistory.isEmpty) {
      return buildPlaceholderMessage(
        label: appModel.translate('enter_a_search_term'),
        icon: Icons.search,
      );
    } else if (searchResult == null) {
      return buildSearchHistory();
    }

    if (searchResult!.entries.isEmpty) {
      return buildPlaceholderMessage(
        label:
            "${appModel.translate("dictionary_nomatch_before")}『${searchResult!.originalSearchTerm}』${appModel.translate("dictionary_nomatch_after")}",
        icon: Icons.search_off,
      );
    }

    return buildDictionaryItems();
  }

  Widget buildDictionaryItems() {
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
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widgets,
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

  Future<void> onSubmitted(String query) async {
    query = query.trim();
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
  }

  Future<void> onQueryChanged(String query) async {
    query = query.trim();
    if (appModel.getCurrentDictionary() == null) {
      return;
    }
    if (query.isEmpty) {
      searchResult = null;
      setState(() {});
      return;
    }

    if (!isSearching) {
      if (appModel
          .getDictionaryFormatFromName(
              appModel.getCurrentDictionary()!.formatName)
          .isOnline) {
        await Future.delayed(const Duration(seconds: 2), () {});
      }

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
  }

  Future<void> onFocusChanged({required bool focus}) async {
    isFocus = focus;
    if (!isFocus) {
      searchBarController.close();
      setState(() {});

      if (widget.focusCallback != null) {
        widget.focusCallback?.call();
      }
    }

    searchResult = null;
  }

  void showClearAllDialog(BuildContext context) {
    Widget alertDialog = AlertDialog(
      shape: const RoundedRectangleBorder(),
      title: Text(
        appModel.translate('clear_dictionary_history'),
      ),
      content: Text(
        appModel.translate('clear_dictionary_history_warning'),
        textAlign: TextAlign.justify,
      ),
      actions: <Widget>[
        TextButton(
            child: Text(
              appModel.translate('dialog_yes'),
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onPressed: () async {
              await appModel.setSearchHistory([]);
              await appModel
                  .getDictionaryMediaHistory()
                  .clearAllDictionaryItems();

              Navigator.pop(context);

              widget.focusCallback?.call();
            }),
        TextButton(
            child: Text(
              appModel.translate('dialog_no'),
            ),
            onPressed: () => Navigator.pop(context)),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: FloatingSearchBar(
        controller: searchBarController,
        hint: (appModel.getCurrentDictionary() != null)
            ? appModel.getCurrentDictionaryName()
            : appModel.translate('import_dictionaries_for_use'),
        borderRadius: BorderRadius.zero,
        scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
        transitionDuration: Duration.zero,
        margins: const EdgeInsets.symmetric(horizontal: 6),
        width: double.maxFinite,
        openAxisAlignment: 0,
        elevation: 0,
        debounceDelay: const Duration(milliseconds: 500),
        progress: isSearching,
        transition: SlideFadeFloatingSearchBarTransition(),
        onFocusChanged: (focus) => onFocusChanged(focus: focus),
        backgroundColor: (appModel.getIsDarkMode())
            ? Theme.of(context).cardColor
            : const Color(0xFFE5E5E5),
        backdropColor: (appModel.getIsDarkMode())
            ? Colors.black.withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        accentColor: Theme.of(context).focusColor,
        onQueryChanged: onQueryChanged,
        onSubmitted: onSubmitted,
        leadingActions: [
          buildDictionaryButton(),
          buildBackButton(),
        ],
        automaticallyImplyBackButton: false,
        actions: [
          FloatingSearchBarAction.icon(
            onTap: () async {
              showClearAllDialog(context);
            },
            icon: Icon(
              Icons.clear_all,
              color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
            ),
            size: 20,
          ),
          FloatingSearchBarAction.searchToClear(
            size: 20,
            duration: Duration.zero,
            color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
          ),
        ],
        isScrollControlled:
            searchResult == null || searchResult!.entries.isEmpty,
        builder: (context, transition) {
          return buildBody();
        },
      ),
    );
  }

  Widget buildDictionaryButton() {
    return FloatingSearchBarAction(
      child: CircularButton(
        icon: Icon(
          Icons.auto_stories,
          size: 20,
          color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
        ),
        onPressed: () async {
          await dictionaryButtonAction();
        },
      ),
    );
  }

  Widget buildBackButton() {
    return FloatingSearchBarAction.back(
      color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
      size: 20,
    );
  }

  Future<void> dictionaryButtonAction() async {
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

        searchResult =
            await appModel.searchDictionary(searchBarController.query);
        setState(() {
          isSearching = false;
        });
      }
    } else {
      setState(() {});
    }
  }

  Widget getFooterTextSpans() {
    Color labelColor = Theme.of(context).unselectedWidgetColor;

    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          getContextSourceIcon(),
          TextSpan(
            text: appModel.translate('instant_search_label_before'),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: '${searchResult!.entries.length}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: appModel.translate('instant_search_label_after'),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: '『',
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
            text: '』',
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

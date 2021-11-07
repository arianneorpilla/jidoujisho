import 'dart:ui';

import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/dictionary_dialog_widget.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/util/media_type_button.dart';
import 'package:chisa/util/return_from_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/util/dictionary_scrollable_widget.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/media/media_history_items/dictionary_media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:chisa/util/busy_icon_button.dart';
import 'package:chisa/util/center_icon_message.dart';

class DictionaryHomePage extends MediaHomePage {
  const DictionaryHomePage({
    Key? key,
    required MediaType mediaType,
  }) : super(
          key: key,
          mediaType: mediaType,
        );

  @override
  State<StatefulWidget> createState() => DictionaryPageState();
}

class DictionaryPageState extends State<DictionaryHomePage> {
  late AppModel appModel;

  TextEditingController wordController = TextEditingController(text: "");

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  bool isSearching = false;
  bool isFocus = false;
  DictionarySearchResult? searchResult;
  FloatingSearchBarController searchBarController =
      FloatingSearchBarController();

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

  Widget buildFloatingSearchBar() {
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
      transitionCurve: Curves.easeInOut,
      margins: EdgeInsets.symmetric(horizontal: 6),
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      progress: isSearching,

      onFocusChanged: (focus) {
        isFocus = focus;
        setState(() {});

        searchResult = null;
      },

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

          searchResult = await appModel.searchDictionary(query);
          setState(() {
            isSearching = false;
          });
        }
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.

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

      backdropColor: appModel.getIsDarkMode()
          ? Colors.black26
          : Colors.grey.shade300.withOpacity(0.3),
      actions: [
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
            padding: EdgeInsets.all(16),
            child: Center(
              child: showCenterIconMessage(
                context: context,
                label: appModel.translate("import_dictionaries_for_use"),
                icon: Icons.auto_stories,
                jumpingDots: false,
              ),
            ),
          );
        }

        if (searchResult == null) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: showCenterIconMessage(
                context: context,
                label: appModel.translate("enter_a_search_term"),
                icon: Icons.search,
                jumpingDots: false,
              ),
            ),
          );
        }

        if (searchResult!.entries.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: showCenterIconMessage(
                context: context,
                label:
                    "${appModel.translate("dictionary_nomatch_before")}『${searchResult!.originalSearchTerm}』${appModel.translate("dictionary_nomatch_after")}",
                icon: Icons.search,
                jumpingDots: false,
              ),
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
            padding: EdgeInsets.only(bottom: 4),
            child: getFooterTextSpans(),
          ),
        );
        for (int i = 0; i < searchResult!.entries.length; i++) {
          DictionaryEntry entry = searchResult!.entries[i];
          widgets.add(
            ClipRect(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  onTap: () async {
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
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: double.maxFinite,
                    color: Theme.of(context).cardColor.withOpacity(0.75),
                    child: appModel.buildDictionarySearchResult(
                        context: context,
                        dictionaryEntry: entry,
                        dictionaryFormat: format,
                        dictionary: dictionary,
                        selectable: false),
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

  Widget buildMask() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    if (!appModel.hasInitialized) {
      return Container();
    }

    if (appModel.getDictionaryMediaHistory().getDictionaryItems().isEmpty) {
      return Stack(
        children: [
          buildEmptyBody(),
          if (isFocus) buildMask(),
          buildFloatingSearchBar(),
        ],
      );
    }

    return Stack(
      children: [
        buildBody(),
        if (isFocus) buildMask(),
        buildFloatingSearchBar(),
      ],
    );

    if (appModel.getDictionaryMediaHistory().getDictionaryItems().isEmpty) {
      return buildEmptyBody();
    } else {
      return buildBody();
    }
  }

  Widget buildBody() {
    List<DictionaryMediaHistoryItem> mediaHistoryItems = appModel
        .getDictionaryMediaHistory()
        .getDictionaryItems()
        .reversed
        .toList();

    List<DictionarySearchResult> results = mediaHistoryItems
        .map((item) => DictionarySearchResult.fromJson(item.key))
        .toList();

    ScrollController scrollController =
        ScrollController(initialScrollOffset: appModel.scrollOffset);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      scrollController.addListener(() {
        appModel.setScrollOffset = scrollController.offset;
      });
      scrollController.position.isScrollingNotifier.addListener(() {
        appModel.setScrollOffset = scrollController.offset;
      });
    });

    return Scaffold(
      body: RawScrollbar(
        controller: scrollController,
        thumbColor:
            (appModel.getIsDarkMode()) ? Colors.grey[700] : Colors.grey[400],
        child: ListView.builder(
          controller: scrollController,
          addAutomaticKeepAlives: true,
          key: UniqueKey(),
          itemCount: results.length + 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return SizedBox(height: 72);
              //return buildSearchField();
            } else if (index == 1) {
              return buildCardCreatorButton();
            }

            DictionarySearchResult result = results[index - 2];
            DictionaryMediaHistoryItem mediaHistoryItem =
                mediaHistoryItems[index - 2];
            return buildDictionaryResult(result, mediaHistoryItem);
          },
        ),
      ),
    );
  }

  Widget buildEmptyBody() {
    return Column(
      children: [
        SizedBox(height: 72),
        //buildSearchField(),
        buildCardCreatorButton(),
        buildEmptyMessage(),
      ],
    );
  }

  Widget buildEmptyMessage() {
    return Expanded(
      child: showCenterIconMessage(
        context: context,
        label: appModel.translate("history_empty"),
        icon: Icons.auto_stories,
        jumpingDots: false,
      ),
    );
  }

  Widget buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: TextFormField(
        keyboardType: TextInputType.text,
        maxLines: 1,
        controller: wordController,
        enabled: (appModel.getCurrentDictionary() != null),
        onFieldSubmitted: (result) async {
          setState(() {});
          await appModel.searchDictionary(wordController.text);
          setState(() {});
        },
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).unselectedWidgetColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).focusColor),
          ),
          contentPadding: const EdgeInsets.all(0),
          prefixIcon: Icon(widget.mediaType.icon()),
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              BusyIconButton(
                iconSize: 18,
                icon: const Icon(Icons.search),
                enabled: (appModel.getCurrentDictionary() != null &&
                    !appModel.isSearching),
                onPressed: () async {
                  await appModel.searchDictionary(wordController.text);
                  setState(() {});
                },
              ),
              BusyIconButton(
                iconSize: 18,
                icon: const Icon(Icons.auto_stories),
                enabled: (appModel.getCurrentDictionary() != null),
                onPressed: () => appModel.showDictionaryMenu(context),
              ),
              BusyIconButton(
                iconSize: 18,
                icon: const Icon(Icons.clear),
                enabled: (appModel.getCurrentDictionary() != null),
                onPressed: () async {
                  wordController.clear();
                },
              ),
            ],
          ),
          labelText: appModel.translate(
            (appModel.getCurrentDictionary() != null)
                ? "search"
                : "import_dictionaries_for_use",
          ),
          hintText: appModel.translate("enter_search_term_here"),
        ),
      ),
    );
  }

  Widget buildCardCreatorButton() {
    return MediaTypeButton(
      label: appModel.translate("card_creator"),
      icon: Icons.note_add,
      onTap: () async {
        await navigateToCreator(
          context: context,
          appModel: appModel,
        );
        setState(() {});
      },
    );
  }

  Widget buildDictionaryResult(DictionarySearchResult result,
      DictionaryMediaHistoryItem mediaHistoryItem) {
    DictionaryFormat dictionaryFormat =
        appModel.getDictionaryFormatFromName(result.formatName);
    Dictionary dictionary =
        appModel.getDictionaryFromName(result.dictionaryName);
    ValueNotifier<int> indexNotifier =
        ValueNotifier<int>(mediaHistoryItem.currentProgress);

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      color: appModel.getIsDarkMode()
          ? Theme.of(context).unselectedWidgetColor.withOpacity(0.055)
          : Theme.of(context).unselectedWidgetColor.withOpacity(0.030),
      child: InkWell(
        onTap: () async {
          DictionaryEntry entry = result.entries[indexNotifier.value];

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
          ValueNotifier<int> dialogIndexNotifier =
              ValueNotifier<int>(indexNotifier.value);

          HapticFeedback.vibrate();
          await showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => DictionaryDialogWidget(
              mediaHistoryItem: mediaHistoryItem,
              dictionary: dictionary,
              dictionaryFormat: dictionaryFormat,
              result: result,
              callback: () {
                setState(() {});
              },
              indexNotifier: dialogIndexNotifier,
              actions: [
                TextButton(
                  child: Text(
                    appModel.translate("dialog_remove"),
                    style: TextStyle(
                      color: Theme.of(context).focusColor,
                    ),
                  ),
                  onPressed: () async {
                    await appModel.removeDictionaryHistoryItem(result);

                    Navigator.pop(context);
                    setState(() {});
                  },
                ),
                if (mediaHistoryItem.contextItem != null)
                  TextButton(
                    child: Text(
                      appModel.translate("dialog_context"),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await returnFromContext(
                          context, mediaHistoryItem.contextItem!);

                      setState(() {});
                    },
                  ),
                TextButton(
                    child: Text(
                      appModel.translate("dialog_creator"),
                    ),
                    onPressed: () async {
                      DictionaryEntry dialogEntry =
                          result.entries[dialogIndexNotifier.value];
                      await navigateToCreator(
                        context: context,
                        appModel: appModel,
                        initialParams: AnkiExportParams(
                          word: dialogEntry.word,
                          meaning: dialogEntry.meaning,
                          reading: dialogEntry.reading,
                        ),
                      );
                      setState(() {});
                    }),
              ],
            ),
          );
          // showDictionaryDialog(entry, entry.swipeIndex);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DictionaryScrollableWidget(
            appModel: appModel,
            mediaHistoryItem: mediaHistoryItem,
            result: result,
            dictionary: appModel.getDictionaryFromName(result.dictionaryName),
            dictionaryFormat: appModel.getDictionaryFormatFromName(
              result.formatName,
            ),
            indexNotifier: indexNotifier,
            callback: () {
              setState(() {});
            },
          ),
        ),
      ),
    );
  }
}

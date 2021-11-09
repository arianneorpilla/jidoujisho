import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/dictionary_dialog_widget.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/util/dictionary_search_widget.dart';
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

  DictionarySearchResult? searchResult;
  DictionarySearchWidget? dictionaryVerticalWidget;
  FloatingSearchBarController searchBarController =
      FloatingSearchBarController();

  bool isSearching = false;
  bool isFocus = false;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void focusCallback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    dictionaryVerticalWidget ??= DictionarySearchWidget(
      appModel: appModel,
      searchBarController: searchBarController,
      focusCallback: focusCallback,
    );

    if (!appModel.hasInitialized) {
      return Container();
    }

    if (appModel.getDictionaryMediaHistory().getDictionaryItems().isEmpty) {
      return Stack(
        children: [
          buildEmptyBody(),
          dictionaryVerticalWidget!,
        ],
      );
    }

    return Stack(
      children: [
        buildBody(),
        dictionaryVerticalWidget!,
      ],
    );

    // if (appModel.getDictionaryMediaHistory().getDictionaryItems().isEmpty) {
    //   return buildEmptyBody();
    // } else {
    //   return buildBody();
    // }
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

    return RawScrollbar(
      controller: scrollController,
      thumbColor:
          (appModel.getIsDarkMode()) ? Colors.grey[700] : Colors.grey[400],
      child: ListView.builder(
        controller: scrollController,
        addAutomaticKeepAlives: true,
        key: UniqueKey(),
        itemCount: results.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return const SizedBox(height: 60);
            //return buildSearchField();
          }

          DictionarySearchResult result = results[index - 1];
          DictionaryMediaHistoryItem mediaHistoryItem =
              mediaHistoryItems[index - 1];
          return buildDictionaryResult(result, mediaHistoryItem);
        },
      ),
    );
  }

  Widget buildEmptyBody() {
    return Column(
      children: [
        const SizedBox(height: 60),
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

import 'package:chisa/dictionary/dictionary_entry_widget.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_search_results.dart';
import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:chisa/util/busy_icon_button.dart';
import 'package:chisa/util/center_icon_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    if (appModel.getDictionaryHistory().isNotEmpty) {
      return buildBody();
    } else {
      return buildEmptyBody();
    }
  }

  Widget buildBody() {
    List<DictionarySearchResult> results =
        appModel.getDictionaryHistory().reversed.toList();
    DictionaryFormat dictionaryFormat =
        appModel.getDictionaryFormatFromName(results.first.formatName);

    ScrollController scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        addAutomaticKeepAlives: true,
        key: UniqueKey(),
        itemCount: results.length + 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return buildSearchField();
          } else if (index == 1) {
            return buildCardCreatorButton();
          }

          DictionarySearchResult result = results[index - 2];

          return appModel.buildDictionarySearchResult(
            context,
            dictionaryFormat,
            result.entries.first,
          );
        },
      ),
    );
  }

  Widget buildEmptyBody() {
    return Column(
      children: [
        buildSearchField(),
        buildCardCreatorButton(),
        Expanded(
          child: showCenterIconMessage(
            context: context,
            label: AppLocalizations.getLocalizedValue(
                appModel.getAppLanguageName(), "dictionary_history_empty"),
            icon: Icons.auto_stories,
            jumpingDots: false,
          ),
        ),
      ],
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
        onFieldSubmitted: (result) {
          // wordFieldSearch();
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
          prefixIcon: const Icon(
            Icons.search,
          ),
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              BusyIconButton(
                iconSize: 18,
                icon: const Icon(Icons.search),
                enabled: (appModel.getCurrentDictionary() != null),
                onPressed: () async {
                  DictionarySearchResult result =
                      await appModel.searchDictionary(wordController.text);
                  // print(appModel.getDictionaryHistoryItems());

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
          labelText: AppLocalizations.getLocalizedValue(
            appModel.getAppLanguageName(),
            (appModel.getCurrentDictionary() != null)
                ? "search"
                : "import_dictionaries_for_use",
          ),
          hintText: AppLocalizations.getLocalizedValue(
              appModel.getAppLanguageName(), "enter_search_term_here"),
        ),
      ),
    );
  }

  Widget buildCardCreatorButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12, left: 6, right: 6),
      child: InkWell(
        child: Container(
          color: Theme.of(context).unselectedWidgetColor.withOpacity(0.075),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.note_add_sharp, size: 16),
                const SizedBox(width: 5),
                Text(
                  AppLocalizations.getLocalizedValue(
                      appModel.getAppLanguageName(), "card_creator"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatorPage(),
            ),
          );
        },
      ),
    );
  }
}

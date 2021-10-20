import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/busy_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class MediaHomePage extends StatefulWidget {
  const MediaHomePage({
    Key? key,
    required this.mediaType,
  }) : super(key: key);

  final MediaType mediaType;
}

abstract class MediaHomePageState extends State<MediaHomePage> {
  late AppModel appModel;

  TextEditingController wordController = TextEditingController(text: "");

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    if (!appModel.hasInitialized) {
      return Container();
    }

    if (widget.mediaType.getMediaHistory(context).getItems().isEmpty) {
      return buildEmptyBody();
    } else {
      return buildBody();
    }
  }

  Widget buildBody();

  Widget buildEmptyBody();

  Widget buildEmptyMessage();

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

  Widget buildButton();
}

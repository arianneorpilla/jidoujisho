import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_scrollable_widget.dart';
import 'package:chisa/dictionary/dictionary_search_results.dart';
import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/media/history_items/dictionary_media_history_item.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DictionaryDialogWidget extends StatefulWidget {
  const DictionaryDialogWidget({
    Key? key,
    required this.result,
    required this.mediaHistoryItem,
    required this.dictionaryFormat,
    required this.dictionary,
    required this.indexNotifier,
    this.callback,
  }) : super(key: key);

  final DictionarySearchResult result;
  final DictionaryMediaHistoryItem mediaHistoryItem;
  final DictionaryFormat dictionaryFormat;
  final Dictionary dictionary;
  final VoidCallback? callback;
  final ValueNotifier<int> indexNotifier;

  @override
  State<DictionaryDialogWidget> createState() => DictionaryDialogWidgetState();
}

class DictionaryDialogWidgetState extends State<DictionaryDialogWidget> {
  ScrollController scrollController = ScrollController();

  late AppModel appModel;

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    return AlertDialog(
      contentPadding:
          const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      content: DictionaryScrollableWidget(
        appModel: appModel,
        mediaHistoryItem: widget.mediaHistoryItem,
        result: widget.result,
        dictionaryFormat: widget.dictionaryFormat,
        dictionary: widget.dictionary,
        dialog: true,
        callback: widget.callback,
        indexNotifier: widget.indexNotifier,
      ),
      actions: [
        TextButton(
          child: Text(
            AppLocalizations.getLocalizedValue(
                appModel.getAppLanguageName(), "dialog_delete"),
            style: TextStyle(
              color: Theme.of(context).focusColor,
            ),
          ),
          onPressed: () async {
            await appModel.removeDictionaryHistoryItem(widget.result);

            widget.callback!();

            Navigator.pop(context);
            setState(() {});
          },
        ),
        TextButton(
            child: Text(
              AppLocalizations.getLocalizedValue(
                  appModel.getAppLanguageName(), "dialog_creator"),
              style: const TextStyle(),
            ),
            onPressed: () async {
              int index = widget.indexNotifier.value;
              DictionaryEntry entry = widget.result.entries[index];
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => CreatorPage(
                    initialParams: AnkiExportParams(
                      word: entry.word,
                      meaning: entry.meaning,
                      reading: entry.reading,
                    ),
                  ),
                ),
              );
              setState(() {});
            }),
        TextButton(
          child: Text(
            AppLocalizations.getLocalizedValue(
                appModel.getAppLanguageName(), "dialog_close"),
            style: const TextStyle(),
          ),
          onPressed: () async {
            Navigator.pop(context);
            setState(() {});
          },
        ),
      ],
    );
  }
}

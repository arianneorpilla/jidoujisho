import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/media/history_items/dictionary_media_history_item.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/dictionary_scrollable_widget.dart';

class DictionaryDialogWidget extends StatefulWidget {
  const DictionaryDialogWidget({
    Key? key,
    required this.result,
    required this.mediaHistoryItem,
    required this.dictionaryFormat,
    required this.dictionary,
    required this.indexNotifier,
    required this.actions,
    this.callback,
  }) : super(key: key);

  final DictionarySearchResult result;
  final DictionaryMediaHistoryItem mediaHistoryItem;
  final DictionaryFormat dictionaryFormat;
  final Dictionary dictionary;
  final VoidCallback? callback;
  final ValueNotifier<int> indexNotifier;
  final List<Widget> actions;

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
      actions: widget.actions,
    );
  }
}

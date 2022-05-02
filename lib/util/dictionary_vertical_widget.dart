import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:flutter/material.dart';

import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';

import 'package:chisa/media/media_history_items/dictionary_media_history_item.dart';
import 'package:chisa/models/app_model.dart';
import 'package:flutter/services.dart';

class DictionaryVerticalWidget extends StatefulWidget {
  const DictionaryVerticalWidget({
    Key? key,
    required this.appModel,
    required this.mediaHistoryItem,
    required this.result,
    required this.dictionaryFormat,
    required this.dictionary,
    required this.indexNotifier,
    required this.itemsColor,
    this.itemMaxWidth = double.maxFinite,
    this.selectable = false,
    this.callback,
  }) : super(key: key);

  factory DictionaryVerticalWidget.fromLatestResult({
    required AppModel appModel,
    required DictionarySearchResult result,
    required ValueNotifier<int> indexNotifier,
    double? itemMaxWidth,
    required Color itemsColor,
    bool selectable = false,
  }) {
    return DictionaryVerticalWidget(
      appModel: appModel,
      mediaHistoryItem:
          appModel.getDictionaryMediaHistory().getDictionaryItems().last,
      result: result,
      dictionaryFormat: appModel.getDictionaryFormatFromName(result.formatName),
      dictionary: appModel.getDictionaryFromName(result.dictionaryName),
      indexNotifier: indexNotifier,
      selectable: selectable,
      itemMaxWidth: itemMaxWidth,
      itemsColor: itemsColor,
    );
  }

  final AppModel appModel;
  final DictionaryMediaHistoryItem mediaHistoryItem;
  final DictionarySearchResult result;
  final DictionaryFormat dictionaryFormat;
  final Dictionary dictionary;
  final VoidCallback? callback;
  final ValueNotifier<int> indexNotifier;
  final bool selectable;
  final double? itemMaxWidth;
  final Color itemsColor;

  @override
  State<StatefulWidget> createState() => DictionaryVerticalWidgetState();
}

class DictionaryVerticalWidgetState extends State<DictionaryVerticalWidget> {
  late ValueNotifier<int> indexNotifier;
  late Color labelColor;

  @override
  void initState() {
    super.initState();
    indexNotifier = widget.indexNotifier;
  }

  @override
  Widget build(BuildContext context) {
    labelColor = Theme.of(context).unselectedWidgetColor;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: buildItems(),
      ),
    );
  }

  List<Widget> buildItems() {
    List<Widget> widgets = [];
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: getFooterTextSpans(),
      ),
    );
    for (int i = 0; i < widget.result.entries.length; i++) {
      DictionaryEntry entry = widget.result.entries[i];
      widgets.add(
        ClipRect(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () async {
                FocusScope.of(context).unfocus();
                await navigateToCreator(
                  context: context,
                  appModel: widget.appModel,
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
                width: widget.itemMaxWidth,
                color: widget.itemsColor,
                child: widget.appModel.buildDictionarySearchResult(
                  context: context,
                  dictionaryEntry: entry,
                  dictionaryFormat: widget.dictionaryFormat,
                  dictionary: widget.dictionary,
                  selectable: true,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  WidgetSpan getContextSourceIcon() {
    if (widget.result.mediaHistoryItem == null) {
      return WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 1),
          child: Icon(MediaType.dictionary.icon(), color: labelColor, size: 12),
        ),
      );
    }

    MediaType mediaType = MediaType.values.firstWhere((type) =>
        type.prefsDirectory() ==
        widget.result.mediaHistoryItem!.mediaTypePrefs);
    IconData icon = mediaType.icon();

    return WidgetSpan(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 4, 1),
        child: Icon(icon, color: labelColor, size: 12),
      ),
    );
  }

  Widget getFooterTextSpans() {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          getContextSourceIcon(),
          TextSpan(
            text: widget.appModel.translate('search_label_before'),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: '${indexNotifier.value + 1} ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: widget.appModel.translate('search_label_middle'),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: '${widget.result.entries.length} ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          // if (entry.contextDataSource != "-1")
          //   getContextDataSourceSpan(entry.contextDataSource),
          TextSpan(
            text: widget.appModel.translate('search_label_after'),
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
            text: widget.result.originalSearchTerm,
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
}

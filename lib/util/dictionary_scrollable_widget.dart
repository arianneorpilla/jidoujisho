import 'package:flutter/material.dart';

import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';

import 'package:chisa/media/media_history_items/dictionary_media_history_item.dart';
import 'package:chisa/models/app_model.dart';

class DictionaryScrollableWidget extends StatefulWidget {
  const DictionaryScrollableWidget({
    Key? key,
    required this.appModel,
    required this.mediaHistoryItem,
    required this.result,
    required this.dictionaryFormat,
    required this.dictionary,
    required this.indexNotifier,
    this.callback,
    this.limitHeight = false,
  }) : super(key: key);

  final AppModel appModel;
  final DictionaryMediaHistoryItem mediaHistoryItem;
  final DictionarySearchResult result;
  final DictionaryFormat dictionaryFormat;
  final Dictionary dictionary;
  final bool limitHeight;
  final VoidCallback? callback;
  final ValueNotifier<int> indexNotifier;

  @override
  State<StatefulWidget> createState() => DictionaryScrollableWidgetState();
}

class DictionaryScrollableWidgetState
    extends State<DictionaryScrollableWidget> {
  late ValueNotifier<int> indexNotifier;
  late Color labelColor;

  @override
  void initState() {
    super.initState();
    indexNotifier = widget.indexNotifier;
    labelColor =
        widget.appModel.getIsDarkMode() ? Colors.grey : Colors.grey[600]!;
  }

  @override
  Widget build(BuildContext context) {
    DictionaryEntry dictionaryEntry =
        widget.result.entries[indexNotifier.value];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == 0) return;

        if (details.primaryVelocity!.compareTo(0) == -1) {
          if (indexNotifier.value == widget.result.entries.length - 1) {
            indexNotifier.value = 0;
          } else {
            indexNotifier.value += 1;
          }
        } else {
          if (indexNotifier.value == 0) {
            indexNotifier.value = widget.result.entries.length - 1;
          } else {
            indexNotifier.value -= 1;
          }
        }

        widget.mediaHistoryItem.progress = indexNotifier.value;
        widget.appModel.updateDictionaryHistoryIndex(
          widget.mediaHistoryItem,
          indexNotifier.value,
        );
        setState(() {});
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: widget.appModel.buildDictionarySearchResult(
              context: context,
              dictionaryEntry: dictionaryEntry,
              dictionaryFormat: widget.dictionaryFormat,
              dictionary: widget.dictionary,
            ),
          ),
          const SizedBox(height: 10),
          getFooterTextSpans()
        ],
      ),
    );
  }

  Widget getFooterTextSpans() {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: widget.appModel.translate("search_label_before"),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: "${indexNotifier.value + 1} ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: widget.appModel.translate("search_label_middle"),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: "${widget.result.entries.length} ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          // if (entry.contextDataSource != "-1")
          //   getContextDataSourceSpan(entry.contextDataSource),
          TextSpan(
            text: widget.appModel.translate("search_label_after"),
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
            text: widget.result.originalSearchTerm,
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
}

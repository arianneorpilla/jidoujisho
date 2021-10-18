import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_dialog_widget.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_search_results.dart';
import 'package:chisa/language/app_localizations.dart';
import 'package:chisa/media/history_items/dictionary_media_history_item.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DictionaryScrollableWidget extends StatefulWidget {
  const DictionaryScrollableWidget({
    Key? key,
    required this.appModel,
    required this.mediaHistoryItem,
    required this.result,
    required this.dictionaryFormat,
    required this.dictionary,
    this.indexNotifier,
    this.dialog = false,
  }) : super(key: key);

  final AppModel appModel;
  final DictionaryMediaHistoryItem mediaHistoryItem;
  final DictionarySearchResult result;
  final DictionaryFormat dictionaryFormat;
  final Dictionary dictionary;
  final bool dialog;
  final ValueNotifier<int>? indexNotifier;

  @override
  State<StatefulWidget> createState() => DictionaryScrollableWidgetState();
}

class DictionaryScrollableWidgetState
    extends State<DictionaryScrollableWidget> {
  late int swipeIndex;
  late Color labelColor;

  @override
  void initState() {
    super.initState();
    swipeIndex = widget.mediaHistoryItem.progress;
    labelColor =
        ((widget.appModel.getIsDarkMode()) ? Colors.grey : Colors.grey[600])!;
  }

  @override
  Widget build(BuildContext context) {
    DictionaryEntry entry = widget.result.entries[swipeIndex];
    if (widget.indexNotifier != null) {
      widget.indexNotifier!.value = swipeIndex;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      color: (widget.dialog)
          ? (Colors.transparent)
          : (widget.appModel.getIsDarkMode())
              ? Theme.of(context).unselectedWidgetColor.withOpacity(0.055)
              : Theme.of(context).unselectedWidgetColor.withOpacity(0.030),
      child: InkWell(
        onTap: widget.dialog
            ? null
            : () async {
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
              },
        onLongPress: widget.dialog
            ? null
            : () async {
                HapticFeedback.vibrate();
                await showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) => DictionaryDialogWidget(
                    mediaHistoryItem: widget.mediaHistoryItem,
                    dictionary: widget.dictionary,
                    dictionaryFormat: widget.dictionaryFormat,
                    result: widget.result,
                    indexNotifier: ValueNotifier(swipeIndex),
                  ),
                );

                setState(() {});
                // showDictionaryDialog(entry, entry.swipeIndex);
              },
        child: Padding(
          padding: EdgeInsets.all((!widget.dialog) ? 16 : 0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == 0) return;

              if (details.primaryVelocity!.compareTo(0) == -1) {
                if (swipeIndex == widget.result.entries.length - 1) {
                  swipeIndex = 0;
                } else {
                  swipeIndex += 1;
                }
              } else {
                if (swipeIndex == 0) {
                  swipeIndex = widget.result.entries.length - 1;
                } else {
                  swipeIndex -= 1;
                }
              }

              widget.mediaHistoryItem.progress = swipeIndex;
              widget.appModel.updateDictionaryHistoryIndex(
                  widget.mediaHistoryItem, swipeIndex);
              setState(() {});
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.appModel.buildDictionarySearchResult(
                  context,
                  entry,
                  widget.dictionaryFormat,
                  widget.dictionary,
                ),
                getFooterTextSpans()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getFooterTextSpans() {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: AppLocalizations.getLocalizedValue(
                widget.appModel.getAppLanguageName(), "search_label_before"),
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: "${swipeIndex + 1} ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: AppLocalizations.getLocalizedValue(
                widget.appModel.getAppLanguageName(), "search_label_middle"),
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
            text: AppLocalizations.getLocalizedValue(
                widget.appModel.getAppLanguageName(), "search_label_after"),
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

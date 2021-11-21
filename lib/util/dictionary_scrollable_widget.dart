import 'package:chisa/media/media_type.dart';
import 'package:flutter/material.dart';

import 'package:chisa/dictionary/dictionary.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_format.dart';
import 'package:chisa/dictionary/dictionary_search_result.dart';

import 'package:chisa/media/media_history_items/dictionary_media_history_item.dart';
import 'package:chisa/models/app_model.dart';

class DictionaryScrollableWidget extends StatelessWidget {
  const DictionaryScrollableWidget({
    Key? key,
    required this.appModel,
    required this.mediaHistoryItem,
    required this.result,
    required this.dictionaryFormat,
    required this.dictionary,
    required this.indexNotifier,
    this.selectable = false,
    this.callback,
  }) : super(key: key);

  factory DictionaryScrollableWidget.fromLatestResult({
    required AppModel appModel,
    required DictionarySearchResult result,
    required ValueNotifier<int> indexNotifier,
    bool selectable = false,
  }) {
    return DictionaryScrollableWidget(
      appModel: appModel,
      mediaHistoryItem:
          appModel.getDictionaryMediaHistory().getDictionaryItems().last,
      result: result,
      dictionaryFormat: appModel.getDictionaryFormatFromName(result.formatName),
      dictionary: appModel.getDictionaryFromName(result.dictionaryName),
      selectable: selectable,
      indexNotifier: indexNotifier,
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: indexNotifier,
      builder: (context, index, child) {
        DictionaryEntry dictionaryEntry = result.entries[indexNotifier.value];

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) async {
            if (details.primaryVelocity == 0) return;

            if (details.primaryVelocity!.compareTo(0) == -1) {
              if (indexNotifier.value == result.entries.length - 1) {
                indexNotifier.value = 0;
              } else {
                indexNotifier.value += 1;
              }
            } else {
              if (indexNotifier.value == 0) {
                indexNotifier.value = result.entries.length - 1;
              } else {
                indexNotifier.value -= 1;
              }
            }

            await appModel.setDictionaryHistoryIndex(
              mediaHistoryItem,
              indexNotifier.value,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: appModel.buildDictionarySearchResult(
                  context: context,
                  dictionaryEntry: dictionaryEntry,
                  dictionaryFormat: dictionaryFormat,
                  dictionary: dictionary,
                  selectable: selectable,
                ),
              ),
              const SizedBox(height: 10),
              getFooterTextSpans(context),
            ],
          ),
        );
      },
    );
  }

  WidgetSpan getContextSourceIcon(BuildContext context) {
    if (result.mediaHistoryItem == null) {
      return WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 1),
          child: Icon(MediaType.dictionary.icon(),
              color: Theme.of(context).unselectedWidgetColor, size: 12),
        ),
      );
    }

    MediaType mediaType = MediaType.values.firstWhere((type) =>
        type.prefsDirectory() == result.mediaHistoryItem!.mediaTypePrefs);
    IconData icon = mediaType.icon();

    return WidgetSpan(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 4, 1),
        child: Icon(icon,
            color: Theme.of(context).unselectedWidgetColor, size: 12),
      ),
    );
  }

  Widget getFooterTextSpans(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          getContextSourceIcon(context),
          TextSpan(
            text: appModel.translate("search_label_before"),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).unselectedWidgetColor,
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
            text: appModel.translate("search_label_middle"),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: "${result.entries.length} ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          // if (entry.contextDataSource != "-1")
          //   getContextDataSourceSpan(entry.contextDataSource),
          TextSpan(
            text: appModel.translate("search_label_after"),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: result.originalSearchTerm,
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
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

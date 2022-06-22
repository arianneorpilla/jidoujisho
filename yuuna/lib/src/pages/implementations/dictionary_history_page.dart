import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// Returns the main body of the [HomeDictionaryPage] before the search bar
/// is opened.
class DictionaryHistoryPage extends BasePage {
  /// Create the main body of the [HomeDictionaryPage].
  const DictionaryHistoryPage({
    required this.onSearch,
    required this.onStash,
    super.key,
  });

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

  @override
  BasePageState<DictionaryHistoryPage> createState() =>
      _DictionaryHistoryPageState();
}

class _DictionaryHistoryPageState extends BasePageState<DictionaryHistoryPage> {
  String get searchLabelBefore => appModel.translate('search_label_before');
  String get searchLabelMiddle => appModel.translate('search_label_middle');
  String get searchLabelFrom => appModel.translate('search_label_from');
  String get searchLabelAfter => appModel.translate('search_label_after');
  String get seeMoreLabel => appModel.translate('see_more');

  late Map<String, Dictionary>? dictionaryMap;
  Map<int, Map<int, List<DictionaryMetaEntry>>> metaEntriesCache = {};
  Map<int, Map<int, Map<String, ExpandableController>>> expandedControllers =
      {};
  Map<int, Map<int, Map<String, bool>>> dictionaryHiddens = {};

  @override
  void initState() {
    super.initState();
    appModelNoUpdate.dictionaryMenuNotifier.addListener(dumpCache);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void dumpCache() {
    metaEntriesCache.clear();
    expandedControllers.clear();
    dictionaryHiddens.clear();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    dictionaryMap = Map<String, Dictionary>.fromEntries(
      appModel.dictionaries.map(
        (dictionary) => MapEntry(dictionary.dictionaryName, dictionary),
      ),
    );

    List<DictionaryResult> historyResults =
        appModel.dictionaryHistory.reversed.toList();

    for (DictionaryResult result in historyResults) {
      for (DictionaryTerm term in result.terms) {
        term.entries.sort(
          (a, b) => dictionaryMap![a.dictionaryName]!.order.compareTo(
                dictionaryMap![b.dictionaryName]!.order,
              ),
        );
      }
    }

    return ListView.builder(
      controller: DictionaryMediaType.instance.scrollController,
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      itemCount: historyResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const SizedBox(height: 60);
        }

        DictionaryResult result = historyResults[index - 1];

        ValueNotifier<int> indexNotifier =
            ValueNotifier<int>(result.scrollIndex);

        return ValueListenableBuilder<int>(
          valueListenable: indexNotifier,
          builder: (context, value, child) {
            DictionaryTerm dictionaryTerm = result.terms[indexNotifier.value];

            metaEntriesCache[index - 1] ??= {};
            expandedControllers[index - 1] ??= {};
            dictionaryHiddens[index - 1] ??= {};

            if (metaEntriesCache[index - 1]![result.scrollIndex] == null) {
              final Map<String, ExpandableController> controllers = {};
              final Map<String, bool> hiddens = {};

              for (String dictionaryName in dictionaryMap!.keys.toList()) {
                controllers[dictionaryName] = ExpandableController(
                  initialExpanded: !dictionaryMap![dictionaryName]!.collapsed,
                );
                hiddens[dictionaryName] =
                    dictionaryMap![dictionaryName]!.hidden;
              }

              List<DictionaryMetaEntry> metaEntries =
                  appModel.getMetaEntriesFromTerm(dictionaryTerm.term);
              metaEntries.sort(
                (a, b) => dictionaryMap![a.dictionaryName]!.order.compareTo(
                      dictionaryMap![b.dictionaryName]!.order,
                    ),
              );

              metaEntriesCache[index - 1]![result.scrollIndex] ??= metaEntries;
              expandedControllers[index - 1]![result.scrollIndex] ??=
                  controllers;
              dictionaryHiddens[index - 1]![result.scrollIndex] ??= hiddens;
            }

            return DictionaryTermPage(
              dictionaryMap: dictionaryMap!,
              dictionaryTerm: dictionaryTerm,
              dictionaryMetaEntries:
                  metaEntriesCache[index - 1]![result.scrollIndex]!,
              onSearch: widget.onSearch,
              onStash: widget.onStash,
              expandableControllers:
                  expandedControllers[index - 1]![result.scrollIndex]!,
              dictionaryHiddens:
                  dictionaryHiddens[index - 1]![result.scrollIndex]!,
              onScrollRight: () async {
                if (result.scrollIndex == result.terms.length - 1) {
                  result.scrollIndex = 0;
                } else {
                  result.scrollIndex += 1;
                }

                await appModel.updateDictionaryResultScrollIndex(
                  result: result,
                  newIndex: result.scrollIndex,
                );

                indexNotifier.value = result.scrollIndex;
              },
              onScrollLeft: () async {
                if (result.scrollIndex == 0) {
                  result.scrollIndex = result.terms.length - 1;
                } else {
                  result.scrollIndex -= 1;
                }

                await appModel.updateDictionaryResultScrollIndex(
                  result: result,
                  newIndex: result.scrollIndex,
                );

                indexNotifier.value = result.scrollIndex;
              },
              footerWidget: buildFooterWidget(result, indexNotifier.value),
            );
          },
        );
      },
    );
  }

  double get fontSize => (textTheme.labelMedium?.fontSize)! * 0.9;

  Widget buildFooterWidget(DictionaryResult result, int index) {
    return Center(
      child: Tooltip(
        message: seeMoreLabel,
        child: InkWell(
          onTap: () async {
            await appModel.openResultFromHistory(result: result);
            appModel.refreshDictionaryHistory();
          },
          child: Padding(
            padding: Spacing.of(context).insets.all.small,
            child: buildFooterTextSpans(result, index),
          ),
        ),
      ),
    );
  }

  Widget buildFooterTextSpans(
    DictionaryResult result,
    int index,
  ) {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              child: Icon(
                DictionaryMediaType.instance.icon,
                size: fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
              padding: EdgeInsets.only(
                top: 1.25,
                right: Spacing.of(context).spaces.small,
              ),
            ),
          ),
          TextSpan(
            text: searchLabelBefore,
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: '${index + 1} ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          TextSpan(
            text: searchLabelMiddle,
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: '${result.terms.length} ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          TextSpan(
            text: searchLabelAfter,
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: ' ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: result.searchTerm,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

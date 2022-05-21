import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

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
  String get searchLabel => appModel.translate('search');
  String get stashLabel => appModel.translate('stash');
  String get searchLabelBefore => appModel.translate('search_label_before');
  String get searchLabelMiddle => appModel.translate('search_label_middle');
  String get searchLabelFrom => appModel.translate('search_label_from');
  String get searchLabelAfter => appModel.translate('search_label_after');

  MaterialTextSelectionControls get selectionControls =>
      JidoujishoTextSelectionControls(
        searchAction: widget.onSearch,
        searchActionLabel: searchLabel,
        stashAction: widget.onStash,
        stashActionLabel: stashLabel,
        allowCopy: true,
        allowSelectAll: true,
        allowCut: false,
        allowPaste: false,
      );

  Map<String, int>? dictionaryOrderCache;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appModel.dictionaryWatcher.listen((_) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    dictionaryOrderCache = Map<String, int>.fromEntries(
      appModel.dictionaries.map(
        (dictionary) => MapEntry(dictionary.dictionaryName, dictionary.order),
      ),
    );

    List<DictionaryResult> historyResults =
        appModel.dictionaryHistory.reversed.toList();

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: historyResults.length,
      itemBuilder: (context, index) {
        DictionaryResult result = historyResults[index];
        List<DictionaryEntry> entries = result.mapping[result.scrollIndex];

        entries.sort((a, b) => (dictionaryOrderCache![a.dictionaryName]!)
            .compareTo(dictionaryOrderCache![b.dictionaryName]!));
        Set<String> dictionaryNames =
            entries.map((entry) => entry.dictionaryName).toSet();

        final Map<String, ExpandableController> expandableControllers = {};
        final Map<String, bool> dictionaryHiddens = {};

        for (String dictionaryName in dictionaryNames) {
          Dictionary dictionary =
              appModelNoUpdate.getDictionary(dictionaryName);
          expandableControllers[dictionaryName] = ExpandableController(
            initialExpanded: !dictionary.collapsed,
          );
          dictionaryHiddens[dictionaryName] = dictionary.hidden;
        }

        bool hidePage = true;
        for (bool dictionaryHidden in dictionaryHiddens.values) {
          if (!dictionaryHidden) {
            hidePage = false;
          }
        }

        if (hidePage) {
          return const SizedBox.shrink();
        }

        return DictionaryWordPage(
          entries: entries,
          onSearch: widget.onSearch,
          onStash: widget.onStash,
          expandableControllers: expandableControllers,
          dictionaryHiddens: dictionaryHiddens,
          onScrollRight: () {
            if (result.scrollIndex == result.mapping.length - 1) {
              result.scrollIndex = 0;
            } else {
              result.scrollIndex += 1;
            }

            appModel.updateDictionaryResultScrollIndex(
              result: result,
              newIndex: result.scrollIndex,
            );
          },
          onScrollLeft: () {
            if (result.scrollIndex == 0) {
              result.scrollIndex = result.mapping.length - 1;
            } else {
              result.scrollIndex -= 1;
            }

            appModel.updateDictionaryResultScrollIndex(
              result: result,
              newIndex: result.scrollIndex,
            );
          },
          footerWidget: buildFooterWidget(result),
        );
      },
    );
  }

  double get fontSize => (textTheme.labelMedium?.fontSize)! * 0.9;

  Widget buildFooterWidget(DictionaryResult result) {
    return InkWell(
      onTap: () {
        appModel.openResultFromHistory(result: result);
      },
      child: Padding(
        padding: Spacing.of(context).insets.vertical.small,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildFooterIcon(result),
            const Space.small(),
            buildFooterTextSpans(result),
          ],
        ),
      ),
    );
  }

  Widget buildFooterIcon(DictionaryResult result) {
    return Padding(
      child: Icon(
        DictionaryMediaType.instance.icon,
        size: fontSize,
        color: Theme.of(context).unselectedWidgetColor,
      ),
      padding: EdgeInsets.only(
        top: 1.5,
        right: Spacing.of(context).spaces.small,
      ),
    );
  }

  Widget buildFooterTextSpans(
    DictionaryResult result,
  ) {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: searchLabelBefore,
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: '${result.scrollIndex + 1} ',
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
            text: '${result.mapping.length} ',
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
            text: '『',
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
          TextSpan(
            text: '』',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

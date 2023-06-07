import 'package:collection/collection.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/i18n/strings.g.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// Returns the main body of the [HomeDictionaryPage] before the search bar
/// is opened.
class DictionaryHistoryPage extends BasePage {
  /// Create the main body of the [HomeDictionaryPage].
  const DictionaryHistoryPage({
    required this.onSearch,
    required this.onStash,
    required this.onShare,
    super.key,
  });

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

  /// Action to be done upon selecting the stash option.
  final Function(String) onShare;

  @override
  BasePageState<DictionaryHistoryPage> createState() =>
      _DictionaryHistoryPageState();
}

class _DictionaryHistoryPageState extends BasePageState<DictionaryHistoryPage> {
  @override
  Widget build(BuildContext context) {
    AnkiMapping lastSelectedMapping = appModel.lastSelectedMapping;

    List<DictionarySearchResult> historyResults =
        appModel.dictionaryHistory.reversed.toList();

    return CustomScrollView(
      cacheExtent: 999999999999999,
      controller: DictionaryMediaType.instance.scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 60)),
        ...historyResults
            .map(
              (result) => _DictionaryHistoryScrollableItem(
                result: result,
                onSearch: widget.onSearch,
                onStash: widget.onStash,
                onShare: widget.onShare,
                lastSelectedMapping: lastSelectedMapping,
              ),
            )
            .toList(),
      ],
    );
  }
}

class _DictionaryHistoryScrollableItem extends BasePage {
  const _DictionaryHistoryScrollableItem({
    required this.result,
    required this.onStash,
    required this.onSearch,
    required this.onShare,
    required this.lastSelectedMapping,
  });

  /// The result pertaining to this item.
  final DictionarySearchResult result;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

  /// Action to be done upon selecting the stash option.
  final Function(String) onShare;

  /// The current mapping.
  final AnkiMapping lastSelectedMapping;

  @override
  _DictionaryHistoryScrollableItemState createState() =>
      _DictionaryHistoryScrollableItemState();
}

class _DictionaryHistoryScrollableItemState
    extends BasePageState<_DictionaryHistoryScrollableItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    DictionarySearchResult result = widget.result;
    Map<int, DictionaryHeading> headingsById = Map.fromEntries(
      result.headings.map(
        (heading) => MapEntry(heading.id, heading),
      ),
    );

    List<DictionaryHeading> headings =
        result.headingIds.map((id) => headingsById[id]).whereNotNull().toList();

    List<Dictionary> dictionaries = appModel.dictionaries;
    Map<String, bool> dictionaryNamesByHidden = Map<String, bool>.fromEntries(
        dictionaries
            .map((e) => MapEntry(e.name, e.isHidden(appModel.targetLanguage))));
    Map<String, bool> dictionaryNamesByCollapsed =
        Map<String, bool>.fromEntries(dictionaries.map(
            (e) => MapEntry(e.name, e.isCollapsed(appModel.targetLanguage))));
    Map<String, int> dictionaryNamesByOrder = Map<String, int>.fromEntries(
        dictionaries.map((e) => MapEntry(e.name, e.order)));

    final Map<DictionaryHeading, Map<Dictionary, ExpandableController>>
        expandableControllersByHeading = {};
    for (DictionaryHeading heading in headings) {
      expandableControllersByHeading.putIfAbsent(heading, () => {});
      for (DictionaryEntry entry in heading.entries) {
        Dictionary dictionary = entry.dictionary.value!;
        expandableControllersByHeading[heading]?.putIfAbsent(
          dictionary,
          () => ExpandableController(
            initialExpanded: !dictionaryNamesByCollapsed[dictionary.name]!,
          ),
        );
      }
    }

    if (headings.isEmpty) {
      return const SliverPadding(padding: EdgeInsets.zero);
    }

    DictionaryHeading heading = headings.first;

    return DictionaryTermPage(
      lastSelectedMapping: widget.lastSelectedMapping,
      heading: heading,
      onSearch: widget.onSearch,
      onStash: widget.onStash,
      onShare: widget.onShare,
      expandableControllers: expandableControllersByHeading[heading]!,
      dictionaryNamesByHidden: dictionaryNamesByHidden,
      dictionaryNamesByOrder: dictionaryNamesByOrder,
      footerWidget: headings.length > 1
          ? buildFooterWidget(result: result, length: headings.length)
          : null,
    );
  }

  Widget buildFooterWidget({
    required DictionarySearchResult result,
    required int length,
  }) {
    return Padding(
      padding: Spacing.of(context).insets.onlyBottom.small,
      child: Tooltip(
        message: t.show_more,
        child: InkWell(
          onTap: () async {
            await appModel.openResultFromHistory(result: result);
            appModel.refreshDictionaryHistory();
          },
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            width: double.maxFinite,
            child: Padding(
              padding: Spacing.of(context).insets.all.small,
              child: buildFooterTextSpans(
                result: result,
                length: length,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double get fontSize => (textTheme.labelMedium?.fontSize)! * 0.9;

  Widget buildFooterTextSpans({
    required DictionarySearchResult result,
    required int length,
  }) {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.only(
                top: 1.25,
                right: Spacing.of(context).spaces.small,
              ),
              child: Icon(
                DictionaryMediaType.instance.icon,
                size: fontSize,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          ),
          TextSpan(
            text: t.search_label_before,
            style: TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: '$length ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          TextSpan(
            text: t.search_label_after,
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
            text: result.searchTerm.trim().replaceAll('\n', ' '),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

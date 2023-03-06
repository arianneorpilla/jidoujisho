import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keframe/keframe.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
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
  @override
  Widget build(BuildContext context) {
    AnkiMapping lastSelectedMapping = appModel.lastSelectedMapping;

    List<DictionarySearchResult> historyResults =
        appModel.dictionaryHistory.reversed.toList();

    return SizeCacheWidget(
      child: ListView.builder(
        cacheExtent: 99999999999999,
        controller: DictionaryMediaType.instance.scrollController,
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        itemCount: historyResults.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const SizedBox(height: 60);
          }

          DictionarySearchResult result = historyResults[index - 1];

          return _DictionaryHistoryScrollableItem(
            key: GlobalObjectKey(result.searchTerm),
            result: result,
            onSearch: widget.onSearch,
            onStash: widget.onStash,
            lastSelectedMapping: lastSelectedMapping,
          );
        },
      ),
    );
  }
}

class _DictionaryHistoryScrollableItem extends BasePage {
  const _DictionaryHistoryScrollableItem({
    required this.result,
    required this.onStash,
    required this.onSearch,
    required this.lastSelectedMapping,
    super.key,
  });

  /// The result pertaining to this item.
  final DictionarySearchResult result;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

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

  String get searchLabelBefore => appModel.translate('search_label_before');
  String get searchLabelMiddle => appModel.translate('search_label_middle');
  String get searchLabelFrom => appModel.translate('search_label_from');
  String get searchLabelAfter => appModel.translate('search_label_after');
  String get seeMoreLabel => appModel.translate('see_more');

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
        result.headingIds.map((id) => headingsById[id]!).toList();

    final Map<DictionaryHeading, Map<Dictionary, ExpandableController>>
        expandableControllersByHeading = {};
    for (DictionaryHeading heading in headings) {
      expandableControllersByHeading.putIfAbsent(heading, () => {});
      for (DictionaryEntry entry in heading.entries) {
        Dictionary dictionary = entry.dictionary.value!;
        expandableControllersByHeading[heading]?.putIfAbsent(
          dictionary,
          () => ExpandableController(initialExpanded: !dictionary.collapsed),
        );
      }
    }

    ValueNotifier<int> indexNotifier =
        ValueNotifier<int>(result.scrollPosition);

    return ValueListenableBuilder<int>(
      valueListenable: indexNotifier,
      builder: (context, value, child) {
        DictionaryHeading heading = headings.elementAt(indexNotifier.value);

        Map<Dictionary, ExpandableController> expandableControllers =
            expandableControllersByHeading[heading]!;

        return FrameSeparateWidget(
          child: DictionaryTermPage(
            lastSelectedMapping: widget.lastSelectedMapping,
            heading: heading,
            onSearch: widget.onSearch,
            onStash: widget.onStash,
            expandableControllers: expandableControllers,
            onScrollRight: () async {
              if (result.scrollPosition == headings.length - 1) {
                result.scrollPosition = 0;
              } else {
                result.scrollPosition += 1;
              }

              await appModel.updateDictionaryResultScrollIndex(
                result: result,
                newIndex: result.scrollPosition,
              );

              indexNotifier.value = result.scrollPosition;
            },
            onScrollLeft: () async {
              if (result.scrollPosition == 0) {
                result.scrollPosition = headings.length - 1;
              } else {
                result.scrollPosition -= 1;
              }

              await appModel.updateDictionaryResultScrollIndex(
                result: result,
                newIndex: result.scrollPosition,
              );

              indexNotifier.value = result.scrollPosition;
            },
            footerWidget: buildFooterWidget(
              result: result,
              length: headings.length,
              index: indexNotifier.value,
            ),
          ),
        );
      },
    );
  }

  Widget buildFooterWidget({
    required DictionarySearchResult result,
    required int length,
    required int index,
  }) {
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
            child: buildFooterTextSpans(
              result: result,
              length: length,
              index: index,
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
    required int index,
  }) {
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
            text: '$length ',
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

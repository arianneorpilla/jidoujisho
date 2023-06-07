import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';

/// Returns the widget for a [DictionarySearchResult] which returns a
/// scrollable list of each [DictionaryEntry] in its mappings.
class DictionaryResultPage extends BasePage {
  /// Create the widget of a [DictionarySearchResult].
  const DictionaryResultPage({
    required this.result,
    required this.onSearch,
    required this.onStash,
    required this.onShare,
    this.cardColor,
    this.scrollController,
    this.opacity = 1,
    this.updateHistory = true,
    this.spaceBeforeFirstResult = true,
    this.footerWidget,
    super.key,
  });

  /// The result made from a dictionary database search.
  final DictionarySearchResult result;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

  /// Action to be done upon selecting the share option.
  final Function(String) onShare;

  /// Whether or not to update dictionary history upon viewing this result.
  final bool updateHistory;

  /// Whether or not to put a space before the first result.
  final bool spaceBeforeFirstResult;

  /// Override color for the background color for [DictionaryTermPage].
  final Color? cardColor;

  /// Opacity for entries.
  final double opacity;

  /// Allows controlling the scroll position of the page.
  final ScrollController? scrollController;

  /// Optional footer for use for showing more.
  final Widget? footerWidget;

  @override
  BasePageState<DictionaryResultPage> createState() =>
      _DictionaryResultPageState();
}

class _DictionaryResultPageState extends BasePageState<DictionaryResultPage> {
  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  late ScrollController _scrollController;

  Map<DictionaryHeading, Map<Dictionary, ExpandableController>>
      expandableControllersByHeading = {};

  @override
  Widget build(BuildContext context) {
    AnkiMapping lastSelectedMapping = appModel.lastSelectedMapping;

    Map<int, DictionaryHeading> headingsById = Map.fromEntries(
      widget.result.headings.map(
        (heading) => MapEntry(heading.id, heading),
      ),
    );

    List<DictionaryHeading> headings =
        widget.result.headingIds.map((id) => headingsById[id]!).toList();

    List<Dictionary> dictionaries = appModel.dictionaries;
    Map<String, bool> dictionaryNamesByHidden = Map<String, bool>.fromEntries(
        dictionaries
            .map((e) => MapEntry(e.name, e.isHidden(appModel.targetLanguage))));
    Map<String, bool> dictionaryNamesByCollapsed =
        Map<String, bool>.fromEntries(dictionaries.map(
            (e) => MapEntry(e.name, e.isCollapsed(appModel.targetLanguage))));
    Map<String, int> dictionaryNamesByOrder = Map<String, int>.fromEntries(
        dictionaries.map((e) => MapEntry(e.name, e.order)));

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

    return MediaQuery(
      data: MediaQuery.of(context).removePadding(
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
      ),
      child: RawScrollbar(
        thumbVisibility: true,
        thickness: 3,
        controller: _scrollController,
        child: Padding(
          padding: Spacing.of(context).insets.onlyRight.extraSmall,
          child: CustomScrollView(
            cacheExtent: 999999999999999,
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                  padding: widget.spaceBeforeFirstResult
                      ? Spacing.of(context).insets.onlyTop.normal
                      : EdgeInsets.zero),
              ...headings
                  .map((heading) => DictionaryTermPage(
                        lastSelectedMapping: lastSelectedMapping,
                        opacity: widget.opacity,
                        cardColor: widget.cardColor,
                        heading: heading,
                        onSearch: widget.onSearch,
                        onStash: widget.onStash,
                        onShare: widget.onShare,
                        expandableControllers:
                            expandableControllersByHeading[heading]!,
                        dictionaryNamesByHidden: dictionaryNamesByHidden,
                        dictionaryNamesByOrder: dictionaryNamesByOrder,
                      ))
                  .toList(),
              if (widget.footerWidget != null) widget.footerWidget!,
            ],
          ),
        ),
      ),
    );
  }
}

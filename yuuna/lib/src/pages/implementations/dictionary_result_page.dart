import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';

/// Returns the widget for a [DictionarySearchResult] which returns a scrollable list
/// of each [DictionaryEntry] in its mappings.
class DictionaryResultPage extends BasePage {
  /// Create the widget of a [DictionarySearchResult].
  const DictionaryResultPage({
    required this.result,
    required this.onSearch,
    required this.onStash,
    this.scrollController,
    this.opacity = 1,
    this.updateHistory = true,
    this.spaceBeforeFirstResult = true,
    super.key,
  });

  /// The result made from a dictionary database search.
  final DictionarySearchResult result;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

  /// Whether or not to update dictionary history upon viewing this result.
  final bool updateHistory;

  /// Whether or not to put a space before the first result.
  final bool spaceBeforeFirstResult;

  /// Opacity for entries.
  final double opacity;

  /// Allows controlling the scroll position of the page.
  final ScrollController? scrollController;

  @override
  BasePageState<DictionaryResultPage> createState() =>
      _DictionaryResultPageState();
}

class _DictionaryResultPageState extends BasePageState<DictionaryResultPage> {
  @override
  void initState() {
    super.initState();
    appModelNoUpdate.dictionaryMenuNotifier.addListener(dumpCache);

    _scrollController = widget.scrollController ?? ScrollController();
  }

  void dumpCache() {
    if (mounted) {
      for (DictionaryHeading heading in widget.result.headings) {
        for (DictionaryEntry entry in heading.entries) {
          entry.dictionary.loadSync();
        }
        for (DictionaryFrequency frequency in heading.frequencies) {
          frequency.dictionary.loadSync();
        }
        for (DictionaryPitch pitch in heading.pitches) {
          pitch.dictionary.loadSync();
        }
      }
    }

    setState(() {});
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

    for (DictionaryHeading heading in headings) {
      expandableControllersByHeading.putIfAbsent(heading, () => {});
      for (DictionaryEntry entry in heading.entries) {
        Dictionary dictionary = entry.dictionary.value!;
        expandableControllersByHeading[heading]?.putIfAbsent(
          dictionary,
          () => ExpandableController(
            initialExpanded: !dictionary.isCollapsed(appModel.targetLanguage),
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
                        heading: heading,
                        onSearch: widget.onSearch,
                        onStash: widget.onStash,
                        expandableControllers:
                            expandableControllersByHeading[heading]!,
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

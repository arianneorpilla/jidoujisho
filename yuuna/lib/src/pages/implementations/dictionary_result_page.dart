import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:keframe/keframe.dart';
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
    this.entryOpacity = 1,
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
  final double entryOpacity;

  @override
  BasePageState<DictionaryResultPage> createState() =>
      _DictionaryResultPageState();
}

class _DictionaryResultPageState extends BasePageState<DictionaryResultPage> {
  @override
  void initState() {
    super.initState();
    appModelNoUpdate.dictionaryMenuNotifier.addListener(dumpCache);
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

  final ScrollController _scrollController = ScrollController();

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
          child: SizeCacheWidget(
            child: CustomScrollView(
              cacheExtent: 99999999999999,
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: headings.length + 1,
                    (context, index) {
                      if (index == 0) {
                        return widget.spaceBeforeFirstResult
                            ? const Space.normal()
                            : const SizedBox.shrink();
                      }

                      DictionaryHeading heading = headings.elementAt(index - 1);
                      Map<Dictionary, ExpandableController>
                          expandableControllers =
                          expandableControllersByHeading[heading]!;

                      return DictionaryTermPage(
                        lastSelectedMapping: lastSelectedMapping,
                        entryOpacity: widget.entryOpacity,
                        heading: heading,
                        onSearch: widget.onSearch,
                        onStash: widget.onStash,
                        expandableControllers: expandableControllers,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

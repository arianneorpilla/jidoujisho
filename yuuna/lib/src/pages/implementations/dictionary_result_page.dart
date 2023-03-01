import 'package:collection/collection.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:keframe/keframe.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';

/// Returns the widget for a [DictionaryResult] which returns a scrollable list
/// of each [DictionaryEntry] in its mappings.
class DictionaryResultPage extends BasePage {
  /// Create the widget of a [DictionaryResult].
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

    List<DictionaryHeading> headings = widget.result.headingIds
        .map((id) => headingsById[id]!)
        .toList()
        .where((heading) => heading.entries.isNotEmpty)
        .toList();
    Map<DictionaryHeading, int> headingOrders = Map.fromEntries(
      headings.mapIndexed(
        (index, id) => MapEntry(headings[index], index),
      ),
    );

    headings.sort((a, b) {
      if (a.term == b.term) {
        int hasPopularTag = (a.tags.any((e) => e.name == 'P') ? -1 : 1)
            .compareTo(b.tags.any((e) => e.name == 'P') ? -1 : 1);
        if (hasPopularTag != 0) {
          return hasPopularTag;
        }

        int popularityCompare = (b.popularitySum).compareTo(a.popularitySum);
        if (popularityCompare != 0) {
          return popularityCompare;
        }
      } else if ((a.reading.isNotEmpty && b.reading.isNotEmpty) &&
          a.reading == b.reading) {
        int hasPopularTag = (a.tags.any((e) => e.name == 'P') ? -1 : 1)
            .compareTo(b.tags.any((e) => e.name == 'P') ? -1 : 1);
        if (hasPopularTag != 0) {
          return hasPopularTag;
        }

        int popularityCompare = (b.popularitySum).compareTo(a.popularitySum);
        if (popularityCompare != 0) {
          return popularityCompare;
        }
      }

      return headingOrders[a]!.compareTo(headingOrders[b]!);
    });

    //  headings.sort((a, b) {
    //   if (a.term == b.term ||
    //       (a.reading.isNotEmpty && b.reading.isNotEmpty) &&
    //           a.reading == b.reading) {
    //     int hasPopularTag = (a.tags.any((e) => e.name == 'P') ? -1 : 1)
    //         .compareTo(b.tags.any((e) => e.name == 'P') ? -1 : 1);
    //     if (hasPopularTag != 0) {
    //       return hasPopularTag;
    //     }

    //     List<DictionaryFrequency> aFrequencies = a.frequencies.toList();
    //     List<DictionaryFrequency> bFrequencies = b.frequencies.toList();
    //     aFrequencies.sort((a, b) =>
    //         a.dictionary.value!.order.compareTo(b.dictionary.value!.order));
    //     bFrequencies.sort((a, b) =>
    //         a.dictionary.value!.order.compareTo(b.dictionary.value!.order));

    //     Map<Dictionary, List<DictionaryFrequency>> aFrequenciesByDictionary =
    //         groupBy<DictionaryFrequency, Dictionary>(
    //             aFrequencies, (frequency) => frequency.dictionary.value!);
    //     Map<Dictionary, List<DictionaryFrequency>> bFrequenciesByDictionary =
    //         groupBy<DictionaryFrequency, Dictionary>(
    //             bFrequencies, (frequency) => frequency.dictionary.value!);
    //     Map<Dictionary, double> aValues = aFrequenciesByDictionary
    //         .map((k, v) => MapEntry(k, v.map((e) => e.value).max));
    //     Map<Dictionary, double> bValues = bFrequenciesByDictionary
    //         .map((k, v) => MapEntry(k, v.map((e) => e.value).max));

    //     Set<Dictionary> sharedDictionaries =
    //         aValues.keys.toSet().intersection(bValues.keys.toSet());

    //     if (sharedDictionaries.isNotEmpty) {
    //       for (Dictionary dictionary in sharedDictionaries) {
    //         int freqCompare =
    //             bValues[dictionary]!.compareTo(aValues[dictionary]!);
    //         if (freqCompare != 0) {
    //           return freqCompare;
    //         }
    //       }
    //     } else {
    //       int popularityCompare = (b.popularitySum).compareTo(a.popularitySum);
    //       if (popularityCompare != 0) {
    //         return popularityCompare;
    //       }
    //     }
    //   }

    //   return headingOrders[a]!.compareTo(headingOrders[b]!);
    // });

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
                    childCount: headings.length,
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

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
  final DictionaryResult result;

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
      setState(() {});
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    AnkiMapping lastSelectedMapping = appModel.lastSelectedMapping;

    Map<String, Dictionary> dictionaryMap = Map<String, Dictionary>.fromEntries(
      appModel.dictionaries.map(
        (dictionary) => MapEntry(dictionary.dictionaryName, dictionary),
      ),
    );

    for (DictionaryTerm term in widget.result.terms!) {
      List<MapEntry<DictionaryEntry, List<DictionaryTag>>> entryTagGroups = term
          .entries
          .mapIndexed(
              (index, entry) => MapEntry(entry, term.meaningTagsGroups[index]))
          .toList();

      term.metaEntries.sort(
        (a, b) => dictionaryMap[a.dictionaryName]!.order.compareTo(
              dictionaryMap[b.dictionaryName]!.order,
            ),
      );
      entryTagGroups.sort(
        (a, b) => dictionaryMap[a.key.dictionaryName]!.order.compareTo(
              dictionaryMap[b.key.dictionaryName]!.order,
            ),
      );

      Map<DictionaryEntry, List<DictionaryTag>> entryTagMap =
          Map.fromEntries(entryTagGroups);

      term.entries = entryTagMap.keys.toList();
      term.meaningTagsGroups = entryTagMap.values.toList();
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
                    childCount: widget.result.terms!.length + 1,
                    (context, index) {
                      if (index == 0) {
                        return widget.spaceBeforeFirstResult
                            ? const Space.normal()
                            : const SizedBox.shrink();
                      }

                      DictionaryTerm dictionaryTerm =
                          widget.result.terms![index - 1];

                      final Map<String, ExpandableController> controllers = {};
                      final Map<String, bool> hiddens = {};

                      for (String dictionaryName
                          in dictionaryMap.keys.toList()) {
                        controllers[dictionaryName] = ExpandableController(
                          initialExpanded:
                              !dictionaryMap[dictionaryName]!.collapsed,
                        );
                        hiddens[dictionaryName] =
                            dictionaryMap[dictionaryName]!.hidden;
                      }

                      return DictionaryTermPage(
                        lastSelectedMapping: lastSelectedMapping,
                        entryOpacity: widget.entryOpacity,
                        dictionaryMap: dictionaryMap,
                        dictionaryTerm: dictionaryTerm,
                        onSearch: widget.onSearch,
                        onStash: widget.onStash,
                        expandableControllers: controllers,
                        dictionaryHiddens: hiddens,
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

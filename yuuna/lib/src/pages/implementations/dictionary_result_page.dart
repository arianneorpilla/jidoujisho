import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
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
    required this.getCurrentSearchTerm,
    this.updateHistory = true,
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

  /// Used to check if the current search term is still the same. Used to
  /// add to search history without adding too many duplicate partial search
  /// terms.
  final String? Function() getCurrentSearchTerm;

  @override
  BasePageState<DictionaryResultPage> createState() =>
      _DictionaryResultPageState();
}

class _DictionaryResultPageState extends BasePageState<DictionaryResultPage> {
  String get searchLabel => appModel.translate('search');
  String get stashLabel => appModel.translate('stash');

  Map<String, Dictionary>? dictionaryMap;
  Map<int, List<DictionaryMetaEntry>> metaEntriesCache = {};
  Map<int, Map<String, ExpandableController>> expandedControllers = {};
  Map<int, Map<String, bool>> dictionaryHiddens = {};

  @override
  void initState() {
    super.initState();
    appModelNoUpdate.dictionaryMenuNotifier.addListener(dumpCache);
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

    for (DictionaryTerm term in widget.result.terms) {
      term.entries.sort(
        (a, b) => dictionaryMap![a.dictionaryName]!.order.compareTo(
              dictionaryMap![b.dictionaryName]!.order,
            ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: widget.result.terms.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Space.normal();
        }

        DictionaryTerm dictionaryTerm = widget.result.terms[index - 1];

        if (metaEntriesCache[index - 1] == null) {
          final Map<String, ExpandableController> controllers = {};
          final Map<String, bool> hiddens = {};

          for (String dictionaryName in dictionaryMap!.keys.toList()) {
            controllers[dictionaryName] = ExpandableController(
              initialExpanded: !dictionaryMap![dictionaryName]!.collapsed,
            );
            hiddens[dictionaryName] = dictionaryMap![dictionaryName]!.hidden;
          }

          List<DictionaryMetaEntry> metaEntries =
              appModel.getMetaEntriesFromTerm(dictionaryTerm.term);
          metaEntries.sort(
            (a, b) => dictionaryMap![a.dictionaryName]!.order.compareTo(
                  dictionaryMap![b.dictionaryName]!.order,
                ),
          );

          metaEntriesCache[index - 1] ??= metaEntries;

          expandedControllers[index - 1] ??= controllers;
          dictionaryHiddens[index - 1] ??= hiddens;
        }

        return DictionaryTermPage(
          dictionaryMap: dictionaryMap!,
          dictionaryTerm: dictionaryTerm,
          dictionaryMetaEntries: metaEntriesCache[index - 1]!,
          onSearch: widget.onSearch,
          onStash: widget.onStash,
          expandableControllers: expandedControllers[index - 1]!,
          dictionaryHiddens: dictionaryHiddens[index - 1]!,
        );
      },
    );
  }
}

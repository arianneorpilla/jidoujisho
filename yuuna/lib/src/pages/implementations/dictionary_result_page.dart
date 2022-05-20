import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// Returns the widget for a [DictionaryResult] which returns a scrollable list
/// of each [DictionaryEntry] in its mappings.
class DictionaryResultPage extends BasePage {
  /// Create the widget of a [DictionaryResult].
  const DictionaryResultPage({
    required this.result,
    required this.onSearch,
    required this.onStash,
    required this.getCurrentSearchTerm,
    super.key,
  });

  /// The result made from a dictionary database search.
  final DictionaryResult result;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

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
  Widget build(BuildContext context) {
    dictionaryOrderCache = Map<String, int>.fromEntries(
      appModel.dictionaries.map(
        (dictionary) => MapEntry(dictionary.dictionaryName, dictionary.order),
      ),
    );

    for (List<DictionaryEntry> entriesGroup in widget.result.mapping) {
      entriesGroup.sort((a, b) => (dictionaryOrderCache![a.dictionaryName]!)
          .compareTo(dictionaryOrderCache![b.dictionaryName]!));
    }

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        if (widget.getCurrentSearchTerm() == widget.result.searchTerm) {
          appModel.addToSearchHistory(
            uniqueKey: DictionaryMediaType.instance.uniqueKey,
            searchTerm: widget.result.searchTerm,
          );
        }
      }
    });

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.result.mapping.length,
      itemBuilder: (context, index) {
        List<DictionaryEntry> entries = widget.result.mapping[index];
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

        return DictionaryWordPage(
          entries: entries,
          onSearch: widget.onSearch,
          onStash: widget.onStash,
          expandableControllers: expandableControllers,
          dictionaryHiddens: dictionaryHiddens,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// Returns the widget for a [DictionaryResult] which returns a scrollable list
/// of each [DictionaryEntry] in its mappings.
class DictionaryResultPage extends BasePage {
  /// Create the widget of a [DictionaryResult].
  const DictionaryResultPage({
    required this.result,
    required this.onTextSelect,
    super.key,
  });

  /// The result made from a dictionary database search.
  final DictionaryResult result;

  /// Action to be done upon text select made when hovering over the text
  /// elements contained in this widget.
  final Function(String) onTextSelect;

  @override
  BasePageState<DictionaryResultPage> createState() =>
      _DictionaryResultPageState();
}

class _DictionaryResultPageState extends BasePageState<DictionaryResultPage> {
  String get searchLabel => appModel.translate('search');

  MaterialTextSelectionControls get selectionControls =>
      JidoujishoTextSelectionControls(
        customAction: widget.onTextSelect,
        customActionLabel: searchLabel,
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.result.mapping.length,
        itemBuilder: (context, index) {
          List<DictionaryEntry> entries = widget.result.mapping[index];

          return DictionaryWordPage(
            entries: entries,
            onTextSelect: widget.onTextSelect,
          );
        },
      ),
    );
  }
}

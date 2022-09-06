import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';
import 'package:collection/collection.dart';

/// Returns the widget for a [DictionaryEntry] making up a collection of
/// meanings.
class DictionaryEntryPage extends BasePage {
  /// Create the widget for a dictionary entry.
  const DictionaryEntryPage({
    required this.entry,
    required this.onSearch,
    required this.onStash,
    required this.expandableController,
    super.key,
  });

  /// The entry particular to this widget.
  final DictionaryEntry entry;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

  /// Controller specific to a dictionary name.
  final ExpandableController expandableController;

  @override
  BasePageState<DictionaryEntryPage> createState() =>
      _DictionaryEntryPageState();
}

class _DictionaryEntryPageState extends BasePageState<DictionaryEntryPage> {
  String get dictionaryImportTag =>
      appModelNoUpdate.translate('dictionary_import_tag');

  @override
  Widget build(BuildContext context) {
    List<Widget> tags = appModel.getTagsForEntry(widget.entry);

    List<Widget> children = widget.entry.meanings.mapIndexed((index, meaning) {
      if (widget.entry.meanings.length != 1) {
        String sourceText = '• ${widget.entry.meanings[index].trim()}';
        return SelectableText(
          sourceText,
          selectionControls: selectionControls,
        );
      } else {
        String sourceText = widget.entry.meanings.first.trim();
        return SelectableText(
          sourceText,
          selectionControls: selectionControls,
        );
      }
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        top: Spacing.of(context).spaces.extraSmall,
        bottom: Spacing.of(context).spaces.normal,
      ),
      child: ExpandablePanel(
        theme: ExpandableThemeData(
          iconPadding: EdgeInsets.zero,
          iconSize: Theme.of(context).textTheme.titleLarge?.fontSize,
          expandIcon: Icons.arrow_drop_down,
          collapseIcon: Icons.arrow_drop_up,
          iconColor: Theme.of(context).unselectedWidgetColor,
          headerAlignment: ExpandablePanelHeaderAlignment.center,
        ),
        controller: widget.expandableController,
        header: Wrap(children: tags),
        collapsed: const SizedBox.shrink(),
        expanded: Padding(
          padding: EdgeInsets.only(
            top: Spacing.of(context).spaces.small,
            left: Spacing.of(context).spaces.normal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

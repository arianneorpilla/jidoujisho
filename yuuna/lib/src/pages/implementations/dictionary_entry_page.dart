import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

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
  JidoujishoTextSelectionControls get selectionControls =>
      JidoujishoTextSelectionControls(
        searchAction: widget.onSearch,
        searchActionLabel: searchLabel,
        stashAction: widget.onStash,
        stashActionLabel: stashLabel,
        allowCopy: true,
        allowSelectAll: true,
        allowCut: true,
        allowPaste: true,
      );

  @override
  Widget build(BuildContext context) {
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
        header: Wrap(children: getTagsForEntry()),
        collapsed: const SizedBox.shrink(),
        expanded: Padding(
          padding: EdgeInsets.only(
            top: Spacing.of(context).spaces.small,
            left: Spacing.of(context).spaces.normal,
          ),
          child: SelectableText(
            widget.entry.compactDefinitions,
            style: TextStyle(
              fontSize: appModel.dictionaryFontSize,
            ),
            // contextMenuBuilder: (context, state) {
            //   String searchTerm = _selectableTextController.selection
            //       .textInside(widget.entry.compactDefinitions);

            //   return JidoujishoTextSelectionToolbar(
            //     anchorAbove: state.contextMenuAnchors.primaryAnchor,
            //     anchorBelow: state.contextMenuAnchors.secondaryAnchor == null
            //         ? state.contextMenuAnchors.primaryAnchor
            //         : state.contextMenuAnchors.secondaryAnchor!,
            //     children: [
            //       ContextMenuPage(searchTerm: searchTerm),
            //     ],
            //   );
            // },
            selectionControls: selectionControls,
          ),
        ),
      ),
    );
  }

  /// Fetches the tag widgets for a [DictionaryEntry].
  List<Widget> getTagsForEntry() {
    String dictionaryImportTag = appModel.translate('dictionary_import_tag');

    List<Widget> tagWidgets = [];

    Dictionary dictionary = widget.entry.dictionary.value!;

    tagWidgets.add(
      JidoujishoTag(
        text: dictionary.name,
        message: dictionaryImportTag.replaceAll(
          '%dictionaryName%',
          dictionary.name,
        ),
        backgroundColor: Colors.red.shade900,
      ),
    );

    tagWidgets.addAll(widget.entry.tags.map((tag) {
      return JidoujishoTag(
        text: tag.name,
        message: tag.notes,
        backgroundColor: tag.color,
      );
    }).toList());

    return tagWidgets;
  }
}

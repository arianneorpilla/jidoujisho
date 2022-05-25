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
  String get searchLabel => appModelNoUpdate.translate('search');
  String get stashLabel => appModelNoUpdate.translate('stash');
  String get dictionaryImportTag =>
      appModelNoUpdate.translate('dictionary_import_tag');

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tags = [];

    tags.add(
      JidoujishoTag(
        text: widget.entry.dictionaryName,
        message: dictionaryImportTag.replaceAll(
          '%dictionaryName%',
          widget.entry.dictionaryName,
        ),
        backgroundColor: Colors.red.shade900,
      ),
    );
    tags.addAll(widget.entry.meaningTags.map((tagName) {
      if (tagName.isNotEmpty) {
        DictionaryTag tag = appModel.getDictionaryTag(
          dictionaryName: widget.entry.dictionaryName,
          tagName: tagName,
        );

        return JidoujishoTag(
          text: tag.name,
          message: tag.notes,
          backgroundColor: tag.color,
        );
      } else {
        return const SizedBox.shrink();
      }
    }).toList());

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
        expanded: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: Spacing.of(context).spaces.small,
                left: Spacing.of(context).spaces.normal,
              ),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.entry.meanings.length,
                itemBuilder: (context, index) {
                  if (widget.entry.meanings.length != 1) {
                    return SelectableText(
                      '• ${widget.entry.meanings[index].trim()}',
                      selectionControls: selectionControls,
                    );
                  } else {
                    return SelectableText(
                      widget.entry.meanings.first.trim(),
                      selectionControls: selectionControls,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

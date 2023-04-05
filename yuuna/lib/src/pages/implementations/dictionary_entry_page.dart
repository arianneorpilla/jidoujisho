import 'dart:math';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/utils.dart';

/// Returns the widget for a [DictionaryEntry] making up a collection of
/// meanings.
class DictionaryEntryPage extends ConsumerStatefulWidget {
  /// Create the widget for a dictionary entry.
  const DictionaryEntryPage({
    required this.entry,
    required this.onSearch,
    required this.onStash,
    required this.expandableController,
    super.key,
  });

  /// The entry particular to this
  final DictionaryEntry entry;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

  /// Controller specific to a dictionary name.
  final ExpandableController expandableController;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DictionaryEntryPageState();
}

class _DictionaryEntryPageState extends ConsumerState<DictionaryEntryPage> {
  @override
  Widget build(BuildContext context) {
    AppModel appModel = ref.watch(appProvider);

    final JidoujishoSelectableTextController _selectableTextController =
        JidoujishoSelectableTextController();

    bool _isSearching = false;

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
          collapseIcon: Icons.arrow_drop_down,
          iconColor: Theme.of(context).unselectedWidgetColor,
          headerAlignment: ExpandablePanelHeaderAlignment.center,
        ),
        controller: widget.expandableController,
        header: _DictionaryEntryTagsWrap(entry: widget.entry),
        collapsed: const SizedBox.shrink(),
        expanded: Padding(
          padding: EdgeInsets.only(
            top: Spacing.of(context).spaces.small,
            left: Spacing.of(context).spaces.normal,
          ),
          child: JidoujishoSelectableText(
            widget.entry.compactDefinitions,
            style: TextStyle(
                fontSize: appModel.dictionaryFontSize,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black),
            controller: _selectableTextController,
            selectionControls: JidoujishoTextSelectionControls(
              searchAction: widget.onSearch,
              searchActionLabel: t.search,
              stashAction: widget.onStash,
              stashActionLabel: t.stash,
              allowCopy: true,
              allowSelectAll: true,
              allowCut: true,
              allowPaste: true,
            ),
            onSelectionChanged: (selection, cause) async {
              if (appModel.targetLanguage.isSpaceDelimited) {
                return;
              }

              if (!selection.isCollapsed &&
                  cause == SelectionChangedCause.tap &&
                  !_isSearching) {
                _isSearching = true;
                try {
                  String searchTerm = widget.entry.compactDefinitions
                      .substring(selection.baseOffset);

                  int whitespaceOffset =
                      searchTerm.length - searchTerm.trimLeft().length;
                  int offsetIndex = appModel.targetLanguage.getStartingIndex(
                        text: widget.entry.compactDefinitions,
                        index: selection.baseOffset,
                      ) +
                      whitespaceOffset;
                  int length = appModel.targetLanguage
                      .textToWords(searchTerm)
                      .firstWhere((e) => e.trim().isNotEmpty)
                      .length;

                  _selectableTextController.setSelection(
                    offsetIndex,
                    offsetIndex + length,
                  );

                  DictionarySearchResult result =
                      await appModel.searchDictionary(
                    searchTerm: searchTerm,
                    searchWithWildcards: false,
                  );

                  length = appModel.targetLanguage.isSpaceDelimited
                      ? appModel.targetLanguage
                          .textToWords(searchTerm)
                          .firstWhere((e) => e.trim().isNotEmpty)
                          .length
                      : max(1, result.bestLength);

                  _selectableTextController.setSelection(
                      offsetIndex, offsetIndex + length);
                } finally {
                  _isSearching = false;
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

class _DictionaryEntryTagsWrap extends ConsumerWidget {
  const _DictionaryEntryTagsWrap({
    required this.entry,
  });

  final DictionaryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Dictionary dictionary = entry.dictionary.value!;
    List<Widget> children = [
      JidoujishoTag(
        text: dictionary.name,
        backgroundColor: Colors.red.shade900,
      ),
      ...entry.tags.map((tag) {
        return JidoujishoTag(
          text: tag.name,
          message: tag.notes,
          backgroundColor: tag.color,
        );
      })
    ];

    Widget last = children.removeLast();

    children.add(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          last,
          SizedBox(
            height: 22,
            width: 22,
            child: PopupMenuButton<VoidCallback>(
              surfaceTintColor: Colors.red,
              iconSize: 16,
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).unselectedWidgetColor,
              ),
              color: Theme.of(context).popupMenuTheme.color,
              tooltip: t.show_more,
              onSelected: (value) => value(),
              itemBuilder: (context) => getMenuItems(
                context: context,
                dictionary: dictionary,
                ref: ref,
                heading: entry.heading.value!,
              ),
            ),
          )
        ],
      ),
    );

    return Wrap(
      children: children,
    );
  }

  List<PopupMenuEntry<VoidCallback>> getMenuItems({
    required BuildContext context,
    required Dictionary dictionary,
    required WidgetRef ref,
    required DictionaryHeading heading,
  }) {
    AppModel appModel = ref.watch(appProvider);
    CreatorModel creatorModel = ref.watch(creatorProvider);

    List<QuickAction> filteredActions = appModel.lastSelectedMapping
        .getActions(appModel: appModel)
        .where((e) => e.showInSingleDictionary)
        .toList();

    return [
      ...filteredActions.map((quickAction) {
        return PopupMenuItem<VoidCallback>(
          value: () async {
            await quickAction.executeAction(
              context: context,
              ref: ref,
              appModel: appModel,
              creatorModel: creatorModel,
              heading: heading,
              dictionaryName: dictionary.name,
            );

            ref.refresh(quickActionColorProvider(heading));
          },
          child: Row(
            children: [
              Icon(
                quickAction.icon,
                size: Theme.of(context).textTheme.bodyMedium?.fontSize,
              ),
              const Space.normal(),
              Text(
                quickAction.getLocalisedLabel(appModel),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }).toList(),
    ];
  }
}

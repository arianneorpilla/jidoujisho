import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// Returns the widget for a list of [DictionaryEntry] making up a word.
class DictionaryWordPage extends BasePage {
  /// Create the widget for a dictionary word.
  const DictionaryWordPage({
    required this.entries,
    required this.onSearch,
    required this.onStash,
    required this.expandableControllers,
    required this.dictionaryHiddens,
    this.onScrollLeft,
    this.onScrollRight,
    this.footerWidget,
    super.key,
  });

  /// The result made from a dictionary database search.
  final List<DictionaryEntry> entries;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

  /// Controls expandables by dictionary name.
  final Map<String, ExpandableController> expandableControllers;

  /// Used to hide entries by dictionary name.
  final Map<String, bool> dictionaryHiddens;

  /// Called when the widget is scrolled to the left.
  final Function()? onScrollLeft;

  /// Called when the widget is scrolled to the right.
  final Function()? onScrollRight;

  /// Optional footer foor use in [DictionaryHistoryPage].
  final Widget? footerWidget;

  @override
  BasePageState<DictionaryWordPage> createState() => _DictionaryWordPageState();
}

class _DictionaryWordPageState extends BasePageState<DictionaryWordPage> {
  String get searchLabel => appModel.translate('search');
  String get stashLabel => appModel.translate('stash');
  String get dictionaryNameNotes => appModel.translate('dictionary_name_notes');

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

  String get word => widget.entries.first.word;
  String get reading => widget.entries.first.reading;

  List<Widget>? tags;

  @override
  Widget build(BuildContext context) {
    if (tags == null) {
      tags = [];

      Set<DictionaryPair> pairs = {};

      for (DictionaryEntry entry in widget.entries) {
        for (String tag in entry.wordTags) {
          pairs.add(
            DictionaryPair(
              word: entry.dictionaryName,
              reading: tag,
            ),
          );
        }
      }

      tags!.addAll(pairs.map((pair) {
        if (pair.reading.isNotEmpty) {
          DictionaryTag tag = appModel.getDictionaryTag(
            dictionaryName: pair.word,
            tagName: pair.reading,
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
    }

    List<Widget> children = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  word,
                  style: textTheme.titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                  selectionControls: selectionControls,
                ),
                SelectableText(
                  reading,
                  style: textTheme.titleMedium,
                  selectionControls: selectionControls,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Spacing.of(context).spaces.small,
              right: Spacing.of(context).spaces.small,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: buildQuickActions(),
            ),
          ),
        ],
      ),
      const Space.normal(),
      Wrap(children: tags!),
      const Space.normal(),
      Padding(
        padding: Spacing.of(context).insets.horizontal.small,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.entries.length,
          itemBuilder: (context, index) {
            DictionaryEntry entry = widget.entries[index];

            if (widget.dictionaryHiddens[entry.dictionaryName]!) {
              return const SizedBox.shrink();
            }

            return DictionaryEntryPage(
              expandableController:
                  widget.expandableControllers[entry.dictionaryName]!,
              entry: entry,
              onSearch: widget.onSearch,
              onStash: widget.onStash,
            );
          },
        ),
      ),
      if (widget.footerWidget != null) widget.footerWidget!
    ];

    return GestureDetector(
      child: Card(
        color: appModel.isDarkMode
            ? const Color(0xff313131)
            : const Color(0xfff6f6f6),
        elevation: 0,
        shape: const RoundedRectangleBorder(),
        child: Padding(
          padding: EdgeInsets.only(
            left: Spacing.of(context).spaces.semiBig,
            top: Spacing.of(context).spaces.normal,
            right: Spacing.of(context).spaces.normal,
            bottom: Spacing.of(context).spaces.normal,
          ),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => children[index],
            itemCount: children.length,
          ),
        ),
      ),
      onHorizontalDragEnd: (details) async {
        if (details.primaryVelocity == 0) {
          return;
        }

        if (details.primaryVelocity!.compareTo(0) == -1) {
          widget.onScrollRight?.call();
        } else {
          widget.onScrollLeft?.call();
        }
      },
    );
  }

  List<Widget> buildQuickActions() {
    AnkiMapping mapping = appModel.lastSelectedMapping;
    List<Widget> buttons = [];

    for (int i = 0; i < appModel.maximumFieldEnhancements; i++) {
      Widget button = buildQuickAction(
        mapping: mapping,
        slotNumber: i,
      );

      buttons.add(button);
    }

    return buttons.reversed.toList();
  }

  Widget buildQuickAction({
    required AnkiMapping mapping,
    required int slotNumber,
  }) {
    String? actionName = mapping.actions[slotNumber];
    QuickAction? quickAction;

    if (actionName != null) {
      quickAction = appModel.quickActions[actionName];
    }

    if (quickAction == null) {
      return const SizedBox.shrink();
    } else {
      return Padding(
        padding: Spacing.of(context).insets.onlyLeft.semiSmall,
        child: JidoujishoIconButton(
          busy: true,
          enabledColor: quickAction.getIconColor(
            context: context,
            appModel: appModel,
            word: word,
            reading: reading,
            entries: widget.entries,
          ),
          shapeBorder: const RoundedRectangleBorder(),
          backgroundColor:
              Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
          size: Spacing.of(context).spaces.semiBig,
          tooltip: quickAction.getLocalisedLabel(appModel),
          icon: quickAction.icon,
          onTap: () async {
            await quickAction?.executeAction(
              context: context,
              ref: ref,
              appModel: appModel,
              creatorModel: creatorModel,
              word: word,
              reading: reading,
              entries: widget.entries,
            );
            setState(() {});
          },
        ),
      );
    }
  }
}

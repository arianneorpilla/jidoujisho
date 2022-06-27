import 'package:expandable/expandable.dart';
import 'package:float_column/float_column.dart';
import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:collection/collection.dart';

/// Returns the widget for a list of [DictionaryEntry] making up a term.
class DictionaryTermPage extends BasePage {
  /// Create the widget for a dictionary word.
  const DictionaryTermPage({
    required this.dictionaryMap,
    required this.dictionaryTerm,
    required this.dictionaryMetaEntries,
    required this.onSearch,
    required this.onStash,
    required this.expandableControllers,
    required this.dictionaryHiddens,
    this.onScrollLeft,
    this.onScrollRight,
    this.footerWidget,
    super.key,
  });

  /// Used for optimisations.
  final Map<String, Dictionary> dictionaryMap;

  /// The result made from a dictionary database search.
  final DictionaryTerm dictionaryTerm;

  /// Meta entries for this term.
  final List<DictionaryMetaEntry> dictionaryMetaEntries;

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
  BasePageState<DictionaryTermPage> createState() => _DictionaryTermPageState();
}

class _DictionaryTermPageState extends BasePageState<DictionaryTermPage> {
  String get dictionaryImportTag => appModel.translate('dictionary_import_tag');

  @override
  Widget build(BuildContext context) {
    if (widget.onScrollLeft == null && widget.onScrollRight == null) {
      return buildCard();
    }

    return GestureDetector(
      child: buildCard(),
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

  Widget buildCard() {
    List<Widget> tags = appModel.getTagsForTerm(widget.dictionaryTerm);
    return Card(
      color: appModel.isDarkMode
          ? const Color.fromARGB(255, 15, 15, 15)
          : const Color.fromARGB(255, 246, 246, 246),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: EdgeInsets.only(
          left: Spacing.of(context).spaces.semiBig,
          top: Spacing.of(context).spaces.normal,
          right: Spacing.of(context).spaces.normal,
          bottom: Spacing.of(context).spaces.normal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTopRow(metaEntries: widget.dictionaryMetaEntries),
            const Space.normal(),
            Wrap(children: tags),
            const Space.normal(),
            buildMetaWidgets(metaEntries: widget.dictionaryMetaEntries),
            const Space.normal(),
            buildEntries(),
            if (widget.footerWidget != null) widget.footerWidget!
          ],
        ),
      ),
    );
  }

  List<Widget> buildQuickActions({
    required List<DictionaryMetaEntry> metaEntries,
  }) {
    AnkiMapping mapping = appModel.lastSelectedMapping;
    List<Widget> buttons = [];

    for (int i = 0; i < appModel.maximumQuickActions; i++) {
      Widget button = buildQuickAction(
        mapping: mapping,
        slotNumber: i,
        metaEntries: metaEntries,
      );

      buttons.add(button);
    }

    return buttons.reversed.toList();
  }

  Widget buildQuickAction({
    required AnkiMapping mapping,
    required int slotNumber,
    required List<DictionaryMetaEntry> metaEntries,
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
            dictionaryTerm: widget.dictionaryTerm,
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
              dictionaryTerm: widget.dictionaryTerm,
              metaEntries: metaEntries,
            );
            setState(() {});
          },
        ),
      );
    }
  }

  Widget buildTopRow({
    required List<DictionaryMetaEntry> metaEntries,
  }) {
    return FloatColumn(
      children: [
        Floatable(
          float: FCFloat.end,
          padding: EdgeInsets.only(
            top: Spacing.of(context).spaces.small,
            right: Spacing.of(context).spaces.small,
            bottom: Spacing.of(context).spaces.small,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: buildQuickActions(metaEntries: metaEntries),
          ),
        ),
        Floatable(
          float: FCFloat.start,
          child: GestureDetector(
            child: appModel.targetLanguage.getTermReadingOverrideWidget(
              context: context,
              appModel: appModel,
              dictionaryTerm: widget.dictionaryTerm,
            ),
            onTap: () => appModel.copyToClipboard(widget.dictionaryTerm.term),
            onLongPress: () =>
                appModel.copyToClipboard(widget.dictionaryTerm.term),
          ),
        ),
      ],
    );
  }

  Widget buildMetaWidgets({
    required List<DictionaryMetaEntry> metaEntries,
  }) {
    if (metaEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> children = metaEntries.map((metaEntry) {
      if (widget.dictionaryMap[metaEntry.dictionaryName]!.hidden) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: Spacing.of(context).insets.horizontal.small,
        child: appModel.getTagsForMetaEntry(
          context: context,
          dictionaryTerm: widget.dictionaryTerm,
          metaEntry: metaEntry,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget buildEntries() {
    List<Widget> children =
        widget.dictionaryTerm.entries.mapIndexed((index, meaning) {
      DictionaryEntry entry = widget.dictionaryTerm.entries[index];

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
    }).toList();

    return Padding(
      padding: Spacing.of(context).insets.horizontal.small,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
